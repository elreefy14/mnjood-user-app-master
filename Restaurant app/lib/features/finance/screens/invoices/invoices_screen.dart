import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/widgets/invoice_card_widget.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['all', 'pending', 'partial', 'paid', 'overdue'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<FinanceController>().getInvoices();
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
      appBar: CustomAppBarWidget(title: 'invoices'.tr),
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
              Get.find<FinanceController>().getInvoices(
                status: _tabs[index] == 'all' ? null : _tabs[index],
              );
            },
          ),
          Expanded(
            child: GetBuilder<FinanceController>(builder: (controller) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.invoices == null || controller.invoices!.isEmpty) {
                return Center(
                  child: Text(
                    'no_invoices_found'.tr,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.getInvoices();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: controller.invoices!.length,
                  itemBuilder: (context, index) {
                    return InvoiceCardWidget(
                      invoice: controller.invoices![index],
                      onTap: () {
                        Get.toNamed(RouteHelper.getInvoiceDetailsRoute(
                          controller.invoices![index].id!,
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
