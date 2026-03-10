import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/pos/controllers/pos_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class PosCheckoutScreen extends StatefulWidget {
  const PosCheckoutScreen({super.key});

  @override
  State<PosCheckoutScreen> createState() => _PosCheckoutScreenState();
}

class _PosCheckoutScreenState extends State<PosCheckoutScreen> {
  final TextEditingController _cashController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'checkout'.tr),
      body: GetBuilder<PosController>(builder: (posController) {
        final cart = posController.cart;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              _buildSection(
                context,
                title: 'order_summary'.tr,
                child: Column(
                  children: [
                    ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: robotoRegular,
                                ),
                              ),
                              Text(
                                PriceConverter.convertPrice(item.totalWithDiscount),
                                style: robotoMedium,
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    _buildTotalRow(context, 'subtotal'.tr, cart.subtotal),
                    const SizedBox(height: 4),
                    _buildTotalRow(context, 'tax_vat'.tr, cart.tax),
                    const Divider(height: 16),
                    _buildTotalRow(context, 'total'.tr, cart.total, isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Payment Method
              _buildSection(
                context,
                title: 'payment_method'.tr,
                child: Column(
                  children: [
                    _buildPaymentOption(
                      context,
                      posController,
                      'cash',
                      'cash'.tr,
                      HeroiconsOutline.banknotes,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      context,
                      posController,
                      'card',
                      'card'.tr,
                      HeroiconsOutline.creditCard,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Cash Payment Details
              if (posController.paymentMethod == 'cash')
                _buildSection(
                  context,
                  title: 'cash_payment'.tr,
                  child: Column(
                    children: [
                      TextField(
                        controller: _cashController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'cash_received'.tr,
                          border: const OutlineInputBorder(),
                          prefixText: 'SAR ',
                        ),
                        onChanged: (value) {
                          final amount = double.tryParse(value) ?? 0;
                          posController.setCashReceived(amount);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quick cash buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickCashButton(context, posController, cart.total),
                          _buildQuickCashButton(context, posController, 50),
                          _buildQuickCashButton(context, posController, 100),
                          _buildQuickCashButton(context, posController, 200),
                          _buildQuickCashButton(context, posController, 500),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Change amount
                      if (posController.cashReceived >= cart.total)
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('change'.tr, style: robotoBold.copyWith(color: Colors.green)),
                              Text(
                                PriceConverter.convertPrice(posController.changeAmount),
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: GetBuilder<PosController>(builder: (posController) {
        final canCheckout = posController.paymentMethod != 'cash' ||
            posController.cashReceived >= posController.cart.total;

        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: CustomButtonWidget(
              buttonText: 'complete_order'.tr,
              isLoading: posController.isLoading,
              onPressed: canCheckout
                  ? () async {
                      final result = await posController.placeOrder();
                      if (result != null) {
                        _showSuccessDialog(context, result);
                      } else {
                        showCustomSnackBar('order_failed'.tr, isError: true);
                      }
                    }
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          child,
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge) : robotoRegular,
        ),
        Text(
          PriceConverter.convertPrice(amount),
          style: isTotal
              ? robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor,
                )
              : robotoMedium,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    PosController controller,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.paymentMethod == value;

    return InkWell(
      onTap: () => controller.setPaymentMethod(value),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Text(label, style: robotoMedium)),
            if (isSelected)
              Icon(HeroiconsOutline.checkCircle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCashButton(BuildContext context, PosController controller, double amount) {
    return OutlinedButton(
      onPressed: () {
        _cashController.text = amount.toStringAsFixed(0);
        controller.setCashReceived(amount);
      },
      child: Text(PriceConverter.convertPrice(amount)),
    );
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(HeroiconsOutline.checkCircle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('order_completed'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: 8),
            Text(
              '${'order'.tr} #${result['order_id'] ?? ''}',
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
        actions: [
          CustomButtonWidget(
            buttonText: 'new_order'.tr,
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to POS screen
            },
          ),
        ],
      ),
    );
  }
}
