class MedicineRequest {
  final String id;
  final String patientUID;
  final String patientName;
  final String medicineName;
  final String quantity;
  final String pharmacistId;
  final String status;
  final DateTime requestDate;
  final String notes;

  MedicineRequest({
    required this.id,
    required this.patientUID,
    required this.patientName,
    required this.medicineName,
    required this.quantity,
    this.pharmacistId = '',
    this.status = 'pending',
    required this.requestDate,
    this.notes = '',
  });

  factory MedicineRequest.fromJson(Map<String, dynamic> json) {
    return MedicineRequest(
      id: json['_id'] ?? '',
      patientUID: json['patientUID'] ?? '',
      patientName: json['patientName'] ?? '',
      medicineName: json['medicineName'] ?? '',
      quantity: json['quantity'] ?? '',
      pharmacistId: json['pharmacistId'] ?? '',
      status: json['status'] ?? 'pending',
      requestDate: json['requestDate'] != null 
          ? DateTime.parse(json['requestDate']) 
          : DateTime.now(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientUID': patientUID,
      'patientName': patientName,
      'medicineName': medicineName,
      'quantity': quantity,
      'pharmacistId': pharmacistId,
      'status': status,
      'notes': notes,
    };
  }
}
