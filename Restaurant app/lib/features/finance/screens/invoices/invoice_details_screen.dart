import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<FinanceController>().getInvoice(widget.invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'invoice_details'.tr),
      body: GetBuilder<FinanceController>(builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final invoice = controller.selectedInvoice;
        if (invoice == null) {
          return Center(child: Text('invoice_not_found'.tr));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                              Text(invoice.invoiceNumber ?? '', style: robotoBold.copyWith(fontSize: 18)),
                              _buildStatusBadge(invoice),
                            ],
                          ),
                          const Divider(height: Dimensions.paddingSizeLarge),
                          _buildInfoRow('supplier'.tr, invoice.supplierName ?? 'N/A'),
                          _buildInfoRow('supplier_invoice'.tr, invoice.supplierInvoiceNumber ?? 'N/A'),
                          _buildInfoRow(
                            'invoice_date'.tr,
                            invoice.invoiceDate != null
                                ? DateConverter.convertDateToDate(invoice.invoiceDate!)
                                : 'N/A',
                          ),
                          _buildInfoRow(
                            'due_date'.tr,
                            invoice.dueDate != null
                                ? DateConverter.convertDateToDate(invoice.dueDate!)
                                : 'N/A',
                            valueColor: invoice.isOverdue ? Colors.red : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Amount Summary
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(
                        children: [
                          _buildAmountRow('subtotal'.tr, invoice.subtotal ?? 0),
                          _buildAmountRow('tax'.tr, invoice.taxAmount ?? 0),
                          const Divider(),
                          _buildAmountRow('total'.tr, invoice.totalAmount ?? 0, isBold: true),
                          _buildAmountRow('amount_paid'.tr, invoice.amountPaid ?? 0, color: Colors.green),
                          _buildAmountRow('amount_due'.tr, invoice.amountDue ?? 0,
                              color: (invoice.amountDue ?? 0) > 0 ? Colors.red : Colors.green,
                              isBold: true),
                        ],
                      ),
                    ),

                    if ((invoice.amountPaid ?? 0) > 0) ...[
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      LinearProgressIndicator(
                        value: invoice.paymentProgress,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          invoice.isPaid ? Colors.green : Theme.of(context).primaryColor,
                        ),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(invoice.paymentProgress * 100).toStringAsFixed(0)}% ${'paid'.tr}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],

                    // Payment History
                    if (invoice.payments != null && invoice.payments!.isNotEmpty) ...[
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Text('payment_history'.tr, style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ...invoice.payments!.map((payment) => Container(
                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: const Icon(HeroiconsOutline.banknotes, color: Colors.green),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeDefault),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        PriceConverter.convertPrice(payment.amount ?? 0),
                                        style: robotoBold,
                                      ),
                                      Text(
                                        payment.paymentMethodDisplay,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  payment.paymentDate != null
                                      ? DateConverter.convertDateToDate(payment.paymentDate!)
                                      : '',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),

            // Record Payment Button
            if (!invoice.isPaid)
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: CustomButtonWidget(
                  buttonText: 'record_payment'.tr,
                  onPressed: () => _showPaymentDialog(context, invoice),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
          Text(value, style: robotoMedium.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? robotoBold : robotoRegular),
          PriceConverter.convertPriceWithSvg(amount, textStyle: isBold
                ? robotoBold.copyWith(color: color ?? Theme.of(context).primaryColor)
                : robotoMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceModel invoice) {
    Color color;
    String text;

    if (invoice.isOverdue && !invoice.isPaid) {
      color = Colors.red;
      text = 'overdue'.tr;
    } else {
      switch (invoice.status) {
        case 'pending':
          color = Colors.orange;
          text = 'pending'.tr;
          break;
        case 'partial':
          color = Colors.blue;
          text = 'partial'.tr;
          break;
        case 'paid':
          color = Colors.green;
          text = 'paid'.tr;
          break;
        default:
          color = Colors.grey;
          text = invoice.status ?? 'unknown';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(text, style: robotoMedium.copyWith(color: color)),
    );
  }

  void _showPaymentDialog(BuildContext context, InvoiceModel invoice) {
    final amountController = TextEditingController();
    String selectedMethod = 'cash';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('record_payment'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${'amount_due'.tr}: ${PriceConverter.convertPrice(invoice.amountDue ?? 0)}'),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'amount'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            DropdownButtonFormField<String>(
              value: selectedMethod,
              decoration: InputDecoration(
                labelText: 'payment_method'.tr,
                border: const OutlineInputBorder(),
              ),
              items: ['cash', 'bank_transfer', 'check', 'card'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method.tr));
              }).toList(),
              onChanged: (value) => selectedMethod = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                showCustomSnackBar('please_enter_valid_amount'.tr);
                return;
              }
              if (amount > (invoice.amountDue ?? 0)) {
                showCustomSnackBar('amount_exceeds_due'.tr);
                return;
              }

              Navigator.pop(context);

              final payment = PaymentRecordModel(
                amount: amount,
                paymentMethod: selectedMethod,
                paymentDate: DateTime.now().toIso8601String().split('T')[0],
              );

              final success = await Get.find<FinanceController>()
                  .recordPayment(invoice.id!, payment);

              if (success) {
                showCustomSnackBar('payment_recorded'.tr, isError: false);
              }
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
    );
  }
}
