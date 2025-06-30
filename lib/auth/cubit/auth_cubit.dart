import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:wash_wheels/core/models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<firebase_auth.User?>? _userSubscription;

  AuthCubit(this._firebaseAuth) : super(AuthInitial()) {
    _userSubscription = _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          final userProfile = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userProfile.exists) {
            final appUser = User.fromFirestore(userProfile.data()!, firebaseUser.uid);
            emit(AuthAuthenticated(appUser));
          } else {
            await signOut();
            emit(const AuthError("User profile not found. Please sign up again."));
          }
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown sign-in error occurred.'));
    }
  }

  // --- THIS IS THE MODIFIED METHOD ---
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String displayName, // NEW: Added displayName parameter
  }) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // --- NEW: Add displayName to the Firestore document ---
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': email,
          'displayName': displayName, // ADDED THIS LINE
          'role': role == UserRole.provider ? 'provider' : 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
        // The listener will automatically log the user in.
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown sign-up error occurred.'));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}