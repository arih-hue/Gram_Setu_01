const mongoose = require('mongoose');

const VitalsSchema = new mongoose.Schema({
  patientUID: { type: String, required: true },
  systolic: { type: Number },
  diastolic: { type: Number },
  heartRate: { type: Number },
  spo2: { type: Number },
  temperature: { type: Number },
  bloodSugar: { type: Number },
  weight: { type: Number },
  notes: { type: String },
  recordedBy: { type: String }, // Role or ID of the person recording
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Vitals', VitalsSchema);
