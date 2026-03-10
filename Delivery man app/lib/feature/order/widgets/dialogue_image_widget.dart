import 'package:flutter/cupertino.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/order/widgets/camera_button_sheet_widget.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogImageWidget extends StatelessWidget {
  const DialogImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () => Get.back(),
            child: Container(
              decoration:  BoxDecoration(
                shape: BoxShape.circle, color: Theme.of(context).disabledColor.withOpacity(0.5),
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(HeroiconsOutline.xMark, size: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(
          'take_a_picture'.tr, textAlign: TextAlign.center,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            GetBuilder<OrderController>(builder: (orderController) {
              return InkWell(
                onTap: () {
                  Get.back();
                  Get.bottomSheet(const CameraButtonSheetWidget());
                },
                child: Container(
                  height: 100, width: 100, alignment: Alignment.center, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                ),
                  child:  Icon(HeroiconsOutline.camera, color: Theme.of(context).primaryColor, size: 40),
                ),
              );
            }),

          ]),
        ),

      ]),
    );
  }
}