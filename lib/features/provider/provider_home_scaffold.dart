import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';
import 'package:wash_wheels/features/common/profile_page.dart';
import 'package:wash_wheels/features/provider/cubit/provider_schedule_cubit.dart'; // <-- IMPORT THE NEW CUBIT
import 'package:wash_wheels/features/provider/provider_schedule_page.dart';

class ProviderHomeScaffold extends StatefulWidget {
  const ProviderHomeScaffold({super.key});
  @override
  State<ProviderHomeScaffold> createState() => _ProviderHomeScaffoldState();
}

class _ProviderHomeScaffoldState extends State<ProviderHomeScaffold> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = ['My Schedule', 'My Profile'];

  // The page list remains the same. Use const for better performance.
  static final List<Widget> _pages = <Widget>[
    const ProviderSchedulePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE KEY CHANGE ---
    // We provide the ProviderScheduleCubit here, making it available
    // to the ProviderSchedulePage.
    return BlocProvider(
      create: (context) => ProviderScheduleCubit(
        // The cubit needs the AuthCubit to know which provider is logged in.
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_selectedIndex]),
          backgroundColor: const Color(0xFF3E3C63),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF3E3C63),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
      ),
    );
  }
}