const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

const JWT_SECRET = process.env.JWT_SECRET || 'gram_setu_secret_key_123!';
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const client = new OAuth2Client(GOOGLE_CLIENT_ID);

// Internal Token Generation
const generateToken = (user) => {
  return jwt.sign(
    { userId: user._id, role: user.role, email: user.email },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
};

// Register via Custom Credentials (UID, Phone, MCI ID, Password)
exports.register = async (req, res) => {
  try {
    const { name, uid, phone, location, gender, age, emergencyContact, password, role, mciNumber, ashaId, panchayatId, village, block, hospitalName } = req.body;

    // Validation
    if (role === 'doctor') {
      if (!name || !mciNumber || !phone || !hospitalName || !password) {
        console.warn('❌ Doctor Registration Missing Fields:', { name, mciNumber, phone, hospitalName, password_len: password ? password.length : 0 });
        return res.status(400).json({ success: false, message: 'Doctors require Name, MCI Number, Phone, Hospital Name, and Password.' });
      }
    } else if (role === 'asha') {
      if (!name || !ashaId || !phone || !password) {
        return res.status(100).json({ success: false, message: 'ASHA Workers require Name, ASHA ID, Phone, and Password.' });
      }
    } else if (role === 'panchayat') {
      if (!panchayatId || !village || !block || !password) {
        return res.status(400).json({ success: false, message: 'Panchayat Members require Panchayat ID, Village, Block, and Password.' });
      }
    } else {
      if (!name || (!uid && !phone && !mciNumber && !ashaId && !panchayatId) || !password) {
        console.warn('❌ Registration Missing Fields:', { name, uid, phone, mciNumber, ashaId, panchayatId, password_len: password ? password.length : 0 });
        return res.status(400).json({ success: false, message: 'Please provide required fields (Name, ID, Password).' });
      }
    }
    
    if (password.length < 6 || password.length > 20) { // Increased limit slightly for flexibility
      return res.status(400).json({ success: false, message: 'Password must be between 6 and 20 characters.' });
    }

    // Check if user exists
    let userExists = await User.findOne({ 
      $or: [
        { uid: uid ? uid.toString().trim() : undefined }, 
        { phone: phone ? phone.toString().trim() : undefined },
        { mciNumber: mciNumber ? mciNumber.toString().trim() : undefined },
        { ashaId: ashaId ? ashaId.toString().trim() : undefined },
        { panchayatId: panchayatId ? panchayatId.toString().trim() : undefined }
      ].filter(cond => Object.values(cond)[0] !== undefined)
    });

    if (userExists) {
      return res.status(400).json({ success: false, message: 'User already exists with this ID or Phone.' });
    }

    // Hash Password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create User
    const user = await User.create({
      name,
      uid,
      mciNumber,
      ashaId,
      panchayatId,
      phone,
      hospitalName,
      location: location || `${village}, ${block}`,
      village,
      block,
      gender,
      age,
      emergencyContact,
      password: hashedPassword,
      role: role || 'patient'
    });

    console.log('✨ New User Registered Details:', {
      id: user._id,
      name: user.name,
      role: user.role,
      uid: user.uid,
      mciNumber: user.mciNumber,
      ashaId: user.ashaId,
      panchayatId: user.panchayatId,
      phone: user.phone,
      hospitalName: user.hospitalName
    });

    const token = generateToken(user);
    
    // Remove password from response for security
    const userResponse = user.toObject();
    userResponse.id = user._id.toString(); 
    delete userResponse.password;

    res.status(201).json({ success: true, token, user: userResponse });
  } catch (error) {
    console.error('❌ Registration Error Details:', error);
    res.status(500).json({ success: false, message: 'Server error during registration', error: error.message });
  }
};

// Login via Custom Credentials (Flexible Identifier: UID, Phone, or MCI ID + Password)
exports.login = async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ success: false, message: 'Please provide an Identifier and Password.' });
    }

    // Find User searching across all possible ID fields
    const user = await User.findOne({
      $or: [
        { uid: identifier.toString().trim() },
        { phone: identifier.toString().trim() },
        { mciNumber: identifier.toString().trim() },
        { ashaId: identifier.toString().trim() },
        { panchayatId: identifier.toString().trim() }
      ]
    });

    if (!user || !user.password) {
      console.warn(`❌ Login Failed (User Not Found): ${identifier}`);
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }

    // Check Password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials.' });
    }
    const token = generateToken(user);
    
    const userResponse = user.toObject();
    userResponse.id = user._id.toString(); // Explicitly add string ID
    delete userResponse.password;

    res.status(200).json({ success: true, token, user: userResponse });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ success: false, message: 'Server error during login', error: error.message });
  }
};

// Google Login (From current server.js implementation)
exports.googleLogin = async (req, res) => {
  try {
    const { idToken, role } = req.body;

    // Verify Google ID Token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture } = payload;
    
    // Check if User already exists in MongoDB
    let user = await User.findOne({ googleId });

    if (!user) {
      // Create new user if not found
      user = await User.create({
        googleId,
        email,
        name,
        picture,
        role: role || 'patient',
      });
      console.log('✨ New User Registered via Google:', email);
    } else {
      console.log('🔑 Returning User Logged In via Google:', email);
    }
    
    // Generate Internal JWT for Flutter
    const token = generateToken(user);
    
    res.status(200).json({ success: true, token, user });
  } catch (error) {
    console.error('Auth Error:', error.message);
    res.status(401).json({ success: false, message: 'Invalid or expired Google token' });
  }
};

// Update profile information
exports.updateProfile = async (req, res) => {
  try {
    const { uid, _id, mciNumber, ashaId, panchayatId, ...updateFields } = req.body;
    
    // Find identifier
    const identifierCondition = _id ? { _id } : uid ? { uid } : mciNumber ? { mciNumber } : ashaId ? { ashaId } : panchayatId ? { panchayatId } : null;
    
    if (!identifierCondition) {
      return res.status(400).json({ success: false, message: 'Valid ID is required for update.' });
    }

    // prevent password updates through this general profile update route without hashing
    delete updateFields.password;

    const user = await User.findOneAndUpdate(identifierCondition, updateFields, { new: true });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    const userResponse = user.toObject();
    delete userResponse.password;
    res.status(200).json({ success: true, user: userResponse, message: 'Profile updated successfully' });
  } catch (error) {
    console.error('Update Profile Error:', error);
    res.status(500).json({ success: false, message: 'Error updating profile', error: error.message });
  }
};

// permanently delete user profile
exports.deleteProfile = async (req, res) => {
  try {
    const { uid, _id, mciNumber, ashaId, panchayatId } = req.body;
    const identifierCondition = _id ? { _id } : uid ? { uid } : mciNumber ? { mciNumber } : ashaId ? { ashaId } : panchayatId ? { panchayatId } : null;

    if (!identifierCondition) {
      return res.status(400).json({ success: false, message: 'Valid ID is required for deletion.' });
    }
    const user = await User.findOneAndDelete(identifierCondition);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.status(200).json({ success: true, message: 'Account permanently deleted from Atlas' });
  } catch (error) {
    console.error('Delete Profile Error:', error);
    res.status(500).json({ success: false, message: 'Error deleting profile', error: error.message });
  }
};
