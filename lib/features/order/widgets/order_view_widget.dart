import 'package:mnjood/common/enums/order_status.dart';
import 'package:mnjood/common/enums/order_type.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/domain/models/order_details_model.dart';
import 'package:mnjood/features/order/screens/order_details_screen.dart';
import 'package:mnjood/features/order/widgets/order_shimmer_widget.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/review/domain/models/rate_review_model.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/helper/color_coverter.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  final bool isSubscription;
  final bool isCombined;
  const OrderViewWidget({super.key, required this.isRunning, this.isSubscription = false, this.isCombined = false});

  @override
  Widget build(BuildContext context) {
    
    final ScrollController scrollController = ScrollController();
    bool isDeskTop = ResponsiveHelper.isDesktop(context);
    
    return Scaffold(
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<OrderModel>? orderList;
        bool paginate = false;
        int pageSize = 1;
        int offset = 1;
        if(orderController.runningOrderList != null && orderController.historyOrderList != null) {
          if (isCombined) {
            orderList = [...(orderController.runningOrderList ?? []), ...(orderController.historyOrderList ?? [])];
            paginate = orderController.historyPaginate;
            pageSize = ((orderController.historyPageSize ?? 0)/10).ceil();
            offset = orderController.historyOffset;
          } else {
            orderList = isSubscription ? orderController.runningSubscriptionOrderList : isRunning ? orderController.runningOrderList : orderController.historyOrderList;
            paginate = isSubscription ? orderController.runningSubscriptionPaginate : isRunning ? orderController.runningPaginate : orderController.historyPaginate;
            pageSize = isSubscription ? ((orderController.runningSubscriptionPageSize ?? 0)/10).ceil() : isRunning ? ((orderController.runningPageSize ?? 0)/10).ceil() : ((orderController.historyPageSize ?? 0)/10).ceil();
            offset = isSubscription ? orderController.runningSubscriptionOffset : isRunning ? orderController.runningOffset : orderController.historyOffset;
          }
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent && orderList != null && !paginate) {
            if (offset < pageSize) {
              Get.find<OrderController>().setOffset(offset + 1, false, isSubscription);
              debugPrint('end of the page');
              Get.find<OrderController>().showBottomLoader(false, isSubscription);
              Get.find<OrderController>().getHistoryOrders(offset+1);
            }
          }
        });

        return orderList != null ? orderList.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isCombined) {
              await orderController.getRunningOrders(1);
              await orderController.getHistoryOrders(1);
            } else if(isRunning) {
              await orderController.getRunningOrders(1);
            }else if(isSubscription){
              await orderController.getRunningSubscriptionOrders(1);
            }else {
              await orderController.getHistoryOrders(1);
            }
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: FooterViewWidget(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: isDeskTop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge,
                      mainAxisSpacing: isDeskTop ? Dimensions.paddingSizeSmall : 0,
                      crossAxisCount: isDeskTop ? 2 : 1,
                      mainAxisExtent: isDeskTop ? 195 : 175
                    ),
                    padding: isDeskTop ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemCount: orderList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {

                      String dineInOrderStatus = '';
                      String? orderStatus = orderList![index].orderStatus;
                      bool isDineIn = orderList[index].orderType == OrderType.dine_in.name;
                      bool isDelivery = orderList[index].orderType == OrderType.delivery.name;
                      bool delivered = orderList[index].orderStatus == OrderStatus.delivered.name;
                      bool cancelled = orderList[index].orderStatus == OrderStatus.canceled.name;
                      bool failed = orderList[index].orderStatus == OrderStatus.failed.name;
                      bool refundRequestCanceled = orderList[index].orderStatus == OrderStatus.refund_request_canceled.name;
                      bool isOrderRunning = isCombined ? !(delivered || cancelled || failed || refundRequestCanceled
                          || orderList[index].orderStatus == OrderStatus.refunded.name) : isRunning;

                      if(isDineIn) {
                        dineInOrderStatus = orderStatus == OrderStatus.processing.name ? 'cooking'.tr
                          : orderStatus == OrderStatus.handover.name ? 'ready_to_serve'.tr
                          : orderStatus == OrderStatus.pending.name ? 'pending'.tr
                          : orderStatus == OrderStatus.canceled.name ? 'canceled'.tr
                          : orderStatus == OrderStatus.confirmed.name ? 'confirmed'.tr
                          : 'served'.tr;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                          ),
                          child: CustomInkWellWidget(
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.getOrderDetailsRoute(orderList![index].id),
                                arguments: OrderDetailsScreen(orderId: orderList[index].id, orderModel: orderList[index]),
                              );
                            },
                            radius: Dimensions.radiusDefault,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                              Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Column(
                                  children: [
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                      Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          child: CustomImageWidget(
                                            image: orderList[index].restaurant?.logoFullUrl ?? '',
                                            height: 40, width: 40, fit: BoxFit.cover, isRestaurant: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                          Text('${'order'.tr} # ${orderList[index].id}', style: robotoBold),
                                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                          Text(
                                            DateConverter.dateTimeStringToDateTimeToLines(orderList[index].createdAt ?? ''),
                                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                          ),

                                        ]),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                        margin: EdgeInsets.only(bottom: isDeskTop ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeDefault),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          color: ColorConverter.getStatusColor(orderStatus ?? 'pending').withValues(alpha: 0.15),
                                        ),
                                        child: Text(
                                          isDineIn ? dineInOrderStatus : (orderStatus ?? 'pending').tr,
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: ColorConverter.getStatusColor(orderStatus ?? 'pending')),
                                        ),
                                      ),

                                    ]),
                                    SizedBox(height: Dimensions.paddingSizeDefault),

                                    Row(children: [

                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                                color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                                              ),
                                              child: Text(
                                                '${orderList[index].detailsCount ?? 0} ${(orderList[index].detailsCount ?? 0) > 1 ? 'items'.tr : 'item'.tr}',
                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if ((orderList[index].chatCount ?? 0) > 0 || orderList[index].hasActiveChat == true)
                                        Padding(
                                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            Icon(Icons.chat_bubble, size: 12, color: Theme.of(context).primaryColor),
                                            const SizedBox(width: 2),
                                            Text('${orderList[index].chatCount ?? 0}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                                          ]),
                                        ),

                                      SizedBox(width: Dimensions.paddingSizeLarge),

                                      Expanded(
                                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [

                                          Icon(HeroiconsOutline.buildingStorefront, size: 20, color: Theme.of(context).disabledColor.withValues(alpha: 0.6)),
                                          SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                          Flexible(
                                            child: Text(
                                              orderList[index].restaurant?.name ?? '',
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                              overflow: TextOverflow.ellipsis, maxLines: 1,
                                            ),
                                          ),

                                        ]),
                                      ),

                                    ]),
                                  ],
                                ),
                              ),
                              SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Container(
                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                  PriceConverter.convertPriceWithSvg(orderList[index].orderAmount, textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  ),

                                  (isOrderRunning || isSubscription) ? isDelivery ? InkWell(
                                    onTap: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(orderList![index].id)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                        color: Theme.of(context).primaryColor,
                                        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                      ),
                                      child: Text('track_order'.tr, style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor,
                                      )),
                                    ),
                                  ) : const SizedBox() : Row(children: [

                                    (!isSubscription && delivered && orderList[index].itemCampaignId == null) ? InkWell(
                                      onTap: () async {
                                        await Get.find<OrderController>().getOrderDetails(orderList![index].id.toString());

                                        List<OrderDetailsModel> orderDetailsList = [];
                                        List<int?> orderDetailsIdList = [];
                                        for (var orderDetail in orderController.orderDetails!) {
                                          if(!orderDetailsIdList.contains(orderDetail.foodDetails!.id)) {
                                            orderDetailsList.add(orderDetail);
                                            orderDetailsIdList.add(orderDetail.foodDetails!.id);
                                          }
                                        }
                                        orderController.cancelTimer();
                                        RateReviewModel rateReviewModel = RateReviewModel(orderDetailsList: orderDetailsList, deliveryMan: orderList[index].deliveryMan);
                                        await Get.toNamed(RouteHelper.getReviewRoute(rateReviewModel));
                                        orderController.callTrackOrderApi(orderModel: orderList[index], orderId: orderList[index].id.toString(), contactNumber: orderList[index].deliveryAddress?.contactPersonNumber);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 7),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                        ),
                                        child: Text('give_review'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                      ),
                                    ) : SizedBox(),
                                    SizedBox(width: (!isSubscription && delivered && orderList[index].itemCampaignId == null) ? Dimensions.paddingSizeSmall : 0),

                                    !isSubscription && (Get.find<SplashController>().configModel?.repeatOrderOption ?? false) && (delivered || cancelled || failed || refundRequestCanceled)
                                        ? orderList[index].itemCampaignId == null ? InkWell(
                                      onTap: () async {
                                        await Get.find<OrderController>().getOrderDetails(orderList![index].id.toString());
                                        orderController.reOrder(orderController.orderDetails!, orderList[index].restaurant?.zoneId);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 7),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                                          color: Theme.of(context).primaryColor,
                                          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                        ),
                                        child: Text('buy_again'.tr, style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor,
                                        )),
                                      ),
                                    ) : SizedBox() : SizedBox(),

                                  ]),

                                ]),
                              ),

                            ]),
                          ),
                        ),
                      );
                    },
                  ),

                  paginate ? const Center(child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CircularProgressIndicator(),
                  )) : const SizedBox(),
                ]),
              ),
            )),
          ),
        ) : SingleChildScrollView(child: FooterViewWidget(child: NoDataScreen(title: 'no_order_yet'.tr, isEmptyOrder: true))) : OrderShimmerWidget(orderController: orderController);
      }),
    );
  }
}
