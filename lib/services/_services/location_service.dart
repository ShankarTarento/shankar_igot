import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _currentPosition;

  Future<LocationPermission> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return permission;
      }
    }
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return permission;
    }
    return permission;
  }

  Future<Position?> getCurrentPosition() async {
    final LocationPermission permission = await handleLocationPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return null;
    Position? position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings)
            .then((Position position) {
      _currentPosition = position;
      return _currentPosition;
    }).catchError((e) {
      throw e;
    });
    return position;
  }

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1000,
  );

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  bool isValidLocationRange({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    double distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );

    return distanceInMeters <= 1000.0;
  }
}
