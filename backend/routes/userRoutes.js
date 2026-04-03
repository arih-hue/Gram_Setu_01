const express = require('express');
const router = express.Router();
const User = require('../models/User');
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
        res.status(200).json({ success: true, user });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
