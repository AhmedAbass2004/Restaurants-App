import 'package:flutter/material.dart';

import '../../controllers/restaurant_controller.dart';
import '../../models/product.dart';
import '../../models/restaurant.dart';

class RestaurantProductsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantProductsScreen({super.key, required this.restaurant});

  @override
  State<RestaurantProductsScreen> createState() =>
      _RestaurantProductsScreenState();
}

class _RestaurantProductsScreenState extends State<RestaurantProductsScreen> {
  final RestaurantController _restaurantController = RestaurantController();

  @override
  void initState() {
    super.initState();
    _restaurantController.loadProductsForRestaurant(widget.restaurant.id);
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.restaurant.name} - Products'),
        elevation: 0,
      ),
      body: StreamBuilder<bool>(
        stream: _restaurantController.loadingStream,
        builder: (context, loadingSnapshot) {
          final isLoading = loadingSnapshot.data ?? false;

          return StreamBuilder<String?>(
            stream: _restaurantController.errorStream,
            builder: (context, errorSnapshot) {
              final error = errorSnapshot.data;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () => _restaurantController.loadProductsForRestaurant(
                              widget.restaurant.id,
                            ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return StreamBuilder<List<Product>>(
                stream: _restaurantController.productsStream,
                builder: (context, productsSnapshot) {
                  final products = productsSnapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Text('No products available for this restaurant'),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.description != null)
                                Text(product.description!),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: product.description != null,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
