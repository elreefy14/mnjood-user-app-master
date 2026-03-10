import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutButtonWidget extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  const CheckoutButtonWidget({super.key, required this.cartController, required this.availableList, required this.isRestaurantOpen, this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
      decoration: isDesktop ? null : BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: GetBuilder<RestaurantController>(builder: (restaurantController) {
          final configModel = Get.find<SplashController>().configModel;
          final adminFreeDelivery = configModel?.adminFreeDelivery;
          final freeDeliveryOver = adminFreeDelivery?.freeDeliveryOver;
          final restaurantFreeDelivery = restaurantController.restaurant?.freeDelivery;

          bool showFreeDeliveryProgress = restaurantController.restaurant != null
              && restaurantFreeDelivery != null
              && !(restaurantFreeDelivery)
              && adminFreeDelivery?.status == true
              && adminFreeDelivery?.type == 'free_delivery_by_specific_criteria'
              && freeDeliveryOver != null
              && freeDeliveryOver > 0;

          if(showFreeDeliveryProgress) {
            percentage = cartController.subTotal / freeDeliveryOver!;
          }

          return Column(mainAxisSize: MainAxisSize.min, children: [
            (showFreeDeliveryProgress && percentage < 1)
            ? Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(children: [
                  Image.asset(Images.percentTag, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  PriceConverter.convertAnimationPrice(
                    (freeDeliveryOver ?? 0) - cartController.subTotal,
                    textStyle: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    value: percentage,
                    minHeight: 6,
                  ),
                ),
              ]),
            ) : const SizedBox(),

            GetBuilder<CartController>(
              builder: (cartController) {
                return CustomButtonWidget(
                  radius: Dimensions.radiusLarge,
                  buttonText: 'confirm_delivery_details'.tr,
                  onPressed: cartController.isLoading || restaurantController.restaurant == null ? null : () {
                    Get.find<CheckoutController>().updateFirstTime();
                    _processToCheckoutButtonPressed(restaurantController);
                  },
                );
              }
            ),
            SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraLarge : 0),
          ]);
        }),
      ),
    );
  }

  void _processToCheckoutButtonPressed(RestaurantController restaurantController) {
    if(cartController.cartList.isEmpty) {
      showCustomSnackBar('cart_is_empty'.tr);
    } else if(!(cartController.cartList.first.product?.scheduleOrder ?? true) && cartController.availableList.contains(false)) {
      showCustomSnackBar('one_or_more_product_unavailable'.tr);
    } else {
      Get.find<CouponController>().removeCouponData(false);
      Get.toNamed(RouteHelper.getCheckoutRoute('cart', fromDineIn: fromDineIn));
    }
  }

}
