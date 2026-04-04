const express = require('express');
const router = express.Router();

// Import Routes
const authRoutes = require('./authRoutes');
const livekitRoutes = require('./livekitRoutes');
const consultationRoutes = require('./consultationRoutes');
const prescriptionRoutes = require('./prescriptionRoutes');
const userRoutes = require('./userRoutes');
const triageRoutes = require('./triageRoutes');
const doctorRoutes = require('./doctorRoutes');
const statsRoutes = require('./statsRoutes');

// Use Routes
router.use('/auth', authRoutes);
router.use('/livekit', livekitRoutes);
router.use('/consultation', consultationRoutes);
router.use('/prescription', prescriptionRoutes);
router.use('/users', userRoutes);
router.use('/patient', userRoutes);
router.use('/doctor', doctorRoutes);
router.use('/triage', triageRoutes);
router.use('/stats', statsRoutes);


// Optional: Test Route
router.get('/health', (req, res) => res.status(200).json({ status: 'ok', API_Version: '1.0' }));

module.exports = router;
