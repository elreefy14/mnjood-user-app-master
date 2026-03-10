import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/order/domain/models/status_list_model.dart';
import 'package:mnjood_delivery/feature/order/widgets/history_order_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/order_button_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/order_list_shimmer.dart';
import 'package:mnjood_delivery/helper/custom_print_helper.dart';
import 'package:mnjood_delivery/helper/date_converter_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_delivery/util/styles.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getCompletedOrders(offset: 1, status: 'all', isUpdate: false);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<OrderController>().completedOrderList != null && !Get.find<OrderController>().paginate) {
        int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
        if (Get.find<OrderController>().offset < pageSize) {
          Get.find<OrderController>().setOffset(Get.find<OrderController>().offset+1);
          customPrint('end of the page');
          Get.find<OrderController>().showBottomLoader();
          Get.find<OrderController>().getCompletedOrders(offset: Get.find<OrderController>().offset, status: Get.find<OrderController>().selectedMyOrderStatus!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'my_orders'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        centerTitle: false,
      ),

      body: GetBuilder<OrderController>(builder: (orderController) {

        List<StatusListModel> statusList = StatusListModel.getMyOrderStatusList();
        int totalOrders = orderController.completedOrderList?.length ?? 0;

        return Column(children: [

          // Order count + filter chips
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeSmall,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Total count
              if (orderController.completedOrderList != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Text(
                    '$totalOrders ${'orders'.tr}',
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),

              // Status filter chips
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: statusList.length,
                  itemBuilder: (context, index) {
                    return OrderButtonWidget(
                      statusListModel: statusList[index],
                      index: index,
                      orderController: orderController,
                      fromMyOrder: true,
                    );
                  },
                ),
              ),

            ]),
          ),

          // Divider line
          Container(
            height: 1,
            color: Theme.of(context).disabledColor.withOpacity(0.1),
          ),

          // Order list
          Expanded(
            child: orderController.completedOrderList != null
              ? orderController.completedOrderList!.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () async {
                      await orderController.getCompletedOrders(
                        offset: 1,
                        status: Get.find<OrderController>().selectedMyOrderStatus!,
                      );
                    },
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ..._buildGroupedOrderWidgets(orderController.completedOrderList!),
                        if (orderController.paginate)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ]),
                    ),
                  )
                : Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        HeroiconsOutline.clipboardDocumentList,
                        size: 60,
                        color: Theme.of(context).disabledColor.withOpacity(0.4),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        'no_order_found'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).disabledColor,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ]),
                  )
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: OrderListShimmer(),
                ),
          ),

        ]);
      }),
    );
  }

  List<Widget> _buildGroupedOrderWidgets(List orders) {
    final List<Widget> widgets = [];
    final now = DateTime.now();

    final Map<String, List> grouped = {};

    for (var order in orders) {
      final createdDate = DateTime.tryParse(order.createdAt ?? '') ?? now;
      String label;

      if (_isSameDate(createdDate, now)) {
        label = 'today'.tr;
      } else if (_isSameDate(createdDate, now.subtract(const Duration(days: 1)))) {
        label = 'yesterday'.tr;
      } else {
        label = DateConverter.estimatedDate(createdDate);
      }

      grouped.putIfAbsent(label, () => []).add(order);
    }

    grouped.forEach((label, list) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeExtraSmall),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ));

      for (int i = 0; i < list.length; i++) {
        widgets.add(HistoryOrderWidget(
          orderModel: list[i],
          isRunning: false,
          index: i,
        ));
      }
    });

    return widgets;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}
