class AddressModel {
  const AddressModel({
    required this.id,
    required this.recipientName,
    required this.line1,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  final int id;
  final String recipientName;
  final String line1;
  final String city;
  final String postalCode;
  final String country;

  String get shortLabel => '$recipientName, $line1, $city';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] as num).toInt(),
      recipientName: (json['recipient_name'] ?? '') as String,
      line1: (json['line1'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      postalCode: (json['postal_code'] ?? '') as String,
      country: (json['country'] ?? '') as String,
    );
  }
}
