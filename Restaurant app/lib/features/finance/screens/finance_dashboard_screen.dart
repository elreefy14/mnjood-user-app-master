import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/widgets/finance_summary_card.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<FinanceController>().getOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'finance_management'.tr),
      body: GetBuilder<FinanceController>(builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final overview = controller.overview;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getOverview();
          },
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
                      child: FinanceSummaryCard(
                        title: 'total_payables'.tr,
                        value: PriceConverter.convertPrice(overview?.totalPayables ?? 0),
                        icon: HeroiconsOutline.wallet,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: FinanceSummaryCard(
                        title: 'overdue'.tr,
                        value: PriceConverter.convertPrice(overview?.overduePayables ?? 0),
                        icon: HeroiconsOutline.exclamationTriangle,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Expanded(
                      child: FinanceSummaryCard(
                        title: 'pending_invoices'.tr,
                        value: '${overview?.pendingInvoices ?? 0}',
                        icon: HeroiconsOutline.documentText,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: FinanceSummaryCard(
                        title: 'open_purchase_orders'.tr,
                        value: '${overview?.openPurchaseOrders ?? 0}',
                        icon: HeroiconsOutline.shoppingCart,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                FinanceSummaryCard(
                  title: 'monthly_expenses'.tr,
                  value: PriceConverter.convertPrice(overview?.monthlyExpenses ?? 0),
                  icon: HeroiconsOutline.arrowTrendingDown,
                  color: Colors.purple,
                  fullWidth: true,
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Quick Actions
                Text(
                  'quick_actions'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: HeroiconsOutline.userGroup,
                        label: 'suppliers'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getFinanceSuppliersRoute()),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: HeroiconsOutline.shoppingCart,
                        label: 'purchase_orders'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getFinancePurchaseOrdersRoute()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: HeroiconsOutline.receiptPercent,
                        label: 'invoices'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getFinanceInvoicesRoute()),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: HeroiconsOutline.banknotes,
                        label: 'expenses'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getFinanceExpensesRoute()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _buildQuickActionButton(
                  icon: HeroiconsOutline.chartBar,
                  label: 'financial_reports'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getFinanceReportsRoute()),
                  fullWidth: true,
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Expense Breakdown
                if (overview?.expenseBreakdown != null && overview!.expenseBreakdown!.isNotEmpty) ...[
                  Text(
                    'expense_breakdown'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
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
                      children: overview.expenseBreakdown!.map((expense) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                expense.category ?? 'unknown'.tr,
                                style: robotoRegular,
                              ),
                              Text(
                                PriceConverter.convertPrice(expense.total ?? 0),
                                style: robotoBold,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(label, style: robotoMedium),
          ],
        ),
      ),
    );
  }
}
