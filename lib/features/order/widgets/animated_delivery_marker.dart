import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/helper/position_interpolator.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

/// Controller for managing animated delivery marker
class AnimatedMarkerController extends ChangeNotifier {
  final PositionInterpolator _interpolator = PositionInterpolator();
  AnimationController? _animationController;
  LatLng _displayPosition = const LatLng(0, 0);
  bool _isAnimating = false;

  /// Initialize with animation controller from a StatefulWidget
  void init(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );

    _animationController!.addListener(() {
      _displayPosition = _interpolator.interpolate(_animationController!.value);
      notifyListeners();
    });
  }

  /// Update marker position with smooth animation
  void animateToPosition(LatLng newPosition) {
    if (_animationController == null) return;

    _interpolator.updatePosition(newPosition);

    if (!_isAnimating) {
      _isAnimating = true;
      _animationController!.forward(from: 0).then((_) {
        _isAnimating = false;
        _displayPosition = newPosition;
        notifyListeners();
      });
    }
  }

  /// Set position immediately without animation (for initial load)
  void setPosition(LatLng position) {
    _interpolator.updatePosition(position);
    _displayPosition = position;
    notifyListeners();
  }

  /// Get current display position (interpolated during animation)
  LatLng get displayPosition => _displayPosition;

  /// Get current bearing for marker rotation
  double get bearing => _interpolator.bearing;

  /// Check if rider is moving
  bool get isMoving => _interpolator.isMoving;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

/// Animated pulse effect widget for the rider marker
class RiderPulseAnimation extends StatefulWidget {
  final bool isActive;
  final Color color;

  const RiderPulseAnimation({
    super.key,
    this.isActive = true,
    this.color = const Color(0xFFDA281C),
  });

  @override
  State<RiderPulseAnimation> createState() => _RiderPulseAnimationState();
}

class _RiderPulseAnimationState extends State<RiderPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RiderPulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 60 * _scaleAnimation.value,
          height: 60 * _scaleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_opacityAnimation.value),
          ),
        );
      },
    );
  }
}

/// Custom marker icon widget for the rider
class RiderMarkerWidget extends StatelessWidget {
  final String? imageUrl;
  final bool isMoving;
  final double bearing;

  const RiderMarkerWidget({
    super.key,
    this.imageUrl,
    this.isMoving = false,
    this.bearing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse effect when moving
          if (isMoving)
            Positioned(
              bottom: 20,
              child: RiderPulseAnimation(
                isActive: isMoving,
                color: const Color(0xFFDA281C),
              ),
            ),

          // Rider icon container
          Positioned(
            bottom: 0,
            child: Transform.rotate(
              angle: bearing * 3.14159 / 180,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFDA281C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),

          // Direction indicator arrow
          if (isMoving)
            Positioned(
              top: 0,
              child: Transform.rotate(
                angle: bearing * 3.14159 / 180,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDA281C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    HeroiconsSolid.arrowUp,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper class to create Google Maps marker from widget
class MarkerGenerator {
  /// Generate a BitmapDescriptor for the rider marker
  static Future<BitmapDescriptor> createRiderMarker({
    bool isMoving = false,
  }) async {
    // Use default marker with custom hue for now
    // In production, you could render a widget to image
    return BitmapDescriptor.defaultMarkerWithHue(
      isMoving ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
    );
  }
}

/// Mixin for StatefulWidget to easily integrate animated marker
mixin AnimatedMarkerMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimatedMarkerController _markerController;

  AnimatedMarkerController get markerController => _markerController;

  void initAnimatedMarker() {
    _markerController = AnimatedMarkerController();
    _markerController.init(this);
  }

  void disposeAnimatedMarker() {
    _markerController.dispose();
  }
}
