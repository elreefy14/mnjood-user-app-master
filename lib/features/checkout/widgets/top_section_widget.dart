import 'package:mnjood/features/auth/widgets/auth_dialog_widget.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/widgets/coupon_section.dart';
import 'package:mnjood/features/checkout/widgets/delivery_man_tips_section.dart';
import 'package:mnjood/features/checkout/widgets/delivery_option_button.dart';
import 'package:mnjood/features/checkout/widgets/delivery_section.dart';
import 'package:mnjood/features/checkout/widgets/prescription_section.dart';
import 'package:mnjood/features/checkout/widgets/estimated_arrival_time_widget.dart';
import 'package:mnjood/features/checkout/widgets/guest_login_widget.dart';
import 'package:mnjood/features/checkout/widgets/order_type_widget.dart';
import 'package:mnjood/features/checkout/widgets/partial_pay_view.dart';
import 'package:mnjood/features/checkout/widgets/payment_section.dart';
import 'package:mnjood/features/checkout/widgets/subscription_view.dart';
import 'package:mnjood/features/checkout/widgets/time_slot_section.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class TopSectionWidget extends StatelessWidget {
  final double charge;
  final double deliveryCharge;
  final LocationController locationController;
  final bool tomorrowClosed;
  final bool todayClosed;
  final double price;
  final double discount;
  final double addOns;
  final bool restaurantSubscriptionActive;
  final bool showTips;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final double total;
  final JustTheController tooltipController3;
  final JustTheController tooltipController2;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController loginTooltipController;
  final Function() callBack;
  final String deliveryChargeForView;
  final JustTheController deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final ScrollController deliveryOptionScrollController;

  const TopSectionWidget({
    super.key, required this.charge, required this.deliveryCharge, required this.locationController,
    required this.tomorrowClosed, required this.todayClosed, required this.price, required this.discount,
    required this.addOns, required this.restaurantSubscriptionActive, required this.showTips,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive,
    required this.fromCart, required this.total, required this.tooltipController3, required this.tooltipController2,
    required this.guestNameTextEditingController, required this.guestNumberTextEditingController, required this.guestNumberNode,
    required this.isOfflinePaymentActive, required this.guestEmailController, required this.guestEmailNode,
    required this.loginTooltipController, required this.callBack, required this.deliveryChargeForView,
    required this.deliveryFeeTooltipController, required this.badWeatherCharge, required this.extraChargeForToolTip, required this.deliveryOptionScrollController});

  @override
  Widget build(BuildContext context) {
    bool takeAway = false;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      takeAway = (checkoutController.orderType == 'take_away');
      return Column(children: [

        SizedBox(height: isGuestLoggedIn && !isDesktop ? Dimensions.paddingSizeSmall : 0),

        isGuestLoggedIn ? GuestLoginWidget(
          loginTooltipController: loginTooltipController,
          onTap: () async {
            if(!isDesktop) {
              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))!.then((value) {
                if(AuthHelper.isLoggedIn()) {
                  callBack();
                }
              });
            }else{
              Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: true))).then((value) {
                if(AuthHelper.isLoggedIn()) {
                  callBack();
                }
              });
            }
          },
        ) : const SizedBox(),
        SizedBox(height: isGuestLoggedIn ? Dimensions.paddingSizeSmall : 0),

        SizedBox(height: !isDesktop && isCashOnDeliveryActive && restaurantSubscriptionActive ? Dimensions.paddingSizeSmall : 0),

        restaurantSubscriptionActive && isLoggedIn ? Container(
          width: context.width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
          ),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(HeroiconsOutline.clipboardDocumentList, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text('order_type'.tr, style: robotoSemiBold),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Row(children: [
              Expanded(child: OrderTypeWidget(
                title: 'regular'.tr,
                icon: Images.regularOrder,
                isSelected: !checkoutController.subscriptionOrder,
                onTap: () {
                  checkoutController.setSubscription(false);
                  if(checkoutController.isPartialPay){
                    checkoutController.changePartialPayment();
                  } else {
                    checkoutController.setPaymentMethod(-1);
                  }
                  checkoutController.updateTips(
                    checkoutController.getDmTipIndex().isNotEmpty ? int.parse(checkoutController.getDmTipIndex()) : 1, notify: false,
                  );
                },
              )),
              SizedBox(width: isCashOnDeliveryActive ? Dimensions.paddingSizeSmall : 0),

              Expanded(child: OrderTypeWidget(
                title: 'subscription'.tr,
                icon: Images.subscriptionOrder,
                isSelected: checkoutController.subscriptionOrder,
                onTap: () {
                  checkoutController.setSubscription(true);
                  checkoutController.addTips(0);
                  if(checkoutController.isPartialPay){
                    checkoutController.changePartialPayment();
                  } else {
                    checkoutController.setPaymentMethod(-1);
                  }
                },
              )),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            checkoutController.subscriptionOrder ? SubscriptionView(
              checkoutController: checkoutController,
            ) : const SizedBox(),
            SizedBox(height: checkoutController.subscriptionOrder ? Dimensions.paddingSizeLarge : 0),
          ]),
        ) : const SizedBox(),
        SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : isCashOnDeliveryActive && restaurantSubscriptionActive && isLoggedIn ? Dimensions.paddingSizeSmall : 0),

        checkoutController.restaurant != null ? Container(
          width: context.width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
          ),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Icon(HeroiconsOutline.truck, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text('delivery_option'.tr, style: robotoSemiBold),
            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            SingleChildScrollView(controller: deliveryOptionScrollController, scrollDirection: Axis.horizontal, child: Builder(
              builder: (context) {
                // Null-safe configModel and restaurant access
                final configModel = Get.find<SplashController>().configModel;
                final restaurant = checkoutController.restaurant;
                final homeDeliveryEnabled = (configModel?.homeDelivery ?? false) && (restaurant?.delivery ?? false);
                final takeAwayEnabled = (configModel?.takeAway ?? false) && (restaurant?.takeAway ?? false) && !checkoutController.subscriptionOrder;
                final dineInEnabled = (configModel?.dineInOrderOption ?? false) && (restaurant?.isActiveDineIn ?? false) && !checkoutController.subscriptionOrder;

                return Row(children: [
                  homeDeliveryEnabled ? DeliveryOptionButton(
                    value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                    isFree: restaurant?.freeDelivery, total: total,
                    chargeForView: deliveryChargeForView, deliveryFeeTooltipController: deliveryFeeTooltipController,
                    badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
                  ) : const SizedBox(),
                  SizedBox(width: homeDeliveryEnabled ? Dimensions.paddingSizeDefault : 0),

                  takeAwayEnabled ? DeliveryOptionButton(
                    value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true, total: total,
                    badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
                  ) : const SizedBox(),
                  SizedBox(width: takeAwayEnabled ? Dimensions.paddingSizeDefault : 0),

                  dineInEnabled ? DeliveryOptionButton(
                    value: 'dine_in', title: 'dine_in'.tr, charge: deliveryCharge, isFree: true, total: total,
                    badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip, guestNameTextEditingController: guestNameTextEditingController,
                    guestNumberTextEditingController: guestNumberTextEditingController, guestEmailController: guestEmailController,
                  ) : const SizedBox(),
                ]);
              },
            )),
            SizedBox(height: isDesktop ? Dimensions.paddingSizeDefault : 0),
          ]),
        ) : const SizedBox(),
        const SizedBox(height: 12),

        ///Dine in Estimated Arrival Time
        EstimatedArrivalTimeWidget(checkoutController: checkoutController),

        /// Time Slot
        TimeSlotSection(fromCart: fromCart, checkoutController: checkoutController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, tooltipController2: tooltipController2),

        ///Delivery Address
        DeliverySection(
          checkoutController: checkoutController,
          locationController: locationController, guestNameTextEditingController: guestNameTextEditingController,
          guestNumberTextEditingController: guestNumberTextEditingController, guestNumberNode: guestNumberNode,
          guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
        ),
        const SizedBox(height: 12),

        /// Prescription Image (for pharmacy orders)
        const PrescriptionSection(),
        const SizedBox(height: 12),

        /// Coupon
        !ResponsiveHelper.isDesktop(context) && !isGuestLoggedIn ? CouponSection(
          charge: charge, checkoutController: checkoutController, price: price,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, total: total,
        ) : const SizedBox(),
        SizedBox(height: !ResponsiveHelper.isDesktop(context) ? 12.0 : 0),

        ///DmTips
        DeliveryManTipsSection(
          takeAway: takeAway, tooltipController3: tooltipController3, checkoutController: checkoutController,
          totalPrice: total, onTotalChange: (double price) => total + price,
        ),

        ///payment..
        Column(children: [
          isDesktop ? PaymentSection(
            isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
            isWalletActive: isWalletActive, total: total, checkoutController: checkoutController, isOfflinePaymentActive: isOfflinePaymentActive,
          ) : const SizedBox(),
          isDesktop ? PartialPayView(totalPrice: total) : const SizedBox(),
        ]),

        isDesktop ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text('additional_note'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CustomTextFieldWidget(
            controller: checkoutController.noteController,
            hintText: 'share_any_specific_delivery_details_here'.tr,
            showLabelText: false,
            maxLines: 3,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.done,
            capitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]) : const SizedBox(),

      ]);
    });
  }
}
