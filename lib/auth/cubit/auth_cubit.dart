import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:wash_wheels/core/models/user.dart'; // <-- IMPORT YOUR CUSTOM MODEL

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  StreamSubscription<firebase_auth.User?>? _userSubscription;

  AuthCubit(this._firebaseAuth) : super(AuthInitial()) {
    // Listen to authentication state changes
    _userSubscription = _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // User is logged in, now fetch their role from Firestore
        try {
          final userProfile = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userProfile.exists) {
            // Create our custom User model
            final appUser = User.fromFirestore(userProfile.data()!, firebaseUser.uid);
            emit(AuthAuthenticated(appUser));
          } else {
            // This case happens if a user exists in Auth but not Firestore.
            // This is an error state, so we log them out.
            await signOut();
            emit(const AuthError("User profile not found. Please sign up again."));
          }
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      } else {
        // User is logged out
        emit(AuthUnauthenticated());
      }
    });
  }

  // MODIFIED: signIn now doesn't need to do anything after success,
  // the listener will handle it.
  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      // The listener will automatically fetch the role and emit AuthAuthenticated
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown sign-in error occurred.'));
    }
  }

  // NEW: A separate method for signing up a new user.
  // This creates the user in Auth AND creates their profile in Firestore.
  Future<void> signUp({required String email, required String password, required UserRole role}) async {
    emit(AuthLoading());
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // 2. Create user profile in Firestore with the role
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': email,
          'role': role == UserRole.provider ? 'provider' : 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
        // The listener will now pick up the new user and log them in automatically.
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown sign-up error occurred.'));
    }
  }


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // The listener will automatically emit AuthUnauthenticated
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}