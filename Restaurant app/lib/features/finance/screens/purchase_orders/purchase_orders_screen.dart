import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/widgets/po_card_widget.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['all', 'draft', 'sent', 'received'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<FinanceController>().getPurchaseOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'purchase_orders'.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getCreatePurchaseOrderRoute()),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(HeroiconsOutline.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).disabledColor,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: _tabs.map((tab) => Tab(text: tab.tr)).toList(),
            onTap: (index) {
              Get.find<FinanceController>().getPurchaseOrders(
                status: _tabs[index] == 'all' ? null : _tabs[index],
              );
            },
          ),
          Expanded(
            child: GetBuilder<FinanceController>(builder: (controller) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.purchaseOrders == null || controller.purchaseOrders!.isEmpty) {
                return Center(
                  child: Text(
                    'no_purchase_orders_found'.tr,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.getPurchaseOrders();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: controller.purchaseOrders!.length,
                  itemBuilder: (context, index) {
                    return PoCardWidget(
                      purchaseOrder: controller.purchaseOrders![index],
                      onTap: () {
                        Get.toNamed(RouteHelper.getPurchaseOrderDetailsRoute(
                          controller.purchaseOrders![index].id!,
                        ));
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
