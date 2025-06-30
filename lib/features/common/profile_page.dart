import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';


import '../../auth/cubit/role_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user info from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF3E3C63),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF8A2BE2),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user?.email ?? 'No email found', style: const TextStyle(fontSize: 20))),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Manage My Vehicles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* TODO: Navigate to vehicle management page */ },
          ),
          ListTile(
            leading: const Icon(Icons.payment_outlined),
            title: const Text('Payment Options'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* TODO: Navigate to payment options page */ },
          ),
          ListTile(
            leading: const Icon(Icons.loyalty_outlined),
            title: const Text('Loyalty & Subscription'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* TODO: Navigate to subscription page */ },
          ),
          const Divider(),
          // This is a temporary button for development to test the other UI
          SwitchListTile(
            title: const Text('View as Service Provider'),
            secondary: const Icon(Icons.switch_account_outlined),
            value: context.watch<RoleCubit>().state == UserRole.provider,
            onChanged: (isProvider) {
              context.read<RoleCubit>().setRole(isProvider ? UserRole.provider : UserRole.customer);
            },
          )
        ],
      ),
    );
  }
}