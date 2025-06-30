import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';
import 'package:wash_wheels/auth/cubit/role_cubit.dart';
import 'package:wash_wheels/core/models/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // An AppBar gives us a nice back button automatically
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
              );
          }
          // If signup is successful, AuthWrapper will handle navigation,
          // so we can just pop this page off the stack.
          if (state is AuthAuthenticated) {
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('I am a...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  const _RoleSelector(), // Re-using the role selector widget
                  const SizedBox(height: 32),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration(label: 'Email', icon: Icons.email_outlined, theme: theme),
                    validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration(label: 'Password', icon: Icons.lock_outline, theme: theme),
                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration(label: 'Confirm Password', icon: Icons.lock_clock_outlined, theme: theme),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final selectedRole = context.read<RoleCubit>().state;
                            context.read<AuthCubit>().signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              role: selectedRole,
                            );
                          }
                        },
                        child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// --- These helper widgets can be moved to a shared file later ---

class _RoleSelector extends StatelessWidget {
  const _RoleSelector();
  @override
  Widget build(BuildContext context) {
    final selectedRole = context.watch<RoleCubit>().state;
    final theme = Theme.of(context);
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.customer, label: Text('Customer')),
        ButtonSegment(value: UserRole.provider, label: Text('Provider')),
      ],
      selected: {selectedRole},
      onSelectionChanged: (newSelection) => context.read<RoleCubit>().selectRole(newSelection.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white70,
        selectedBackgroundColor: theme.colorScheme.primary,
        selectedForegroundColor: Colors.white,
      ),
    );
  }
}

InputDecoration _inputDecoration({required String label, required IconData icon, required ThemeData theme}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: Colors.white70),
    filled: true,
    fillColor: theme.colorScheme.secondary.withOpacity(0.5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
  );
}