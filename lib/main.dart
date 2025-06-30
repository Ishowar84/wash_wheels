import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wash_wheels/core/models/user.dart'; // <-- IMPORTANT: Import user model for UserRole
import 'package:wash_wheels/features/customer/customer_home_scaffold.dart';
import 'package:wash_wheels/features/provider/provider_home_scaffold.dart';

import 'auth/cubit/auth_cubit.dart';
import 'auth/cubit/role_cubit.dart';
import 'auth/view/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(FirebaseAuth.instance)),
        BlocProvider(create: (context) => RoleCubit()),
      ],
      child: MaterialApp(
        title: 'WashWheels',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF2C2B4B),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8A2BE2),
            secondary: Color(0xFF3E3C63),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// THIS IS THE CORRECTED ROUTING LOGIC
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the AuthCubit's state changes here
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // If the user is successfully authenticated...
        if (state is AuthAuthenticated) {
          // ...we check the role from the user object inside the state
          if (state.user.role == UserRole.provider) {
            return const ProviderHomeScaffold();
          } else {
            return const CustomerHomeScaffold();
          }
        }

        // If the user is unauthenticated...
        if (state is AuthUnauthenticated) {
          return const LoginPage();
        }

        // For any other state (AuthInitial, AuthLoading, AuthError),
        // we show a loading screen. This prevents flashes of the wrong screen.
        // The LoginPage will show the specific error message if the state is AuthError.
        return const Scaffold(
          backgroundColor: Color(0xFF2C2B4B),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}