import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wash_wheels/core/models/booking.dart';
import 'package:wash_wheels/features/provider/cubit/provider_schedule_cubit.dart';

class ProviderSchedulePage extends StatelessWidget {
  const ProviderSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<ProviderScheduleCubit, ProviderScheduleState>(
        builder: (context, state) {
          if (state is ProviderScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProviderScheduleError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is ProviderScheduleLoaded) {
            return ListView(
              children: [
                if (state.pendingBookings.isNotEmpty)
                  _PendingBookingsList(pendingBookings: state.pendingBookings),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('My Confirmed Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                TableCalendar<Booking>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: state.focusedDay,
                  selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
                  eventLoader: (day) => state.events[day] ?? [],
                  onDaySelected: (selectedDay, focusedDay) {
                    context.read<ProviderScheduleCubit>().onDaySelected(selectedDay, focusedDay);
                  },
                  onPageChanged: (focusedDay) {
                    context.read<ProviderScheduleCubit>().onDaySelected(focusedDay, focusedDay);
                  },
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Divider(thickness: 1),
                ),

                state.selectedDayEvents.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('No confirmed bookings for this day.')),
                )
                    : Column(
                  children: state.selectedDayEvents.map((booking) =>
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        color: theme.colorScheme.secondary,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          title: Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${booking.location}\n${DateFormat.jm().format(booking.date)}',
                            style: TextStyle(color: Colors.white70, height: 1.4),
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            '\$${booking.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.greenAccent),
                          ),
                          onTap: () { /* TODO: Navigate to details page */ },
                        ),
                      )
                  ).toList(),
                ),
              ],
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}

class _PendingBookingsList extends StatelessWidget {
  const _PendingBookingsList({required this.pendingBookings});

  final List<Booking> pendingBookings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingBookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final booking = pendingBookings[index];
              return Card(
                color: theme.colorScheme.primary.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.primary, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('${booking.location}\n${DateFormat.yMMMd().add_jm().format(booking.date)}', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () { /* TODO: Implement decline logic */ },
                            child: const Text('Decline'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () {
                              context.read<ProviderScheduleCubit>().acceptBooking(booking.id);
                            },
                            child: const Text('Accept', style: TextStyle(color: Colors.white)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}