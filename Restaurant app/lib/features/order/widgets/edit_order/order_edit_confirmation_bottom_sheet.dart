import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_details_model.dart';
import 'package:mnjood_vendor/features/order/screens/edit_order/edit_product_screen.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';

class OrderEditConfirmationBottomSheet extends StatelessWidget {
  final int orderId;
  final String orderStatus;
  final List<OrderDetailsModel>? orderDetailsModel;
  const OrderEditConfirmationBottomSheet({super.key, this.orderDetailsModel, required this.orderId, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => Get.back(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(HeroiconsOutline.xCircle, color: Theme.of(context).hintColor.withValues(alpha: 0.8), size: 27),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            
            CustomAssetImageWidget(image: Images.warning, height: 60, width: 60),
            SizedBox(height: Dimensions.paddingSizeDefault),

            Text('are_you_sure'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            SizedBox(height: Dimensions.paddingSizeDefault),

            Text('order_edit_description'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor), textAlign: TextAlign.center),
            SizedBox(height: Dimensions.paddingSizeOverExtraLarge),

            Row(children: [

              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'no'.tr,
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'yes'.tr,
                  onPressed: () {
                    Get.back();
                    Get.toNamed(
                      RouteHelper.getEditProductRoute(),
                      arguments: EditProductScreen(orderDetailsModel: orderDetailsModel, orderId: orderId, orderStatus: orderStatus),
                    );
                  },
                ),
              ),

            ]),

          ]),
        ),

      ]),
    );
  }
}
