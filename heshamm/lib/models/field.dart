import 'package:cloud_firestore/cloud_firestore.dart';

class Field {
  final String name;
  final double morningPrice;
  final double eveningPrice;
  final String imageUrl;
  final Map<String, String> slots;

  Field({
    required this.name,
    required this.morningPrice,
    required this.eveningPrice,
    required this.imageUrl,
    required this.slots,
  });

  factory Field.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Field(
      name: data['name'] ?? '',
      morningPrice: data['morningPrice']?.toDouble() ?? 0.0,
      eveningPrice: data['eveningPrice']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      slots: Map<String, String>.from(data['slots'] ?? {}),
    );
  }
}
