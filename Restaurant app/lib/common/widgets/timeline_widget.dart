import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:mnjood_vendor/util/app_colors.dart';

/// A timeline step item
class TimelineStep {
  final String title;
  final String? subtitle;
  final String? timestamp;
  final IconData? icon;
  final bool isCompleted;
  final bool isCurrent;
  final Color? color;

  const TimelineStep({
    required this.title,
    this.subtitle,
    this.timestamp,
    this.icon,
    this.isCompleted = false,
    this.isCurrent = false,
    this.color,
  });
}

/// A vertical timeline widget for order status, etc.
class TimelineWidget extends StatelessWidget {
  final List<TimelineStep> steps;
  final double lineWidth;
  final double dotSize;
  final bool showConnectors;

  const TimelineWidget({
    super.key,
    required this.steps,
    this.lineWidth = 2,
    this.dotSize = 12,
    this.showConnectors = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return _buildStep(context, step, isLast);
      }).toList(),
    );
  }

  Widget _buildStep(BuildContext context, TimelineStep step, bool isLast) {
    final bool isDark = Get.isDarkMode;
    final Color stepColor = step.color ??
        (step.isCompleted
            ? AppColors.success
            : step.isCurrent
                ? Theme.of(context).primaryColor
                : AppColors.gray300);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _buildDot(step, stepColor, isDark),
                if (!isLast && showConnectors)
                  Expanded(
                    child: Container(
                      width: lineWidth,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: step.isCompleted
                          ? stepColor.withOpacity(0.5)
                          : AppColors.gray200,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: (step.isCurrent ? robotoSemiBold : robotoMedium)
                              .copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: step.isCompleted || step.isCurrent
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      if (step.timestamp != null)
                        Text(
                          step.timestamp!,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                  if (step.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(TimelineStep step, Color color, bool isDark) {
    if (step.icon != null) {
      return Container(
        width: dotSize + 8,
        height: dotSize + 8,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          step.icon,
          size: dotSize,
          color: color,
        ),
      );
    }

    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: step.isCompleted ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: step.isCompleted
          ? Icon(
              HeroiconsOutline.check,
              size: dotSize - 4,
              color: Colors.white,
            )
          : null,
    );
  }
}

/// Order status timeline
class OrderStatusTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> statusHistory;
  final String currentStatus;

  const OrderStatusTimeline({
    super.key,
    required this.statusHistory,
    required this.currentStatus,
  });

  static const List<String> _standardStatuses = [
    'pending',
    'confirmed',
    'cooking',
    'ready',
    'picked_up',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final steps = _standardStatuses.map((status) {
      final historyItem = statusHistory.firstWhereOrNull(
        (item) => item['status'] == status,
      );
      final isCompleted = historyItem != null;
      final isCurrent = status == currentStatus;

      return TimelineStep(
        title: _getStatusLabel(status),
        subtitle: historyItem?['note'],
        timestamp: historyItem?['time'],
        icon: _getStatusIcon(status),
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        color: AppColors.getOrderStatusColor(status),
      );
    }).toList();

    return TimelineWidget(steps: steps);
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'order_placed'.tr;
      case 'confirmed':
        return 'order_confirmed'.tr;
      case 'cooking':
        return 'preparing'.tr;
      case 'ready':
        return 'ready_for_pickup'.tr;
      case 'picked_up':
        return 'out_for_delivery'.tr;
      case 'delivered':
        return 'delivered'.tr;
      default:
        return status.tr;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return HeroiconsOutline.clock;
      case 'confirmed':
        return HeroiconsOutline.checkCircle;
      case 'cooking':
        return HeroiconsOutline.fire;
      case 'ready':
        return HeroiconsOutline.shoppingBag;
      case 'picked_up':
        return HeroiconsOutline.truck;
      case 'delivered':
        return HeroiconsOutline.checkBadge;
      default:
        return HeroiconsOutline.ellipsisHorizontalCircle;
    }
  }
}

/// Operating hours timeline (horizontal)
class OperatingHoursWidget extends StatelessWidget {
  final List<Map<String, dynamic>> schedule;
  final bool isOpen;

  const OperatingHoursWidget({
    super.key,
    required this.schedule,
    this.isOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOpen ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isOpen ? 'open_now'.tr : 'closed'.tr,
              style: robotoMedium.copyWith(
                color: isOpen ? AppColors.success : AppColors.error,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        ...schedule.map((day) => _buildDayRow(day, isDark)),
      ],
    );
  }

  Widget _buildDayRow(Map<String, dynamic> day, bool isDark) {
    final bool isToday = day['isToday'] ?? false;
    final bool isClosed = day['isClosed'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day['day'] ?? '',
              style: (isToday ? robotoMedium : robotoRegular).copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isToday
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            child: Text(
              isClosed ? 'closed'.tr : '${day['open']} - ${day['close']}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isClosed
                    ? AppColors.error
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'today'.tr,
                style: robotoMedium.copyWith(
                  fontSize: 10,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple progress step indicator (horizontal dots)
class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final Color active = activeColor ?? Theme.of(context).primaryColor;
    final Color inactive = inactiveColor ?? AppColors.gray300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final bool isActive = index <= currentStep;
        final bool isCurrent = index == currentStep;

        return Padding(
          padding: EdgeInsets.only(right: index < totalSteps - 1 ? spacing : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isCurrent ? dotSize * 2 : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? active : inactive,
              borderRadius: BorderRadius.circular(dotSize / 2),
            ),
          ),
        );
      }),
    );
  }
}
