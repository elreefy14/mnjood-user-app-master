import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class PurchaseOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const PurchaseOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<PurchaseOrderDetailsScreen> createState() => _PurchaseOrderDetailsScreenState();
}

class _PurchaseOrderDetailsScreenState extends State<PurchaseOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<FinanceController>().getPurchaseOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'purchase_order_details'.tr),
      body: GetBuilder<FinanceController>(builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final order = controller.selectedPurchaseOrder;
        if (order == null) {
          return Center(child: Text('order_not_found'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.poNumber ?? '', style: robotoBold.copyWith(fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            order.statusDisplay,
                            style: robotoMedium.copyWith(color: _getStatusColor(order.status)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: Dimensions.paddingSizeLarge),
                    _buildInfoRow('supplier'.tr, order.supplierName ?? 'N/A'),
                    _buildInfoRow(
                      'order_date'.tr,
                      order.orderDate != null
                          ? DateConverter.convertDateToDate(order.orderDate!)
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      'expected_delivery'.tr,
                      order.expectedDeliveryDate != null
                          ? DateConverter.convertDateToDate(order.expectedDeliveryDate!)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Items
              Text('items'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName ?? 'N/A', style: robotoMedium),
                                Text(
                                  '${item.quantity} x ${PriceConverter.convertPrice(item.unitPrice ?? 0)}',
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            PriceConverter.convertPrice(item.totalPrice ?? 0),
                            style: robotoBold,
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Totals
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(
                  children: [
                    _buildTotalRow('subtotal'.tr, order.subtotal ?? 0),
                    _buildTotalRow('tax'.tr, order.taxAmount ?? 0),
                    if ((order.discountAmount ?? 0) > 0)
                      _buildTotalRow('discount'.tr, -(order.discountAmount ?? 0)),
                    if ((order.shippingCost ?? 0) > 0)
                      _buildTotalRow('shipping'.tr, order.shippingCost ?? 0),
                    const Divider(),
                    _buildTotalRow('total'.tr, order.totalAmount ?? 0, isBold: true),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
          Text(value, style: robotoMedium),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? robotoBold : robotoRegular),
          PriceConverter.convertPriceWithSvg(amount, textStyle: isBold
                ? robotoBold.copyWith(color: Theme.of(context).primaryColor)
                : robotoMedium,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'partially_received':
        return Colors.orange;
      case 'received':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
