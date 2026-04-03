const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');

// POST /api/consultation/create
router.post('/create', async (req, res) => {
    try {
        const { patientName, patientUID, patientAge, patientGender, reason, bookedBy } = req.body;
        
        const newConsultation = new Consultation({
            patientName,
            patientUID,
            patientAge,
            patientGender,
            reason,
            bookedBy,
            status: 'pending'
        });

        await newConsultation.save();
        res.status(201).json({ success: true, message: 'Consultation request created', consultation: newConsultation });
    } catch (error) {
        console.error('Error in /create:', error);
        res.status(500).json({ success: false, message: 'Server error creating consultation' });
    }
});

// GET /api/consultation/all
// Return only consultations where status = 'pending' AND acceptedByDoctorId = null
router.get('/all', async (req, res) => {
    try {
        const consultations = await Consultation.find({ 
            status: 'pending', 
            acceptedByDoctorId: null 
        }).sort({ createdAt: -1 });
        
        res.status(200).json({ success: true, consultations });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// @route   PATCH /api/consultation/accept/:id
// @desc    Accept a consultation request
router.patch('/accept/:id', async (req, res) => {
    try {
        const { acceptedByDoctorId, acceptedByDoctorName } = req.body;
        console.log(`👨‍⚕️ Doctor ${acceptedByDoctorName} (${acceptedByDoctorId}) is accepting consultation ${req.params.id}`);
        
        const updatedConsultation = await Consultation.findByIdAndUpdate(
            req.params.id,
            { 
                status: 'accepted', 
                acceptedByDoctorId, 
                acceptedByDoctorName 
            },
            { new: true }
        );
        
        if (!updatedConsultation) {
            console.error('❌ Consultation not found for acceptance');
            return res.status(404).json({ success: false, message: 'Consultation not found' });
        }

        console.log('✅ Consultation status updated to accepted');
        res.status(200).json({ success: true, message: 'Consultation accepted', consultation: updatedConsultation });
    } catch (error) {
        console.error('❌ Error accepting consultation:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// @route   GET /api/consultation/accepted/:doctorId
// @desc    Get all accepted consultations for a specific doctor
router.get('/accepted/:doctorId', async (req, res) => {
    try {
        console.log(`📡 Fetching accepted consultations for Doctor ID: ${req.params.doctorId}`);
        const consultations = await Consultation.find({ 
            acceptedByDoctorId: req.params.doctorId.toString(),
            status: 'accepted'
        }).sort({ createdAt: -1 });
        
        console.log(`✅ Found ${consultations.length} accepted consultations`);
        res.status(200).json({ success: true, consultations });
    } catch (error) {
        console.error('❌ Error fetching accepted consultations:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// PATCH /api/consultation/complete/:id
router.patch('/complete/:id', async (req, res) => {
    try {
        const consultation = await Consultation.findByIdAndUpdate(
            req.params.id,
            { status: 'completed' },
            { new: true }
        );
        res.status(200).json({ success: true, message: 'Consultation completed', consultation });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// GET /api/consultation/count/:uid
router.get('/count/:uid', async (req, res) => {
    try {
        const count = await Consultation.countDocuments({ 
            patientUID: req.params.uid, 
            status: 'completed' 
        });
        res.status(200).json({ success: true, count });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
