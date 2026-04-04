const express = require('express');
const router = express.Router();
const MedicineRequest = require('../models/MedicineRequest');

// Create a new request
router.post('/add', async (req, res) => {
  try {
    const newRequest = new MedicineRequest(req.body);
    await newRequest.save();
    res.status(201).json({ success: true, message: 'Request created', request: newRequest });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error adding request', error: error.message });
  }
});

// Get all requests (for specific pharmacist? or broad?)
router.get('/all', async (req, res) => {
  try {
    const { pharmacistId } = req.query;
    const filter = pharmacistId ? { pharmacistId } : {};
    const requests = await MedicineRequest.find(filter).sort({ requestDate: -1 });
    res.status(200).json({ success: true, requests });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching requests', error: error.message });
  }
});

// Get by Patient UID
router.get('/patient/:uid', async (req, res) => {
  try {
    const requests = await MedicineRequest.find({ patientUID: req.params.uid }).sort({ requestDate: -1 });
    res.status(200).json({ success: true, requests });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching requests', error: error.message });
  }
});

// Update status
router.patch('/update/:id', async (req, res) => {
  try {
    const { status } = req.body;
    const request = await MedicineRequest.findByIdAndUpdate(req.params.id, { status }, { new: true });
    if (!request) return res.status(404).json({ success: false, message: 'Request not found' });
    res.status(200).json({ success: true, message: 'Status updated', request });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating status', error: error.message });
  }
});

module.exports = router;
