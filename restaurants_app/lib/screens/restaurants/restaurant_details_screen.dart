import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/restaurant.dart';
import '../../services/location_service.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant restaurant;
  final double? distance;
  final Position? userLocation;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurant,
    this.distance,
    this.userLocation,
  });

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  Future<void> _openDirections() async {
    if (widget.restaurant.latitude == null ||
        widget.restaurant.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant location not available')),
      );
      return;
    }

    final lat = widget.restaurant.latitude!;
    final lon = widget.restaurant.longitude!;
    final restaurantName = Uri.encodeComponent(widget.restaurant.name);

    try {
      final candidates = <Uri>[
        Uri.parse('geo:$lat,$lon?q=$restaurantName'),
        Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
        ),
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon'),
      ];

      for (final uri in candidates) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening directions: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = widget.distance != null
        ? LocationService.formatDistance(widget.distance!)
        : 'Distance unavailable';

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Details'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with restaurant icon
            Container(
              color: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.restaurant, size: 60, color: Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.restaurant.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Information cards
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Distance card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.teal,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Distance from Your Location',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            distanceText,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          if (widget.userLocation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Your location: ${widget.userLocation!.latitude.toStringAsFixed(4)}, '
                                '${widget.userLocation!.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location details card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                color: Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Restaurant Location',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (widget.restaurant.address != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.restaurant.address!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          Text(
                            'Coordinates',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Latitude: ${widget.restaurant.latitude?.toStringAsFixed(6) ?? 'N/A'}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Longitude: ${widget.restaurant.longitude?.toStringAsFixed(6) ?? 'N/A'}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Directions button
                  if (widget.restaurant.latitude != null &&
                      widget.restaurant.longitude != null)
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _openDirections,
                        icon: const Icon(Icons.directions),
                        label: const Text(
                          'Open Directions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // Back button
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back to Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
