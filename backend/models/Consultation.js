const mongoose = require('mongoose');

const ConsultationSchema = new mongoose.Schema({
    patientName: { type: String, required: true },
    patientUID: { type: String, required: true },
    patientAge: { type: Number, required: true },
    patientGender: { type: String, required: true },
    reason: { type: String, required: true },
    status: { 
        type: String, 
        enum: ['pending', 'accepted', 'completed'], 
        default: 'pending' 
    },
    acceptedByDoctorId: { type: String, default: null },
    acceptedByDoctorName: { type: String, default: null },
    bookedBy: { 
        type: String, 
        enum: ['patient', 'asha', 'panchayat'], 
        required: true 
    },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Consultation', ConsultationSchema);
