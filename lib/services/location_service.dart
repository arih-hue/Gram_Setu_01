import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Fetches the current location and returns a Map containing village, block, and fullLocation.
  /// Throws an error message if fetching fails or permission is denied.
  static Future<Map<String, String>> getCurrentLocationData() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable them in settings.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied. Please enable them in app settings.';
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // Reverse geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw 'Fetch timed out. Weak GPS signal.',
    );

    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      
      // Build structured location
      String village = place.locality ?? place.subAdministrativeArea ?? place.name ?? 'Unknown Village';
      String block = place.subLocality ?? place.administrativeArea ?? 'Unknown Block';
      String fullLocation = "$village, $block";

      return {
        'village': village,
        'block': block,
        'fullLocation': fullLocation
      };
    }
    
    throw 'No address found for these coordinates.';
  }

  // Backward compatibility
  static Future<String> getCurrentLocation() async {
    final data = await getCurrentLocationData();
    return data['fullLocation']!;
  }
}
