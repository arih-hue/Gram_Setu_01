const express = require('express');
const router = express.Router();
const Prescription = require('../models/Prescription');
const Consultation = require('../models/Consultation');

// POST /api/prescription/create
router.post('/create', async (req, res) => {
    try {
        const { 
            patientName, patientUID, patientAge, 
            doctorName, doctorId, 
            medicines, extraNote, consultationId 
        } = req.body;

        const newPrescription = new Prescription({
            patientName, patientUID, patientAge, 
            doctorName, doctorId, 
            medicines, extraNote, consultationId
        });

        await newPrescription.save();

        // Mark consultation as completed and calculate duration
        const consultation = await Consultation.findById(consultationId);
        if (consultation) {
            const completedAt = new Date();
            const startedAt = consultation.startedAt || consultation.createdAt;
            const durationMinutes = Math.round((completedAt - startedAt) / (1000 * 60));

            consultation.status = 'completed';
            consultation.completedAt = completedAt;
            consultation.durationMinutes = durationMinutes;
            await consultation.save();
        }

        res.status(201).json({ success: true, message: 'Prescription created successfully' });
    } catch (error) {
        console.error('Error in /create:', error);
        res.status(500).json({ success: false, message: 'Server error creating prescription' });
    }
});

// GET /api/prescription/patient/:uid
router.get('/patient/:uid', async (req, res) => {
    try {
        const prescriptions = await Prescription.find({ 
            patientUID: req.params.uid 
        })
        .populate('consultationId', 'reason')
        .sort({ date: -1 });
        
        res.status(200).json({ success: true, prescriptions });
    } catch (error) {
        console.error('Fetch Rx Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
