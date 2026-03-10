import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/feature/order/screens/order_details_screen.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunningOrder;
  final int orderIndex;
  const OrderWidget({super.key, required this.orderModel, required this.isRunningOrder, required this.orderIndex});

  @override
  Widget build(BuildContext context) {
    bool isPaid = orderModel.paymentStatus == 'paid';
    bool isPickedUp = orderModel.orderStatus == 'picked_up';

    return InkWell(
      onTap: () {
        Get.toNamed(
          RouteHelper.getOrderDetailsRoute(orderModel.id),
          arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: isRunningOrder, orderIndex: orderIndex),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(children: [
              // Order Info
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'order'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text(
                      '# ${orderModel.id}',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${orderModel.detailsCount} ${'item'.tr})',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ]),
                ]),
              ),

              // Chat Badge
              if ((orderModel.chatCount ?? 0) > 0 || orderModel.hasActiveChat == true)
                Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.chat_bubble, size: 12, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 2),
                    Text('${orderModel.chatCount ?? 0}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                  ]),
                ),

              // Payment Status & Method
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? 'paid'.tr : 'unpaid'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isPaid ? Colors.green : ColorResources.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderModel.paymentMethod == 'cash_on_delivery' ? 'COD' : 'digitally_paid'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ]),
            ]),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Location Row
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPickedUp ? HeroiconsOutline.user : HeroiconsOutline.buildingStorefront,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPickedUp ? 'customer_location'.tr : orderModel.restaurantName ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Address Row with Direction
              Row(children: [
                Icon(
                  HeroiconsOutline.mapPin,
                  size: 18,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPickedUp
                        ? orderModel.deliveryAddress!.address.toString()
                        : orderModel.restaurantAddress ?? '',
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Direction Button
                InkWell(
                  onTap: () async {
                    String url;
                    if (isPickedUp) {
                      url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.deliveryAddress!.latitude}'
                          ',${orderModel.deliveryAddress!.longitude}&mode=d';
                    } else {
                      url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.restaurantLat ?? '0'}'
                          ',${orderModel.restaurantLng ?? '0'}&mode=d';
                    }
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url, mode: LaunchMode.externalApplication);
                    } else {
                      showCustomSnackBar('${'could_not_launch'.tr} $url');
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        HeroiconsOutline.arrowTrendingUp,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'direction'.tr,
                        style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Details Link
              Text(
                'details'.tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                ),
              ),
            ]),
          ),

        ]),
      ),
    );
  }
}
