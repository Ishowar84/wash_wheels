import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wash_wheels/core/models/booking.dart';
import 'package:wash_wheels/features/customer/cubit/customer_bookings_cubit.dart'; // Import the new cubit

// The page itself no longer holds any data or state
class BookingsListPage extends StatelessWidget {
  const BookingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This page will now be wrapped in a BlocProvider for the CustomerBookingsCubit
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF3E3C63),
      ),
      // Use BlocBuilder to listen to the cubit's state changes
      body: BlocBuilder<CustomerBookingsCubit, CustomerBookingsState>(
        builder: (context, state) {
          // State 1: We are loading the bookings from Firestore
          if (state is CustomerBookingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: We have successfully loaded the bookings
          if (state is CustomerBookingsLoaded) {
            // Show a message if there are no bookings
            if (state.bookings.isEmpty) {
              return const Center(child: Text('You have no past or upcoming bookings.'));
            }

            // Build the list using the data from the state
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF3E3C63),
                  child: ListTile(
                    leading: Icon(_getIconForStatus(booking.status), color: _getColorForStatus(booking.status), size: 40),
                    title: Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(booking.date)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${booking.status.name[0].toUpperCase()}${booking.status.name.substring(1)}',
                          style: TextStyle(color: _getColorForStatus(booking.status), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('\$${booking.price.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // State 3: An error occurred while fetching data
          if (state is CustomerBookingsError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // Default state (shouldn't be reached)
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  // Your helper methods are perfect, no changes needed here
  IconData _getIconForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Icons.hourglass_top_outlined;
      case BookingStatus.confirmed: return Icons.check_circle_outline; // You might want a separate icon for confirmed
      case BookingStatus.inProgress: return Icons.directions_car_outlined;
      case BookingStatus.completed: return Icons.task_alt_outlined;
      case BookingStatus.cancelled: return Icons.cancel_outlined;
    }
  }

  Color _getColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.confirmed: return Colors.blue;
      case BookingStatus.inProgress: return Colors.lightBlueAccent;
      case BookingStatus.completed: return Colors.green;
      case BookingStatus.cancelled: return Colors.red;
    }
  }
}