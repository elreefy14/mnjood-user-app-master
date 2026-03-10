import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Badge widget to indicate prescription status on order cards
class PrescriptionBadgeWidget extends StatelessWidget {
  final String? status;
  final bool compact;

  const PrescriptionBadgeWidget({
    super.key,
    this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final text = _getStatusText();

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 12),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: robotoMedium.copyWith(
              color: color,
              fontSize: Dimensions.fontSizeExtraSmall,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending_verification':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'approved':
        return HeroiconsSolid.checkBadge;
      case 'rejected':
        return HeroiconsSolid.xCircle;
      case 'pending_verification':
      default:
        return HeroiconsOutline.beaker;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'approved':
        return 'rx_verified'.tr;
      case 'rejected':
        return 'rx_rejected'.tr;
      case 'pending_verification':
      default:
        return 'rx_pending'.tr;
    }
  }
}

/// Large prescription alert widget for dashboard
class PrescriptionAlertWidget extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onTap;

  const PrescriptionAlertWidget({
    super.key,
    required this.pendingCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade400,
                Colors.orange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  HeroiconsOutline.beaker,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pending_prescriptions'.tr,
                      style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pendingCount ${'orders_need_verification'.tr}',
                      style: robotoRegular.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'verify'.tr,
                      style: robotoMedium.copyWith(
                        color: Colors.orange,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      HeroiconsOutline.arrowRight,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
