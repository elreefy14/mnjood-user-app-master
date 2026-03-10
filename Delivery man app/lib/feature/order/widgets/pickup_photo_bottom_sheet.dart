import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/common/widgets/custom_button_widget.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';

class PickupPhotoBottomSheet extends StatelessWidget {
  final int? orderId;
  const PickupPhotoBottomSheet({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
        color: Theme.of(context).cardColor,
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

          // Handle bar
          Container(
            height: 4, width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Title
          Text(
            'take_pickup_photo'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            'photo_required_for_pickup'.tr,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Photo area
          orderController.pickupProofImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Image.file(
                    File(orderController.pickupProofImage!.path),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              : InkWell(
                  onTap: () => orderController.capturePickupPhoto(),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(HeroiconsOutline.camera, size: 40, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        'take_pickup_photo'.tr,
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ]),
                  ),
                ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Buttons
          if (orderController.pickupProofImage != null) ...[
            // Retake button
            TextButton(
              onPressed: () => orderController.capturePickupPhoto(),
              child: Text('retake'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],

          // Confirm button
          CustomButtonWidget(
            buttonText: orderController.pickupProofImage != null ? 'confirm_pickup'.tr : 'take_pickup_photo'.tr,
            isLoading: orderController.isLoading,
            onPressed: () {
              if (orderController.pickupProofImage == null) {
                orderController.capturePickupPhoto();
              } else {
                orderController.updateOrderStatus(orderId, 'picked_up').then((success) {
                  if (success) {
                    Get.find<ProfileController>().getProfile();
                    Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
                  }
                });
              }
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]);
      }),
    );
  }
}
