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

        // 2. Active Cases (status='pending') in this village
        // Since Consultation model stores patientUID, we might need a join or filter
        // But the prompt says: "Count of all consultation requests with status = 'pending' AND patient's village = panchayat user's village"
        // We'll need to fetch all pending consultations and match with patient's village
        
        const pendingConsultations = await Consultation.find({ status: 'pending' });
        
        // Fetch patient UIDs for these consultations to check their villages
        const patientUIDs = pendingConsultations.map(c => c.patientUID);
        const patientsInVillage = await User.find({ 
            uid: { $in: patientUIDs },
            'location.village': village 
        }).select('uid');
        
        const villagePatientUIDs = new Set(patientsInVillage.map(p => p.uid));
        const activeCases = pendingConsultations.filter(c => villagePatientUIDs.has(c.patientUID)).length;

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

module.exports = router;
