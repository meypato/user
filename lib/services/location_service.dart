import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling location operations using the Geolocator plugin
/// Provides location permission management, position acquisition, and distance calculations
class LocationService {
  // Private constructor to prevent instantiation
  LocationService._();

  /// Check if location services are enabled on the device
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location permission status using permission_handler
  static Future<PermissionStatus> getLocationPermissionStatus() async {
    return await Permission.location.status;
  }

  /// Check if we have location permission
  static Future<bool> hasLocationPermission() async {
    final status = await getLocationPermissionStatus();
    return status.isGranted;
  }

  /// Request location permission from the user using permission_handler
  static Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status;
  }

  /// Check if location permission is permanently denied
  static Future<bool> isLocationPermissionPermanentlyDenied() async {
    final status = await getLocationPermissionStatus();
    return status.isPermanentlyDenied;
  }

  /// Get detailed permission status information
  static Future<LocationPermissionInfo> getDetailedPermissionInfo() async {
    final locationStatus = await Permission.location.status;
    final serviceEnabled = await isLocationServiceEnabled();

    return LocationPermissionInfo(
      permissionStatus: locationStatus,
      serviceEnabled: serviceEnabled,
      canRequest: !locationStatus.isPermanentlyDenied,
      shouldShowRationale: locationStatus.isDenied,
    );
  }

  /// Get the current position of the device
  /// Returns null if location services are disabled or permission denied
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw LocationServiceDisabledException();
      }

      // Check/request permission using permission_handler
      PermissionStatus permission = await getLocationPermissionStatus();

      if (permission.isDenied) {
        permission = await requestLocationPermission();
        if (permission.isDenied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission.isPermanentlyDenied) {
        throw LocationPermissionPermanentlyDeniedException();
      }

      // Get current position using new LocationSettings
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit ?? const Duration(seconds: 15),
        ),
      );
    } catch (e) {
      // Log error in production, for now just return null
      return null;
    }
  }

  /// Get the last known position (faster but potentially less accurate)
  /// Returns null if no cached position is available
  static Future<Position?> getLastKnownPosition() async {
    try {
      if (!await hasLocationPermission()) {
        return null;
      }

      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Get position with fallback strategy:
  /// 1. Try to get last known position (fast)
  /// 2. If not available or too old, get current position
  static Future<Position?> getPositionWithFallback({
    Duration maxAge = const Duration(minutes: 5),
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // First try to get last known position
      final lastPosition = await getLastKnownPosition();

      if (lastPosition != null) {
        final age = DateTime.now().difference(lastPosition.timestamp);
        if (age <= maxAge) {
          return lastPosition;
        }
      }

      // Fall back to current position
      return await getCurrentPosition(accuracy: accuracy);
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two geographic points using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate distance between a position and coordinates
  /// Returns distance in kilometers
  static double calculateDistanceFromPosition(
    Position position,
    double lat,
    double lon,
  ) {
    return calculateDistance(
      position.latitude,
      position.longitude,
      lat,
      lon,
    );
  }

  /// Get formatted distance string for UI display
  /// Examples: "1.2 km", "0.8 km", "15.3 km"
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return "${(distanceKm * 1000).round()} m";
    } else if (distanceKm < 10.0) {
      return "${distanceKm.toStringAsFixed(1)} km";
    } else {
      return "${distanceKm.round()} km";
    }
  }

  /// Check if coordinates are within a specified radius
  /// Useful for filtering nearby locations
  static bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radiusKm;
  }

  /// Sort a list of coordinates by distance from a reference point
  /// Returns a list of maps with original index and calculated distance
  static List<Map<String, dynamic>> sortLocationsByDistance(
    double referenceLat,
    double referenceLon,
    List<Map<String, double>> locations, // [{lat: double, lon: double}]
  ) {
    final List<Map<String, dynamic>> locationsWithDistance = [];

    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      final distance = calculateDistance(
        referenceLat,
        referenceLon,
        location['lat']!,
        location['lon']!,
      );

      locationsWithDistance.add({
        'index': i,
        'lat': location['lat'],
        'lon': location['lon'],
        'distance': distance,
      });
    }

    // Sort by distance (ascending)
    locationsWithDistance.sort((a, b) =>
      (a['distance'] as double).compareTo(b['distance'] as double));

    return locationsWithDistance;
  }

  /// Open device location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app-specific settings where user can enable location permissions
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Utility method to convert degrees to radians
  static double _toRadians(double degree) => degree * (math.pi / 180.0);

  /// Get location accuracy description for UI
  static String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return "Lowest accuracy (~3000m)";
      case LocationAccuracy.low:
        return "Low accuracy (~1000m)";
      case LocationAccuracy.medium:
        return "Medium accuracy (~100m)";
      case LocationAccuracy.high:
        return "High accuracy (~10m)";
      case LocationAccuracy.best:
        return "Best accuracy (~3m)";
      case LocationAccuracy.bestForNavigation:
        return "Navigation accuracy (~1m)";
      default:
        return "Unknown accuracy";
    }
  }
}

/// Helper class to store location permission information
class LocationPermissionInfo {
  final PermissionStatus permissionStatus;
  final bool serviceEnabled;
  final bool canRequest;
  final bool shouldShowRationale;

  LocationPermissionInfo({
    required this.permissionStatus,
    required this.serviceEnabled,
    required this.canRequest,
    required this.shouldShowRationale,
  });

  bool get hasPermission => permissionStatus.isGranted;
  bool get isDenied => permissionStatus.isDenied;
  bool get isPermanentlyDenied => permissionStatus.isPermanentlyDenied;
  bool get canShowRationale => isDenied && shouldShowRationale;

  String get statusDescription {
    if (permissionStatus.isGranted) return 'Permission granted';
    if (permissionStatus.isPermanentlyDenied) return 'Permission permanently denied';
    if (permissionStatus.isDenied) return 'Permission denied';
    if (permissionStatus.isRestricted) return 'Permission restricted';
    if (permissionStatus.isLimited) return 'Permission limited';
    return 'Permission status unknown';
  }

  @override
  String toString() {
    return 'LocationPermissionInfo(status: ${permissionStatus.name}, serviceEnabled: $serviceEnabled)';
  }
}

/// Exception classes for better error handling
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([this.message = 'Location services are disabled']);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException([this.message = 'Location permission denied']);

  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  LocationPermissionPermanentlyDeniedException([
    this.message = 'Location permission permanently denied'
  ]);

  @override
  String toString() => 'LocationPermissionPermanentlyDeniedException: $message';
}

/// Helper class to store location data with additional metadata
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final double? altitude;
  final double? heading;
  final double? speed;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.altitude,
    this.heading,
    this.speed,
  });

  /// Create LocationData from Geolocator Position
  factory LocationData.fromPosition(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
    );
  }

  /// Calculate distance to another location
  double distanceTo(LocationData other) {
    return LocationService.calculateDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Check if this location is within radius of another location
  bool isWithinRadiusOf(LocationData other, double radiusKm) {
    return distanceTo(other) <= radiusKm;
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lon: $longitude, accuracy: ${accuracy}m)';
  }
}