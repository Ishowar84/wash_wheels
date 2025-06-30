import 'package:equatable/equatable.dart';

class ServicePackage extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;

  const ServicePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  // NEW: Creates a ServicePackage from a Firestore document
  factory ServicePackage.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ServicePackage(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // NEW: Converts a ServicePackage into a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
    };
  }

  @override
  List<Object> get props => [id, name, description, price];
}