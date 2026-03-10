import 'package:flutter/material.dart';
import 'package:mnjood_vendor/util/app_colors.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A colored dot indicator with optional label
class StatusIndicator extends StatelessWidget {
  final String? label;
  final Color color;
  final double size;
  final bool showPulse;
  final TextStyle? labelStyle;

  const StatusIndicator({
    super.key,
    this.label,
    required this.color,
    this.size = 8,
    this.showPulse = false,
    this.labelStyle,
  });

  /// Factory constructors for common statuses
  factory StatusIndicator.success({String? label, bool showPulse = false}) {
    return StatusIndicator(
      label: label,
      color: AppColors.success,
      showPulse: showPulse,
    );
  }

  factory StatusIndicator.warning({String? label, bool showPulse = false}) {
    return StatusIndicator(
      label: label,
      color: AppColors.warning,
      showPulse: showPulse,
    );
  }

  factory StatusIndicator.error({String? label, bool showPulse = false}) {
    return StatusIndicator(
      label: label,
      color: AppColors.error,
      showPulse: showPulse,
    );
  }

  factory StatusIndicator.info({String? label, bool showPulse = false}) {
    return StatusIndicator(
      label: label,
      color: AppColors.info,
      showPulse: showPulse,
    );
  }

  factory StatusIndicator.neutral({String? label}) {
    return StatusIndicator(
      label: label,
      color: AppColors.gray400,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (showPulse) {
      dot = _PulsingDot(color: color, size: size);
    }

    if (label == null) {
      return dot;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          label!,
          style: labelStyle ??
              robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.2,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A status badge with background color
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
    this.fontSize,
    this.padding,
  });

  /// Factory for order status
  factory StatusBadge.fromOrderStatus(String status) {
    return StatusBadge(
      label: _formatStatus(status),
      color: AppColors.getOrderStatusColor(status),
      backgroundColor: AppColors.getOrderStatusBgColor(status),
    );
  }

  static String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: fontSize ?? Dimensions.fontSizeSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Busy level indicator (idle, moderate, busy, overloaded)
class BusyLevelIndicator extends StatelessWidget {
  final String level;
  final bool showLabel;

  const BusyLevelIndicator({
    super.key,
    required this.level,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(level);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: config.fillFactor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: config.color,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            config.label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: config.color,
            ),
          ),
        ],
      ],
    );
  }

  _BusyConfig _getConfig(String level) {
    switch (level.toLowerCase()) {
      case 'idle':
        return _BusyConfig(
          color: AppColors.success,
          label: 'Idle',
          fillFactor: 0.25,
        );
      case 'moderate':
        return _BusyConfig(
          color: AppColors.warning,
          label: 'Moderate',
          fillFactor: 0.5,
        );
      case 'busy':
        return _BusyConfig(
          color: AppColors.primary,
          label: 'Busy',
          fillFactor: 0.75,
        );
      case 'overloaded':
        return _BusyConfig(
          color: AppColors.error,
          label: 'Overloaded',
          fillFactor: 1.0,
        );
      default:
        return _BusyConfig(
          color: AppColors.gray400,
          label: 'Unknown',
          fillFactor: 0.0,
        );
    }
  }
}

class _BusyConfig {
  final Color color;
  final String label;
  final double fillFactor;

  _BusyConfig({
    required this.color,
    required this.label,
    required this.fillFactor,
  });
}
