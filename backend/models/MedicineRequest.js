const mongoose = require('mongoose');

const MedicineRequestSchema = new mongoose.Schema({
  patientUID: { type: String, required: true },
  patientName: { type: String, required: true },
  medicineName: { type: String, required: true },
  quantity: { type: String },
  pharmacistId: { type: String }, // optional if requested from specific store
  status: { type: String, enum: ['pending', 'accepted', 'rejected', 'completed'], default: 'pending' },
  requestDate: { type: Date, default: Date.now },
  notes: { type: String }
});

module.exports = mongoose.model('MedicineRequest', MedicineRequestSchema);
