import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class Booking extends Equatable {
  final String id;
  final String customerId; // ADDED: The ID of the user who booked.
  final String providerId; // ADDED: The ID of the provider assigned.
  final String serviceName;
  final double price;
  final DateTime date;
  final String location;     // ADDED: The address for the service.
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.location,
    this.status = BookingStatus.pending,
  });

  // Creates a Booking from a Firestore document
  factory Booking.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Booking(
      id: documentId,
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceName: data['serviceName'] ?? 'Unknown Service',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      // Firestore stores Timestamps, so we convert it to a Dart DateTime
      date: (data['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      location: data['location'] ?? 'No location provided',
      // Convert the string status from Firestore to our enum
      status: BookingStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
        orElse: () => BookingStatus.pending,
      ),
    );
  }

  // Converts a Booking object into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'serviceName': serviceName,
      'price': price,
      // Convert the Dart DateTime back to a Firestore Timestamp
      'date': Timestamp.fromDate(date),
      'location': location,
      // Convert our enum to a simple string for Firestore
      'status': status.toString().split('.').last,
    };
  }

  @override
  List<Object?> get props => [id, customerId, providerId, serviceName, price, date, location, status];
}