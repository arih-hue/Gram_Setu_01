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

        // Automatically mark the consultation as completed
        await Consultation.findByIdAndUpdate(consultationId, { status: 'completed' });

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
        }).sort({ date: -1 });
        
        res.status(200).json({ success: true, prescriptions });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
