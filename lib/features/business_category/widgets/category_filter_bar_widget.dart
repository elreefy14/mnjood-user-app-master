import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

enum SortOption { popular, latest, rating }

class CategoryFilterBarWidget extends StatelessWidget {
  final SortOption selectedSort;
  final bool openNowFilter;
  final bool freeDeliveryFilter;
  final Function(SortOption) onSortChanged;
  final Function(bool) onOpenNowChanged;
  final Function(bool) onFreeDeliveryChanged;

  const CategoryFilterBarWidget({
    super.key,
    required this.selectedSort,
    required this.openNowFilter,
    required this.freeDeliveryFilter,
    required this.onSortChanged,
    required this.onOpenNowChanged,
    required this.onFreeDeliveryChanged,
  });

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.popular:
        return 'popular'.tr;
      case SortOption.latest:
        return 'latest'.tr;
      case SortOption.rating:
        return 'rating'.tr;
    }
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.popular:
        return HeroiconsSolid.fire;
      case SortOption.latest:
        return HeroiconsSolid.sparkles;
      case SortOption.rating:
        return HeroiconsSolid.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Sort dropdown
            PopupMenuButton<SortOption>(
              initialValue: selectedSort,
              onSelected: onSortChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              position: PopupMenuPosition.under,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      HeroiconsOutline.adjustmentsHorizontal,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getSortLabel(selectedSort),
                      style: robotoMedium.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      HeroiconsOutline.chevronDown,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SortOption.popular,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.fire, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('popular'.tr, style: robotoRegular),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.latest,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.sparkles, size: 16, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text('latest'.tr, style: robotoRegular),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.rating,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('rating'.tr, style: robotoRegular),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Open Now filter chip
            FilterChip(
              avatar: Icon(
                openNowFilter ? HeroiconsSolid.clock : HeroiconsOutline.clock,
                size: 16,
                color: openNowFilter ? Colors.white : Theme.of(context).primaryColor,
              ),
              label: Text(
                'open_now'.tr,
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  color: openNowFilter ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              selected: openNowFilter,
              onSelected: onOpenNowChanged,
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              side: BorderSide(
                color: openNowFilter
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),

            const SizedBox(width: 8),

            // Free Delivery filter chip
            FilterChip(
              avatar: Icon(
                freeDeliveryFilter ? HeroiconsSolid.truck : HeroiconsOutline.truck,
                size: 16,
                color: freeDeliveryFilter ? Colors.white : Colors.green,
              ),
              label: Text(
                'free_delivery'.tr,
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  color: freeDeliveryFilter ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              selected: freeDeliveryFilter,
              onSelected: onFreeDeliveryChanged,
              selectedColor: Colors.green,
              backgroundColor: Theme.of(context).cardColor,
              side: BorderSide(
                color: freeDeliveryFilter
                    ? Colors.green
                    : Colors.green.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ],
        ),
      ),
    );
  }
}
