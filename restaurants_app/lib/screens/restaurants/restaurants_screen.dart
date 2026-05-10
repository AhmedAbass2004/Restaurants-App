import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/restaurant_controller.dart';
import '../../models/restaurant.dart';
import '../auth/login_screen.dart';
import 'restaurant_details_screen.dart';
import 'restaurants_search_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final AuthController _authController = AuthController();
  final RestaurantController _restaurantController = RestaurantController();

  @override
  void initState() {
    super.initState();
    _restaurantController.loadRestaurants();
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    _restaurantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants & Cafes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantsSearchScreen(),
                ),
              );
            },
            tooltip: 'Search Products',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
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
                        onPressed: _restaurantController.loadRestaurants,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return StreamBuilder<List<Restaurant>>(
                stream: _restaurantController.restaurantsStream,
                builder: (context, restaurantsSnapshot) {
                  final restaurants = restaurantsSnapshot.data ?? [];

                  if (restaurants.isEmpty) {
                    return const Center(child: Text('No restaurants found'));
                  }

                  return ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal[100],
                            child: const Icon(Icons.restaurant, color: Colors.teal),
                          ),
                          title: Text(
                            restaurant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(restaurant.address ?? 'No address'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RestaurantDetailsScreen(
                                      restaurant: restaurant,
                                    ),
                              ),
                            );
                          },
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
