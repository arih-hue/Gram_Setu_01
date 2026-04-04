const mongoose = require('mongoose');

const ConsultationSchema = new mongoose.Schema({
    patientName: { type: String, required: true },
    patientUID: { type: String, required: true },
    patientAge: { type: Number, required: true },
    patientGender: { type: String, required: true },
    reason: { type: String, required: true },
    status: { 
        type: String, 
        enum: ['pending', 'accepted', 'active', 'completed'], 
        default: 'pending' 
    },
    acceptedByDoctorId: { type: String, default: null },
    acceptedByDoctorName: { type: String, default: null },
    bookedBy: { 
        type: String, 
        enum: ['patient', 'asha', 'panchayat'], 
        required: true 
    },
    startedAt: { type: Date, default: null },
    completedAt: { type: Date, default: null },
    durationMinutes: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Consultation', ConsultationSchema);
