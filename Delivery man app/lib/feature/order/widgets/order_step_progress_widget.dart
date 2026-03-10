import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/styles.dart';

class OrderStepProgressWidget extends StatelessWidget {
  final String currentStatus;
  const OrderStepProgressWidget({super.key, required this.currentStatus});

  static const List<_StepData> _steps = [
    _StepData(icon: Icons.thumb_up_rounded, label: 'accepted'),
    _StepData(icon: Icons.store_rounded, label: 'arrived_at_store'),
    _StepData(icon: Icons.inventory_2_rounded, label: 'picked_up'),
    _StepData(icon: Icons.location_on_rounded, label: 'arrived_at_customer'),
    _StepData(icon: Icons.check_circle_rounded, label: 'delivered'),
  ];

  int _statusToIndex(String status) {
    switch (status) {
      case 'accepted':
        return 0;
      case 'arrived_at_store':
        return 1;
      case 'confirmed':
      case 'processing':
      case 'handover':
        return 1; // Still at store phase
      case 'picked_up':
        return 2;
      case 'arrived_at_customer':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = _statusToIndex(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            int stepBefore = i ~/ 2;
            bool completed = stepBefore < currentIndex;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: completed ? ColorResources.green : Theme.of(context).hintColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          int stepIndex = i ~/ 2;
          _StepData step = _steps[stepIndex];
          bool isCompleted = stepIndex < currentIndex;
          bool isCurrent = stepIndex == currentIndex;

          Color circleColor = isCompleted
              ? ColorResources.green
              : isCurrent
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor.withOpacity(0.25);

          return Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent ? circleColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: isCompleted || isCurrent ? 0 : 2),
                  boxShadow: isCurrent ? [
                    BoxShadow(color: circleColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2)),
                  ] : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check : step.icon,
                  color: isCompleted || isCurrent ? ColorResources.white : Theme.of(context).hintColor.withOpacity(0.4),
                  size: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.label.tr,
                style: robotoMedium.copyWith(
                  fontSize: 8,
                  color: isCompleted || isCurrent ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          );
        }),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String label;
  const _StepData({required this.icon, required this.label});
}
