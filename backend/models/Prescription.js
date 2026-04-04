const mongoose = require('mongoose');

const PrescriptionSchema = new mongoose.Schema({
    patientName: { type: String, required: true },
    patientUID: { type: String, required: true },
    patientAge: { type: Number, required: true },
    doctorName: { type: String, required: true },
    doctorId: { type: String, required: true },
    date: { type: Date, default: Date.now },
    medicines: [{
        medicineName: { type: String, required: true },
        duration: { type: String, required: true },
        timing: { type: String, required: true }
    }],
    extraNote: { type: String, default: null },
    consultationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Consultation', required: true }
});

module.exports = mongoose.model('Prescription', PrescriptionSchema);
