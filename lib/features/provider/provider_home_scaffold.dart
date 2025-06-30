import 'package:flutter/material.dart';
import 'package:wash_wheels/features/common/profile_page.dart';
import 'package:wash_wheels/features/provider/provider_schedule_page.dart';

class ProviderHomeScaffold extends StatefulWidget {
  const ProviderHomeScaffold({super.key});
  @override
  State<ProviderHomeScaffold> createState() => _ProviderHomeScaffoldState();
}

class _ProviderHomeScaffoldState extends State<ProviderHomeScaffold> {
  int _selectedIndex = 0;
  static List<Widget> _pages = <Widget>[ProviderSchedulePage(), const ProfilePage()];
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}