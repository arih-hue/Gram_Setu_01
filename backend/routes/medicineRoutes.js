const express = require('express');
const router = express.Router();
const Medicine = require('../models/Medicine');
const User = require('../models/User');

// Browse medicines with pharmacist details
router.get('/browse', async (req, res) => {
  try {
    const medicines = await Medicine.find().lean();
    const result = await Promise.all(medicines.map(async (med) => {
      // Find pharmacist by their pharmacistId string
      const pharmacist = await User.findOne({ pharmacistId: med.pharmacistId, role: 'pharmacist' }).lean();
      return {
        ...med,
        pharmacistName: pharmacist ? pharmacist.name : 'Unknown Pharmacy',
        pharmacistPhone: pharmacist ? pharmacist.phone : ''
      };
    }));
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching medicines for browsing', error: error.message });
  }
});

// Add a new medicine
router.post('/add', async (req, res) => {
  try {
    const { name, expiryDate, availability, price, description, manufacturer, pharmacistId } = req.body;
    const newMedicine = new Medicine({
      name,
      expiryDate,
      availability: availability !== undefined ? availability : true,
      price,
      description,
      manufacturer,
      pharmacistId
    });
    await newMedicine.save();
    res.status(201).json({ message: 'Medicine added successfully', medicine: newMedicine });
  } catch (error) {
    res.status(500).json({ message: 'Error adding medicine', error: error.message });
  }
});

// Get all medicines
router.get('/all', async (req, res) => {
  try {
    const medicines = await Medicine.find().sort({ createdAt: -1 });
    res.status(200).json(medicines);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching medicines', error: error.message });
  }
});

// Search medicines by name
router.get('/search/:name', async (req, res) => {
  try {
    const medicines = await Medicine.find({ name: { $regex: req.params.name, $options: 'i' } });
    res.status(200).json(medicines);
  } catch (error) {
    res.status(500).json({ message: 'Error searching medicines', error: error.message });
  }
});

// Update medicine
router.put('/update/:id', async (req, res) => {
  try {
    const updatedMedicine = await Medicine.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedMedicine) return res.status(444).json({ message: 'Medicine not found' });
    res.status(200).json({ message: 'Medicine updated successfully', medicine: updatedMedicine });
  } catch (error) {
    res.status(500).json({ message: 'Error updating medicine', error: error.message });
  }
});

// Delete medicine
router.delete('/delete/:id', async (req, res) => {
  try {
    const deletedMedicine = await Medicine.findByIdAndDelete(req.params.id);
    if (!deletedMedicine) return res.status(444).json({ message: 'Medicine not found' });
    res.status(200).json({ message: 'Medicine deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting medicine', error: error.message });
  }
});

module.exports = router;
