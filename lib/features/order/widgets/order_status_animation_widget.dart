import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/util/styles.dart';

/// Design system colors
const Color _primaryOrange = Color(0xFFff9e1b);
const Color _successGreen = Color(0xFF2ECC71);
const Color _errorRed = Color(0xFFE84D4F);

/// Widget to display animated order status
class OrderStatusAnimationWidget extends StatefulWidget {
  final String orderStatus;
  final bool showLabel;

  const OrderStatusAnimationWidget({
    super.key,
    required this.orderStatus,
    this.showLabel = true,
  });

  @override
  State<OrderStatusAnimationWidget> createState() => _OrderStatusAnimationWidgetState();
}

class _OrderStatusAnimationWidgetState extends State<OrderStatusAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(OrderStatusAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderStatus != widget.orderStatus) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(widget.orderStatus);

    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon container — larger with gradient
            Transform.scale(
              scale: _bounceAnimation.value * _pulseAnimation.value,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: statusData.color.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusData.color.withValues(alpha:0.25),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          statusData.color,
                          statusData.color.withValues(alpha:0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusData.icon,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),

            if (widget.showLabel) ...[
              const SizedBox(height: 20),
              Text(
                statusData.label.tr,
                style: robotoBold.copyWith(
                  fontSize: 17,
                  color: statusData.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusData.description.tr,
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }

  _StatusData _getStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'accepted':
      case 'confirmed':
        return _StatusData(
          icon: HeroiconsSolid.checkCircle,
          label: 'order_confirmed',
          description: 'restaurant_preparing_order',
          color: _primaryOrange,
        );
      case 'processing':
        return _StatusData(
          icon: HeroiconsSolid.fire,
          label: 'preparing_order',
          description: 'your_food_is_being_prepared',
          color: _primaryOrange,
        );
      case 'handover':
        return _StatusData(
          icon: HeroiconsSolid.handRaised,
          label: 'ready_for_pickup',
          description: 'order_ready_for_delivery',
          color: _primaryOrange,
        );
      case 'picked_up':
        return _StatusData(
          icon: Icons.delivery_dining,
          label: 'on_the_way',
          description: 'rider_is_delivering_your_order',
          color: _primaryOrange,
        );
      case 'delivered':
        return _StatusData(
          icon: HeroiconsSolid.checkBadge,
          label: 'delivered',
          description: 'enjoy_your_meal',
          color: _successGreen,
        );
      case 'canceled':
      case 'cancelled':
        return _StatusData(
          icon: HeroiconsSolid.xCircle,
          label: 'order_cancelled',
          description: 'your_order_was_cancelled',
          color: _errorRed,
        );
      case 'failed':
        return _StatusData(
          icon: HeroiconsSolid.exclamationTriangle,
          label: 'order_failed',
          description: 'something_went_wrong',
          color: _errorRed,
        );
      default:
        return _StatusData(
          icon: HeroiconsSolid.questionMarkCircle,
          label: status,
          description: '',
          color: Colors.grey,
        );
    }
  }
}

class _StatusData {
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  _StatusData({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });
}

/// Horizontal stepper showing order progress with animations and labels
class AnimatedOrderStepper extends StatefulWidget {
  final String currentStatus;
  final int? etaMinutes;

  const AnimatedOrderStepper({
    super.key,
    required this.currentStatus,
    this.etaMinutes,
  });

  @override
  State<AnimatedOrderStepper> createState() => _AnimatedOrderStepperState();
}

class _AnimatedOrderStepperState extends State<AnimatedOrderStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _connectorAnimation;

  final List<Map<String, String>> _stepData = [
    {'key': 'confirmed', 'label': 'confirmed', 'icon': 'checkCircle'},
    {'key': 'processing', 'label': 'preparing_order', 'icon': 'fire'},
    {'key': 'picked_up', 'label': 'on_the_way', 'icon': 'truck'},
    {'key': 'delivered', 'label': 'delivered', 'icon': 'home'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _connectorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedOrderStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStatus != widget.currentStatus) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _currentStepIndex {
    switch (widget.currentStatus.toLowerCase()) {
      case 'pending':
      case 'accepted':
      case 'confirmed':
        return 0;
      case 'processing':
        return 1;
      case 'handover':
      case 'picked_up':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stepper circles and connectors
          Row(
            children: List.generate(_stepData.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connector line
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < _currentStepIndex;
                final isActive = stepIndex == _currentStepIndex;

                return Expanded(
                  child: AnimatedBuilder(
                    animation: _connectorAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: Stack(
                          children: [
                            // Background line
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Progress fill
                            FractionallySizedBox(
                              widthFactor: isCompleted
                                  ? 1.0
                                  : isActive
                                      ? _connectorAnimation.value
                                      : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _primaryOrange,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                // Step circle with label
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < _currentStepIndex;
                final isActive = stepIndex == _currentStepIndex;

                return _buildStepWithLabel(
                  step: _stepData[stepIndex],
                  stepIndex: stepIndex,
                  isCompleted: isCompleted,
                  isActive: isActive,
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepWithLabel({
    required Map<String, String> step,
    required int stepIndex,
    required bool isCompleted,
    required bool isActive,
  }) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final scale = isActive ? 1.0 + (_progressAnimation.value * 0.15) : 1.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step circle — larger (40px)
            Transform.scale(
              scale: isActive ? scale : 1.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? _primaryOrange
                      : Theme.of(context).disabledColor.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _primaryOrange.withValues(alpha:0.4),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          HeroiconsSolid.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : Icon(
                          _getStepIcon(step['key']!),
                          color: isActive ? Colors.white : Theme.of(context).hintColor,
                          size: 20,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Step label — larger font (10px)
            SizedBox(
              width: 64,
              child: Text(
                step['label']!.tr,
                style: robotoRegular.copyWith(
                  fontSize: 10,
                  color: isCompleted || isActive
                      ? _primaryOrange
                      : Theme.of(context).hintColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Show ETA under active step — chip style (10px)
            if (isActive && widget.etaMinutes != null && widget.etaMinutes! > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _primaryOrange.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '~${widget.etaMinutes} ${'min'.tr}',
                  style: robotoMedium.copyWith(
                    fontSize: 10,
                    color: _primaryOrange,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  IconData _getStepIcon(String step) {
    switch (step) {
      case 'confirmed':
        return HeroiconsSolid.checkCircle;
      case 'processing':
        return HeroiconsSolid.fire;
      case 'picked_up':
        return Icons.delivery_dining;
      case 'delivered':
        return HeroiconsSolid.home;
      default:
        return HeroiconsSolid.questionMarkCircle;
    }
  }
}

/// Success celebration animation for delivered orders
class DeliverySuccessAnimation extends StatefulWidget {
  const DeliverySuccessAnimation({super.key});

  @override
  State<DeliverySuccessAnimation> createState() => _DeliverySuccessAnimationState();
}

class _DeliverySuccessAnimationState extends State<DeliverySuccessAnimation>
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

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _successGreen.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: _successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    HeroiconsSolid.checkBadge,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: _opacityAnimation.value,
              child: Column(
                children: [
                  Text(
                    'order_delivered'.tr,
                    style: robotoBold.copyWith(
                      fontSize: 20,
                      color: _successGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'enjoy_your_meal'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
