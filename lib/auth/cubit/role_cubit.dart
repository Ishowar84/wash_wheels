import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Define the possible roles a user can have.
// This enum provides type-safe roles, preventing typos like "costumer" or "pro-vider".
enum UserRole {
  customer,
  provider,
}

// 2. Create the Cubit class.
// A Cubit is the simplest form of a BLoC. It stores a single state
// and has functions to emit new states.
class RoleCubit extends Cubit<UserRole> {
  // 3. Set the initial state in the constructor.
  // When the app starts, we default to the 'customer' view.
  // We use `super()` to pass the initial state to the parent Cubit class.
  RoleCubit() : super(UserRole.customer);

  // 4. Create a public function to change the state.
  // The UI will call this function when the user toggles the switch.
  // The `emit()` function sends out the new state to any widgets that are listening.
  void setRole(UserRole newRole) {
    emit(newRole);
  }
}