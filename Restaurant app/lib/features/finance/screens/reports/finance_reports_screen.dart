import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class FinanceReportsScreen extends StatefulWidget {
  const FinanceReportsScreen({super.key});

  @override
  State<FinanceReportsScreen> createState() => _FinanceReportsScreenState();
}

class _FinanceReportsScreenState extends State<FinanceReportsScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  void _loadReports() {
    Get.find<FinanceController>().getReports(
      fromDate: _fromDate.toIso8601String().split('T')[0],
      toDate: _toDate.toIso8601String().split('T')[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'financial_reports'.tr),
      body: GetBuilder<FinanceController>(builder: (controller) {
        return Column(
          children: [
            // Date Range Selector
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'from'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            Text(
                              '${_fromDate.day}/${_fromDate.month}/${_fromDate.year}',
                              style: robotoMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(HeroiconsOutline.arrowRight),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'to'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            Text(
                              '${_toDate.day}/${_toDate.month}/${_toDate.year}',
                              style: robotoMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.report == null
                      ? Center(child: Text('no_data'.tr))
                      : RefreshIndicator(
                          onRefresh: () async => _loadReports(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Summary Cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSummaryCard(
                                        'total_purchases'.tr,
                                        controller.report!.totalPurchases ?? 0,
                                        HeroiconsOutline.shoppingCart,
                                        Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                      child: _buildSummaryCard(
                                        'total_payments'.tr,
                                        controller.report!.totalPayments ?? 0,
                                        HeroiconsOutline.banknotes,
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                _buildSummaryCard(
                                  'total_expenses'.tr,
                                  controller.report!.totalExpenses ?? 0,
                                  HeroiconsOutline.banknotes,
                                  Colors.red,
                                  fullWidth: true,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                                // Top Suppliers
                                if (controller.report!.topSuppliers != null &&
                                    controller.report!.topSuppliers!.isNotEmpty) ...[
                                  Text('top_suppliers'.tr, style: robotoBold),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  Container(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: Column(
                                      children: controller.report!.topSuppliers!.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final supplier = entry.value;
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: _getRankColor(index).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: robotoBold.copyWith(
                                                        color: _getRankColor(index),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeDefault),
                                                Expanded(
                                                  child: Text(supplier.supplier ?? 'N/A', style: robotoMedium),
                                                ),
                                                PriceConverter.convertPriceWithSvg(supplier.total ?? 0, textStyle: robotoBold.copyWith(
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (index < controller.report!.topSuppliers!.length - 1)
                                              const Divider(),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                PriceConverter.convertPriceWithSvg(amount, textStyle: robotoBold.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  Future<void> _selectDate(bool isFrom) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isFrom) {
          _fromDate = date;
        } else {
          _toDate = date;
        }
      });
      _loadReports();
    }
  }
}
