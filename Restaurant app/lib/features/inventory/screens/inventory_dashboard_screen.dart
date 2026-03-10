import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/inventory/screens/barcode_scanner_screen.dart';
import 'package:mnjood_vendor/features/inventory/screens/expiry_management_screen.dart';
import 'package:mnjood_vendor/features/inventory/screens/low_stock_items_screen.dart';
import 'package:mnjood_vendor/features/inventory/widgets/expiring_products_widget.dart';
import 'package:mnjood_vendor/features/inventory/widgets/low_stock_alert_widget.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Main dashboard for inventory management
class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final controller = Get.find<InventoryController>();
    await Future.wait([
      controller.getStockOverview(),
      controller.getLowStockProducts(),
      controller.getExpiringProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'inventory_management'.tr),
      body: GetBuilder<InventoryController>(
        builder: (controller) {
          if (controller.isLoading && controller.stockOverview == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock overview cards
                  _buildStockOverview(context, controller),

                  // Quick actions
                  _buildQuickActions(context),

                  // Low stock alerts
                  LowStockAlertWidget(
                    onSeeAll: () => Get.to(() => const LowStockItemsScreen()),
                    maxItems: 3,
                  ),

                  // Expiring products
                  if (BusinessTypeHelper.showExpiryDate())
                    ExpiringProductsWidget(
                      onSeeAll: () => Get.to(() => const ExpiryManagementScreen()),
                      maxItems: 3,
                    ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStockOverview(BuildContext context, InventoryController controller) {
    final overview = controller.stockOverview;

    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'stock_overview'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'total'.tr,
                  '${overview?.totalProducts ?? 0}',
                  Theme.of(context).primaryColor,
                  HeroiconsOutline.cube,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: _buildStatCard(
                  context,
                  'in_stock'.tr,
                  '${overview?.inStockCount ?? 0}',
                  Colors.green,
                  HeroiconsSolid.checkCircle,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'low_stock'.tr,
                  '${overview?.lowStockCount ?? 0}',
                  Colors.orange,
                  HeroiconsOutline.exclamationTriangle,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: _buildStatCard(
                  context,
                  'out_of_stock'.tr,
                  '${overview?.outOfStockCount ?? 0}',
                  Colors.red,
                  HeroiconsOutline.shoppingCart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
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
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_actions'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              if (BusinessTypeHelper.showBarcodeScanner())
                Expanded(
                  child: _buildActionButton(
                    context,
                    'scan_barcode'.tr,
                    HeroiconsOutline.qrCode,
                    Theme.of(context).primaryColor,
                    () => Get.to(() => const BarcodeScannerScreen()),
                  ),
                ),
              if (BusinessTypeHelper.showBarcodeScanner())
                const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: _buildActionButton(
                  context,
                  'low_stock'.tr,
                  HeroiconsOutline.exclamationTriangle,
                  Colors.orange,
                  () => Get.to(() => const LowStockItemsScreen()),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              if (BusinessTypeHelper.showExpiryDate())
                Expanded(
                  child: _buildActionButton(
                    context,
                    'expiry'.tr,
                    HeroiconsOutline.clock,
                    Colors.red,
                    () => Get.to(() => const ExpiryManagementScreen()),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
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
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: color,
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
