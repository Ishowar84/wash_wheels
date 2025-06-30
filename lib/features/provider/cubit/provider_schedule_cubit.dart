import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';
import 'package:wash_wheels/core/models/booking.dart';

// --- CUBIT STATES ---
abstract class ProviderScheduleState extends Equatable {
  const ProviderScheduleState();
  @override
  List<Object> get props => [];
}

class ProviderScheduleLoading extends ProviderScheduleState {}

class ProviderScheduleLoaded extends ProviderScheduleState {
  final List<Booking> bookings;
  const ProviderScheduleLoaded(this.bookings);
  @override
  List<Object> get props => [bookings];
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
    // Listen to auth changes to refetch data on login/logout
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        fetchSchedule(authState.user.uid);
      } else {
        emit(const ProviderScheduleLoaded([])); // Clear schedule on logout
      }
    });

    // Handle the initial state when the cubit is created
    if (_authCubit.state is AuthAuthenticated) {
      fetchSchedule((_authCubit.state as AuthAuthenticated).user.uid);
    }
  }

  void fetchSchedule(String providerId) {
    _bookingSubscription?.cancel();
    _bookingSubscription = _firestore
        .collection('bookings')
    // THIS IS THE KEY QUERY FOR PROVIDERS
        .where('providerId', isEqualTo: providerId)
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress']) // Only show active jobs
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => Booking.fromFirestore(doc.data(), doc.id))
          .toList();
      emit(ProviderScheduleLoaded(bookings));
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