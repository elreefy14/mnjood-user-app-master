import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/order/domain/models/status_list_model.dart';
import 'package:mnjood_delivery/feature/order/widgets/running_order_card_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/order_list_shimmer.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RunningOrderScreen extends StatefulWidget {
  const RunningOrderScreen({super.key});

  @override
  State<RunningOrderScreen> createState() => _RunningOrderScreenState();
}

class _RunningOrderScreenState extends State<RunningOrderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(OrderController orderController) async {
    setState(() => _isRefreshing = true);
    _refreshController.repeat();
    await orderController.getCurrentOrders(status: orderController.selectedRunningOrderStatus!);
    _refreshController.stop();
    _refreshController.reset();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<StatusListModel> statusList = StatusListModel.getRunningOrderStatusList();
        int orderCount = orderController.currentOrderList?.length ?? 0;

        return SafeArea(
          child: Column(children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Title Row
                Row(children: [
                  // Icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.delivery_dining, color: ColorResources.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'active_deliveries'.tr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                      ),
                      const SizedBox(height: 2),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: orderCount > 0
                                ? ColorResources.green.withOpacity(0.1)
                                : Theme.of(context).hintColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$orderCount',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: orderCount > 0 ? ColorResources.green : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'orders_in_progress'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  // Animated Refresh Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isRefreshing ? null : () => _onRefresh(orderController),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RotationTransition(
                          turns: _refreshController,
                          child: Icon(
                            Icons.refresh_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 18),

                // Enhanced Status Filter Chips
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusList.length,
                    itemBuilder: (context, index) {
                      bool isSelected = orderController.selectedRunningOrderStatus == statusList[index].status;
                      int? count = _getStatusCount(orderController, statusList[index].status);

                      return GestureDetector(
                        onTap: () {
                          orderController.setSelectedRunningOrderStatus(statusList[index].status);
                          orderController.getCurrentOrders(status: statusList[index].status);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: index == statusList.length - 1 ? 0 : 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: isSelected ? LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                            ) : null,
                            color: isSelected ? null : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Theme.of(context).hintColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                statusList[index].statusTitle.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: isSelected
                                      ? ColorResources.white
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (count != null && count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ColorResources.white.withOpacity(0.25)
                                        : Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: robotoBold.copyWith(
                                      fontSize: 10,
                                      color: isSelected
                                          ? ColorResources.white
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),

            // Order List
            Expanded(
              child: orderController.currentOrderList != null
                  ? orderController.currentOrderList!.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () => _onRefresh(orderController),
                          color: Theme.of(context).primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: orderController.currentOrderList!.length,
                            itemBuilder: (context, index) {
                              return RunningOrderCardWidget(
                                orderModel: orderController.currentOrderList![index],
                                index: index,
                              );
                            },
                          ),
                        )
                      : _buildEmptyState(context)
                  : const OrderListShimmer(),
            ),
          ]),
        );
      }),
    );
  }

  int? _getStatusCount(OrderController controller, String status) {
    if (controller.currentOrderCountList == null) return null;
    switch (status) {
      case 'all':
        return controller.currentOrderCountList![0];
      case 'accepted':
        return controller.currentOrderCountList![1];
      case 'arrived_at_store':
        return controller.currentOrderCountList![2];
      case 'confirmed':
        return controller.currentOrderCountList![3];
      case 'processing':
        return controller.currentOrderCountList![4];
      case 'handover':
        return controller.currentOrderCountList![5];
      case 'picked_up':
        return controller.currentOrderCountList![6];
      case 'arrived_at_customer':
        return controller.currentOrderCountList![7];
      default:
        return null;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Animated illustration container
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                  ),
                ),
                // Inner circle with icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.2),
                        Theme.of(context).primaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.delivery_dining_outlined,
                    size: 50,
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'no_active_orders'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'accept_orders_to_start_delivery'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Quick action hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'check_requests_tab'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
