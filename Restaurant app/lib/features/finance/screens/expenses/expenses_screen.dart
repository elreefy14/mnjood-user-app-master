import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/widgets/expense_card_widget.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<FinanceController>();
      controller.getExpenses();
      controller.getExpenseCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'expenses'.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddExpenseRoute()),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(HeroiconsOutline.plus, color: Colors.white),
      ),
      body: GetBuilder<FinanceController>(builder: (controller) {
        return Column(
          children: [
            // Category Filter
            if (controller.expenseCategories != null && controller.expenseCategories!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all'.tr, null, controller),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      ...controller.expenseCategories!.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          child: _buildFilterChip(
                            category.name ?? '',
                            category.id,
                            controller,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            // Expenses List
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.expenses == null || controller.expenses!.isEmpty
                      ? Center(
                          child: Text(
                            'no_expenses_found'.tr,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await controller.getExpenses();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            itemCount: controller.expenses!.length,
                            itemBuilder: (context, index) {
                              return ExpenseCardWidget(
                                expense: controller.expenses![index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, int? categoryId, FinanceController controller) {
    final isSelected = controller.expenseCategoryFilter == categoryId;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (categoryId == null) {
          controller.clearExpenseCategoryFilter();
        } else {
          controller.setExpenseCategoryFilter(categoryId);
        }
        controller.getExpenses(categoryId: categoryId);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
