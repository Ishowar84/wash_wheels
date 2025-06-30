// lib/auth/cubit/auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// When the app is checking for auth status (e.g., at startup)
class AuthInitial extends AuthState {}

// When the user is trying to log in
class AuthLoading extends AuthState {}

// When the user is successfully logged in
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

// When the user is not logged in or has logged out
class AuthUnauthenticated extends AuthState {}

// When an error occurs during authentication
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}