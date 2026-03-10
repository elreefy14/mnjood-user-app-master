import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:mnjood_delivery/helper/notification_helper.dart';
import 'package:mnjood_delivery/common/widgets/custom_image_widget.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/feature/order/screens/order_details_screen.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/feature/splash/controllers/splash_controller.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_button_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewRequestDialogWidget extends StatefulWidget {
  final bool isRequest;
  final Function onTap;
  final int orderId;
  const NewRequestDialogWidget({super.key, required this.isRequest, required this.onTap, required this.orderId});

  @override
  State<NewRequestDialogWidget> createState() => _NewRequestDialogWidgetState();
}

class _NewRequestDialogWidgetState extends State<NewRequestDialogWidget> {

  Timer? _timer;
  AudioPlayer? _audioPlayer;
  OrderModel? _orderModel;
  int _orderIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAlarm();
    _findOrderInList();
    Get.find<OrderController>().getOrderDetails(widget.orderId);
  }

  void _findOrderInList() {
    final orderController = Get.find<OrderController>();
    if (orderController.latestOrderList != null) {
      for (int i = 0; i < orderController.latestOrderList!.length; i++) {
        if (orderController.latestOrderList![i].id == widget.orderId) {
          _orderModel = orderController.latestOrderList![i];
          _orderIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _stopAlarm() {
    _timer?.cancel();
    _timer = null;
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    // Stop the background foreground service notification sound
    stopService();
  }

  void _startAlarm() {
    _audioPlayer = AudioPlayer();
    _audioPlayer!.play(AssetSource('notification.mp3'));
    _vibrate();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _audioPlayer?.play(AssetSource('notification.mp3'));
      _vibrate();
    });
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  void _showRejectDialog() {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'reject_order'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Reason text field
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'enter_rejection_reason'.tr,
                hintStyle: robotoRegular.copyWith(color: Theme.of(Get.context!).hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  borderSide: BorderSide(color: Theme.of(Get.context!).hintColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
                ),
                contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Quick rejection reasons
            Text('quick_reasons'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReasonChip('too_far'.tr, reasonController),
                _buildReasonChip('busy_now'.tr, reasonController),
                _buildReasonChip('vehicle_issue'.tr, reasonController),
                _buildReasonChip('personal_reason'.tr, reasonController),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Buttons
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      side: BorderSide(color: Theme.of(Get.context!).hintColor),
                    ),
                  ),
                  child: Text('cancel'.tr, style: robotoMedium.copyWith(color: Theme.of(Get.context!).hintColor)),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: CustomButtonWidget(
                  height: 45,
                  radius: Dimensions.radiusDefault,
                  buttonText: 'confirm_reject'.tr,
                  backgroundColor: Colors.red.shade400,
                  onPressed: () {
                    _stopAlarm();
                    Get.find<OrderController>().ignoreOrderById(widget.orderId, reason: reasonController.text);
                    Get.back(); // Close reject dialog
                    Get.back(); // Close main popup
                    showCustomSnackBar('order_rejected'.tr, isError: false);
                  },
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildReasonChip(String reason, TextEditingController controller) {
    return InkWell(
      onTap: () {
        controller.text = reason;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(Get.context!).primaryColor.withOpacity(0.3)),
        ),
        child: Text(reason, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: GetBuilder<OrderController>(builder: (orderController) {
          // Re-find order model in case list updated
          if (_orderModel == null && orderController.latestOrderList != null) {
            _findOrderInList();
          }

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              // Header with pulse animation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                ),
                child: Column(children: [
                  const Icon(Icons.delivery_dining, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    widget.isRequest ? 'new_order_request'.tr : 'new_order_assigned'.tr,
                    style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'order'.tr} #${widget.orderId}',
                    style: robotoRegular.copyWith(color: Colors.white.withOpacity(0.9), fontSize: Dimensions.fontSizeSmall),
                  ),
                ]),
              ),

              // Order details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Restaurant info
                    if (_orderModel != null) ...[
                      Row(children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2), width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              image: _orderModel!.restaurantLogoFullUrl ?? '',
                              height: 50, width: 50, fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              _orderModel!.restaurantName ?? 'restaurant'.tr,
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _orderModel!.restaurantAddress ?? '',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Divider with icon
                      Row(children: [
                        Expanded(child: Divider(color: Theme.of(context).hintColor.withOpacity(0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_downward, color: Theme.of(context).primaryColor, size: 20),
                        ),
                        Expanded(child: Divider(color: Theme.of(context).hintColor.withOpacity(0.3))),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Delivery address
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 24),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              'deliver_to'.tr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _orderModel!.deliveryAddress?.address ?? 'no_address'.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],

                    // Order info cards
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(children: [
                        // Items count
                        _buildInfoRow(
                          context,
                          Icons.shopping_bag_outlined,
                          'items'.tr,
                          _orderModel != null
                            ? '${_orderModel!.detailsCount ?? orderController.orderDetailsModel?.length ?? 0} ${'items'.tr}'
                            : '${orderController.orderDetailsModel?.length ?? 0} ${'items'.tr}',
                        ),
                        Divider(color: Theme.of(context).hintColor.withOpacity(0.2)),

                        // Payment method
                        _buildInfoRow(
                          context,
                          Icons.payment,
                          'payment'.tr,
                          _orderModel?.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : 'digitally_paid'.tr,
                        ),

                        // Earnings (if enabled)
                        if (Get.find<SplashController>().configModel!.showDmEarning! &&
                            Get.find<ProfileController>().profileModel!.earnings == 1 &&
                            _orderModel != null) ...[
                          Divider(color: Theme.of(context).hintColor.withOpacity(0.2)),
                          _buildInfoRow(
                            context,
                            Icons.monetization_on_outlined,
                            'earning'.tr,
                            PriceConverter.convertPrice(_orderModel!.originalDeliveryCharge! + _orderModel!.dmTips!),
                            valueColor: Colors.green,
                          ),
                        ],
                      ]),
                    ),

                    // Items list
                    if (orderController.orderDetailsModel != null && orderController.orderDetailsModel!.isNotEmpty) ...[
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text('order_items'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ListView.builder(
                        itemCount: orderController.orderDetailsModel!.length > 3 ? 3 : orderController.orderDetailsModel!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'x${orderController.orderDetailsModel![index].quantity}',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  orderController.orderDetailsModel![index].foodDetails?.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                ),
                              ),
                            ]),
                          );
                        },
                      ),
                      if (orderController.orderDetailsModel!.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+${orderController.orderDetailsModel!.length - 3} ${'more_items'.tr}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          ),
                        ),
                    ],
                  ]),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(children: [
                  // Reject button
                  Expanded(
                    child: TextButton(
                      onPressed: _showRejectDialog,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          side: BorderSide(width: 1.5, color: Colors.red.shade300),
                        ),
                      ),
                      child: Text(
                        'reject'.tr,
                        style: robotoBold.copyWith(color: Colors.red.shade400, fontSize: Dimensions.fontSizeLarge),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  // Accept button
                  Expanded(
                    child: CustomButtonWidget(
                      height: 50,
                      radius: Dimensions.radiusDefault,
                      buttonText: 'accept'.tr,
                      isLoading: orderController.isLoading,
                      onPressed: () {
                        _stopAlarm();
                        Get.find<OrderController>().acceptOrderById(widget.orderId).then((isSuccess) {
                          if (isSuccess) {
                            Get.back(); // Close dialog
                            widget.onTap();
                            Get.toNamed(
                              RouteHelper.getOrderDetailsRoute(widget.orderId),
                              arguments: OrderDetailsScreen(
                                orderId: widget.orderId,
                                isRunningOrder: true,
                                orderIndex: Get.find<OrderController>().currentOrderList!.length - 1,
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                ]),
              ),

            ]),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 20, color: Theme.of(context).hintColor),
        const SizedBox(width: 8),
        Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
        const Spacer(),
        Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: valueColor)),
      ]),
    );
  }
}
