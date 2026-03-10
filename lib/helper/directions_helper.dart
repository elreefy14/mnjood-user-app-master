import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Helper for fetching road-following routes from Google APIs.
///
/// Tries Routes API (new) first, then legacy Directions API, then straight line.
/// - In-memory cache keyed by origin+destination (rounded to ~11m precision)
/// - Route splitting at rider's nearest point
/// - Off-route detection (>200m threshold)
/// - Graceful fallback to straight lines on any error
class DirectionsHelper {
  static const String _apiKey = 'AIzaSyCt4nSQ4hlr7K5jQ5c3U3wuCmsGUnBQuhc';
  static const double _offRouteThresholdMeters = 200.0;
  static const int _coordPrecision = 4; // ~11m precision

  /// In-memory route cache: "lat,lng|lat,lng" -> List<LatLng>
  static final Map<String, List<LatLng>> _cache = {};

  /// Build a cache key from two positions, rounded for stability.
  static String _cacheKey(LatLng origin, LatLng destination) {
    final oLat = origin.latitude.toStringAsFixed(_coordPrecision);
    final oLng = origin.longitude.toStringAsFixed(_coordPrecision);
    final dLat = destination.latitude.toStringAsFixed(_coordPrecision);
    final dLng = destination.longitude.toStringAsFixed(_coordPrecision);
    return '$oLat,$oLng|$dLat,$dLng';
  }

  /// Fetch route points. Tries Routes API (new), then Directions API (legacy).
  /// Returns cached result if available; falls back to straight line on error.
  static Future<List<LatLng>> getRoutePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    final key = _cacheKey(origin, destination);

    // Return from cache
    if (_cache.containsKey(key)) {
      debugPrint('DirectionsHelper: cache hit ($key) — ${_cache[key]!.length} points');
      return _cache[key]!;
    }

    debugPrint('DirectionsHelper: cache miss, fetching route for $key');

    // Try Routes API (new — Google recommended)
    List<LatLng>? points = await _fetchFromRoutesApi(origin, destination);

    // Fallback: try legacy Directions API
    points ??= await _fetchFromDirectionsApi(origin, destination);

    if (points != null && points.length >= 2) {
      _cache[key] = points;
      return points;
    }

    // Final fallback: straight line (NOT cached — so next call retries the API)
    debugPrint('DirectionsHelper: all APIs failed, using straight line (not cached)');
    return [origin, destination];
  }

  /// Google Routes API (new) — POST endpoint
  static Future<List<LatLng>?> _fetchFromRoutesApi(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final url = Uri.parse(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
      );

      final body = json.encode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            },
          },
        },
        'travelMode': 'DRIVE',
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final encoded =
              routes[0]['polyline']?['encodedPolyline'] as String?;
          if (encoded != null && encoded.isNotEmpty) {
            debugPrint('DirectionsHelper: Routes API OK (${encoded.length} chars)');
            return decodePolyline(encoded);
          }
        }
      }
      debugPrint('DirectionsHelper: Routes API HTTP ${response.statusCode} — ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
    } catch (e) {
      debugPrint('DirectionsHelper: Routes API error: $e');
    }
    return null;
  }

  /// Legacy Google Directions API — GET endpoint
  static Future<List<LatLng>?> _fetchFromDirectionsApi(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_apiKey',
      );

      final response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final encoded =
              data['routes'][0]['overview_polyline']['points'] as String;
          debugPrint('DirectionsHelper: Directions API OK (${encoded.length} chars)');
          return decodePolyline(encoded);
        }
        debugPrint('DirectionsHelper: Directions API status=${data['status']}');
      } else {
        debugPrint('DirectionsHelper: Directions API HTTP ${response.statusCode} — ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
      }
    } catch (e) {
      debugPrint('DirectionsHelper: Directions API error: $e');
    }
    return null;
  }

  /// Decode a Google encoded polyline string into a list of LatLng.
  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Split a route at the rider's nearest point.
  /// Returns (completedPoints, remainingPoints).
  static ({List<LatLng> completed, List<LatLng> remaining}) splitRouteAtRider(
    List<LatLng> routePoints,
    LatLng riderPosition,
  ) {
    if (routePoints.length < 2) {
      return (completed: routePoints, remaining: routePoints);
    }

    int nearestIndex = 0;
    double minDist = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final dist = _haversineMeters(riderPosition, routePoints[i]);
      if (dist < minDist) {
        minDist = dist;
        nearestIndex = i;
      }
    }

    // Include the rider's actual position for visual accuracy
    final completed = [
      ...routePoints.sublist(0, nearestIndex + 1),
      riderPosition,
    ];
    final remaining = [
      riderPosition,
      ...routePoints.sublist(nearestIndex + 1),
    ];

    return (completed: completed, remaining: remaining);
  }

  /// Check minimum distance from rider to any route point.
  static double distanceToRoute(
    List<LatLng> routePoints,
    LatLng riderPosition,
  ) {
    if (routePoints.isEmpty) return double.infinity;

    double minDist = double.infinity;
    for (final point in routePoints) {
      final dist = _haversineMeters(riderPosition, point);
      if (dist < minDist) {
        minDist = dist;
      }
    }
    return minDist;
  }

  /// Returns true if rider is off-route (>200m from nearest route point).
  static bool isOffRoute(List<LatLng> routePoints, LatLng riderPosition) {
    return distanceToRoute(routePoints, riderPosition) >
        _offRouteThresholdMeters;
  }

  /// Clear all cached routes. Call on screen dispose.
  static void clearCache() {
    _cache.clear();
  }

  /// Haversine distance in meters between two LatLng points.
  static double _haversineMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final sinLat = math.sin(dLat / 2);
    final sinLng = math.sin(dLng / 2);
    final h = sinLat * sinLat +
        math.cos(_toRad(a.latitude)) *
            math.cos(_toRad(b.latitude)) *
            sinLng *
            sinLng;
    return earthRadius * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
