import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wash_wheels/core/models/booking.dart';

class BookingsListPage extends StatelessWidget {
  BookingsListPage({super.key});

  // Mock data
  final List<Booking> bookings = [
    Booking(id: 'b1', serviceName: 'Deluxe Detail', date: DateTime.now(), status: BookingStatus.inProgress, price: 75.00),
    Booking(id: 'b2', serviceName: 'Express Wash', date: DateTime.now().add(const Duration(days: 2)), status: BookingStatus.pending, price: 25.00),
    Booking(id: 'b3', serviceName: 'Ultimate Shine', date: DateTime.now().subtract(const Duration(days: 7)), status: BookingStatus.completed, price: 150.00),
    Booking(id: 'b4', serviceName: 'Express Wash', date: DateTime.now().subtract(const Duration(days: 14)), status: BookingStatus.cancelled, price: 25.00),
  ];

  IconData _getIconForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Icons.hourglass_top_outlined;
      case BookingStatus.inProgress: return Icons.directions_car_outlined;
      case BookingStatus.completed: return Icons.check_circle_outline;
      case BookingStatus.cancelled: return Icons.cancel_outlined;
    }
  }

  Color _getColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.inProgress: return Colors.blue;
      case BookingStatus.completed: return Colors.green;
      case BookingStatus.cancelled: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), backgroundColor: const Color(0xFF3E3C63)),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF3E3C63),
            child: ListTile(
              leading: Icon(_getIconForStatus(booking.status), color: _getColorForStatus(booking.status), size: 40),
              title: Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat.yMMMd().add_jm().format(booking.date)),
              trailing: Text(booking.status.name.toUpperCase(), style: TextStyle(color: _getColorForStatus(booking.status), fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}