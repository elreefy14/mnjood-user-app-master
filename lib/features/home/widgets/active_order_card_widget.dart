import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ActiveOrderCardWidget extends StatelessWidget {
  const ActiveOrderCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final orders = orderController.runningOrderList;
      if (orders == null || orders.isEmpty) return const SizedBox();

      final order = orders.first;
      final status = order.orderStatus ?? '';

      // Don't show for completed/cancelled/failed
      if (['delivered', 'canceled', 'failed', 'refund_requested', 'refunded'].contains(status)) {
        return const SizedBox();
      }

      final progress = _getProgress(status);
      final statusColor = _getStatusColor(status, context);
      final statusText = _getStatusText(status);

      return GestureDetector(
        onTap: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(order.id)),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Icon(HeroiconsSolid.shoppingBag, size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '${'active_order'.tr} #${order.id}',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: statusColor),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  'view_order'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(HeroiconsOutline.chevronRight, size: 14, color: Theme.of(context).primaryColor),
              ]),
            ),
          ]),
        ),
      );
    });
  }

  double _getProgress(String status) {
    switch (status) {
      case 'pending': return 0.1;
      case 'confirmed':
      case 'accepted': return 0.25;
      case 'processing':
      case 'cooking': return 0.5;
      case 'handover':
      case 'picked_up': return 0.75;
      case 'delivered': return 1.0;
      default: return 0.1;
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'pending': return Colors.grey;
      case 'confirmed':
      case 'accepted': return Theme.of(context).primaryColor;
      case 'processing':
      case 'cooking': return Colors.orange;
      case 'handover':
      case 'picked_up': return const Color(0xFFDA281C);
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'pending'.tr;
      case 'confirmed':
      case 'accepted': return 'confirmed'.tr;
      case 'processing':
      case 'cooking': return 'preparing_your_order'.tr;
      case 'handover':
      case 'picked_up': return 'on_the_way'.tr;
      case 'delivered': return 'delivered'.tr;
      default: return status.tr;
    }
  }
}
