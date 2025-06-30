// lib/auth/cubit/auth_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthCubit(this._firebaseAuth) : super(AuthInitial()) {
    // Listen to authentication state changes
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      // The listener above will automatically emit AuthAuthenticated
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown error occurred.'));
      // Reset to unauthenticated after showing error
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    emit(AuthUnauthenticated());
  }
}