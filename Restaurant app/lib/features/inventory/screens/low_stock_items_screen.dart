import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Screen for displaying and managing low stock items
class LowStockItemsScreen extends StatefulWidget {
  const LowStockItemsScreen({super.key});

  @override
  State<LowStockItemsScreen> createState() => _LowStockItemsScreenState();
}

class _LowStockItemsScreenState extends State<LowStockItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load both low stock and out-of-stock products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<InventoryController>();
      controller.getLowStockProducts();
      controller.getOutOfStockProducts();
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
      appBar: CustomAppBarWidget(title: BusinessTypeHelper.getLowStockLabel()),
      body: GetBuilder<InventoryController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get out-of-stock products from dedicated API
          final outOfStock = controller.outOfStockProducts ?? [];
          // Get low stock products (not out of stock)
          final lowStock = (controller.lowStockProducts ?? []).where((p) => !p.isOutOfStock).toList();

          return Column(
            children: [
              // Summary section
              _buildSummarySection(context, outOfStock.length, lowStock.length),

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
                          Text('out_of_stock'.tr),
                          if (outOfStock.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${outOfStock.length}',
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
                          Text('low_stock'.tr),
                          if (lowStock.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${lowStock.length}',
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductList(context, outOfStock, 'no_out_of_stock'.tr),
                    _buildProductList(context, lowStock, 'no_low_stock'.tr),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, int outOfStock, int lowStock) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'out_of_stock'.tr,
              outOfStock,
              Colors.red,
              HeroiconsOutline.shoppingCart,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: _buildSummaryCard(
              context,
              'low_stock'.tr,
              lowStock,
              Colors.orange,
              HeroiconsOutline.exclamationTriangle,
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
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
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
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<LowStockProduct> products, String emptyMessage) {
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
      onRefresh: () async {
        final controller = Get.find<InventoryController>();
        await Future.wait([
          controller.getLowStockProducts(),
          controller.getOutOfStockProducts(),
        ]);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(context, products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, LowStockProduct product) {
    final isOutOfStock = product.isOutOfStock;
    final color = isOutOfStock ? Colors.red : Colors.orange;

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
          // Product info row
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: product.imageFullUrl != null
                      ? Image.network(
                          product.imageFullUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),

                const SizedBox(width: Dimensions.paddingSizeDefault),

                // Product details
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
                      if (product.categoryName != null)
                        Text(
                          product.categoryName!,
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
                    isOutOfStock ? 'out_of_stock'.tr : 'low_stock'.tr,
                    style: robotoMedium.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stock info
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(Dimensions.radiusDefault),
                bottomRight: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Row(
              children: [
                // Current stock
                Expanded(
                  child: _buildStockInfo(
                    context,
                    'current_stock'.tr,
                    '${product.currentStock ?? 0}',
                    color,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: color.withOpacity(0.3),
                ),
                // Reorder point
                Expanded(
                  child: _buildStockInfo(
                    context,
                    'reorder_point'.tr,
                    '${product.reorderPoint ?? 0}',
                    Theme.of(context).disabledColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: color.withOpacity(0.3),
                ),
                // Reorder quantity
                Expanded(
                  child: InkWell(
                    onTap: () => _showRestockDialog(context, product),
                    child: _buildStockInfo(
                      context,
                      'restock'.tr,
                      '+${product.reorderPoint ?? 10}',
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(BuildContext context, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        BusinessTypeHelper.getItemIcon(),
        color: Colors.grey[400],
        size: 28,
      ),
    );
  }

  void _showRestockDialog(BuildContext context, LowStockProduct product) {
    final controller = TextEditingController(
      text: '${product.reorderPoint ?? 10}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('restock_product'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name ?? '',
              style: robotoBold,
            ),
            const SizedBox(height: 4),
            Text(
              '${'current_stock'.tr}: ${product.currentStock ?? 0}',
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'quantity_to_add'.tr,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(HeroiconsOutline.plus),
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
                  adjustmentType: 'add',
                  quantity: qty,
                  reason: 'restock',
                );
                Navigator.pop(context);
                Get.snackbar(
                  'success'.tr,
                  'stock_adjusted'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('add_stock'.tr),
          ),
        ],
      ),
    );
  }
}
