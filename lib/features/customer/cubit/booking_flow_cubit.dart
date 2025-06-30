import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:wash_wheels/core/models/booking.dart';
import 'package:wash_wheels/core/models/service_package.dart';
import 'package:wash_wheels/core/models/user.dart';

// --- State class remains the same ---
class BookingFlowState extends Equatable {
  // ... no changes needed in the state class
  final List<ServicePackage> packages;
  final List<User> providers;
  final ServicePackage? selectedPackage;
  final User? selectedProvider;
  final DateTime? selectedDateTime;
  final String? selectedLocation;
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final bool isCheckingAvailability;
  final String? availabilityMessage;

  const BookingFlowState({
    this.packages = const [],
    this.providers = const [],
    this.selectedPackage,
    this.selectedProvider,
    this.selectedDateTime,
    this.selectedLocation,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.isCheckingAvailability = false,
    this.availabilityMessage,
  });

  BookingFlowState copyWith({
    List<ServicePackage>? packages,
    List<User>? providers,
    ServicePackage? selectedPackage,
    User? selectedProvider,
    DateTime? selectedDateTime,
    String? selectedLocation,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool? isCheckingAvailability,
    String? availabilityMessage,
    bool clearAvailabilityMessage = false,
  }) {
    return BookingFlowState(
      packages: packages ?? this.packages,
      providers: providers ?? this.providers,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      isCheckingAvailability: isCheckingAvailability ?? this.isCheckingAvailability,
      availabilityMessage: clearAvailabilityMessage ? null : availabilityMessage ?? this.availabilityMessage,
    );
  }

  @override
  List<Object?> get props => [
    packages, providers, selectedPackage, selectedProvider, selectedDateTime,
    selectedLocation, isLoading, isSuccess, error, isCheckingAvailability, availabilityMessage
  ];
}


// --- THE UPGRADED CUBIT WITH DEBUGGING ---
class BookingFlowCubit extends Cubit<BookingFlowState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingFlowCubit() : super(const BookingFlowState()) {
    fetchInitialData();
  }

  // Combines initial data fetching
  Future<void> fetchInitialData() async {
    emit(state.copyWith(isLoading: true));

    // --- ADDED DEBUGGING ---
    print("[CUBIT_DEBUG] Starting to fetch initial data...");
    try {
      // Fetch packages
      final packageSnapshot = await _firestore.collection('service_packages').get();
      print("[CUBIT_DEBUG] Firestore snapshot for 'service_packages' received. Number of documents: ${packageSnapshot.docs.length}");

      final packages = packageSnapshot.docs
          .map((doc) => ServicePackage.fromFirestore(doc.data(), doc.id))
          .toList();
      print("[CUBIT_DEBUG] Successfully mapped ${packages.length} packages.");

      // Fetch providers
      print("[CUBIT_DEBUG] Fetching providers...");
      final providerSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'provider').get();
      print("[CUBIT_DEBUG] Firestore snapshot for 'users' (providers) received. Number of documents: ${providerSnapshot.docs.length}");

      final providers = providerSnapshot.docs
          .map((doc) => User.fromFirestore(doc.data(), doc.id))
          .toList();
      print("[CUBIT_DEBUG] Successfully mapped ${providers.length} providers.");

      emit(state.copyWith(packages: packages, providers: providers, isLoading: false));
    } catch (e) {
      // This will now print the exact error to your console!
      print("[CUBIT_DEBUG] !!! AN ERROR OCCURRED: $e");
      emit(state.copyWith(error: "Failed to load services or providers.", isLoading: false));
    }
  }

  // ... rest of the cubit methods remain unchanged ...
  void selectPackage(ServicePackage package) => emit(state.copyWith(selectedPackage: package));
  void selectLocation(String location) => emit(state.copyWith(selectedLocation: location));
  void selectProvider(User provider) {
    emit(state.copyWith(selectedProvider: provider, clearAvailabilityMessage: true));
    _checkAvailability();
  }
  void selectDateTime(DateTime dateTime) {
    emit(state.copyWith(selectedDateTime: dateTime, clearAvailabilityMessage: true));
    _checkAvailability();
  }
  Future<void> _checkAvailability() async {
    if (state.selectedProvider == null || state.selectedDateTime == null) {
      return;
    }

    emit(state.copyWith(isCheckingAvailability: true, availabilityMessage: "Checking..."));

    final providerId = state.selectedProvider!.uid;
    final dateTime = state.selectedDateTime!;

    final snapshot = await _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('date', isEqualTo: Timestamp.fromDate(dateTime))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      emit(state.copyWith(isCheckingAvailability: false, availabilityMessage: "Slot is unavailable."));
    } else {
      emit(state.copyWith(isCheckingAvailability: false, availabilityMessage: "Slot is available!"));
    }
  }
  Future<void> confirmBooking({required String customerId}) async {
    if (state.selectedPackage == null || state.selectedDateTime == null || state.selectedLocation == null || state.selectedProvider == null) {
      emit(state.copyWith(error: "Please complete all selections."));
      return;
    }
    if (state.availabilityMessage != "Slot is available!") {
      emit(state.copyWith(error: "Please select an available time slot."));
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final newBooking = Booking(
        id: '',
        customerId: customerId,
        providerId: state.selectedProvider!.uid,
        serviceName: state.selectedPackage!.name,
        price: state.selectedPackage!.price,
        date: state.selectedDateTime!,
        location: state.selectedLocation!,
        status: BookingStatus.pending,
      );

      await _firestore.collection('bookings').add(newBooking.toJson());
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: "Failed to confirm booking."));
    }
  }
}