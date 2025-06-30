import 'package:flutter/material.dart';
import 'package:wash_wheels/core/models/product.dart';

class MarketplacePage extends StatelessWidget {
  MarketplacePage({super.key});

  // Mock data
  final List<Product> products =  [
    Product(id: 'p1', name: 'Microfiber Towel Set', imageUrl: 'https://picsum.photos/seed/towel/200', price: 19.99),
    Product(id: 'p2', name: 'Premium Car Wax', imageUrl: 'https://picsum.photos/seed/wax/200', price: 24.50),
    Product(id: 'p3', name: 'Tire Shine Spray', imageUrl: 'https://picsum.photos/seed/tire/200', price: 12.99),
    Product(id: 'p4', name: 'Interior Cleaner', imageUrl: 'https://picsum.photos/seed/cleaner/200', price: 15.00),
    Product(id: 'p5', name: 'Leather Conditioner', imageUrl: 'https://picsum.photos/seed/leather/200', price: 22.00),
    Product(id: 'p6', name: 'Wheel Brush', imageUrl: 'https://picsum.photos/seed/brush/200', price: 9.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessory Shop'), backgroundColor: const Color(0xFF3E3C63)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            color: const Color(0xFF3E3C63),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(bottom: 8.0),
                  child: Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}