import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  /// Request location permission from the user.
  /// Returns true if permission is granted, false otherwise.
  static Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        return result == LocationPermission.whileInUse ||
            result == LocationPermission.always;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Get current device location.
  /// Returns Position if successful, null if permission denied or error occurs.
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } on TimeoutException {
      // Try with lower accuracy if timeout
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
        return position;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two points using Haversine formula.
  /// Returns distance in kilometers.
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadiusKm * c;
  }

  /// Convert degrees to radians.
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Format distance for display (e.g., "2.5 km", "150 m").
  static String formatDistance(double distanceKm) {
    if (distanceKm < 0.1) {
      final meters = (distanceKm * 1000).toStringAsFixed(0);
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
