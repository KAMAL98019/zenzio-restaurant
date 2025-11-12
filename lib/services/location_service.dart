import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  /// Default location: New Delhi, India 🇮🇳
  static const LatLng defaultLocation = LatLng(28.6139, 77.2090);

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current GPS location of the device
  Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location services are disabled.');
        return null;
      }

      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        debugPrint('⚠️ Location permissions are denied.');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Get formatted address for given coordinates
  /// If outside India, will fallback to 'India' context
  Future<String> getAddressFromCoordinates(LatLng location) async {
    debugPrint(
      "📍 getAddressFromCoordinates called with: ${location.latitude}, ${location.longitude}",
    );

    try {
      // Check platform
      if (kIsWeb) {
        return "Reverse geocoding not supported on Web";
      }

      // Reverse geocode coordinates
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        debugPrint("🗺️ Placemark found: ${place.toString()}");

        // Enforce India ISO filter
        if (place.isoCountryCode != 'IN') {
          debugPrint('🌍 Location outside India. Using default Indian context.');
          return 'India';
        }

        // Build a readable address
        final List<String> addressParts = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
          place.postalCode,
        ]
            .whereType<String>()
            .where((e) => e.trim().isNotEmpty)
            .toList();

        final String formattedAddress = addressParts.join(', ');

        debugPrint("🗺️ Formatted Indian address: $formattedAddress");
        return formattedAddress.isNotEmpty
            ? formattedAddress
            : 'Unknown Location in India';
      } else {
        return 'Unknown Location in India';
      }
    } catch (e) {
      debugPrint('❌ Error in reverse geocoding: $e');
      return 'Unable to fetch address in India';
    }
  }

  /// Track live movement of user
  Stream<Position> trackLiveLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Calculate distance between two coordinates (in KM)
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000;
  }
}
