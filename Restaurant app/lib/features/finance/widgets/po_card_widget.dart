import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/features/finance/domain/models/purchase_order_model.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class PoCardWidget extends StatelessWidget {
  final PurchaseOrderModel purchaseOrder;
  final VoidCallback? onTap;

  const PoCardWidget({
    super.key,
    required this.purchaseOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchaseOrder.poNumber ?? '',
                  style: robotoBold,
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              children: [
                Icon(HeroiconsOutline.buildingOffice, size: 16, color: Theme.of(context).disabledColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    purchaseOrder.supplierName ?? 'N/A',
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(HeroiconsOutline.calendar, size: 16, color: Theme.of(context).disabledColor),
                const SizedBox(width: 4),
                Text(
                  purchaseOrder.orderDate != null
                      ? DateConverter.convertDateToDate(purchaseOrder.orderDate!)
                      : 'N/A',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
            const Divider(height: Dimensions.paddingSizeLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total'.tr + ':', style: robotoRegular),
                PriceConverter.convertPriceWithSvg(purchaseOrder.totalAmount ?? 0, textStyle: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    switch (purchaseOrder.status) {
      case 'draft':
        color = Colors.grey;
        break;
      case 'sent':
        color = Colors.blue;
        break;
      case 'partially_received':
        color = Colors.orange;
        break;
      case 'received':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        purchaseOrder.statusDisplay,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}
