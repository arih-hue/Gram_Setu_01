class Medicine {
  final String id;
  final String name;
  final String expiryDate;
  final bool availability;
  final double price;
  final String description;
  final String manufacturer;
  final String pharmacistId;

  Medicine({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.availability,
    required this.price,
    required this.description,
    required this.manufacturer,
    required this.pharmacistId,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      availability: json['availability'] ?? true,
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      pharmacistId: json['pharmacistId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'expiryDate': expiryDate,
      'availability': availability,
      'price': price,
      'description': description,
      'manufacturer': manufacturer,
      'pharmacistId': pharmacistId,
    };
  }
}
