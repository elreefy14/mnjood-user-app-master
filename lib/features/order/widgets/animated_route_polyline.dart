import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/helper/position_interpolator.dart';

/// Widget that manages animated route polyline between points
class AnimatedRouteController extends ChangeNotifier {
  List<LatLng> _routePoints = [];
  double _progress = 0.0; // 0.0 to 1.0
  AnimationController? _animationController;

  /// Initialize the route with points
  void setRoute(List<LatLng> points) {
    _routePoints = points;
    notifyListeners();
  }

  /// Set route from rider position to destination
  void setSimpleRoute(LatLng from, LatLng to) {
    _routePoints = [from, to];
    notifyListeners();
  }

  /// Initialize animation controller
  void init(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController!.addListener(() {
      _progress = _animationController!.value;
      notifyListeners();
    });
  }

  /// Animate the route drawing
  void animateRoute() {
    _animationController?.forward(from: 0);
  }

  /// Update progress based on rider position
  void updateProgress(LatLng riderPosition, LatLng destination) {
    if (_routePoints.isEmpty) return;

    final totalDistance = PositionInterpolator.calculateDistance(
      _routePoints.first,
      destination,
    );

    final coveredDistance = PositionInterpolator.calculateDistance(
      _routePoints.first,
      riderPosition,
    );

    _progress = (coveredDistance / totalDistance).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Get the completed portion of the route
  List<LatLng> get completedRoute {
    if (_routePoints.length < 2) return _routePoints;

    final pointIndex = (_progress * (_routePoints.length - 1)).floor();
    return _routePoints.sublist(0, pointIndex + 1);
  }

  /// Get the remaining portion of the route
  List<LatLng> get remainingRoute {
    if (_routePoints.length < 2) return _routePoints;

    final pointIndex = (_progress * (_routePoints.length - 1)).floor();
    return _routePoints.sublist(pointIndex);
  }

  /// Get all route points
  List<LatLng> get routePoints => _routePoints;

  /// Get current progress
  double get progress => _progress;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

/// Build polylines for the tracking map
class RoutePolylineBuilder {
  static const Color brandPrimary = Color(0xFFff9e1b);
  static const Color brandPrimaryLight = Color(0x40ff9e1b);
  static const Color completedColor = Color(0xFFE53935);

  /// Create polylines for tracking display
  static Set<Polyline> buildTrackingPolylines({
    required LatLng restaurantPosition,
    required LatLng riderPosition,
    required LatLng destinationPosition,
    required String orderStatus,
  }) {
    final polylines = <Polyline>{};

    // Restaurant to Rider (completed path - if rider picked up)
    if (orderStatus == 'picked_up' || orderStatus == 'handover') {
      // Completed segment: restaurant → rider (solid green)
      polylines.add(
        Polyline(
          polylineId: const PolylineId('completed_route'),
          points: [restaurantPosition, riderPosition],
          color: completedColor,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );

      // Remaining segment: rider → destination (dashed primary)
      polylines.add(
        Polyline(
          polylineId: const PolylineId('remaining_route'),
          points: [riderPosition, destinationPosition],
          color: brandPrimary,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        ),
      );
    } else {
      // Before pickup - show full route from restaurant to destination
      polylines.add(
        Polyline(
          polylineId: const PolylineId('full_route'),
          points: [restaurantPosition, destinationPosition],
          color: brandPrimary,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          patterns: [
            PatternItem.dash(15),
            PatternItem.gap(10),
          ],
        ),
      );
    }

    return polylines;
  }

  /// Create polylines from pre-computed road route segments.
  /// Used with [DirectionsHelper] for road-following routes.
  static Set<Polyline> buildRoadRoutePolylines({
    required List<LatLng> completedPoints,
    required List<LatLng> remainingPoints,
    required String orderStatus,
  }) {
    final polylines = <Polyline>{};

    if (orderStatus == 'picked_up' || orderStatus == 'handover') {
      // Completed segment: restaurant → rider (solid green, road-following)
      if (completedPoints.length >= 2) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('completed_route'),
            points: completedPoints,
            color: completedColor,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }

      // Remaining segment: rider → destination (dashed primary, road-following)
      if (remainingPoints.length >= 2) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('remaining_route'),
            points: remainingPoints,
            color: brandPrimary,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10),
            ],
          ),
        );
      }
    } else {
      // Before pickup - show full remaining route (restaurant → destination)
      if (remainingPoints.length >= 2) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('full_route'),
            points: remainingPoints,
            color: brandPrimary,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [
              PatternItem.dash(15),
              PatternItem.gap(10),
            ],
          ),
        );
      }
    }

    return polylines;
  }

  /// Create animated polyline that draws progressively
  static Polyline buildAnimatedPolyline({
    required List<LatLng> points,
    required double progress,
    required String polylineId,
  }) {
    if (points.isEmpty) {
      return Polyline(
        polylineId: PolylineId(polylineId),
        points: const [],
      );
    }

    // Calculate how many points to show based on progress
    final visiblePointCount = (points.length * progress).ceil().clamp(1, points.length);
    final visiblePoints = points.sublist(0, visiblePointCount);

    return Polyline(
      polylineId: PolylineId(polylineId),
      points: visiblePoints,
      color: brandPrimary,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  /// Create a pulsing effect polyline (for active delivery)
  static List<Polyline> buildPulsingPolyline({
    required LatLng from,
    required LatLng to,
    required double pulseValue, // 0.0 to 1.0 from animation
  }) {
    return [
      // Outer glow
      Polyline(
        polylineId: const PolylineId('route_glow'),
        points: [from, to],
        color: brandPrimary.withOpacity(0.3 * (1 - pulseValue)),
        width: (8 + pulseValue * 4).toInt(),
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
      // Main line
      Polyline(
        polylineId: const PolylineId('route_main'),
        points: [from, to],
        color: brandPrimary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    ];
  }
}

/// Widget to display progress bar for delivery journey
class DeliveryProgressBar extends StatelessWidget {
  final double progress;
  final String startLabel;
  final String endLabel;

  const DeliveryProgressBar({
    super.key,
    required this.progress,
    this.startLabel = 'Picked Up',
    this.endLabel = 'Delivered',
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            return SizedBox(
              height: 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track background
                  Positioned(
                    left: 0, right: 0, top: 5,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Animated fill
                  Positioned(
                    left: 0, top: 5,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: barWidth * progress.clamp(0.0, 1.0),
                      height: 6,
                      decoration: BoxDecoration(
                        color: brandColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Dot indicator
                  Positioned(
                    left: (barWidth * progress.clamp(0.0, 1.0)) - 8,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: brandColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              startLabel,
              style: TextStyle(
                fontSize: 12,
                color: progress > 0 ? brandColor : Colors.grey,
                fontWeight: progress > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              endLabel,
              style: TextStyle(
                fontSize: 12,
                color: progress >= 1.0 ? brandColor : Colors.grey,
                fontWeight: progress >= 1.0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
