import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget to display expiring products on the dashboard
class ExpiringProductsWidget extends StatelessWidget {
  final VoidCallback? onSeeAll;
  final int maxItems;

  const ExpiringProductsWidget({
    super.key,
    this.onSeeAll,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (controller) {
        final expiringProducts = controller.expiringProducts ?? [];

        if (expiringProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        // Count by urgency
        final expiredCount = expiringProducts.where((p) => p.isExpired).length;
        final expiring3Days = expiringProducts.where((p) => !p.isExpired && p.urgencyLevel == 2).length;
        final expiring7Days = expiringProducts.where((p) => p.urgencyLevel == 1).length;

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
                        HeroiconsOutline.clock,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        BusinessTypeHelper.getExpiryLabel(),
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

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Summary chips
              Wrap(
                spacing: Dimensions.paddingSizeSmall,
                runSpacing: Dimensions.paddingSizeSmall,
                children: [
                  if (expiredCount > 0)
                    _buildSummaryChip(
                      context,
                      'expired'.tr,
                      expiredCount,
                      Colors.red,
                    ),
                  if (expiring3Days > 0)
                    _buildSummaryChip(
                      context,
                      'expiring_in_3_days'.tr,
                      expiring3Days,
                      Colors.orange,
                    ),
                  if (expiring7Days > 0)
                    _buildSummaryChip(
                      context,
                      'expiring_in_7_days'.tr,
                      expiring7Days,
                      Colors.amber,
                    ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Product list
              ...expiringProducts.take(maxItems).map((product) =>
                  _buildProductItem(context, product)),

              // Show more indicator
              if (expiringProducts.length > maxItems)
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Center(
                    child: Text(
                      '+${expiringProducts.length - maxItems} ${'more'.tr}',
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

  Widget _buildSummaryChip(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, ExpiringProduct product) {
    final color = _getUrgencyColor(product.urgencyLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
                if (product.batchNumber != null)
                  Text(
                    '${'batch'.tr}: ${product.batchNumber}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
              ],
            ),
          ),

          // Expiry info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  product.isExpired
                      ? 'expired'.tr
                      : '${product.daysUntilExpiry} ${'days'.tr}',
                  style: robotoMedium.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeExtraSmall,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'qty'.tr + ': ${product.quantity}',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
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

  Color _getUrgencyColor(int level) {
    switch (level) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.amber;
      default:
        return Colors.green;
    }
  }
}
