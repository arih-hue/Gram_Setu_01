const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Consultation = require('../models/Consultation');

// GET /api/stats/village?village=X&block=Y
router.get('/village', async (req, res) => {
    try {
        const { village, block } = req.query;

        if (!village) {
            return res.status(400).json({ success: false, message: 'Village name is required' });
        }

        // 1. Total Patients in this village
        const totalPatients = await User.countDocuments({ 
            role: 'patient', 
            'location.village': village 
        });

        // 2. Active Consultations in this village
        const activeCases = await Consultation.countDocuments({
            status: 'pending',
            village: village
        });

        // 3. Total Doctors in matching village or block
        const totalDoctors = await User.countDocuments({
            role: 'doctor',
            $or: [
                { 'location.village': village },
                { 'location.block': block }
            ]
        });

        // 4. Total Asha Workers in matching village or block
        const totalAshaWorkers = await User.countDocuments({
            role: 'asha',
            $or: [
                { 'location.village': village },
                { 'location.block': block }
            ]
        });

        res.status(200).json({
            success: true,
            totalPatients,
            activeCases,
            totalDoctors,
            totalAshaWorkers
        });
    } catch (error) {
        console.error('Village Stats Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// GET /api/stats/asha?ashaId=X&village=Y
router.get('/asha', async (req, res) => {
    try {
        const { ashaId, village } = req.query;

        if (!ashaId || !village) {
            return res.status(400).json({ success: false, message: 'ashaId and village are required' });
        }

        // 1. Patients in this village
        const villagePatients = await User.countDocuments({
            role: 'patient',
            'location.village': village
        });

        // 2. Consultations booked by this ASHA
        // We'll search by bookedById = ashaId OR bookedBy = 'asha' + some other logic if available
        // Since we just added bookedById, historic data might not have it.
        // For now, let's look for bookedById
        const bookedConsultations = await Consultation.countDocuments({
            bookedById: ashaId
        });

        res.status(200).json({
            success: true,
            villagePatients,
            bookedConsultations
        });
    } catch (error) {
        console.error('ASHA Stats Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
