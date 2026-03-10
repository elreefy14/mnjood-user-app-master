import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class InvoiceCardWidget extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback? onTap;

  const InvoiceCardWidget({
    super.key,
    required this.invoice,
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
          border: invoice.isOverdue
              ? Border.all(color: Colors.red.withOpacity(0.5))
              : null,
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
                Text(invoice.invoiceNumber ?? '', style: robotoBold),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              invoice.supplierName ?? 'N/A',
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(HeroiconsOutline.calendar, size: 14, color: Theme.of(context).disabledColor),
                const SizedBox(width: 4),
                Text(
                  '${'due'.tr}: ${invoice.dueDate != null ? DateConverter.dateTimeStringToDate(invoice.dueDate!) : 'N/A'}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: invoice.isOverdue ? Colors.red : Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
            const Divider(height: Dimensions.paddingSizeLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    Text(
                      PriceConverter.convertPrice(invoice.totalAmount ?? 0),
                      style: robotoBold,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'amount_due'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    PriceConverter.convertPriceWithSvg(invoice.amountDue ?? 0, textStyle: robotoBold.copyWith(
                        color: (invoice.amountDue ?? 0) > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if ((invoice.amountPaid ?? 0) > 0) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              LinearProgressIndicator(
                value: invoice.paymentProgress,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  invoice.isPaid ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    switch (invoice.status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'partial':
        color = Colors.blue;
        break;
      case 'paid':
        color = Colors.green;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    if (invoice.isOverdue && invoice.status != 'paid') {
      color = Colors.red;
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
        invoice.isOverdue && invoice.status != 'paid' ? 'overdue'.tr : invoice.statusDisplay,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}
