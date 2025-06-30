import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';
import 'package:wash_wheels/core/models/service_package.dart'; // Import ServicePackage
import 'package:wash_wheels/core/models/user.dart';
import 'package:wash_wheels/features/customer/cubit/booking_flow_cubit.dart';

class BookServicePage extends StatelessWidget {
  const BookServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingFlowCubit(),
      child: const _BookServiceView(),
    );
  }
}

class _BookServiceView extends StatelessWidget {
  const _BookServiceView();

  // List of preset locations
  static const List<String> presetLocations = ['Madrid', 'Barcelona', 'Valencia', 'Seville', 'Zaragoza'];

  @override
  Widget build(BuildContext context) {
    final customerId = (context.read<AuthCubit>().state as AuthAuthenticated).user.uid;

    return Scaffold(
      // The AppBar is handled by the CustomerHomeScaffold, so it's not needed here.
      body: BlocConsumer<BookingFlowCubit, BookingFlowState>(
        listener: (context, state) {
          // Listen for success or error to show feedback
          if (state.isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Booking confirmed successfully!'),
                backgroundColor: Colors.green,
              ));
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ));
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.packages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Determine if the confirm button should be enabled
          final isBookingReady = state.selectedPackage != null &&
              state.selectedProvider != null &&
              state.selectedDateTime != null &&
              state.selectedLocation != null &&
              state.availabilityMessage == "Slot is available!";

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('1. Select a Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- MODIFIED SECTION: Replaced Cards with a Dropdown ---
              DropdownButtonFormField<ServicePackage>(
                value: state.selectedPackage,
                hint: const Text('Select a service package'),
                decoration: _inputDecoration(),
                items: state.packages.map((package) {
                  return DropdownMenuItem(
                    value: package,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(package.name),
                        Text('\$${package.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<BookingFlowCubit>().selectPackage(value);
                  }
                },
                isExpanded: true, // Important for the Row to work correctly
              ),
              // --- END OF MODIFICATION ---

              const SizedBox(height: 24),
              const Text('2. Choose Location & Provider', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Location Dropdown
              DropdownButtonFormField<String>(
                value: state.selectedLocation,
                hint: const Text('Select a city'),
                decoration: _inputDecoration(),
                items: presetLocations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                onChanged: (value) {
                  if (value != null) context.read<BookingFlowCubit>().selectLocation(value);
                },
              ),
              const SizedBox(height: 16),
              // Provider Dropdown
              DropdownButtonFormField<User>(
                value: state.selectedProvider,
                hint: const Text('Select a provider'),
                decoration: _inputDecoration(),
                items: state.providers.map((p) => DropdownMenuItem(value: p, child: Text(p.displayName ?? 'Unnamed Provider'))).toList(),
                onChanged: (value) {
                  if (value != null) context.read<BookingFlowCubit>().selectProvider(value);
                },
              ),

              const SizedBox(height: 24),
              const Text('3. Choose Date & Time', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Date and Time Picker Button
              ElevatedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 30)),
                  );
                  if (date == null) return;

                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));
                  if (time == null) return;

                  final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  context.read<BookingFlowCubit>().selectDateTime(dateTime);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  state.selectedDateTime == null
                      ? 'Select Date & Time'
                      : DateFormat.yMMMd().add_jm().format(state.selectedDateTime!),
                ),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF3E3C63)),
              ),

              // Availability check result
              if (state.isCheckingAvailability)
                const Padding(padding: EdgeInsets.only(top: 8.0), child: Center(child: CircularProgressIndicator())),
              if (state.availabilityMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      state.availabilityMessage!,
                      style: TextStyle(
                        color: state.availabilityMessage == "Slot is available!" ? Colors.greenAccent : Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),
              // Confirm Booking Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF8A2BE2),
                ),
                onPressed: (state.isLoading || !isBookingReady)
                    ? null
                    : () => context.read<BookingFlowCubit>().confirmBooking(customerId: customerId),
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: Color(0xFF3E3C63),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}