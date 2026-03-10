import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class SupplierDetailsScreen extends StatefulWidget {
  final int supplierId;

  const SupplierDetailsScreen({super.key, required this.supplierId});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<FinanceController>().getSupplier(widget.supplierId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'supplier_details'.tr,
        menuWidget: GetBuilder<FinanceController>(builder: (controller) {
          if (controller.selectedSupplier != null) {
            return IconButton(
              icon: const Icon(HeroiconsOutline.pencil),
              onPressed: () {
                Get.toNamed(
                  RouteHelper.getAddSupplierRoute(),
                  arguments: controller.selectedSupplier,
                );
              },
            );
          }
          return const SizedBox();
        }),
      ),
      body: GetBuilder<FinanceController>(builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final supplier = controller.selectedSupplier;
        if (supplier == null) {
          return Center(
            child: Text('supplier_not_found'.tr),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Text(
                          (supplier.name ?? 'S').substring(0, 1).toUpperCase(),
                          style: robotoBold.copyWith(
                            fontSize: 36,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(supplier.name ?? '', style: robotoBold.copyWith(fontSize: 18)),
                    if (supplier.contactPerson != null)
                      Text(
                        supplier.contactPerson!,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: supplier.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        supplier.isActive ? 'active'.tr : 'inactive'.tr,
                        style: robotoRegular.copyWith(
                          color: supplier.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Outstanding Balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: (supplier.outstandingBalance ?? 0) > 0
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('outstanding_balance'.tr, style: robotoMedium),
                    PriceConverter.convertPriceWithSvg(supplier.outstandingBalance ?? 0, textStyle: robotoBold.copyWith(
                        color: (supplier.outstandingBalance ?? 0) > 0 ? Colors.red : Colors.green,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Contact Info
              _buildSection('contact_info'.tr, [
                _buildInfoRow(HeroiconsOutline.phone, 'phone'.tr, supplier.phone),
                _buildInfoRow(HeroiconsOutline.envelope, 'email'.tr, supplier.email),
                _buildInfoRow(HeroiconsOutline.mapPin, 'address'.tr, supplier.address),
                _buildInfoRow(HeroiconsOutline.buildingOffice2, 'city'.tr, supplier.city),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Payment Info
              _buildSection('payment_info'.tr, [
                _buildInfoRow(HeroiconsOutline.clock, 'payment_terms'.tr, supplier.paymentTermsDisplay),
                _buildInfoRow(
                  HeroiconsOutline.creditCard,
                  'credit_limit'.tr,
                  PriceConverter.convertPrice(supplier.creditLimit ?? 0),
                ),
                _buildInfoRow(HeroiconsOutline.receiptPercent, 'tax_number'.tr, supplier.taxNumber),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Bank Details
              if (supplier.bankName != null || supplier.bankAccount != null || supplier.iban != null)
                _buildSection('bank_details'.tr, [
                  _buildInfoRow(HeroiconsOutline.buildingLibrary, 'bank_name'.tr, supplier.bankName),
                  _buildInfoRow(HeroiconsOutline.creditCard, 'bank_account'.tr, supplier.bankAccount),
                  _buildInfoRow(HeroiconsOutline.ticket, 'iban'.tr, supplier.iban),
                ]),

              if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _buildSection('notes'.tr, [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(supplier.notes!, style: robotoRegular),
                  ),
                ]),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: robotoBold),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).disabledColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                Text(value, style: robotoMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
