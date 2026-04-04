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
    const { name, uid, phone, location, village, block, gender } = req.body;

    try {
        // Check if user with this Aadhar (uid) already exists
        let user = await User.findOne({ uid });
        if (user) {
            return res.status(400).json({ success: false, message: 'User with this Aadhar number already exists' });
        }

        user = new User({
            name,
            uid,
            phone,
            location: {
                village: village || '',
                block: block || '',
                fullLocation: location || ''
            },
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

// @route   GET /api/patient/uid/:uid (also mapped to /users/uid/:uid)
router.get('/uid/:uid', async (req, res) => {
    try {
        const user = await User.findOne({ uid: req.params.uid });
        if (!user) {
            return res.status(404).json({ success: false, message: 'No patient found with this UID' });
        }

        const consultations = await Consultation.find({ patientUID: req.params.uid }).sort({ createdAt: -1 });
        const prescriptions = await Prescription.find({ patientUID: req.params.uid }).sort({ date: -1 });

        res.status(200).json({ 
            success: true, 
            user: user,
            personalDetails: {
                name: user.name,
                age: user.age || 'N/A',
                gender: user.gender || 'N/A',
                uid: user.uid,
                hospital: user.hospitalName || 'Rural Clinic'
            },
            consultations,
            prescriptions
        });
    } catch (error) {
        console.error('Fetch Patient Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
