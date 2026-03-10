import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CancellationBottomSheet extends StatefulWidget {
  final int? orderId;
  const CancellationBottomSheet({super.key, required this.orderId});

  @override
  State<CancellationBottomSheet> createState() => _CancellationBottomSheetState();
}

class _CancellationBottomSheetState extends State<CancellationBottomSheet> {
  final TextEditingController _otherReasonController = TextEditingController();
  int? _selectedReasonId;
  bool _showOtherInput = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<OrderController>().getOrderCancelReasons();
      Get.find<OrderController>().setOrderCancelReason('');
    });
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Icon(HeroiconsOutline.xCircle, color: Theme.of(context).colorScheme.error, size: 24),
              const SizedBox(width: 8),
              Text('cancel_order'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const Spacer(),
              InkWell(
                onTap: () => Get.back(),
                child: Icon(HeroiconsOutline.xMark, size: 24, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),

          const Divider(height: 1),

          // Reason title
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('cancellation_reason'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ),
          ),

          // Reasons list
          orderController.orderCancelReasons != null ? orderController.orderCancelReasons!.isNotEmpty ? Flexible(
            child: ListView.builder(
              itemCount: orderController.orderCancelReasons!.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                final cancelData = orderController.orderCancelReasons![index];
                final reason = cancelData.reason ?? '';
                final isSelected = _selectedReasonId == cancelData.id;
                final hasFee = (cancelData.feePercentage ?? 0) > 0;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedReasonId = cancelData.id;
                      _showOtherInput = cancelData.requiresText == true;
                    });
                    orderController.setOrderCancelReason(reason);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        isSelected ? HeroiconsSolid.checkCircle : HeroiconsOutline.minusCircle,
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        size: 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reason, style: robotoRegular, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (hasFee && isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'fee_warning'.trParams({'fee': '${cancelData.feePercentage!.toStringAsFixed(0)}%'}),
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                        ],
                      )),
                    ]),
                  ),
                );
              },
            ),
          ) : Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Text('no_reasons_available'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
          ) : const Center(child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CircularProgressIndicator(),
          )),

          // Other reason text input
          if (_showOtherInput)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: TextField(
                controller: _otherReasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'enter_reason'.tr,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  contentPadding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                ),
              ),
            ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: !orderController.isCancelLoading ? Row(children: [
              Expanded(child: CustomButtonWidget(
                buttonText: 'cancel'.tr,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: () => Get.back(),
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: CustomButtonWidget(
                buttonText: 'confirm_cancellation'.tr,
                color: Theme.of(context).colorScheme.error,
                onPressed: () {
                  if (_selectedReasonId == null) {
                    showCustomSnackBar('cancellation_reason'.tr);
                    return;
                  }

                  String? customReason;
                  if (_showOtherInput) {
                    customReason = _otherReasonController.text.trim();
                    if (customReason.isEmpty) {
                      showCustomSnackBar('enter_reason'.tr);
                      return;
                    }
                  }

                  orderController.cancelOrder(
                    widget.orderId,
                    orderController.cancelReason,
                    reasonId: _selectedReasonId,
                    customReason: customReason,
                  ).then((success) {
                    if (success) {
                      orderController.trackOrder(widget.orderId.toString(), null, true);
                      showCustomSnackBar('order_cancelled_successfully'.tr, isError: false);
                    }
                  });
                },
              )),
            ]) : const Center(child: CircularProgressIndicator()),
          ),
        ]),
      );
    });
  }
}

void showCancellationBottomSheet({required int? orderId}) {
  Get.bottomSheet(
    CancellationBottomSheet(orderId: orderId),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
