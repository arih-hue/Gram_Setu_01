const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  phone: { type: String, unique: true, sparse: true }, 
  uid: { type: String, unique: true, sparse: true },   
  mciNumber: { type: String, unique: true, sparse: true }, 
  ashaId: { type: String, unique: true, sparse: true },   
  panchayatId: { type: String, unique: true, sparse: true },
  googleId: { type: String, unique: true, sparse: true }, 
  email: { type: String, unique: true, sparse: true },
  password: { type: String }, 
  name: { type: String, default: "User" },
  picture: { type: String },
  location: {
    village: { type: String, default: '' },
    block: { type: String, default: '' },
    fullLocation: { type: String, default: '' }
  },
  hospitalName: { type: String }, 
  age: { type: String },      
  emergencyContact: { type: String }, 
  gender: { type: String, enum: ['Male', 'Female', 'Others'] },
  role: { type: String, enum: ['patient', 'doctor', 'admin', 'asha', 'panchayat'], default: 'patient' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);