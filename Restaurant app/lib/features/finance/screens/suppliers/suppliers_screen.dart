import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/widgets/supplier_card_widget.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<FinanceController>().getSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'suppliers'.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddSupplierRoute()),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(HeroiconsOutline.plus, color: Colors.white),
      ),
      body: GetBuilder<FinanceController>(builder: (controller) {
        return Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'search_suppliers'.tr,
                      prefixIcon: const Icon(HeroiconsOutline.magnifyingGlass),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(HeroiconsOutline.xMark),
                              onPressed: () {
                                _searchController.clear();
                                controller.getSuppliers();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                    ),
                    onSubmitted: (value) {
                      controller.getSuppliers(search: value);
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all'.tr, 'all', controller),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        _buildFilterChip('active'.tr, 'active', controller),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        _buildFilterChip('inactive'.tr, 'inactive', controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Suppliers List
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.suppliers == null || controller.suppliers!.isEmpty
                      ? Center(
                          child: Text(
                            'no_suppliers_found'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await controller.getSuppliers(search: _searchController.text);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            itemCount: controller.suppliers!.length,
                            itemBuilder: (context, index) {
                              return SupplierCardWidget(
                                supplier: controller.suppliers![index],
                                onTap: () {
                                  Get.toNamed(RouteHelper.getSupplierDetailsRoute(
                                    controller.suppliers![index].id!,
                                  ));
                                },
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

  Widget _buildFilterChip(String label, String value, FinanceController controller) {
    final isSelected = controller.supplierStatusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.getSuppliers(status: value, search: _searchController.text);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
