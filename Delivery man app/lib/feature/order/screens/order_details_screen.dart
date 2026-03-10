import 'dart:async';
import 'dart:io';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_card.dart';
import 'package:mnjood_delivery/common/widgets/custom_tool_tip_widget.dart';
import 'package:mnjood_delivery/common/widgets/details_custom_card.dart';
import 'package:mnjood_delivery/feature/language/controllers/localization_controller.dart';
import 'package:mnjood_delivery/feature/notification/controllers/notification_controller.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/order/widgets/order_details_shimmer.dart';
import 'package:mnjood_delivery/feature/splash/controllers/splash_controller.dart';
import 'package:mnjood_delivery/feature/notification/domain/models/notification_body_model.dart';
import 'package:mnjood_delivery/feature/chat/domain/models/conversation_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_details_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/substitution_proposal_model.dart';
import 'package:mnjood_delivery/feature/order/widgets/camera_button_sheet_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/cancellation_dialogue_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/collect_money_delivery_sheet_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/dialogue_image_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/info_card_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/order_product_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/order_step_progress_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/pickup_photo_bottom_sheet.dart';
import 'package:mnjood_delivery/feature/order/widgets/slider_button_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:mnjood_delivery/feature/order/widgets/waiting_timer_widget.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/helper/date_converter_helper.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/helper/responsive_helper.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/helper/string_extensions.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_button_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_image_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  final String? orderStatus;
  const OrderDetailsScreen({super.key, required this.orderId, required this.isRunningOrder, required this.orderIndex, this.fromNotification = false, this.orderStatus});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  Timer? _timer;
  int? orderPosition;

  void _startApiCalling(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(Get.find<OrderController>().orderModel!.id);
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    if(Get.find<OrderController>().showDeliveryImageField){
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
    if(widget.orderIndex == null){
      await Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus ?? 'accepted');
      for(int index=0; index<(Get.find<OrderController>().currentOrderList?.length ?? 0); index++) {
        if(Get.find<OrderController>().currentOrderList![index].id == widget.orderId){
          orderPosition = index;
          break;
        }
      }
    }
    Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId);
  }

  @override
  void initState() {
    super.initState();

    orderPosition = widget.orderIndex;

    _loadData();
    _startApiCalling();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {

    bool? cancelPermission = Get.find<SplashController>().configModel!.canceledByDeliveryman;
    bool selfDelivery = Get.find<ProfileController>().profileModel!.type != 'zone_wise';

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }else {
          return;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Scaffold(
          appBar: AppBar(
            title: Column(children: [
              Text(
                '${'order'.tr} #${widget.orderId}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(orderController.orderModel?.orderStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderController.orderModel?.orderStatus?.tr.capitalizeFirst ?? '',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: _getStatusColor(orderController.orderModel?.orderStatus),
                  ),
                ),
              ),
            ]),
            centerTitle: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(HeroiconsOutline.arrowLeft, size: 20),
                color: Theme.of(context).textTheme.bodyLarge!.color,
                onPressed: () {
                  if (widget.fromNotification) {
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getOrderChatRoute(widget.orderId ?? 0)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Badge(
                      isLabelVisible: (orderController.orderModel?.chatCount ?? 0) > 0,
                      label: Text('${orderController.orderModel?.chatCount ?? 0}', style: const TextStyle(fontSize: 8, color: Colors.white)),
                      child: Icon(Icons.chat_bubble_outline, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ),
                ),
              ),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(0),
            child: GetBuilder<OrderController>(builder: (orderController) {

              OrderModel? controllerOrderModel = orderController.orderModel;

              bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';

              late bool showBottomView;
              bool showDeliveryConfirmImage = orderController.showDeliveryImageField && Get.find<SplashController>().configModel!.dmPictureUploadStatus!;

              double? deliveryCharge = 0;
              double itemsPrice = 0;
              double? discount = 0;
              double? couponDiscount = 0;
              double? dmTips = 0;
              double? tax = 0;
              bool? taxIncluded = false;
              double addOns = 0;
              double additionalCharge = 0;
              double extraPackagingAmount = 0;
              double referrerBonusAmount = 0;
              OrderModel? order = controllerOrderModel;

              if(order != null && orderController.orderDetailsModel != null ) {

                if(order.orderType == 'delivery') {
                  deliveryCharge = order.deliveryCharge;
                  dmTips = order.dmTips;
                }
                discount = order.restaurantDiscountAmount;
                tax = order.totalTaxAmount;
                taxIncluded = order.taxStatus;
                couponDiscount = order.couponDiscountAmount;
                additionalCharge = order.additionalCharge!;
                extraPackagingAmount = order.extraPackagingAmount!;
                referrerBonusAmount = order.referrerBonusAmount!;
                for(OrderDetailsModel orderDetails in orderController.orderDetailsModel!) {
                  for(AddOn addOn in orderDetails.addOns!) {
                    addOns = addOns + (addOn.price! * addOn.quantity!);
                  }
                  itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
                }
              }
              //double subTotal = itemsPrice + addOns;
              double total = itemsPrice + addOns - discount! + (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips! + additionalCharge + extraPackagingAmount - referrerBonusAmount;

              if(controllerOrderModel != null){
                showBottomView = controllerOrderModel.orderStatus == 'accepted' || controllerOrderModel.orderStatus == 'confirmed'
                    || controllerOrderModel.orderStatus == 'processing' || controllerOrderModel.orderStatus == 'handover'
                    || controllerOrderModel.orderStatus == 'picked_up' || controllerOrderModel.orderStatus == 'arrived_at_store'
                    || controllerOrderModel.orderStatus == 'arrived_at_customer' || (widget.isRunningOrder ?? true);
              }

              return (orderController.orderDetailsModel != null && controllerOrderModel != null && order != null) ? Column(children: [

                Expanded(child: SingleChildScrollView(
                  child: Container(
                    color: Theme.of(context).hintColor.withOpacity(0.04),
                    child: Column(children: [

                    // Compact delivery time banner (replaces cooking animation)
                    DateConverter.isBeforeTime(controllerOrderModel.scheduleAt) ? (controllerOrderModel.orderStatus != 'handover' && controllerOrderModel.orderStatus != 'delivered'
                    && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refund_requested' && controllerOrderModel.orderStatus != 'our_for_delivery'
                    && controllerOrderModel.orderStatus != 'refunded' && controllerOrderModel.orderStatus != 'refund_request_canceled') ? Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        Icon(HeroiconsOutline.clock, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'food_need_to_deliver_within'.tr,
                            style: robotoRegular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateConverter.differenceInMinute(controllerOrderModel.restaurantDeliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt) < 5 ? '1-5 ${'min'.tr}'
                            : '${DateConverter.differenceInMinute(controllerOrderModel.restaurantDeliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt)-5}-${DateConverter.differenceInMinute(controllerOrderModel.restaurantDeliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt)} ${'min'.tr}',
                            style: robotoBold.copyWith(fontSize: 13, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ]),
                    ) : const SizedBox() : const SizedBox(),

                    // Bring change notice
                    controllerOrderModel.bringChangeAmount != null && controllerOrderModel.bringChangeAmount! > 0 ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0XFF009AF1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0XFF009AF1).withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Icon(HeroiconsOutline.banknotes, color: const Color(0XFF009AF1), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(text: 'please_bring'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
                              TextSpan(text: ' ${PriceConverter.convertPrice(controllerOrderModel.bringChangeAmount)}', style: robotoBold.copyWith(color: const Color(0XFF009AF1), fontSize: 13)),
                              TextSpan(text: ' ${'in_change_for_the_customer_when_making_the_delivery'.tr}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
                            ]),
                          ),
                        ),
                      ]),
                    ) : const SizedBox(),

                    InfoCardWidget(
                      title: 'customer_contact_details'.tr, addressModel: controllerOrderModel.deliveryAddress, isDelivery: true,
                      image: controllerOrderModel.customer != null ? '${controllerOrderModel.customer!.imageFullUrl}' : '',
                      name: controllerOrderModel.deliveryAddress!.contactPersonName, phone: controllerOrderModel.deliveryAddress!.contactPersonNumber,
                      latitude: controllerOrderModel.deliveryAddress!.latitude, longitude: controllerOrderModel.deliveryAddress!.longitude,
                      showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled'),
                      orderModel: controllerOrderModel,
                      messageOnTap: () async {
                        if(controllerOrderModel.customer != null){
                          _timer?.cancel();
                          await Get.toNamed(RouteHelper.getChatRoute(
                            notificationBody: NotificationBodyModel(
                              orderId: controllerOrderModel.id, customerId: controllerOrderModel.customer!.id,
                            ),
                            user: User(
                              id: controllerOrderModel.customer!.id, fName: controllerOrderModel.customer!.fName,
                              lName: controllerOrderModel.customer!.lName, imageFullUrl: controllerOrderModel.customer!.imageFullUrl,
                            ),
                          ));
                          _startApiCalling();
                        }else{
                          showCustomSnackBar('customer_not_found'.tr);
                        }
                      },
                    ),

                    InfoCardWidget(
                      isRestaurant: true,
                      title: 'restaurant_details'.tr, addressModel: DeliveryAddress(address: controllerOrderModel.restaurantAddress),
                      image: '${controllerOrderModel.restaurantLogoFullUrl}',
                      name: controllerOrderModel.restaurantName, phone: controllerOrderModel.restaurantPhone,
                      latitude: controllerOrderModel.restaurantLat, longitude: controllerOrderModel.restaurantLng,
                      showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled'),
                      orderModel: controllerOrderModel,
                      messageOnTap: () async {
                        if(controllerOrderModel.restaurantModel != 'commission' && controllerOrderModel.chatPermission == 0){
                          showCustomSnackBar('restaurant_have_no_chat_permission'.tr);
                        }else{
                          _timer?.cancel();
                          await Get.toNamed(RouteHelper.getChatRoute(
                            notificationBody: NotificationBodyModel(
                              orderId: controllerOrderModel.id, vendorId: controllerOrderModel.vendorId,
                            ),
                            user: User(
                              id: controllerOrderModel.vendorId, fName: controllerOrderModel.restaurantName,
                              imageFullUrl: controllerOrderModel.restaurantLogoFullUrl,
                            ),
                          ));
                          _startApiCalling();
                        }
                      },
                    ),

                    // Contact Admin Support
                    GestureDetector(
                      onTap: () async {
                        _timer?.cancel();
                        await Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBodyModel(adminId: 0),
                        ));
                        _startApiCalling();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(HeroiconsOutline.lifebuoy, color: Theme.of(context).primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'contact_admin_support'.tr,
                              style: robotoMedium.copyWith(fontSize: 14),
                            ),
                          ),
                          Icon(
                            Get.find<LocalizationController>().isLtr ? HeroiconsOutline.chevronRight : HeroiconsOutline.chevronLeft,
                            color: Theme.of(context).hintColor,
                            size: 20,
                          ),
                        ]),
                      ),
                    ),

                    // Item Info Section - Modern Card Style
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(HeroiconsOutline.shoppingBag, color: Theme.of(context).primaryColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text('item_info'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Theme.of(context).hintColor)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${orderController.orderDetailsModel!.length} ${'items'.tr}',
                              style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderController.orderDetailsModel!.length,
                          itemBuilder: (context, index) {
                            return OrderProductWidgetWidget(
                              order: controllerOrderModel,
                              orderDetails: orderController.orderDetailsModel![index],
                              showDivider: index != orderController.orderDetailsModel!.length - 1,
                            );
                          },
                        ),

                      ]),
                    ),

                    // Substitution Proposals
                    if (orderController.substitutionProposals != null && orderController.substitutionProposals!.isNotEmpty)
                      _buildSubstitutionProposalsCard(context, orderController.substitutionProposals!),

                    (controllerOrderModel.cutlery != null) ? DetailsCustomCard(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      borderRadius: Dimensions.radiusSmall,
                      isBorder: false,
                      child: Row(children: [

                        Text('${'cutlery'.tr}: ', style: robotoBold),
                        const Expanded(child: SizedBox()),

                        Text(
                          controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
                          style: robotoRegular,
                        ),

                      ]),
                    ) : const SizedBox(),

                    controllerOrderModel.unavailableItemNote != null ? DetailsCustomCard(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      borderRadius: Dimensions.radiusSmall,
                      isBorder: false,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('unavailable_item_note'.tr, style: robotoBold),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
                            color: Theme.of(context).hintColor.withOpacity(0.1),
                          ),
                          child: Text(
                            controllerOrderModel.unavailableItemNote!.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ),

                      ]),
                    ): const SizedBox(),

                    controllerOrderModel.deliveryInstruction != null ? DetailsCustomCard(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      borderRadius: Dimensions.radiusSmall,
                      isBorder: false,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('delivery_instruction'.tr, style: robotoBold),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
                            color: Theme.of(context).hintColor.withOpacity(0.1),
                          ),
                          child: Text(
                            controllerOrderModel.deliveryInstruction!.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ),

                      ]),
                    ): const SizedBox(),

                    (controllerOrderModel.orderNote  != null && controllerOrderModel.orderNote!.isNotEmpty) ? DetailsCustomCard(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      borderRadius: Dimensions.radiusSmall,
                      isBorder: false,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('additional_note'.tr, style: robotoBold),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
                            color: Theme.of(context).hintColor.withOpacity(0.1),
                          ),
                          child: Text(
                            controllerOrderModel.orderNote!.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ),

                      ]),
                    ) : const SizedBox(),

                    (controllerOrderModel.orderStatus == 'delivered' && controllerOrderModel.orderProofFullUrl != null && controllerOrderModel.orderProofFullUrl!.isNotEmpty) ? DetailsCustomCard(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      borderRadius: Dimensions.radiusSmall,
                      isBorder: false,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('order_proof'.tr, style: robotoBold),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.5,
                            crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 5,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controllerOrderModel.orderProofFullUrl!.length,
                          itemBuilder: (BuildContext context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => openDialog(context, controllerOrderModel.orderProofFullUrl![index]),
                                child: Center(child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: CustomImageWidget(
                                    image: controllerOrderModel.orderProofFullUrl![index],
                                    width: 100, height: 100,
                                  ),
                                )),
                              ),
                            );
                          },
                        ),

                      ]),
                    ) : const SizedBox(),

                    // Payment & Billing - Combined Modern Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        // Payment Method Header
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(HeroiconsOutline.creditCard, color: Theme.of(context).primaryColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text('payment_method'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Theme.of(context).hintColor)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: controllerOrderModel.paymentStatus == 'paid' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controllerOrderModel.paymentStatus!.toTitleCase(),
                              style: robotoMedium.copyWith(
                                fontSize: 12,
                                color: controllerOrderModel.paymentStatus == 'paid' ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),

                        // Payment Type
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            Icon(
                              controllerOrderModel.paymentMethod == 'cash_on_delivery' ? HeroiconsOutline.banknotes :
                              controllerOrderModel.paymentMethod == 'wallet' ? HeroiconsOutline.wallet :
                              HeroiconsOutline.devicePhoneMobile,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              controllerOrderModel.paymentMethod == 'cash_on_delivery' ? 'cash'.tr :
                              controllerOrderModel.paymentMethod == 'wallet' ? 'wallet_payment'.tr :
                              order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr : 'digital_payment'.tr,
                              style: robotoMedium.copyWith(fontSize: 14),
                            ),
                          ]),
                        ),

                        const SizedBox(height: 20),
                        Divider(height: 1, color: Theme.of(context).hintColor.withOpacity(0.1)),
                        const SizedBox(height: 20),

                        // Billing Section
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(HeroiconsOutline.documentText, color: Theme.of(context).primaryColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text('billing_info'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Theme.of(context).hintColor)),
                        ]),
                        const SizedBox(height: 16),

                        // Subtotal
                        Row(children: [
                          Text('subtotal'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 14)),
                          taxIncluded ? Text(' ${'vat_tax_inc'.tr}', style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor)) : const SizedBox(),
                          const Spacer(),
                          PriceConverter.convertPriceWithSvg(total - dmTips, textStyle: robotoMedium.copyWith(fontSize: 14)),
                        ]),
                        const SizedBox(height: 10),

                        // Tips
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('delivery_man_tips'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 14)),
                          PriceConverter.convertPriceWithSvg(dmTips, textStyle: robotoMedium.copyWith(fontSize: 14, color: Colors.green), symbolSize: 12),
                        ]),

                        const SizedBox(height: 16),

                        // Total Amount - Highlighted
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('total_amount'.tr, style: robotoBold.copyWith(fontSize: 15)),
                            PriceConverter.convertPriceWithSvg(total, textStyle: robotoBold.copyWith(fontSize: 18, color: Theme.of(context).primaryColor)),
                          ]),
                        ),

                        // Partial Payment Info
                        order.paymentMethod == 'partial_payment' ? Column(children: [
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('paid_amount_via_wallet'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 13)),
                            PriceConverter.convertPriceWithSvg(order.payments![0].amount, textStyle: robotoMedium.copyWith(fontSize: 13), symbolSize: 11),
                          ]),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(child: Text('${order.payments![1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.toString().replaceAll('_', ' ')})', style: robotoMedium.copyWith(fontSize: 13, color: Colors.orange.shade700))),
                              PriceConverter.convertPriceWithSvg(order.payments![1].amount, textStyle: robotoBold.copyWith(fontSize: 14, color: Colors.orange.shade700)),
                            ]),
                          ),
                        ]) : const SizedBox(),
                      ]),
                    ),
                    const SizedBox(height: 8),

                  ]),
                  ),
                )),

                showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? CustomCard(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  isBorder: false,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Row(children: [
                      Text('completed_after_delivery_picture'.tr, style: robotoBold),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      CustomToolTip(
                        message: 'completed_after_delivery_picture'.tr,
                        child: const Icon(HeroiconsOutline.informationCircle, size: 20),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: orderController.pickedPrescriptions.length+1,
                        itemBuilder: (context, index) {

                          XFile? file = index == orderController.pickedPrescriptions.length ? null : orderController.pickedPrescriptions[index];

                          if(index < 5 && index == orderController.pickedPrescriptions.length) {
                            return InkWell(
                              onTap: () {
                                Get.bottomSheet(const CameraButtonSheetWidget());
                              },
                              child: Container(
                                height: 60, width: 60, alignment: Alignment.center, decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                                child:  Icon(HeroiconsOutline.camera, color: Theme.of(context).primaryColor, size: 32),
                              ),
                            );
                          }

                          return file != null ? Container(
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Stack(children: [

                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: GetPlatform.isWeb ? Image.network(
                                  file.path, width: 60, height: 60, fit: BoxFit.cover,
                                ) : Image.file(
                                  File(file.path), width: 60, height: 60, fit: BoxFit.cover,
                                ),
                              ),

                            ]),
                          ) : const SizedBox();
                        },
                      ),
                    ),

                  ]),
                ) : const SizedBox(),

                // Step Progress Bar
                if (showBottomView && controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'failed')
                  OrderStepProgressWidget(currentStatus: controllerOrderModel.orderStatus!),

                // Bottom Action Area
                SafeArea(
                  child: showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                    child: CustomButtonWidget(
                      buttonText: 'complete_delivery'.tr,
                      onPressed: () {
                        if(Get.find<SplashController>().configModel!.orderDeliveryVerification!){
                          Get.find<NotificationController>().sendDeliveredNotification(controllerOrderModel.id);
                          Get.bottomSheet(VerifyDeliverySheetWidget(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true).then((isSuccess) {
                            if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                              Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                                orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                                orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                                cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                              ), isScrollControlled: true, isDismissible: false);
                            }
                          });
                        } else{
                          Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true);
                        }
                      },
                    ),
                  ) : showBottomView ? _buildBottomActionByStatus(
                    context: context,
                    orderController: orderController,
                    controllerOrderModel: controllerOrderModel,
                    order: order,
                    total: total,
                    restConfModel: restConfModel,
                    selfDelivery: selfDelivery,
                    cancelPermission: cancelPermission,
                  ) : const SizedBox(),
                ),

              ]) : OrderDetailsShimmer();
            }),
          ),
        );
      }),
    );
  }

  Widget _buildBottomActionByStatus({
    required BuildContext context,
    required OrderController orderController,
    required OrderModel controllerOrderModel,
    required OrderModel order,
    required double total,
    required bool restConfModel,
    required bool selfDelivery,
    bool? cancelPermission,
  }) {
    String status = controllerOrderModel.orderStatus ?? '';

    switch (status) {
      case 'accepted':
        // COD + cancel permission: show cancel + confirm buttons
        if (controllerOrderModel.paymentMethod == 'cash_on_delivery' && !restConfModel && !selfDelivery && cancelPermission == true) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(children: [
              // "Arrived at Store" slider
              SliderButtonWidget(
                action: () {
                  orderController.updateOrderStatus(controllerOrderModel.id, 'arrived_at_store').then((success) {
                    if (success) {
                      Get.find<ProfileController>().getProfile();
                      Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
                    }
                  });
                },
                label: Text(
                  'swipe_to_arrive_store'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
                dismissThresholds: 0.5, dismissible: false, shimmer: true,
                width: 1170, height: 50, buttonSize: 50, radius: 10,
                icon: Center(child: Icon(
                  Get.find<LocalizationController>().isLtr ? HeroiconsOutline.chevronDoubleRight : HeroiconsOutline.chevronLeft,
                  color: ColorResources.white, size: 20.0,
                )),
                isLtr: Get.find<LocalizationController>().isLtr,
                boxShadow: const BoxShadow(blurRadius: 0),
                buttonColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                baseColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              // Cancel button row
              TextButton(
                onPressed: () {
                  orderController.setOrderCancelReason('');
                  Get.dialog(CancellationDialogueWidget(orderId: controllerOrderModel.id));
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!),
                  ),
                ),
                child: Text('cancel'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.titleSmall!.color,
                  fontSize: Dimensions.fontSizeLarge,
                )),
              ),
            ]),
          );
        }
        // Non-COD or restConfModel: show arrive at store slider
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: SliderButtonWidget(
            action: () {
              orderController.updateOrderStatus(controllerOrderModel.id, 'arrived_at_store').then((success) {
                if (success) {
                  Get.find<ProfileController>().getProfile();
                  Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
                }
              });
            },
            label: Text(
              'swipe_to_arrive_store'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            ),
            dismissThresholds: 0.5, dismissible: false, shimmer: true,
            width: 1170, height: 50, buttonSize: 50, radius: 10,
            icon: Center(child: Icon(
              Get.find<LocalizationController>().isLtr ? HeroiconsOutline.chevronDoubleRight : HeroiconsOutline.chevronLeft,
              color: ColorResources.white, size: 20.0,
            )),
            isLtr: Get.find<LocalizationController>().isLtr,
            boxShadow: const BoxShadow(blurRadius: 0),
            buttonColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            baseColor: Theme.of(context).primaryColor,
          ),
        );

      case 'arrived_at_store':
        // Waiting at store — show timer + info text
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [
            WaitingTimerWidget(arrivedAt: controllerOrderModel.arrivedAtStore ?? controllerOrderModel.updatedAt, label: 'waiting_at_store'),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'store_is_preparing'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
          ]),
        );

      case 'confirmed':
      case 'processing':
        // Food is preparing / waiting for cook
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          alignment: Alignment.center,
          child: Column(children: [
            Text(
              status == 'processing' ? 'food_is_preparing'.tr : 'food_waiting_for_cook'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              status == 'processing' ? 'when_it_is_ready_you_will_be_notified'.tr : 'when_it_is_ready_for_cooking_you_will_be_notified'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
            ),
          ]),
        );

      case 'handover':
        // Swipe to pick up — opens photo bottom sheet
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: SliderButtonWidget(
            action: () {
              if (Get.find<ProfileController>().profileModel!.active == 1) {
                orderController.clearPickupPhoto();
                Get.bottomSheet(
                  PickupPhotoBottomSheet(orderId: controllerOrderModel.id),
                  isScrollControlled: true,
                );
              } else {
                showCustomSnackBar('make_yourself_online_first'.tr);
              }
            },
            label: Text(
              'swipe_to_pick_up_with_photo'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            ),
            dismissThresholds: 0.5, dismissible: false, shimmer: true,
            width: 1170, height: 50, buttonSize: 50, radius: 10,
            icon: Center(child: Icon(
              Get.find<LocalizationController>().isLtr ? HeroiconsOutline.chevronDoubleRight : HeroiconsOutline.chevronLeft,
              color: ColorResources.white, size: 20.0,
            )),
            isLtr: Get.find<LocalizationController>().isLtr,
            boxShadow: const BoxShadow(blurRadius: 0),
            buttonColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            baseColor: Theme.of(context).primaryColor,
          ),
        );

      case 'picked_up':
        // Swipe to arrive at customer
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: SliderButtonWidget(
            action: () {
              orderController.updateOrderStatus(controllerOrderModel.id, 'arrived_at_customer').then((success) {
                if (success) {
                  Get.find<ProfileController>().getProfile();
                  Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
                }
              });
            },
            label: Text(
              'swipe_to_arrive_customer'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            ),
            dismissThresholds: 0.5, dismissible: false, shimmer: true,
            width: 1170, height: 50, buttonSize: 50, radius: 10,
            icon: Center(child: Icon(
              Get.find<LocalizationController>().isLtr ? HeroiconsOutline.chevronDoubleRight : HeroiconsOutline.chevronLeft,
              color: ColorResources.white, size: 20.0,
            )),
            isLtr: Get.find<LocalizationController>().isLtr,
            boxShadow: const BoxShadow(blurRadius: 0),
            buttonColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            baseColor: Theme.of(context).primaryColor,
          ),
        );

      case 'arrived_at_customer':
        // Waiting at customer + complete delivery slider
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [
            WaitingTimerWidget(arrivedAt: controllerOrderModel.arrivedAtCustomer ?? controllerOrderModel.updatedAt, label: 'waiting_at_customer'),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            SliderButtonWidget(
              action: () {
                if(Get.find<SplashController>().configModel!.orderDeliveryVerification! || controllerOrderModel.paymentMethod == 'cash_on_delivery') {
                  orderController.changeDeliveryImageStatus();
                  if(Get.find<SplashController>().configModel!.dmPictureUploadStatus!) {
                    showCustomBottomSheet(child: DialogImageWidget());
                  } else {
                    if(Get.find<SplashController>().configModel!.orderDeliveryVerification!){
                      Get.find<NotificationController>().sendDeliveredNotification(controllerOrderModel.id);
                      Get.bottomSheet(VerifyDeliverySheetWidget(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true).then((isSuccess) {
                        if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                          Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true, isDismissible: false);
                        }
                      });
                    } else {
                      Get.bottomSheet(CollectMoneyDeliverySheetWidget(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true);
                    }
                  }
                } else {
                  Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, 'delivered').then((success) {
                    if(success) {
                      Get.find<ProfileController>().getProfile();
                      Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
                    }
                  });
                }
              },
              label: Text(
                'swipe_to_deliver_order'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),
              dismissThresholds: 0.5, dismissible: false, shimmer: true,
              width: 1170, height: 50, buttonSize: 50, radius: 10,
              icon: Center(child: Icon(
                Get.find<LocalizationController>().isLtr ? HeroiconsOutline.chevronDoubleRight : HeroiconsOutline.chevronLeft,
                color: ColorResources.white, size: 20.0,
              )),
              isLtr: Get.find<LocalizationController>().isLtr,
              boxShadow: const BoxShadow(blurRadius: 0),
              buttonColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              baseColor: Theme.of(context).primaryColor,
            ),
          ]),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildSubstitutionProposalsCard(BuildContext context, List<SubstitutionProposal> proposals) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(HeroiconsOutline.arrowsRightLeft, color: Colors.orange, size: 18),
          ),
          const SizedBox(width: 12),
          Text('substitution_proposals'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Theme.of(context).hintColor)),
        ]),
        const SizedBox(height: 12),
        ...proposals.map((proposal) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(proposal.originalFood ?? '', style: robotoRegular.copyWith(fontSize: 13, decoration: TextDecoration.lineThrough, color: Theme.of(context).hintColor)),
                  const SizedBox(height: 4),
                  Text(proposal.substituteFood ?? '', style: robotoMedium.copyWith(fontSize: 13)),
                  if (proposal.quantity != null)
                    Text('x${proposal.quantity}', style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor)),
                ]),
              ),
              if (proposal.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: proposal.status == 'accepted' ? Colors.green.withOpacity(0.1) : proposal.status == 'rejected' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    proposal.status!.capitalizeFirst ?? '',
                    style: robotoMedium.copyWith(
                      fontSize: 11,
                      color: proposal.status == 'accepted' ? Colors.green : proposal.status == 'rejected' ? Colors.red : Colors.orange,
                    ),
                  ),
                ),
            ]),
          ),
        )),
      ]),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'confirmed':
        return Colors.blue;
      case 'arrived_at_store':
        return Colors.amber;
      case 'processing':
      case 'handover':
        return Colors.purple;
      case 'picked_up':
        return Colors.teal;
      case 'arrived_at_customer':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      case 'canceled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: Icon(HeroiconsOutline.xCircle, color: Theme.of(context).colorScheme.error),
          )),

        ]),
      );
    },
  );
}