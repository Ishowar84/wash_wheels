import 'package:equatable/equatable.dart';

// Use the enum you already have for roles
enum UserRole { customer, provider, unknown }

class User extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final UserRole role;

  const User({
    required this.uid,
    this.email,
    this.displayName,
    this.role = UserRole.unknown,
  });

  // Helper to create a User object from a Firestore document
  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      // Convert the string role from Firestore to the UserRole enum
      role: (data['role'] == 'provider') ? UserRole.provider : UserRole.customer,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, role];
}