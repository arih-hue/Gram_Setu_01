const express = require('express');
const router = express.Router();
const User = require('../models/User');

// GET /api/patient/uid/:uid
router.get('/uid/:uid', async (req, res) => {
    try {
        const user = await User.findOne({ uid: req.params.uid, role: 'patient' });
        if (user) {
            res.status(200).json({ success: true, patient: user });
        } else {
            res.status(404).json({ success: false, message: 'Patient not found' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
