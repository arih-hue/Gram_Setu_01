const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');
const User = require('../models/User');

// GET /api/doctor/stats/:doctorId
router.get('/stats/:doctorId', async (req, res) => {
    try {
        const { doctorId } = req.params;
        
        const completedConsultations = await Consultation.find({
            acceptedByDoctorId: doctorId,
            status: 'completed'
        });

        const patientsSeen = completedConsultations.length;
        
        let totalMinutes = 0;
        let thisWeekMinutes = 0;
        
        const now = new Date();
        const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
        startOfWeek.setHours(0, 0, 0, 0);

        completedConsultations.forEach(c => {
            totalMinutes += c.durationMinutes || 0;
            if (c.completedAt && new Date(c.completedAt) >= startOfWeek) {
                thisWeekMinutes += c.durationMinutes || 0;
            }
        });

        res.status(200).json({
            success: true,
            patientsSeen,
            hoursGiven: (totalMinutes / 60).toFixed(1),
            thisWeekHours: (thisWeekMinutes / 60).toFixed(1)
        });
    } catch (error) {
        console.error('Stats Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// GET /api/doctor/leaderboard
router.get('/leaderboard', async (req, res) => {
    try {
        // Collect all consultations to calculate total durationMinutes per doctor
        const consultations = await Consultation.find({ status: 'completed' });
        
        const doctorDurationMap = {}; // { doctorId: minutes }
        consultations.forEach(c => {
            if (c.acceptedByDoctorId) {
                doctorDurationMap[c.acceptedByDoctorId] = (doctorDurationMap[c.acceptedByDoctorId] || 0) + (c.durationMinutes || 0);
            }
        });

        // Fetch all doctors
        const doctors = await User.find({ role: 'doctor' });
        
        const leaderboard = doctors.map(d => {
            const minutes = doctorDurationMap[d._id.toString()] || 0;
            return {
                doctorName: d.name,
                hospital: d.hospitalName || 'District Hospital',
                totalHours: (minutes / 60).toFixed(1),
                totalMinutes: minutes,
                doctorId: d._id.toString()
            };
        });

        // Sort by totalDuration
        const order = req.query.order || 'desc';
        if (order === 'asc') {
            leaderboard.sort((a, b) => a.totalMinutes - b.totalMinutes);
        } else {
            leaderboard.sort((a, b) => b.totalMinutes - a.totalMinutes);
        }

        // Assign ranks
        const rankedLeaderboard = leaderboard.map((item, index) => ({
            ...item,
            rank: index + 1
        }));

        res.status(200).json({ success: true, leaderboard: rankedLeaderboard });
    } catch (error) {
        console.error('Leaderboard Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

module.exports = router;
