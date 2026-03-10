import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Badge widget that displays the business type with appropriate icon and color
class BusinessTypeBadge extends StatelessWidget {
  final BusinessType? businessType;
  final bool showLabel;
  final bool compact;
  final double? iconSize;

  const BusinessTypeBadge({
    super.key,
    this.businessType,
    this.showLabel = true,
    this.compact = false,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final type = businessType ?? BusinessTypeHelper.getCurrentBusinessType();
    final config = _getConfig(type);

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Icon(
          config.icon,
          size: iconSize ?? 18,
          color: config.color,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: iconSize ?? 16,
            color: config.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              config.label,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: config.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BadgeConfig _getConfig(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return _BadgeConfig(
          icon: HeroiconsOutline.buildingStorefront,
          color: const Color(0xFFFF9E1B),
          label: 'Restaurant',
        );
      case BusinessType.supermarket:
        return _BadgeConfig(
          icon: HeroiconsOutline.shoppingCart,
          color: const Color(0xFF4CAF50),
          label: 'Supermarket',
        );
      case BusinessType.pharmacy:
        return _BadgeConfig(
          icon: HeroiconsOutline.beaker,
          color: const Color(0xFF2196F3),
          label: 'Pharmacy',
        );
      case BusinessType.coffeeShop:
        return _BadgeConfig(
          icon: HeroiconsSolid.fire,
          color: const Color(0xFF8B4513),
          label: 'Coffee Shop',
        );
    }
  }
}

class _BadgeConfig {
  final IconData icon;
  final Color color;
  final String label;

  _BadgeConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}

/// A row of business type badges for selection
class BusinessTypeSelector extends StatelessWidget {
  final BusinessType? selectedType;
  final ValueChanged<BusinessType>? onChanged;
  final bool enabled;

  const BusinessTypeSelector({
    super.key,
    this.selectedType,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BusinessType.values.map((type) {
        final isSelected = type == selectedType;
        final config = _getConfig(type);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != BusinessType.values.last ? 8 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? () => onChanged?.call(type) : null,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? config.color.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                      color: isSelected
                          ? config.color
                          : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        config.icon,
                        size: 24,
                        color: isSelected ? config.color : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.label,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: isSelected ? config.color : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  _BadgeConfig _getConfig(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return _BadgeConfig(
          icon: HeroiconsOutline.buildingStorefront,
          color: const Color(0xFFFF9E1B),
          label: 'Restaurant',
        );
      case BusinessType.supermarket:
        return _BadgeConfig(
          icon: HeroiconsOutline.shoppingCart,
          color: const Color(0xFF4CAF50),
          label: 'Supermarket',
        );
      case BusinessType.pharmacy:
        return _BadgeConfig(
          icon: HeroiconsOutline.beaker,
          color: const Color(0xFF2196F3),
          label: 'Pharmacy',
        );
      case BusinessType.coffeeShop:
        return _BadgeConfig(
          icon: HeroiconsSolid.fire,
          color: const Color(0xFF8B4513),
          label: 'Coffee',
        );
    }
  }
}
