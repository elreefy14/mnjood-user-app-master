import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_cancellation_body_model.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_button_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancellationDialogueWidget extends StatefulWidget {
  final int? orderId;
  const CancellationDialogueWidget({super.key, required this.orderId});

  @override
  State<CancellationDialogueWidget> createState() => _CancellationDialogueWidgetState();
}

class _CancellationDialogueWidgetState extends State<CancellationDialogueWidget> {
  final TextEditingController _customReasonController = TextEditingController();
  CancellationData? _selectedReason;

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getOrderCancelReasons();
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(builder: (orderController) {
        return SizedBox(
          width: 500, height: MediaQuery.of(context).size.height * 0.6,
          child: Column(children: [

            Container(
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
              ),
              child: Column(children: [
                Text('select_cancellation_reasons'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ]),
            ),

            Expanded(
              child: orderController.orderCancelReasons != null ? orderController.orderCancelReasons!.isNotEmpty ? ListView.builder(
                itemCount: orderController.orderCancelReasons!.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  final reason = orderController.orderCancelReasons![index];
                  final isSelected = _selectedReason?.id == reason.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(children: [
                      ListTile(
                        onTap: (){
                          setState(() {
                            _selectedReason = reason;
                            if (reason.requiresText != true) {
                              _customReasonController.clear();
                            }
                          });
                          orderController.setOrderCancelReason(reason.reason);
                        },
                        title: Row(
                          children: [
                            Icon(isSelected ? HeroiconsOutline.checkCircle : HeroiconsOutline.stop, color: Theme.of(context).primaryColor, size: 18),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Flexible(child: Text(reason.reason!, style: robotoRegular, maxLines: 3, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      if (isSelected && reason.requiresText == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: TextField(
                            controller: _customReasonController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'enter_reason_details'.tr,
                              hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                              contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              isDense: true,
                            ),
                          ),
                        ),
                    ]),
                  );
                },
              ) : Center(child: Text('no_reasons_available'.tr)) : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: !orderController.isLoading ? Row(children: [

                Expanded(child: CustomButtonWidget(
                  buttonText: 'cancel'.tr, backgroundColor: Theme.of(context).disabledColor, radius: 50,
                  onPressed: () => Get.back(),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: CustomButtonWidget(
                  buttonText: 'submit'.tr, radius: 50,
                  onPressed: (){
                    if(_selectedReason != null){
                      String? reasonText = _selectedReason!.reason;
                      if (_selectedReason!.requiresText == true && _customReasonController.text.trim().isNotEmpty) {
                        reasonText = _customReasonController.text.trim();
                      }

                      orderController.updateOrderStatus(
                        widget.orderId, 'canceled',
                        back: true,
                        reason: reasonText,
                        reasonId: _selectedReason!.id,
                      ).then((success) {
                        if(success) {
                          Get.find<ProfileController>().getProfile();
                          Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
                        }
                      });

                    }else{
                      if(Get.isDialogOpen!){
                        Get.back();
                      }
                      showCustomSnackBar('you_did_not_select_select_any_reason'.tr);
                    }
                  },
                )),
              ]) : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        );
      }),
    );
  }
}
