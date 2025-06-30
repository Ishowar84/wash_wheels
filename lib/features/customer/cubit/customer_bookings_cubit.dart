import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart'; // To get the current user
import 'package:wash_wheels/core/models/booking.dart';

// --- CUBIT STATES ---
abstract class CustomerBookingsState extends Equatable {
  const CustomerBookingsState();
  @override
  List<Object> get props => [];
}

class CustomerBookingsLoading extends CustomerBookingsState {}

class CustomerBookingsLoaded extends CustomerBookingsState {
  final List<Booking> bookings;
  const CustomerBookingsLoaded(this.bookings);
  @override
  List<Object> get props => [bookings];
}

class CustomerBookingsError extends CustomerBookingsState {
  final String message;
  const CustomerBookingsError(this.message);
  @override
  List<Object> get props => [message];
}

// --- THE CUBIT ---
class CustomerBookingsCubit extends Cubit<CustomerBookingsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthCubit _authCubit; // We need this to know who the user is
  StreamSubscription? _bookingSubscription;
  StreamSubscription? _authSubscription;

  CustomerBookingsCubit({required AuthCubit authCubit})
      : _authCubit = authCubit,
        super(CustomerBookingsLoading()) {
    // Listen to auth state changes. If user logs in/out, refetch bookings.
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        fetchBookings(authState.user.uid);
      } else {
        // If user logs out, clear the list
        emit(const CustomerBookingsLoaded([]));
      }
    });

    // Handle the initial state
    if (_authCubit.state is AuthAuthenticated) {
      fetchBookings((_authCubit.state as AuthAuthenticated).user.uid);
    }
  }

  void fetchBookings(String customerId) {
    _bookingSubscription?.cancel();
    _bookingSubscription = _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: customerId) // THE KEY QUERY
        .orderBy('date', descending: true)
        .snapshots() // Use snapshots for real-time updates
        .listen((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => Booking.fromFirestore(doc.data(), doc.id))
          .toList();
      emit(CustomerBookingsLoaded(bookings));
    }, onError: (error) {
      emit(CustomerBookingsError(error.toString()));
    });
  }

  @override
  Future<void> close() {
    _bookingSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}