const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');

// POST /api/consultation/create
router.post('/create', async (req, res) => {
    try {
        const { patientName, patientUID, patientAge, patientGender, reason, bookedBy, bookedById, village, block } = req.body;
        
        const newConsultation = new Consultation({
            patientName,
            patientUID,
            patientAge,
            patientGender,
            village,
            block,
            reason,
            bookedBy,
            bookedById,
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

// PATCH /api/consultation/accept/:id
router.patch('/accept/:id', async (req, res) => {
    try {
        const { acceptedByDoctorId, acceptedByDoctorName } = req.body;
        
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
            return res.status(404).json({ success: false, message: 'Consultation not found' });
        }

        res.status(200).json({ success: true, message: 'Consultation accepted', consultation: updatedConsultation });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// PATCH /api/consultation/start/:id
router.patch('/start/:id', async (req, res) => {
    try {
        const updated = await Consultation.findByIdAndUpdate(
            req.params.id,
            { 
                status: 'active',
                startedAt: new Date()
            },
            { new: true }
        );
        if (!updated) return res.status(404).json({ success: false, message: 'Consultation not found' });
        res.status(200).json({ success: true, consultation: updated });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// GET /api/consultation/accepted/:doctorId
router.get('/accepted/:doctorId', async (req, res) => {
    try {
        const consultations = await Consultation.find({ 
            acceptedByDoctorId: req.params.doctorId,
            status: { $in: ['accepted', 'active'] } // Include both accepted and active
        }).sort({ createdAt: -1 });
        
        res.status(200).json({ success: true, consultations });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// PATCH /api/consultation/complete/:id
router.patch('/complete/:id', async (req, res) => {
    try {
        const consultation = await Consultation.findById(req.params.id);
        if (!consultation) return res.status(404).json({ success: false, message: 'Consultation not found' });

        const completedAt = new Date();
        const startedAt = consultation.startedAt || consultation.createdAt; // Fallback if start wasn't clicked
        
        const durationMinutes = Math.round((completedAt - startedAt) / (1000 * 60));

        consultation.status = 'completed';
        consultation.completedAt = completedAt;
        consultation.durationMinutes = durationMinutes;

        await consultation.save();
        res.status(200).json({ success: true, message: 'Consultation completed', consultation });
    } catch (error) {
        console.error('Completion Error:', error);
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
