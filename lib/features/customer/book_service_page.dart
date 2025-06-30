import 'package:flutter/material.dart';
import 'package:wash_wheels/core/models/service_package.dart';

class BookServicePage extends StatelessWidget {
   BookServicePage({super.key});

  // Mock data - In the future, this will come from a database
  final List<ServicePackage> servicePackages = [
    ServicePackage(id: '1', name: 'Express Wash', description: 'Exterior wash and dry.', price: 25.00),
    ServicePackage(id: '2', name: 'Deluxe Detail', description: 'Exterior wash, wax, and interior vacuum.', price: 75.00),
    ServicePackage(id: '3', name: 'Ultimate Shine', description: 'Full exterior and interior detail with tire shine.', price: 150.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Wash'), backgroundColor: const Color(0xFF3E3C63)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Select a Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...servicePackages.map((package) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF3E3C63),
            child: ListTile(
              title: Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(package.description, style: const TextStyle(color: Colors.white70)),
              trailing: Text('\$${package.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              onTap: () {
                // TODO: Handle package selection
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${package.name} selected!')));
              },
            ),
          )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () { /* TODO: Show date time picker */ },
            icon: const Icon(Icons.calendar_today_outlined),
            label: const Text('Choose Date & Time'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF3E3C63),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { /* TODO: Finalize booking */ },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF8A2BE2),
            ),
            child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}