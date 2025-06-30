import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // The AppBar is now in the home scaffolds, so we don't need one here.
      // We wrap the body in a BlocBuilder to get the latest auth state.
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // --- THIS IS THE KEY ---
          // We only build the profile UI if the user is authenticated.
          if (state is AuthAuthenticated) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // User's Email Tile
                Card(
                  color: theme.colorScheme.secondary,
                  child: ListTile(
                    leading: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                    title: const Text('Email'),
                    subtitle: Text(
                      state.user.email ?? 'No email provided', // Safely access the user's email
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                // User's Role Tile
                Card(
                  color: theme.colorScheme.secondary,
                  child: ListTile(
                    leading: Icon(Icons.verified_user_outlined, color: theme.colorScheme.primary),
                    title: const Text('Account Type'),
                    subtitle: Text(
                      // Capitalize the first letter of the role for display
                      state.user.role.name[0].toUpperCase() + state.user.role.name.substring(1),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- SIGN OUT BUTTON ---
                // We don't need a sign-out button here anymore because it's
                // in the AppBar of the home scaffolds. This simplifies the page.
                // If you *want* a button here, you can uncomment this:
                /*
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // This calls the same signOut method
                    context.read<AuthCubit>().signOut();
                  },
                  child: const Text('Sign Out'),
                ),
                */
              ],
            );
          }

          // If the state is not authenticated for some reason,
          // show a fallback to prevent crashing.
          return const Center(
            child: Text('Not logged in.'),
          );
        },
      ),
    );
  }
}