import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A model for quick action items
class QuickActionItem {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? badge;
  final bool enabled;

  const QuickActionItem({
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
    this.badge,
    this.enabled = true,
  });
}

/// A grid of quick action buttons
class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> items;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;

  const QuickActionGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = Dimensions.paddingSizeSmall,
    this.childAspectRatio = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _QuickActionButton(item: items[index]);
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final QuickActionItem item;

  const _QuickActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color effectiveColor = item.color ?? Theme.of(context).primaryColor;
    final bool isEnabled = item.enabled && item.onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? item.onTap : null,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: effectiveColor.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: effectiveColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        item.label,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: effectiveColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.badge!,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal row of quick action buttons
class QuickActionRow extends StatelessWidget {
  final List<QuickActionItem> items;
  final double spacing;

  const QuickActionRow({
    super.key,
    required this.items,
    this.spacing = Dimensions.paddingSizeSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < items.length - 1 ? spacing : 0,
            ),
            child: _QuickActionChip(item: item),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final QuickActionItem item;

  const _QuickActionChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color effectiveColor = item.color ?? Theme.of(context).primaryColor;
    final bool isEnabled = item.enabled && item.onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? item.onTap : null,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                color: effectiveColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: effectiveColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    item.label,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: effectiveColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
