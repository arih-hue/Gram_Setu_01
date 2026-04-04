const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Consultation = require('../models/Consultation');
const Prescription = require('../models/Prescription');
const jwt = require('jsonwebtoken');

// @route   POST /api/users/register
// @desc    Register a new patient
// @access  Public
router.post('/register', async (req, res) => {
    const { name, uid, phone, location, gender } = req.body;

    try {
        // Check if user with this Aadhar (uid) already exists
        let user = await User.findOne({ uid });
        if (user) {
            return res.status(400).json({ success: false, message: 'User with this Aadhar number already exists' });
        }

        // Check if user with this phone already exists
        let userByPhone = await User.findOne({ phone });
        if (userByPhone) {
             return res.status(400).json({ success: false, message: 'User with this phone number already exists' });
        }

        user = new User({
            name,
            uid,
            phone,
            location,
            gender,
            role: 'patient'
        });

        await user.save();

        const token = jwt.sign(
            { userId: user._id, role: user.role },
            process.env.JWT_SECRET || 'gram_setu_secret_key_123!',
            { expiresIn: '7d' }
        );

        res.status(201).json({ success: true, token, user });
    } catch (error) {
        console.error('Registration Error:', error.message);
        res.status(500).json({ success: false, message: 'Server error during registration' });
    }
});

// @route   GET /api/users/uid/:uid
// @desc    Get user details by UID
router.get('/uid/:uid', async (req, res) => {
    try {
        const user = await User.findOne({ uid: req.params.uid });
        if (!user) {
            return res.status(404).json({ success: false, message: 'Patient not found' });
        }

        // Fetch full profile if requested (per instruction 7)
        const consultations = await Consultation.find({ patientUID: req.params.uid }).sort({ createdAt: -1 });
        const prescriptions = await Prescription.find({ patientUID: req.params.uid }).sort({ date: -1 });

        res.status(200).json({ 
            success: true, 
            user,
            personalDetails: {
                name: user.name,
                age: user.age || 30,
                gender: user.gender,
                uid: user.uid,
                location: user.location || { village: '', block: '', fullLocation: '' }
            },
            consultations,
            prescriptions
        });
    } catch (error) {
        console.error('Error fetching patient profile:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
