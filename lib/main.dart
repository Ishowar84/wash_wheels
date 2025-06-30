
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wash_wheels/auth/cubit/role_cubit.dart';
import 'package:wash_wheels/features/customer/customer_home_scaffold.dart';
import 'package:wash_wheels/features/provider/provider_home_scaffold.dart';

import 'auth/cubit/auth_cubit.dart';
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

// THIS WIDGET IS THE KEY - WE ARE FIXING IT HERE
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // CHANGED: We now handle each state explicitly

        if (state is AuthAuthenticated) {
          // If the user is logged in, show the role-based home page
          return const RoleBasedHomePage();
        }

        if (state is AuthUnauthenticated || state is AuthError) {
          // If the user is logged out or an error occurred, show the login page
          return const LoginPage();
        }

        // NEW: While the state is AuthInitial, show a loading screen.
        // This is the most important change and fixes the white screen.
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}


class RoleBasedHomePage extends StatelessWidget {
  const RoleBasedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleCubit, UserRole>(
      builder: (context, role) {
        if (role == UserRole.provider) {
          return const ProviderHomeScaffold();
        }
        return const CustomerHomeScaffold();
      },
    );
  }
}