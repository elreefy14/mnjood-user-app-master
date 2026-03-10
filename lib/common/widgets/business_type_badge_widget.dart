import 'package:flutter/material.dart';
import 'package:mnjood/common/enums/business_type_enum.dart';
import 'package:mnjood/helper/business_type_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class BusinessTypeBadgeWidget extends StatelessWidget {
  final BusinessType businessType;
  final double? size;
  final bool showLabel;
  final bool isCompact;

  const BusinessTypeBadgeWidget({
    super.key,
    required this.businessType,
    this.size,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (businessType == BusinessType.all) {
      return const SizedBox.shrink();
    }

    final color = BusinessTypeHelper.getColor(businessType);
    final lightColor = BusinessTypeHelper.getLightColor(businessType);
    final icon = BusinessTypeHelper.getIcon(businessType);

    if (isCompact) {
      // Compact version - just icon with background
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: lightColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size ?? 14,
          color: color,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: size ?? 14,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              businessType.singularDisplayName,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BusinessTypeIconWidget extends StatelessWidget {
  final BusinessType businessType;
  final double size;
  final Color? color;

  const BusinessTypeIconWidget({
    super.key,
    required this.businessType,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      BusinessTypeHelper.getIcon(businessType),
      size: size,
      color: color ?? BusinessTypeHelper.getColor(businessType),
    );
  }
}
