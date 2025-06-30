import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wash_wheels/features/provider/cubit/provider_schedule_cubit.dart';

class ProviderSchedulePage extends StatelessWidget {
  const ProviderSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar is now in the home scaffold, so we can remove it from here
      // to avoid having two AppBars.
      body: BlocBuilder<ProviderScheduleCubit, ProviderScheduleState>(
        builder: (context, state) {
          if (state is ProviderScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProviderScheduleLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(child: Text('You have no upcoming bookings.'));
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF3E3C63),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(
                      booking.serviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // Use the real data from the booking object
                    subtitle: Text(
                      '${booking.location}\n${DateFormat.yMMMd().add_jm().format(booking.date)}',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            '\$${booking.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.greenAccent)
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to a details page where provider can update status
                      // For example: Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsPage(booking: booking)));
                    },
                  ),
                );
              },
            );
          }

          if (state is ProviderScheduleError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}