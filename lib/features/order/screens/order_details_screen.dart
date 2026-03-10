import 'package:mnjood/common/enums/order_status.dart';
import 'package:mnjood/features/checkout/widgets/offline_success_dialog.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/domain/models/subscription_schedule_model.dart';
import 'package:mnjood/features/order/widgets/bottom_view_widget.dart';
import 'package:mnjood/features/order/widgets/order_info_section.dart';
import 'package:mnjood/features/order/widgets/order_pricing_section.dart';
import 'package:mnjood/features/order/widgets/order_status_animation_widget.dart';
import 'package:mnjood/features/order/widgets/live_tracking_overlay_widget.dart';
import 'package:mnjood/features/order/widgets/tracking_map_section_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/features/order/domain/models/order_details_model.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/helper/color_coverter.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/custom_dialog_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/features/order_chat/screens/order_chat_screen.dart';
import 'package:mnjood/features/order/screens/invoice_print_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromOfflinePayment;
  final String? contactNumber;
  final bool fromGuestTrack;
  final bool fromNotification;
  final bool fromDineIn;
  const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.contactNumber, this.fromOfflinePayment = false, this.fromGuestTrack = false, this.fromNotification = false, this.fromDineIn = false});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {

  final ScrollController scrollController = ScrollController();

  Future<void> _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), widget.orderModel, false, contactNumber: widget.contactNumber).then((value) {
      if(widget.fromOfflinePayment) {
        Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      }else if(widget.fromDineIn) {
        Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId, isDineIn: true)));
      }
    });
    Get.find<OrderController>().getOrderCancelReasons();
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
    if(Get.find<OrderController>().trackModel != null){
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderId.toString(), contactNumber: widget.contactNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderId.toString(), contactNumber: widget.contactNumber);
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    Get.find<OrderController>().cancelTimer();
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (((widget.orderModel == null || widget.fromOfflinePayment) && !widget.fromGuestTrack) || widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else if(widget.fromGuestTrack){
          return;
        } else{
          return;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        double? deliveryCharge = 0;
        double itemsPrice = 0;
        double? discount = 0;
        double? couponDiscount = 0;
        double? tax = 0;
        double addOns = 0;
        double? dmTips = 0;
        double additionalCharge = 0;
        double extraPackagingCharge = 0;
        double referrerBonusAmount = 0;
        bool showChatPermission = true;
        bool? taxIncluded = false;
        OrderModel? order = orderController.trackModel;
        bool subscription = false;
        bool isDineIn = false;
        List<String> schedules = [];
        if(orderController.orderDetails != null && order != null) {
          isDineIn = order.orderType == 'dine_in';
          subscription = order.subscription != null;

          if(subscription) {
            if(order.subscription!.type == 'weekly') {
              List<String> weekDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
              for(SubscriptionScheduleModel schedule in orderController.schedules!) {
                schedules.add('${weekDays[schedule.day!].tr} (${DateConverter.convertTimeToTime(schedule.time!)})');
              }
            }else if(order.subscription!.type == 'monthly') {
              for(SubscriptionScheduleModel schedule in orderController.schedules!) {
                schedules.add('${'day_capital'.tr} ${schedule.day} (${DateConverter.convertTimeToTime(schedule.time!)})');
              }
            }else {
              schedules.add(DateConverter.convertTimeToTime(orderController.schedules![0].time!));
            }
          }
          if(order.orderType == 'delivery') {
            deliveryCharge = order.deliveryCharge;
            dmTips = order.dmTips;
          }
          couponDiscount = order.couponDiscountAmount;
          discount = order.restaurantDiscountAmount;
          tax = order.totalTaxAmount;
          taxIncluded = order.taxStatus;
          additionalCharge = order.additionalCharge ?? 0;
          extraPackagingCharge = order.extraPackagingAmount ?? 0;
          referrerBonusAmount = order.referrerBonusAmount ?? 0;
          for(OrderDetailsModel orderDetails in orderController.orderDetails!) {
            for(AddOn addOn in orderDetails.addOns!) {
              addOns = addOns + (addOn.price! * addOn.quantity!);
            }
            itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
          }
          if(order.restaurant != null) {
            if (order.restaurant!.restaurantModel == 'commission') {
              showChatPermission = true;
            } else if (order.restaurant!.restaurantSubscription != null &&
                order.restaurant!.restaurantSubscription!.chat == 1) {
              showChatPermission = true;
            } else {
              showChatPermission = false;
            }
          }
        }
        double subTotal = itemsPrice + addOns;
        double total = itemsPrice + addOns - (discount ?? 0) + ((taxIncluded ?? false) ? 0 : (tax ?? 0)) + (deliveryCharge ?? 0) - (couponDiscount ?? 0) + (dmTips ?? 0) + additionalCharge + extraPackagingCharge - referrerBonusAmount;

        bool pending = order?.orderStatus == OrderStatus.pending.name;
        bool confirmed = order?.orderStatus == OrderStatus.confirmed.name;
        bool processing = order?.orderStatus == OrderStatus.processing.name;
        bool handover = order?.orderStatus == OrderStatus.handover.name;
        bool cancelled = order?.orderStatus == OrderStatus.canceled.name;

        return Scaffold(
          appBar: !isDesktop ? AppBar(
            title: Column(children: [

              Text('${subscription ? 'subscription'.tr : 'order'.tr} # ${order?.id ?? ''}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              isDineIn ? Text(
                (pending || confirmed) ? '${'your_order_is'.tr} ${orderController.trackModel?.orderStatus?.tr ?? ''}'
                : processing ? 'your_food_is_cooking'.tr : handover ? 'your_food_is_ready'.tr
                : cancelled ? 'your_order_is_canceled'.tr : 'your_food_is_served'.tr,
                style: robotoBold.copyWith(color:  ColorConverter.getStatusColor(order?.orderStatus ?? '')),
              ) : Text('${'your_order_is'.tr} ${orderController.trackModel?.orderStatus?.tr ?? ''}', style: robotoBold.copyWith(color: ColorConverter.getStatusColor(order?.orderStatus ?? ''))),

            ]),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(HeroiconsOutline.chevronLeft),
              onPressed: () {
                if((widget.orderModel == null || widget.fromOfflinePayment) && !widget.fromGuestTrack) {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                } else if(widget.fromGuestTrack){
                  Get.back();
                } else {
                  Get.back();
                }
              },
            ),
            actions: [
              if (order != null && orderController.orderDetails != null)
                IconButton(
                  icon: const Icon(Icons.print_outlined),
                  tooltip: 'print_invoice'.tr,
                  onPressed: () => Get.to(() => InvoicePrintScreen(
                    order: order,
                    orderDetails: orderController.orderDetails!,
                    itemsPrice: itemsPrice,
                    addOns: addOns,
                    discount: discount ?? 0,
                    couponDiscount: couponDiscount ?? 0,
                    tax: tax ?? 0,
                    deliveryCharge: deliveryCharge ?? 0,
                    dmTips: dmTips ?? 0,
                    total: total,
                  )),
                )
              else
                const SizedBox(),
            ],
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
            elevation: 2,
          ) : CustomAppBarWidget(title: subscription ? 'subscription_details'.tr : 'order_details'.tr, onBackPressed: () {
            if(((widget.orderModel == null || widget.fromOfflinePayment) && !widget.fromGuestTrack) || widget.fromNotification) {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else if(widget.fromGuestTrack){
              Get.back();
            } else {
              Get.back();
            }
          }),
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,

          floatingActionButton: (order != null && order.orderStatus != 'delivered' && order.orderStatus != 'canceled' && order.orderStatus != 'failed')
              ? FloatingActionButton(
                  onPressed: () => Get.to(() => OrderChatScreen(orderId: widget.orderId ?? 0)),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Badge(
                    isLabelVisible: (order.chatCount ?? 0) > 0,
                    label: Text('${order.chatCount ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  ),
                )
              : null,

          body: SafeArea(
            child: (order != null && orderController.orderDetails != null) ? Column(children: [

              WebScreenTitleWidget(title: subscription ? 'subscription_details'.tr : 'order_details'.tr),

              // Top section: status animation OR live map (mobile only)
              if (!isDesktop) _buildTopSection(order, orderController),

              Expanded(child: SingleChildScrollView(
                controller: scrollController,
                child: FooterViewWidget(child: SizedBox(width: Dimensions.webMaxWidth,
                  child: isDesktop ? Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Expanded(flex: 6, child: Column(children: [

                        subscription ? Text('${'subscription'.tr} # ${order.id.toString()}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)) : const SizedBox(),
                        SizedBox(height: subscription ? Dimensions.paddingSizeExtraSmall : 0),

                        subscription ? Text('${'your_order_is'.tr} ${order.orderStatus}', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)) : const SizedBox(),
                        SizedBox(height: subscription ? Dimensions.paddingSizeLarge : 0),

                          OrderInfoSection(order: order, orderController: orderController, schedules: schedules, showChatPermission: showChatPermission,
                            contactNumber: widget.contactNumber, totalAmount: total),
                        ],
                      )),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(flex: 4,child: OrderPricingSection(
                        itemsPrice: itemsPrice, addOns: addOns, order: order, subTotal: subTotal, discount: discount ?? 0,
                        couponDiscount: couponDiscount ?? 0, tax: tax ?? 0, dmTips: dmTips ?? 0, deliveryCharge: deliveryCharge ?? 0,
                        total: total, orderController: orderController, orderId: widget.orderId, contactNumber: widget.contactNumber,
                        extraPackagingAmount: extraPackagingCharge, referrerBonusAmount: referrerBonusAmount,
                      ))

                    ]),
                  ) : Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: Column(children: [

                      OrderInfoSection(order: order, orderController: orderController, schedules: schedules, showChatPermission: showChatPermission,
                        contactNumber: widget.contactNumber, totalAmount: total),

                      OrderPricingSection(
                        itemsPrice: itemsPrice, addOns: addOns, order: order, subTotal: subTotal, discount: discount ?? 0,
                        couponDiscount: couponDiscount ?? 0, tax: tax ?? 0, dmTips: dmTips ?? 0, deliveryCharge: deliveryCharge ?? 0,
                        total: total, orderController: orderController, orderId: widget.orderId, contactNumber: widget.contactNumber,
                        extraPackagingAmount: extraPackagingCharge, referrerBonusAmount: referrerBonusAmount,
                      ),

                    ]),
                  ),
                )),
              )),

              !isDesktop ? BottomViewWidget(orderController: orderController, order: order, orderId: widget.orderId, total: total, contactNumber: widget.contactNumber) : const SizedBox(),


            ]) : const Center(child: CircularProgressIndicator()),
          ),

        );
      }),
    );
  }

  /// Build the conditional top section:
  /// - Pre-pickup (pending/confirmed/accepted/processing): animated status + stepper
  /// - On the way (handover/picked_up with deliveryMan, delivery type): live map
  /// - Otherwise (delivered/cancelled/failed/dine_in): nothing
  Widget _buildTopSection(OrderModel order, OrderController orderController) {
    final status = order.orderStatus ?? '';
    final isDelivery = order.orderType == 'delivery';
    final hasDriver = order.deliveryMan != null;
    final isDineIn = order.orderType == 'dine_in';
    final subscription = order.subscription != null;

    // Don't show top section for completed/cancelled/failed/dine_in/subscription orders
    if (status == 'delivered' || status == 'canceled' || status == 'failed' ||
        status == 'refunded' || status == 'refund_requested' || status == 'refund_request_canceled' ||
        isDineIn || subscription) {
      return const SizedBox();
    }

    // Show live map when order is picked up or handed over with a driver assigned
    final bool showMap = isDelivery && hasDriver &&
        (status == 'picked_up' || status == 'handover');

    if (showMap) {
      return Column(children: [
        TrackingMapSectionWidget(
          orderID: widget.orderId.toString(),
          contactNumber: widget.contactNumber,
          track: order,
          height: 250,
        ),
        if (order.deliveryMan != null)
          LiveTrackingOverlayWidget(
            deliveryMan: order.deliveryMan,
            riderPosition: LatLng(
              double.tryParse(order.deliveryMan!.lat ?? '0') ?? 0,
              double.tryParse(order.deliveryMan!.lng ?? '0') ?? 0,
            ),
            destinationPosition: LatLng(
              double.tryParse(order.deliveryAddress?.latitude ?? '') ?? 24.7136,
              double.tryParse(order.deliveryAddress?.longitude ?? '') ?? 46.6753,
            ),
            orderStatus: order.orderStatus ?? '',
            orderId: widget.orderId ?? 0,
          ),
      ]);
    }

    // Show animated status + stepper for pre-pickup statuses
    final bool isPrePickup = (status == 'pending' || status == 'accepted' ||
        status == 'confirmed' || status == 'processing');

    if (isPrePickup) {
      int? etaMinutes;
      if (order.restaurant?.deliveryTime != null) {
        int remaining = DateConverter.differenceInMinute(
          order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt,
        );
        if (remaining > 0) etaMinutes = remaining;
      }

      return Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OrderStatusAnimationWidget(orderStatus: status),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            AnimatedOrderStepper(currentStatus: status, etaMinutes: etaMinutes),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}