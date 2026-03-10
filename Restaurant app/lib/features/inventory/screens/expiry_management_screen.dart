import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:intl/intl.dart';

/// Screen for managing product expiry dates and batches
class ExpiryManagementScreen extends StatefulWidget {
  const ExpiryManagementScreen({super.key});

  @override
  State<ExpiryManagementScreen> createState() => _ExpiryManagementScreenState();
}

class _ExpiryManagementScreenState extends State<ExpiryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load expiring products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<InventoryController>().getExpiringProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'expiry_tracking'.tr),
      body: GetBuilder<InventoryController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = controller.expiringProducts ?? [];
          final expiredProducts = allProducts.where((p) => p.isExpired).toList();
          final expiringSoon = allProducts.where((p) => !p.isExpired && p.urgencyLevel >= 2).toList();
          final expiringLater = allProducts.where((p) => !p.isExpired && p.urgencyLevel < 2).toList();

          return Column(
            children: [
              // Summary cards
              _buildSummarySection(context, expiredProducts.length, expiringSoon.length, expiringLater.length),

              // Tab bar
              Container(
                color: Theme.of(context).cardColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).disabledColor,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('expired'.tr),
                          if (expiredProducts.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${expiredProducts.length}',
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('expiring_soon'.tr),
                          if (expiringSoon.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${expiringSoon.length}',
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(text: 'all_batches'.tr),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductList(context, expiredProducts, 'no_expired_products'.tr),
                    _buildProductList(context, expiringSoon, 'no_expiring_products'.tr),
                    _buildProductList(context, allProducts, 'no_products_with_expiry'.tr),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, int expired, int expiringSoon, int expiringLater) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'expired'.tr,
              expired,
              Colors.red,
              HeroiconsOutline.exclamationTriangle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: _buildSummaryCard(
              context,
              'expiring_3_days'.tr,
              expiringSoon,
              Colors.orange,
              HeroiconsOutline.exclamationTriangle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: _buildSummaryCard(
              context,
              'expiring_7_days'.tr,
              expiringLater,
              Colors.amber,
              HeroiconsOutline.clock,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
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
            '$count',
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<ExpiringProduct> products, String emptyMessage) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HeroiconsOutline.checkCircle,
              size: 64,
              color: Colors.green.withOpacity(0.5),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              emptyMessage,
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Get.find<InventoryController>().getExpiringProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildExpiringProductCard(context, products[index]);
        },
      ),
    );
  }

  Widget _buildExpiringProductCard(BuildContext context, ExpiringProduct product) {
    final color = _getUrgencyColor(product.urgencyLevel);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
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
        children: [
          // Product header
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: product.imageFullUrl != null
                      ? Image.network(
                          product.imageFullUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),

                const SizedBox(width: Dimensions.paddingSizeDefault),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? '',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product.batchNumber != null)
                        Text(
                          '${'batch'.tr}: ${product.batchNumber}',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 6,
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
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Batch details
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                // Expiry date row
                _buildDetailRow(
                  context,
                  'expiry_date'.tr,
                  product.expiryDate != null
                      ? dateFormat.format(product.expiryDate!)
                      : '-',
                  HeroiconsOutline.calendar,
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Quantity row
                _buildDetailRow(
                  context,
                  'qty'.tr,
                  '${product.quantity ?? 0} ${BusinessTypeHelper.getUnitLabel()}',
                  HeroiconsOutline.cube,
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAdjustStockDialog(context, product),
                        icon: const Icon(HeroiconsOutline.pencil, size: 18),
                        label: Text('adjust_stock'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRemoveBatchDialog(context, product),
                        icon: const Icon(HeroiconsOutline.trash, size: 18),
                        label: Text('remove'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).disabledColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(
          '$label: ',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
        Text(
          value,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        BusinessTypeHelper.getItemIcon(),
        color: Colors.grey[400],
        size: 24,
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

  void _showAdjustStockDialog(BuildContext context, ExpiringProduct product) {
    final controller = TextEditingController();
    String adjustmentType = 'remove';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('adjust_stock'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? '',
                style: robotoBold,
              ),
              if (product.batchNumber != null)
                Text(
                  '${'batch'.tr}: ${product.batchNumber}',
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Adjustment type selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('remove'.tr, style: robotoRegular),
                      value: 'remove',
                      groupValue: adjustmentType,
                      onChanged: (value) => setState(() => adjustmentType = value!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('add'.tr, style: robotoRegular),
                      value: 'add',
                      groupValue: adjustmentType,
                      onChanged: (value) => setState(() => adjustmentType = value!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Quantity input
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'quantity'.tr,
                  border: const OutlineInputBorder(),
                  hintText: 'current'.tr + ': ${product.quantity ?? 0}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(controller.text);
                if (qty != null && qty > 0) {
                  Get.find<InventoryController>().adjustStock(
                    productId: product.id ?? 0,
                    adjustmentType: adjustmentType,
                    quantity: qty,
                    reason: 'expiry_adjustment',
                    batchNumber: product.batchNumber,
                  );
                  Navigator.pop(context);
                  Get.snackbar(
                    'success'.tr,
                    'stock_adjusted'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text('confirm'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveBatchDialog(BuildContext context, ExpiringProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('remove_batch'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('remove_batch_confirmation'.tr),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: robotoBold,
                  ),
                  if (product.batchNumber != null)
                    Text('${'batch'.tr}: ${product.batchNumber}'),
                  Text('${'qty'.tr}: ${product.quantity ?? 0}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Remove entire batch quantity
              Get.find<InventoryController>().adjustStock(
                productId: product.id ?? 0,
                adjustmentType: 'remove',
                quantity: product.quantity ?? 0,
                reason: 'expired_removed',
                batchNumber: product.batchNumber,
              );
              Navigator.pop(context);
              Get.snackbar(
                'success'.tr,
                'batch_removed'.tr,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('remove'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
