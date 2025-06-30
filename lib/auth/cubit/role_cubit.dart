import 'package:bloc/bloc.dart';
import 'package:wash_wheels/core/models/user.dart'; // <-- Import the user model here

// The RoleCubit is only responsible for tracking the UI selection on the login page.
// It defaults to UserRole.customer.
class RoleCubit extends Cubit<UserRole> {
  RoleCubit() : super(UserRole.customer);

  // This is the method the login page was looking for.
  // It takes a new role and emits it as the new state.
  void selectRole(UserRole role) {
    emit(role);
  }
}