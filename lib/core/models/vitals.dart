class Vitals {
  final String id;
  final String patientUID;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? spo2;
  final double? temperature;
  final int? bloodSugar;
  final double? weight;
  final String notes;
  final String recordedBy;
  final DateTime timestamp;

  Vitals({
    required this.id,
    required this.patientUID,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.spo2,
    this.temperature,
    this.bloodSugar,
    this.weight,
    required this.notes,
    required this.recordedBy,
    required this.timestamp,
  });

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      id: json['_id'] ?? '',
      patientUID: json['patientUID'] ?? '',
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      heartRate: json['heartRate'],
      spo2: json['spo2'],
      temperature: (json['temperature'] as num?)?.toDouble(),
      bloodSugar: json['bloodSugar'],
      weight: (json['weight'] as num?)?.toDouble(),
      notes: json['notes'] ?? '',
      recordedBy: json['recordedBy'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientUID': patientUID,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'bloodSugar': bloodSugar,
      'weight': weight,
      'notes': notes,
      'recordedBy': recordedBy,
    };
  }
}
