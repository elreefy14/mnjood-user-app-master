import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A model for filter chip items
class FilterChipItem {
  final String id;
  final String label;
  final int? count;
  final IconData? icon;

  const FilterChipItem({
    required this.id,
    required this.label,
    this.count,
    this.icon,
  });
}

/// A horizontal scrollable row of filter chips
class FilterChipRow extends StatelessWidget {
  final List<FilterChipItem> items;
  final String? selectedId;
  final ValueChanged<String>? onSelected;
  final EdgeInsetsGeometry? padding;
  final bool showCount;

  const FilterChipRow({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelected,
    this.padding,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = item.id == selectedId;

          return Padding(
            padding: EdgeInsets.only(
              right: index < items.length - 1 ? Dimensions.paddingSizeSmall : 0,
            ),
            child: _FilterChip(
              item: item,
              isSelected: isSelected,
              onTap: () => onSelected?.call(item.id),
              showCount: showCount,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final FilterChipItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showCount;

  const _FilterChip({
    required this.item,
    required this.isSelected,
    this.onTap,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusCircular),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.grey[800] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(Dimensions.radiusCircular),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                item.label,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
              if (showCount && item.count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.count}',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrap layout of selectable chips (for multi-select)
class SelectableChipWrap extends StatelessWidget {
  final List<FilterChipItem> items;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>>? onChanged;
  final bool multiSelect;

  const SelectableChipWrap({
    super.key,
    required this.items,
    required this.selectedIds,
    this.onChanged,
    this.multiSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensions.paddingSizeSmall,
      runSpacing: Dimensions.paddingSizeSmall,
      children: items.map((item) {
        final isSelected = selectedIds.contains(item.id);

        return _FilterChip(
          item: item,
          isSelected: isSelected,
          showCount: false,
          onTap: () {
            if (multiSelect) {
              final newSelection = Set<String>.from(selectedIds);
              if (isSelected) {
                newSelection.remove(item.id);
              } else {
                newSelection.add(item.id);
              }
              onChanged?.call(newSelection);
            } else {
              onChanged?.call({item.id});
            }
          },
        );
      }).toList(),
    );
  }
}

/// Tab-style filter buttons
class FilterTabs extends StatelessWidget {
  final List<FilterChipItem> items;
  final String? selectedId;
  final ValueChanged<String>? onSelected;
  final bool expanded;

  const FilterTabs({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelected,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isSelected = item.id == selectedId;

          Widget tab = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected?.call(item.id),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall - 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.grey[700] : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall - 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 16,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      item.label,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    if (item.count != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${item.count})',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: isSelected
                              ? primaryColor.withOpacity(0.7)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );

          if (expanded) {
            tab = Expanded(child: tab);
          }

          return tab;
        }).toList(),
      ),
    );
  }
}
