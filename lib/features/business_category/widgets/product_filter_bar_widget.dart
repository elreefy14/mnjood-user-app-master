import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

enum ProductSortOption { popular, latest, priceLowHigh, priceHighLow, rating }

class ProductFilterBarWidget extends StatelessWidget {
  final ProductSortOption selectedSort;
  final bool onSaleFilter;
  final bool inStockFilter;
  final bool newArrivalsFilter;
  final Function(ProductSortOption) onSortChanged;
  final Function(bool) onSaleFilterChanged;
  final Function(bool)? onInStockChanged;
  final Function(bool)? onNewArrivalsChanged;
  final List<CategoryModel>? categories;
  final int? selectedCategoryId;
  final Function(int?)? onCategoryChanged;

  const ProductFilterBarWidget({
    super.key,
    required this.selectedSort,
    required this.onSaleFilter,
    this.inStockFilter = false,
    this.newArrivalsFilter = false,
    required this.onSortChanged,
    required this.onSaleFilterChanged,
    this.onInStockChanged,
    this.onNewArrivalsChanged,
    this.categories,
    this.selectedCategoryId,
    this.onCategoryChanged,
  });

  String _getSortLabel(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.popular:
        return 'popular'.tr;
      case ProductSortOption.latest:
        return 'latest'.tr;
      case ProductSortOption.priceLowHigh:
        return 'price_low_high'.tr;
      case ProductSortOption.priceHighLow:
        return 'price_high_low'.tr;
      case ProductSortOption.rating:
        return 'rating'.tr;
    }
  }

  String _getSelectedCategoryName() {
    if (selectedCategoryId == null || categories == null) return 'all'.tr;
    final cat = categories!.where((c) => c.id == selectedCategoryId).firstOrNull;
    return cat?.name ?? 'all'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Category dropdown (only if categories provided)
            if (categories != null && categories!.isNotEmpty && onCategoryChanged != null) ...[
              PopupMenuButton<int?>(
                initialValue: selectedCategoryId,
                onSelected: onCategoryChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                position: PopupMenuPosition.under,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedCategoryId != null
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedCategoryId != null
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        HeroiconsOutline.squares2x2,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          _getSelectedCategoryName(),
                          style: robotoMedium.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  PopupMenuItem<int?>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(HeroiconsOutline.viewColumns, size: 20, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text('all'.tr, style: robotoRegular.copyWith(
                          fontWeight: selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                        )),
                      ],
                    ),
                  ),
                  ...categories!.map((cat) => PopupMenuItem<int?>(
                    value: cat.id,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CustomImageWidget(
                            image: cat.imageFullUrl ?? '',
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.name ?? '',
                            style: robotoRegular.copyWith(
                              fontWeight: selectedCategoryId == cat.id ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              const SizedBox(width: 8),
            ],

            // Sort dropdown
            PopupMenuButton<ProductSortOption>(
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
                  value: ProductSortOption.popular,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.fire, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('popular'.tr, style: robotoRegular),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ProductSortOption.latest,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.sparkles, size: 16, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text('latest'.tr, style: robotoRegular),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ProductSortOption.rating,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('rating'.tr, style: robotoRegular),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ProductSortOption.priceLowHigh,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.arrowTrendingUp, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('price_low_high'.tr, style: robotoRegular),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ProductSortOption.priceHighLow,
                  child: Row(
                    children: [
                      Icon(HeroiconsSolid.arrowTrendingDown, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('price_high_low'.tr, style: robotoRegular),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // On Sale filter chip
            FilterChip(
              avatar: Icon(
                onSaleFilter ? HeroiconsSolid.tag : HeroiconsOutline.tag,
                size: 14,
                color: onSaleFilter ? Colors.white : const Color(0xFFDC2626),
              ),
              label: Text(
                'on_sale'.tr,
                style: robotoMedium.copyWith(
                  fontSize: 11,
                  color: onSaleFilter ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              selected: onSaleFilter,
              onSelected: onSaleFilterChanged,
              selectedColor: const Color(0xFFDC2626),
              backgroundColor: Theme.of(context).cardColor,
              side: BorderSide(
                color: onSaleFilter
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFDC2626).withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            const SizedBox(width: 8),

            // New Arrivals filter chip
            if (onNewArrivalsChanged != null)
              FilterChip(
                avatar: Icon(
                  newArrivalsFilter ? HeroiconsSolid.sparkles : HeroiconsOutline.sparkles,
                  size: 14,
                  color: newArrivalsFilter ? Colors.white : Colors.purple,
                ),
                label: Text(
                  'new_arrivals'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: newArrivalsFilter ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                selected: newArrivalsFilter,
                onSelected: onNewArrivalsChanged!,
                selectedColor: Colors.purple,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: newArrivalsFilter
                      ? Colors.purple
                      : Colors.purple.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),

            if (onNewArrivalsChanged != null) const SizedBox(width: 8),

            // In Stock filter chip
            if (onInStockChanged != null)
              FilterChip(
                avatar: Icon(
                  inStockFilter ? HeroiconsSolid.checkCircle : HeroiconsOutline.checkCircle,
                  size: 14,
                  color: inStockFilter ? Colors.white : Colors.green,
                ),
                label: Text(
                  'in_stock'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: inStockFilter ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                selected: inStockFilter,
                onSelected: onInStockChanged!,
                selectedColor: Colors.green,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: inStockFilter
                      ? Colors.green
                      : Colors.green.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ),
    );
  }
}
