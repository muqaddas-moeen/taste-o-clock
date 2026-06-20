import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';

/// Device GPS + reverse geocoding.
class LocationService {
  Future<UserLocationModel> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException(
        code: 'location_disabled',
        message: 'Location services are disabled. Enable GPS and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const AppException(
        code: 'location_denied',
        message: 'Location permission is required for delivery.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AppException(
        code: 'location_denied_forever',
        message: 'Location permission is permanently denied. Enable it in settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return _buildLocationModel(position);
  }

  Future<UserLocationModel> _buildLocationModel(Position position) async {
    var location = UserLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      updatedAt: DateTime.now(),
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        location = location.copyWith(
          addressLine: _joinNonEmpty([
            place.street,
            place.subLocality,
            place.name,
          ]),
          city: place.locality ?? place.subAdministrativeArea,
          state: place.administrativeArea,
          postalCode: place.postalCode,
          country: place.country,
        );
      }
    } catch (_) {
      // Coordinates are still useful even if reverse geocoding fails.
    }

    return location;
  }

  String? _joinNonEmpty(List<String?> parts) {
    final filtered = parts
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toSet()
        .toList();

    if (filtered.isEmpty) return null;
    return filtered.join(', ');
  }
}
