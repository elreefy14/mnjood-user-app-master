import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/features/pos/controllers/pos_controller.dart';
import 'package:mnjood_vendor/features/pos/screens/pos_checkout_screen.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class PosCartWidget extends StatelessWidget {
  final PosController posController;
  final ScrollController? scrollController;
  final bool showHeader;

  const PosCartWidget({
    super.key,
    required this.posController,
    this.scrollController,
    this.showHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final cart = posController.cart;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          if (showHeader)
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('cart'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(HeroiconsOutline.xMark),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('cart'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  Text('${cart.itemCount} ${'items'.tr}', style: robotoRegular),
                ],
              ),
            ),

          // Cart Items
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          HeroiconsOutline.shoppingCart,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text('cart_is_empty'.tr, style: robotoMedium),
                        const SizedBox(height: 8),
                        Text(
                          'scan_or_search'.tr,
                          style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Dismissible(
                        key: Key('cart_item_${item.foodId}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => posController.removeFromCart(item.foodId),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(HeroiconsOutline.trash, color: Colors.white),
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImageWidget(
                                image: item.product.imageFullUrl ?? '',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name ?? '',
                                    style: robotoMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    PriceConverter.convertPrice(item.discountedPrice),
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => posController.updateQuantity(
                                      item.foodId,
                                      item.quantity - 1,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        HeroiconsOutline.minus,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 30),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.quantity}',
                                      style: robotoMedium,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => posController.updateQuantity(
                                      item.foodId,
                                      item.quantity + 1,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        HeroiconsOutline.plus,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Totals and Actions
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Subtotal
                    _buildTotalRow(context, 'subtotal'.tr, cart.subtotal),
                    const SizedBox(height: 4),

                    // Discount (if any)
                    if (cart.discountValue > 0) ...[
                      _buildTotalRow(
                        context,
                        'discount'.tr,
                        -cart.discountValue,
                        isDiscount: true,
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Tax
                    _buildTotalRow(context, 'tax_vat'.tr, cart.tax),
                    const Divider(height: 16),

                    // Total
                    _buildTotalRow(
                      context,
                      'total'.tr,
                      cart.total,
                      isTotal: true,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showHoldOrderDialog(context),
                            icon: const Icon(HeroiconsOutline.pause),
                            label: Text('hold'.tr),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          flex: 2,
                          child: CustomButtonWidget(
                            buttonText: 'checkout'.tr,
                            onPressed: () {
                              if (showHeader) Get.back();
                              Get.to(() => const PosCheckoutScreen());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)
              : robotoRegular,
        ),
        Text(
          PriceConverter.convertPrice(amount),
          style: isTotal
              ? robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor,
                )
              : robotoMedium.copyWith(
                  color: isDiscount ? Colors.green : null,
                ),
        ),
      ],
    );
  }

  void _showHoldOrderDialog(BuildContext context) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('hold_order'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('hold_order_note'.tr, style: robotoRegular),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'add_note_optional'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              posController.holdOrder(
                noteController.text.isEmpty ? null : noteController.text,
              );
              Get.back();
              if (showHeader) Get.back();
            },
            child: Text('hold'.tr),
          ),
        ],
      ),
    );
  }
}
