import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/inventory/screens/expiry_management_screen.dart';
import 'package:mnjood_vendor/features/inventory/screens/inventory_dashboard_screen.dart';
import 'package:mnjood_vendor/features/inventory/screens/low_stock_items_screen.dart';
import 'package:mnjood_vendor/features/inventory/widgets/expiring_products_widget.dart';
import 'package:mnjood_vendor/features/inventory/widgets/low_stock_alert_widget.dart';
import 'package:mnjood_vendor/features/order/controllers/order_controller.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget that displays business type-specific dashboard content
class BusinessTypeDashboardWidget extends StatelessWidget {
  const BusinessTypeDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final businessType = BusinessTypeHelper.getCurrentBusinessType();

    switch (businessType) {
      case BusinessType.supermarket:
        return const SupermarketDashboardSection();
      case BusinessType.pharmacy:
        return const PharmacyDashboardSection();
      case BusinessType.coffeeShop:
        return const CoffeeShopDashboardSection();
      case BusinessType.restaurant:
      default:
        return const RestaurantDashboardSection();
    }
  }
}

/// Dashboard section for Restaurant business type
class RestaurantDashboardSection extends StatelessWidget {
  const RestaurantDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      if (orderController.runningOrders == null) {
        return const SizedBox.shrink();
      }

      // Calculate order stats
      int confirmingOrders = 0;
      int cookingOrders = 0;
      int readyOrders = 0;

      for (var orderGroup in orderController.runningOrders!) {
        switch (orderGroup.status.toLowerCase()) {
          case 'confirmed':
            confirmingOrders = orderGroup.orderList.length;
            break;
          case 'cooking':
          case 'processing':
            cookingOrders = orderGroup.orderList.length;
            break;
          case 'handover':
          case 'ready_for_handover':
            readyOrders = orderGroup.orderList.length;
            break;
        }
      }

      final totalActiveOrders = confirmingOrders + cookingOrders + readyOrders;

      // Determine kitchen load
      String busyLevel = 'idle';
      Color busyColor = Colors.green;
      if (totalActiveOrders > 10) {
        busyLevel = 'busy';
        busyColor = Colors.red;
      } else if (totalActiveOrders > 5) {
        busyLevel = 'moderate';
        busyColor = Colors.orange;
      }

      if (totalActiveOrders == 0) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              children: [
                Icon(
                  HeroiconsOutline.fire,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'kitchen_overview'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const Spacer(),
                // Kitchen load indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: busyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: busyColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: busyColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        busyLevel.tr.toUpperCase(),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: busyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order pipeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Expanded(
                  child: _buildOrderPipelineCard(
                    context,
                    'new'.tr,
                    confirmingOrders.toString(),
                    Colors.blue,
                    HeroiconsOutline.clock,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: _buildOrderPipelineCard(
                    context,
                    'cooking'.tr,
                    cookingOrders.toString(),
                    Colors.orange,
                    HeroiconsOutline.fire,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: _buildOrderPipelineCard(
                    context,
                    'ready'.tr,
                    readyOrders.toString(),
                    Colors.green,
                    HeroiconsOutline.checkCircle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      );
    });
  }

  Widget _buildOrderPipelineCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard section for Supermarket business type
class SupermarketDashboardSection extends StatelessWidget {
  const SupermarketDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    HeroiconsOutline.cube,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'inventory_overview'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Get.to(() => const InventoryDashboardScreen()),
                child: Text(
                  'manage'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Quick stats
        GetBuilder<InventoryController>(
          builder: (controller) {
            final overview = controller.stockOverview;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'low_stock'.tr,
                      '${overview?.lowStockCount ?? 0}',
                      Colors.orange,
                      HeroiconsOutline.exclamationTriangle,
                      () => Get.to(() => const LowStockItemsScreen()),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'out_of_stock'.tr,
                      '${overview?.outOfStockCount ?? 0}',
                      Colors.red,
                      HeroiconsOutline.shoppingCart,
                      () => Get.to(() => const LowStockItemsScreen()),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'expiring'.tr,
                      '${controller.expiringCount}',
                      Colors.amber,
                      HeroiconsOutline.clock,
                      () => Get.to(() => const ExpiryManagementScreen()),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Low stock alerts
        LowStockAlertWidget(
          onSeeAll: () => Get.to(() => const LowStockItemsScreen()),
          maxItems: 2,
        ),

        // Expiring products
        ExpiringProductsWidget(
          onSeeAll: () => Get.to(() => const ExpiryManagementScreen()),
          maxItems: 2,
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: color,
              ),
            ),
            Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard section for Pharmacy business type
class PharmacyDashboardSection extends StatelessWidget {
  const PharmacyDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    HeroiconsOutline.beaker,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'pharmacy_overview'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Get.to(() => const InventoryDashboardScreen()),
                child: Text(
                  'manage'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Quick stats
        GetBuilder<InventoryController>(
          builder: (controller) {
            final overview = controller.stockOverview;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPharmacyStatCard(
                      context,
                      'low_stock'.tr,
                      '${overview?.lowStockCount ?? 0}',
                      Colors.orange,
                      HeroiconsOutline.exclamationTriangle,
                      () => Get.to(() => const LowStockItemsScreen()),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: _buildPharmacyStatCard(
                      context,
                      'out_of_stock'.tr,
                      '${overview?.outOfStockCount ?? 0}',
                      Colors.red,
                      HeroiconsOutline.shoppingCart,
                      () => Get.to(() => const LowStockItemsScreen()),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: _buildPharmacyStatCard(
                      context,
                      'expiring'.tr,
                      '${controller.expiringCount}',
                      Colors.amber,
                      HeroiconsOutline.clock,
                      () => Get.to(() => const ExpiryManagementScreen()),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Low stock medicines
        LowStockAlertWidget(
          onSeeAll: () => Get.to(() => const LowStockItemsScreen()),
          maxItems: 2,
        ),

        // Expiring medicines
        ExpiringProductsWidget(
          onSeeAll: () => Get.to(() => const ExpiryManagementScreen()),
          maxItems: 2,
        ),
      ],
    );
  }

  Widget _buildPharmacyStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: color,
              ),
            ),
            Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard section for Coffee Shop business type
class CoffeeShopDashboardSection extends StatelessWidget {
  const CoffeeShopDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      if (orderController.runningOrders == null) {
        return const SizedBox.shrink();
      }

      // Calculate order stats for coffee shop
      int pendingOrders = 0;
      int brewingOrders = 0;
      int readyForPickup = 0;

      for (var orderGroup in orderController.runningOrders!) {
        switch (orderGroup.status.toLowerCase()) {
          case 'pending':
          case 'confirmed':
            pendingOrders = orderGroup.orderList.length;
            break;
          case 'cooking':
          case 'processing':
          case 'brewing':
            brewingOrders = orderGroup.orderList.length;
            break;
          case 'handover':
          case 'ready_for_handover':
            readyForPickup = orderGroup.orderList.length;
            break;
        }
      }

      final queueLength = pendingOrders + brewingOrders;

      // Estimate wait time (3 min per order in queue)
      final estimatedWaitMins = queueLength * 3;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with queue info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              children: [
                Icon(
                  HeroiconsSolid.fire, // Coffee icon
                  color: const Color(0xFF8B4513), // Coffee brown
                  size: 20,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'queue_overview'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const Spacer(),
                // Live queue indicator
                if (queueLength > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: const Color(0xFF8B4513).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HeroiconsOutline.clock,
                          size: 14,
                          color: const Color(0xFF8B4513),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~$estimatedWaitMins ${'min'.tr}',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: const Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Queue cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Expanded(
                  child: _buildQueueCard(
                    context,
                    'in_queue'.tr,
                    pendingOrders.toString(),
                    const Color(0xFF8B4513),
                    HeroiconsOutline.queueList,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: _buildQueueCard(
                    context,
                    'brewing'.tr,
                    brewingOrders.toString(),
                    Colors.orange,
                    HeroiconsSolid.fire,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: _buildQueueCard(
                    context,
                    'ready'.tr,
                    readyForPickup.toString(),
                    Colors.green,
                    HeroiconsOutline.checkCircle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Quick actions for coffee shop
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'popular_today'.tr,
                    HeroiconsOutline.star,
                    const Color(0xFFD2691E),
                    () {},
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'loyalty_stamps'.tr,
                    HeroiconsOutline.gift,
                    Colors.purple,
                    () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      );
    });
  }

  Widget _buildQueueCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              HeroiconsOutline.chevronRight,
              size: 16,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
