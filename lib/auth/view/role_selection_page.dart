import 'package:flutter/material.dart';
import 'package:wash_wheels/auth/view/signup_page.dart';
import 'package:wash_wheels/core/models/user.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Join WashWheels'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'First, tell us who you are.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            _RoleButton(
              theme: theme,
              icon: Icons.directions_car_filled,
              title: "I'm a Car Owner",
              subtitle: 'I want to book a car wash.',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SignUpPage(role: UserRole.customer),
                ));
              },
            ),
            const SizedBox(height: 24),
            _RoleButton(
              theme: theme,
              icon: Icons.store,
              title: "I'm a Service Provider",
              subtitle: 'I want to offer car wash services.',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SignUpPage(role: UserRole.provider),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}