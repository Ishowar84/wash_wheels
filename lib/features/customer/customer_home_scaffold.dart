import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wash_wheels/auth/cubit/auth_cubit.dart';
import 'package:wash_wheels/features/customer/book_service_page.dart';
import 'package:wash_wheels/features/customer/cubit/customer_bookings_cubit.dart'; // <-- IMPORT THE NEW CUBIT
import 'package:wash_wheels/features/customer/marketplace_page.dart';
import 'package:wash_wheels/features/common/profile_page.dart';

import 'booking_lists_page.dart';

class CustomerHomeScaffold extends StatefulWidget {
  const CustomerHomeScaffold({super.key});

  @override
  State<CustomerHomeScaffold> createState() => _CustomerHomeScaffoldState();
}

class _CustomerHomeScaffoldState extends State<CustomerHomeScaffold> {
  int _selectedIndex = 0;

  // The pages list remains the same
  static final List<Widget> _pages = <Widget>[
    BookServicePage(),
    const BookingsListPage(), // Use const here since the page itself is stateless
    MarketplacePage(),
    const ProfilePage(),
  ];

  static const List<String> _pageTitles = [
    'Book a Wash',
    'My Bookings',
    'Marketplace',
    'My Profile'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE KEY CHANGE ---
    // We provide the CustomerBookingsCubit here.
    return BlocProvider(
      create: (context) => CustomerBookingsCubit(
        // The cubit needs the AuthCubit, which we can get from the context
        // because it was provided in main.dart.
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
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF3E3C63),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.car_rental_outlined),
              label: 'Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: 'My Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}