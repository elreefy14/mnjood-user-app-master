import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCartWidget extends StatelessWidget {
  final int? restaurantId;
  final bool fromDineIn;
  const BottomCartWidget({super.key, this.restaurantId, this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
        return Container(
          height: GetPlatform.isIOS ? 100 : 70, width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: const Color(0xFF2A2A2A).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'item'.tr}: ${cartController.cartList.length}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(
                  children: [
                    Text('${'total'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                    PriceConverter.convertPriceWithSvg(
                      cartController.calculationCart(),
                      textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                      symbolColor: Theme.of(context).primaryColor,
                      symbolSize: 16,
                    ),
                  ],
                ),
              ]),

              CustomButtonWidget(buttonText: 'view_cart'.tr, width: 130, height: 45, onPressed: () async {
                if(!AuthHelper.isLoggedIn()) {
                  Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.cart));
                  return;
                }
                await Get.toNamed(RouteHelper.getCartRoute(fromDineIn: fromDineIn));
                Get.find<RestaurantController>().makeEmptyRestaurant();
                if(restaurantId != null) {
                  Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
                }
              })
            ]),
          ),
        );
      });
  }
}
