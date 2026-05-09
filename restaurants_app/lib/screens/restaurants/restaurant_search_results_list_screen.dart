import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../controllers/search_controller.dart' as search_ctrl;
import '../../services/location_service.dart';
import '../../widgets/error_message_widget.dart';
import 'restaurant_details_screen.dart';

class RestaurantSearchResultsListScreen extends StatefulWidget {
  final search_ctrl.SearchController controller;

  const RestaurantSearchResultsListScreen({
    super.key,
    required this.controller,
  });

  @override
  State<RestaurantSearchResultsListScreen> createState() =>
      _RestaurantSearchResultsListScreenState();
}

class _RestaurantSearchResultsListScreenState
    extends State<RestaurantSearchResultsListScreen> {
  late search_ctrl.SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  void _navigateToDetails(int restaurantId) {
    final restaurant = _controller.searchResultsStream.value.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => null as dynamic,
    );
    if (restaurant != null) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Results'), elevation: 0),
      body: StreamBuilder<List<dynamic>>(
        stream: Rx.combineLatest3(
          _controller.searchResultsStream,
          _controller.distancesStream,
          _controller.loadingStream,
          (results, distances, loading) => [results, distances, loading],
        ),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = data[0] as List;
          final isLoading = data[2] as bool;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No restaurants found',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different product',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Search'),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<String?>(
            stream: _controller.errorStream,
            builder: (_, errorSnapshot) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (errorSnapshot.data != null)
                      Column(
                        children: [
                          ErrorMessageWidget(errorMessage: errorSnapshot.data),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final restaurant = results[index];
                        final distance = _controller.getDistanceToRestaurant(
                          restaurant,
                        );
                        final distanceText = distance != null
                            ? LocationService.formatDistance(distance)
                            : 'Distance N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _navigateToDetails(restaurant.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Restaurant icon
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.teal[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 40,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Restaurant info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              distanceText,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _navigateToDetails(restaurant.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'View Details',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
