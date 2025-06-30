import 'package:flutter/material.dart';
import 'package:wash_wheels/core/models/booking.dart';

class ProviderSchedulePage extends StatelessWidget {
  ProviderSchedulePage({super.key});

  final List<Booking> assignedBookings = [
    Booking(id: 'b1', serviceName: 'Deluxe Detail', date: DateTime.now(), status: BookingStatus.inProgress, price: 75.00),
    Booking(id: 'b2', serviceName: 'Express Wash', date: DateTime.now().add(const Duration(days: 2)), status: BookingStatus.pending, price: 25.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule'), backgroundColor: const Color(0xFF3E3C63)),
      body: ListView.builder(
        itemCount: assignedBookings.length,
        itemBuilder: (context, index) {
          final booking = assignedBookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF3E3C63),
            child: ListTile(
              title: Text(booking.serviceName),
              subtitle: Text('Customer Address Here\n${booking.date.toString()}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to a details page where provider can update status
              },
            ),
          );
        },
      ),
    );
  }
}