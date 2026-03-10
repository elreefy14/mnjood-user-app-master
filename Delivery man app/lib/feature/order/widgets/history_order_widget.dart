import 'package:mnjood_delivery/common/widgets/details_custom_card.dart';
import 'package:mnjood_delivery/feature/order/screens/order_details_screen.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/helper/date_converter_helper.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/helper/string_extensions.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/images.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryOrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunning;
  final int index;
  const HistoryOrderWidget({super.key, required this.orderModel, required this.isRunning, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(
        RouteHelper.getOrderDetailsRoute(orderModel.id),
        arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: isRunning, orderIndex: index),
      ),
      child: DetailsCustomCard(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: Column(children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.15),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Row(children: [
              Text('${'order'.tr} # ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

              Text('${orderModel.id} ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),

              Text('(${orderModel.detailsCount} ${'item'.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

              const Expanded(child: SizedBox()),

              if ((orderModel.chatCount ?? 0) > 0 || orderModel.hasActiveChat == true)
                Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.chat_bubble, size: 12, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 2),
                    Text('${orderModel.chatCount ?? 0}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                  ]),
                ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 3),
                decoration: BoxDecoration(
                  color: orderModel.orderStatus == 'pending' ? ColorResources.blue.withOpacity(0.1)
                    : (orderModel.orderStatus == 'accepted' || orderModel.orderStatus == 'confirmed' || orderModel.orderStatus == 'delivered') ? ColorResources.green.withOpacity(0.1)
                    : orderModel.orderStatus == 'canceled' ? ColorResources.red.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  (orderModel.orderStatus ?? 'pending').toTitleCase(),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: orderModel.orderStatus == 'pending' ? ColorResources.blue
                      : (orderModel.orderStatus == 'accepted' || orderModel.orderStatus == 'confirmed' || orderModel.orderStatus == 'delivered') ? ColorResources.green
                      : orderModel.orderStatus == 'canceled' ? ColorResources.red : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Image.asset(Images.house, width: 20, height: 20),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  orderModel.restaurantName ?? 'no_restaurant_data_found'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Spacer(),

                Text(
                  orderModel.createdAt != null ? DateConverter.dateTimeStringToTime(orderModel.createdAt!) : '',
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                orderModel.orderType == 'delivery' ? 'home_delivery'.tr : (orderModel.orderType ?? 'delivery').toTitleCase(),
                style: robotoMedium.copyWith(
                  color: orderModel.orderType == 'delivery' ? ColorResources.blue : Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),

        ]),
      ),
    );
  }
}