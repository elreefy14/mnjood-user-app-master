import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget to display low stock alerts on the dashboard
class LowStockAlertWidget extends StatelessWidget {
  final VoidCallback? onSeeAll;
  final int maxItems;

  const LowStockAlertWidget({
    super.key,
    this.onSeeAll,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (controller) {
        final lowStockProducts = controller.lowStockProducts ?? [];
        final lowStockCount = controller.stockOverview?.lowStockCount ?? 0;

        if (lowStockCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        HeroiconsOutline.exclamationTriangle,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        BusinessTypeHelper.getLowStockLabel(),
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ],
                  ),
                  if (onSeeAll != null)
                    InkWell(
                      onTap: onSeeAll,
                      child: Row(
                        children: [
                          Text(
                            'see_all'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          Icon(
                            HeroiconsOutline.chevronRight,
                            size: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              // Alert count
              Text(
                '$lowStockCount ${BusinessTypeHelper.getItemsLabel()} ${'need_restocking'.tr}',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).disabledColor,
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Product list
              if (lowStockProducts.isNotEmpty)
                ...lowStockProducts.take(maxItems).map((product) =>
                    _buildProductItem(context, product)),

              // Show more indicator
              if (lowStockProducts.length > maxItems)
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Center(
                    child: Text(
                      '+${lowStockProducts.length - maxItems} ${'more'.tr}',
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductItem(BuildContext context, LowStockProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: product.isOutOfStock
            ? Colors.red.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: product.imageFullUrl != null
                ? Image.network(
                    product.imageFullUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.isOutOfStock
                      ? 'out_of_stock'.tr
                      : '${'stock'.tr}: ${product.currentStock}/${product.reorderPoint}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: product.isOutOfStock ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Stock indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: product.isOutOfStock ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Text(
              product.isOutOfStock ? '0' : '${product.currentStock}',
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        BusinessTypeHelper.getItemIcon(),
        color: Colors.grey[400],
        size: 20,
      ),
    );
  }
}
