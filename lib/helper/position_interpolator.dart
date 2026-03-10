import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper class for smooth position interpolation between API updates
/// Used for animating delivery rider marker movement
class PositionInterpolator {
  LatLng? _previousPosition;
  LatLng? _currentPosition;
  DateTime? _lastUpdateTime;
  double _bearing = 0;
  double _speed = 0; // meters per second

  /// Update with new position from API
  void updatePosition(LatLng newPosition) {
    _previousPosition = _currentPosition;
    _currentPosition = newPosition;

    if (_previousPosition != null && _currentPosition != null) {
      // Calculate bearing (direction)
      _bearing = calculateBearing(_previousPosition!, _currentPosition!);

      // Calculate speed based on time and distance
      if (_lastUpdateTime != null) {
        final elapsed = DateTime.now().difference(_lastUpdateTime!).inSeconds;
        if (elapsed > 0) {
          final distance = calculateDistance(_previousPosition!, _currentPosition!);
          _speed = distance / elapsed;
        }
      }
    }

    _lastUpdateTime = DateTime.now();
  }

  /// Get interpolated position between previous and current
  /// [progress] should be 0.0 to 1.0
  LatLng interpolate(double progress) {
    if (_previousPosition == null || _currentPosition == null) {
      return _currentPosition ?? const LatLng(0, 0);
    }

    final lat = _lerpDouble(
      _previousPosition!.latitude,
      _currentPosition!.latitude,
      progress,
    );
    final lng = _lerpDouble(
      _previousPosition!.longitude,
      _currentPosition!.longitude,
      progress,
    );

    return LatLng(lat, lng);
  }

  /// Calculate bearing (direction) between two points in degrees
  static double calculateBearing(LatLng start, LatLng end) {
    final startLat = _toRadians(start.latitude);
    final startLng = _toRadians(start.longitude);
    final endLat = _toRadians(end.latitude);
    final endLng = _toRadians(end.longitude);

    final dLng = endLng - startLng;

    final x = math.sin(dLng) * math.cos(endLat);
    final y = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    final bearing = math.atan2(x, y);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371000.0; // meters

    final dLat = _toRadians(end.latitude - start.latitude);
    final dLng = _toRadians(end.longitude - start.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(start.latitude)) *
            math.cos(_toRadians(end.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculate ETA in minutes based on distance and average speed
  static int calculateETAMinutes(LatLng from, LatLng to, {double avgSpeedKmh = 30}) {
    final distanceKm = calculateDistance(from, to) / 1000;
    final timeHours = distanceKm / avgSpeedKmh;
    return (timeHours * 60).round();
  }

  /// Format distance for display
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Format ETA for display
  static String formatETA(int minutes) {
    if (minutes < 1) {
      return 'Arriving';
    } else if (minutes == 1) {
      return '1 min';
    } else if (minutes < 60) {
      return '$minutes mins';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours hr ${mins > 0 ? '$mins min' : ''}';
    }
  }

  /// Get current bearing (direction rider is facing)
  double get bearing => _bearing;

  /// Get current speed in m/s
  double get speed => _speed;

  /// Get current position
  LatLng? get currentPosition => _currentPosition;

  /// Get previous position
  LatLng? get previousPosition => _previousPosition;

  /// Check if rider is moving (speed > 1 m/s)
  bool get isMoving => _speed > 1;

  // Helper methods
  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Extension for LatLng to make calculations easier
extension LatLngExtension on LatLng {
  /// Calculate distance to another point in meters
  double distanceTo(LatLng other) {
    return PositionInterpolator.calculateDistance(this, other);
  }

  /// Calculate bearing to another point in degrees
  double bearingTo(LatLng other) {
    return PositionInterpolator.calculateBearing(this, other);
  }
}
