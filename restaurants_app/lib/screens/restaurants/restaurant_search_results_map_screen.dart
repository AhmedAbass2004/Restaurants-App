import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';

import '../../controllers/search_controller.dart' as search_ctrl;
import '../../services/location_service.dart';
import 'restaurant_details_screen.dart';

class RestaurantSearchResultsMapScreen extends StatefulWidget {
  final search_ctrl.SearchController controller;

  const RestaurantSearchResultsMapScreen({super.key, required this.controller});

  @override
  State<RestaurantSearchResultsMapScreen> createState() =>
      _RestaurantSearchResultsMapScreenState();
}

class _RestaurantSearchResultsMapScreenState
    extends State<RestaurantSearchResultsMapScreen> {
  late search_ctrl.SearchController _controller;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _mapController = MapController();
    // Defer fitBounds until after first frame to avoid "widget not rendered" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapBounds();
    });
  }

  void _fitMapBounds() {
    final userLoc = _controller.userLocation;
    final results = _controller.searchResultsStream.value;

    if (userLoc == null || results.isEmpty) return;

    final points = <LatLng>[
      LatLng(userLoc.latitude, userLoc.longitude),
      ...results
          .where((r) => r.latitude != null && r.longitude != null)
          .map((r) => LatLng(r.latitude!, r.longitude!)),
    ];

    if (points.isNotEmpty) {
      // Calculate center of all points
      double avgLat = 0, avgLon = 0;
      for (final point in points) {
        avgLat += point.latitude;
        avgLon += point.longitude;
      }
      avgLat /= points.length;
      avgLon /= points.length;

      // Move to center with appropriate zoom
      _mapController.move(LatLng(avgLat, avgLon), 13);
    }
  }

  void _navigateToDetails(int restaurantId) {
    final index = _controller.searchResultsStream.value.indexWhere(
      (restaurant) => restaurant.id == restaurantId,
    );
    if (index == -1) return;

    final restaurant = _controller.searchResultsStream.value[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailsScreen(
          restaurant: restaurant,
          distance: _controller.getDistanceToRestaurant(restaurant),
          userLocation: _controller.userLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results (Map)'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fitMapBounds,
            tooltip: 'Fit bounds',
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: Rx.combineLatest2(
          _controller.searchResultsStream,
          _controller.userLocationStream,
          (results, userLocation) => [results, userLocation],
        ),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final results = data[0];
          final userLocation = data[1];

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No restaurants found',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLocation != null
                      ? LatLng(userLocation.latitude, userLocation.longitude)
                      : const LatLng(30.0444, 31.2357), // Cairo default
                  initialZoom: 13,
                  maxZoom: 18,
                  minZoom: 3,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.restaurants_app',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      // User location marker
                      if (userLocation != null)
                        Marker(
                          point: LatLng(
                            userLocation.latitude,
                            userLocation.longitude,
                          ),
                          width: 60,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Restaurant markers
                      ...results
                          .where(
                            (r) => r.latitude != null && r.longitude != null,
                          )
                          .map(
                            (restaurant) => Marker(
                              point: LatLng(
                                restaurant.latitude!,
                                restaurant.longitude!,
                              ),
                              width: 50,
                              height: 50,
                              child: GestureDetector(
                                onTap: () => _navigateToDetails(restaurant.id),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.teal.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    Tooltip(
                                      message: restaurant.name,
                                      child: const SizedBox(height: 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ],
              ),

              // Bottom sheet with restaurant list
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${results.length} restaurants found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final restaurant = results[index];
                            final distance = _controller
                                .getDistanceToRestaurant(restaurant);
                            final distanceText = distance != null
                                ? LocationService.formatDistance(distance)
                                : 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _navigateToDetails(restaurant.id),
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          restaurant.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              distanceText,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
