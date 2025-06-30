import 'dart:async';
import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';
import 'package:wash_wheels/core/models/booking.dart';
import 'package:table_calendar/table_calendar.dart';

// --- CUBIT STATES ---
abstract class ProviderScheduleState extends Equatable {
  const ProviderScheduleState();
  @override
  List<Object?> get props => [];
}

class ProviderScheduleLoading extends ProviderScheduleState {}

class ProviderScheduleLoaded extends ProviderScheduleState {
  // For the calendar (confirmed/in-progress bookings)
  final LinkedHashMap<DateTime, List<Booking>> events;
  // For the "New Requests" list
  final List<Booking> pendingBookings;
  final DateTime selectedDay;
  final DateTime focusedDay;

  const ProviderScheduleLoaded({
    required this.events,
    required this.pendingBookings,
    required this.selectedDay,
    required this.focusedDay,
  });

  List<Booking> get selectedDayEvents => events[selectedDay] ?? [];

  @override
  List<Object?> get props => [events, pendingBookings, selectedDay, focusedDay];
}

class ProviderScheduleError extends ProviderScheduleState {
  final String message;
  const ProviderScheduleError(this.message);
  @override
  List<Object> get props => [message];
}


// --- THE CUBIT ---
class ProviderScheduleCubit extends Cubit<ProviderScheduleState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthCubit _authCubit;
  StreamSubscription? _bookingSubscription;
  StreamSubscription? _authSubscription;

  ProviderScheduleCubit({required AuthCubit authCubit})
      : _authCubit = authCubit,
        super(ProviderScheduleLoading()) {
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        fetchSchedule(authState.user.uid);
      } else {
        emit(ProviderScheduleLoaded(
          events: LinkedHashMap(),
          pendingBookings: const [],
          selectedDay: DateTime.now(),
          focusedDay: DateTime.now(),
        ));
      }
    });

    if (_authCubit.state is AuthAuthenticated) {
      fetchSchedule((_authCubit.state as AuthAuthenticated).user.uid);
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (state is ProviderScheduleLoaded) {
      final loadedState = state as ProviderScheduleLoaded;
      emit(ProviderScheduleLoaded(
        events: loadedState.events,
        pendingBookings: loadedState.pendingBookings,
        selectedDay: selectedDay,
        focusedDay: focusedDay,
      ));
    }
  }

  // Method for the provider to accept a booking request
  Future<void> acceptBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
      });
      // The stream will automatically refresh the UI.
    } catch (e) {
      // You can emit an error state here if needed
      print("Failed to accept booking: $e");
    }
  }

  void fetchSchedule(String providerId) {
    _bookingSubscription?.cancel();
    _bookingSubscription = _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .listen((snapshot) {

      final List<Booking> allBookings = snapshot.docs
          .map((doc) => Booking.fromFirestore(doc.data(), doc.id))
          .toList();

      // Split the bookings into two separate lists
      final pending = allBookings.where((b) => b.status == BookingStatus.pending).toList();
      final confirmedAndInProgress = allBookings.where((b) => b.status != BookingStatus.pending).toList();

      pending.sort((a,b) => a.date.compareTo(b.date));

      // Process the confirmed bookings for the calendar map
      final events = LinkedHashMap<DateTime, List<Booking>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      );

      for (var booking in confirmedAndInProgress) {
        final dateKey = DateTime.utc(booking.date.year, booking.date.month, booking.date.day);

        if (events[dateKey] == null) {
          events[dateKey] = [];
        }
        events[dateKey]!.add(booking);
      }

      for (var eventList in events.values) {
        eventList.sort((a, b) => a.date.compareTo(b.date));
      }

      final currentState = state;
      final selectedDay = (currentState is ProviderScheduleLoaded) ? currentState.selectedDay : DateTime.now();
      final focusedDay = (currentState is ProviderScheduleLoaded) ? currentState.focusedDay : DateTime.now();

      emit(ProviderScheduleLoaded(
        events: events,
        pendingBookings: pending, // Add the new list to the state
        selectedDay: selectedDay,
        focusedDay: focusedDay,
      ));
    }, onError: (error) {
      emit(ProviderScheduleError(error.toString()));
    });
  }

  @override
  Future<void> close() {
    _bookingSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}