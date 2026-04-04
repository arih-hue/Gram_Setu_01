const mongoose = require('mongoose');

const MedicineSchema = new mongoose.Schema({
  name: { type: String, required: true },
  expiryDate: { type: String, required: true },
  availability: { type: Boolean, default: true },
  price: { type: Number, required: true },
  description: { type: String },
  manufacturer: { type: String },
  pharmacistId: { type: String, required: true }, // To link who added it
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Medicine', MedicineSchema);
