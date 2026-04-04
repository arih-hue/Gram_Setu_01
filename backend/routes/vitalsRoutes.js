const express = require('express');
const router = express.Router();
const Vitals = require('../models/Vitals');
const User = require('../models/User');

// Add vitals record
router.post('/add', async (req, res) => {
  try {
    const { patientUID, systolic, diastolic, heartRate, spo2, temperature, bloodSugar, weight, notes, recordedBy } = req.body;
    
    // Check if user exists (optional, but good)
    const user = await User.findOne({ uid: patientUID });
    if (!user) return res.status(404).json({ message: 'Patient not found' });

    const newVitals = new Vitals({
      patientUID,
      systolic,
      diastolic,
      heartRate,
      spo2,
      temperature,
      bloodSugar,
      weight,
      notes,
      recordedBy
    });
    
    await newVitals.save();
    res.status(201).json({ message: 'Vitals recorded successfully', vitals: newVitals });
  } catch (error) {
    res.status(500).json({ message: 'Error recording vitals', error: error.message });
  }
});

// Get vitals for a patient by UID
router.get('/patient/:uid', async (req, res) => {
  try {
    const records = await Vitals.find({ patientUID: req.params.uid }).sort({ timestamp: -1 });
    res.status(200).json(records);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching vitals', error: error.message });
  }
});

// Delete a vitals record
router.delete('/delete/:id', async (req, res) => {
    try {
        await Vitals.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Vitals record deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting vitals', error: error.message });
    }
});

module.exports = router;
