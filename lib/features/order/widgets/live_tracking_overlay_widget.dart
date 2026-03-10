import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/order/widgets/animated_route_polyline.dart';
import 'package:mnjood/helper/position_interpolator.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Live tracking overlay widget showing rider info, ETA, and progress
class LiveTrackingOverlayWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final LatLng? riderPosition;
  final LatLng? destinationPosition;
  final String orderStatus;
  final int orderId;
  final VoidCallback? onCallPressed;
  final VoidCallback? onChatPressed;

  const LiveTrackingOverlayWidget({
    super.key,
    required this.deliveryMan,
    required this.riderPosition,
    required this.destinationPosition,
    required this.orderStatus,
    required this.orderId,
    this.onCallPressed,
    this.onChatPressed,
  });

  @override
  State<LiveTrackingOverlayWidget> createState() => _LiveTrackingOverlayWidgetState();
}

class _LiveTrackingOverlayWidgetState extends State<LiveTrackingOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_isRiderOnTheWay) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveTrackingOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isRiderOnTheWay && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_isRiderOnTheWay && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isRiderOnTheWay =>
      widget.orderStatus == 'picked_up' || widget.orderStatus == 'handover';

  double get _distance {
    if (widget.riderPosition == null || widget.destinationPosition == null) {
      return 0;
    }
    return PositionInterpolator.calculateDistance(
      widget.riderPosition!,
      widget.destinationPosition!,
    );
  }

  int get _etaMinutes {
    if (widget.riderPosition == null || widget.destinationPosition == null) {
      return 0;
    }
    return PositionInterpolator.calculateETAMinutes(
      widget.riderPosition!,
      widget.destinationPosition!,
    );
  }

  double get _progress {
    // This would need the restaurant position for accurate progress
    // For now, estimate based on ETA
    if (_etaMinutes <= 0) return 1.0;
    if (_etaMinutes >= 30) return 0.1;
    return 1.0 - (_etaMinutes / 30);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deliveryMan == null || !_isRiderOnTheWay) {
      return const SizedBox.shrink();
    }

    final brandColor = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: brandColor.withOpacity(0.1 + (_pulseAnimation.value * 0.1)),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rider Info Section
              _buildRiderInfoSection(context),

              // Divider
              Divider(color: Colors.grey.withOpacity(0.2), height: 1),

              // Progress Section
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: DeliveryProgressBar(
                  progress: _progress,
                  startLabel: 'picked_up'.tr,
                  endLabel: 'arriving'.tr,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiderInfoSection(BuildContext context) {
    final brandColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          // Rider Avatar with pulse
          Stack(
            children: [
              // Pulse effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 60 + (_pulseAnimation.value * 8),
                    height: 60 + (_pulseAnimation.value * 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brandColor.withOpacity(0.1 * (1 - _pulseAnimation.value)),
                    ),
                  );
                },
              ),
              // Avatar
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: brandColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: widget.deliveryMan?.imageFullUrl != null
                          ? CustomImageWidget(
                              image: widget.deliveryMan!.imageFullUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: brandColor.withOpacity(0.1),
                              child: Icon(
                                Icons.delivery_dining,
                                color: brandColor,
                                size: 26,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Rider Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and status
                Row(
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      size: 16,
                      color: brandColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.deliveryMan?.fName ?? ''} ${'is_on_the_way'.tr}',
                        style: robotoBold.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Rating and distance
                Row(
                  children: [
                    // Rating
                    if (widget.deliveryMan?.avgRating != null) ...[
                      Icon(
                        HeroiconsSolid.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.deliveryMan!.avgRating!.toStringAsFixed(1),
                        style: robotoMedium.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Distance
                    Icon(
                      HeroiconsSolid.mapPin,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      PositionInterpolator.formatDistance(_distance),
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ETA Countdown
                ETACountdownWidget(
                  initialMinutes: _etaMinutes,
                  key: ValueKey('eta_$_etaMinutes'),
                ),
              ],
            ),
          ),

          // Action buttons
          Column(
            children: [
              // Call button
              _buildActionButton(
                context: context,
                icon: HeroiconsSolid.phone,
                onTap: () => _makePhoneCall(widget.deliveryMan?.phone),
              ),
              const SizedBox(height: 8),
              // Chat button
              _buildActionButton(
                context: context,
                icon: HeroiconsSolid.chatBubbleLeftRight,
                onTap: () => _openChat(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final brandColor = Theme.of(context).primaryColor;

    return Material(
      color: brandColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: brandColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openChat() {
    if (widget.deliveryMan == null) return;

    Get.toNamed(
      RouteHelper.getChatRoute(
        notificationBody: null,
        conversationID: null,
        index: 0, // delivery man
      ),
    );
  }
}

/// Compact version of the tracking overlay for bottom sheet
class CompactTrackingCard extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  final int etaMinutes;
  final double distance;
  final VoidCallback? onTap;

  const CompactTrackingCard({
    super.key,
    required this.deliveryMan,
    required this.etaMinutes,
    required this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (deliveryMan == null) return const SizedBox.shrink();

    final brandColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: brandColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: brandColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Rider icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: brandColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${deliveryMan?.fName ?? 'Rider'} ${'is_on_the_way'.tr}',
                    style: robotoBold.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${PositionInterpolator.formatETA(etaMinutes)} • ${PositionInterpolator.formatDistance(distance)}',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              HeroiconsOutline.chevronRight,
              color: brandColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// ETA Countdown Timer Widget with pulsing animation
class ETACountdownWidget extends StatefulWidget {
  final int initialMinutes;

  const ETACountdownWidget({
    super.key,
    required this.initialMinutes,
  });

  @override
  State<ETACountdownWidget> createState() => _ETACountdownWidgetState();
}

class _ETACountdownWidgetState extends State<ETACountdownWidget>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialMinutes * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // Start pulsing when ETA < 5 minutes
        if (_remainingSeconds <= 300 && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
          // Haptic feedback when entering urgent zone
          HapticFeedback.mediumImpact();
        }

        // Haptic when arriving
        if (_remainingSeconds == 60) {
          HapticFeedback.heavyImpact();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(ETACountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMinutes != widget.initialMinutes) {
      _remainingSeconds = widget.initialMinutes * 60;
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    if (_remainingSeconds < 60) {
      return 'arriving_now'.tr;
    }
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isUrgent => _remainingSeconds <= 300 && _remainingSeconds > 0;
  bool get _isArriving => _remainingSeconds < 60;

  @override
  Widget build(BuildContext context) {
    final brandColor = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isUrgent ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isArriving
                  ? Colors.green.withOpacity(0.15)
                  : _isUrgent
                      ? brandColor.withOpacity(0.2)
                      : brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: _isUrgent || _isArriving
                  ? Border.all(
                      color: _isArriving
                          ? Colors.green
                          : brandColor,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isArriving
                      ? HeroiconsSolid.checkCircle
                      : HeroiconsSolid.clock,
                  size: 16,
                  color: _isArriving ? Colors.green : brandColor,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isArriving)
                      Text(
                        'eta'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      _formattedTime,
                      style: robotoBold.copyWith(
                        fontSize: _isArriving ? 13 : 14,
                        color: _isArriving
                            ? Colors.green
                            : brandColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
