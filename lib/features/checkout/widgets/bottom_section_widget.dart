import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/widgets/condition_check_box.dart';
import 'package:mnjood/features/checkout/widgets/coupon_section.dart';
import 'package:mnjood/features/checkout/widgets/order_place_button.dart';
import 'package:mnjood/features/checkout/widgets/partial_pay_view.dart';
import 'package:mnjood/features/checkout/widgets/payment_section.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class BottomSectionWidget extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final double total;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final double charge;
  final CheckoutController checkoutController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final double taxPercent;
  final bool fromCart;
  final List<CartModel>? cartList;
  final double price;
  final double addOns;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final ExpansibleController expansionTileController;
  final JustTheController serviceFeeTooltipController;
  final double referralDiscount;
  final double extraPackagingAmount;
  final double additionalCharge;
  const BottomSectionWidget({
    super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.total,
    required this.subTotal, required this.discount, required this.couponController,
    required this.taxIncluded, required this.tax, required this.deliveryCharge, required this.checkoutController,
    required this.locationController, required this.todayClosed, required this.tomorrowClosed,
    required this.orderAmount, this.maxCodOrderAmount, required this.subscriptionQty, required this.taxPercent,
    required this.fromCart, required this.cartList, required this.price, required this.addOns, required this.charge, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.isOfflinePaymentActive, required this.guestEmailController,
    required this.guestEmailNode, required this.expansionTileController, required this.serviceFeeTooltipController, required this.referralDiscount, required this.extraPackagingAmount,
    required this.additionalCharge,
  });

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    return Container(
      decoration: isDesktop ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],

      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        !isDesktop ? PaymentSection(
          isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
          isWalletActive: isWalletActive, total: total, checkoutController: checkoutController, isOfflinePaymentActive: isOfflinePaymentActive,
        ) : const SizedBox(),

        !isDesktop ? PartialPayView(totalPrice: total) : const SizedBox(),

        SizedBox(height: isDesktop ? 0 : Dimensions.paddingSizeSmall),

        /// Coupon
        isDesktop && !isGuestLoggedIn ? CouponSection(
          checkoutController: checkoutController, price: price, charge: charge,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, total: total,
        ) : const SizedBox(),
        SizedBox(height: !isDesktop ? Dimensions.paddingSizeExtraSmall : 0),

        isDesktop ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: pricingView(context, isDesktop),
        ) : const SizedBox(),

        !isDesktop ? Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Icon(HeroiconsOutline.chatBubbleBottomCenterText, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text('additional_note'.tr, style: robotoSemiBold),
            ]),
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

            pricingView(context, isDesktop),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            const CheckoutCondition(),

          ]),
        ) : const SizedBox(),

        isDesktop ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: CheckoutCondition(),
        ) : const SizedBox(),

        isDesktop ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    'total_amount'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                  PriceConverter.convertAnimationPrice(
                    total,
                    textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                ]),
              ),

              OrderPlaceButton(
                checkoutController: checkoutController, locationController: locationController,
                todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, deliveryCharge: deliveryCharge,
                tax: tax, discount: discount, total: total, maxCodOrderAmount: maxCodOrderAmount, subscriptionQty: subscriptionQty,
                cartList: cartList, isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                isWalletActive: isWalletActive, fromCart: fromCart, guestNumberTextEditingController: guestNumberTextEditingController,
                guestNameTextEditingController: guestNameTextEditingController, guestNumberNode: guestNumberNode, isOfflinePaymentActive: isOfflinePaymentActive,
                guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                couponController: couponController, subTotal: subTotal, taxIncluded: taxIncluded, taxPercent: taxPercent, extraPackagingAmount: extraPackagingAmount,
              ),
            ],
          ),

        ) : const SizedBox(),
      ]),
    );
  }

  Widget pricingView(BuildContext context, bool isDesktop) {
    return Container(
      decoration: !isDesktop ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ) : null,
      padding: !isDesktop ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section header
        Row(children: [
          Icon(HeroiconsOutline.calculator, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text('order_summary'.tr, style: !isDesktop ? robotoSemiBold : robotoBold),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Divider(thickness: 0.5, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Pricing rows (always visible, no ExpansionTile)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(!checkoutController.subscriptionOrder ? 'subtotal'.tr : 'item_price'.tr, style: robotoRegular),
          PriceConverter.convertPriceWithSvg(subTotal, textStyle: robotoRegular, symbolSize: 12),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('discount'.tr, style: robotoRegular),
          Row(children: [
            Text('(-) ', style: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
            PriceConverter.convertAnimationPrice(discount, textStyle: robotoRegular.copyWith(color: const Color(0xFF2ECC71)))
          ]),
        ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

        ((couponController.discount ?? 0) > 0 || couponController.freeDelivery) ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('coupon_discount'.tr, style: robotoRegular),
            (couponController.coupon != null && couponController.coupon?.couponType == 'free_delivery') ? Text(
              'free_delivery'.tr, style: robotoRegular.copyWith(color: const Color(0xFF2ECC71)),
            ) : Row(children: [
              Text('(-) ', style: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
              PriceConverter.convertPriceWithSvg(couponController.discount, textStyle: robotoRegular.copyWith(color: const Color(0xFF2ECC71)), symbolSize: 12),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]) : const SizedBox(),

        referralDiscount > 0 ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('referral_discount'.tr, style: robotoRegular),
            Row(children: [
              Text('(-) ', style: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
              PriceConverter.convertPriceWithSvg(referralDiscount, textStyle: robotoRegular.copyWith(color: const Color(0xFF2ECC71)), symbolSize: 12),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]) : const SizedBox(),

        const SizedBox(),
        const SizedBox(),

        (checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in' && (Get.find<SplashController>().configModel?.dmTipsStatus ?? 0) == 1 && !checkoutController.subscriptionOrder) ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('delivery_man_tips'.tr, style: robotoRegular),
            Row(children: [
              Text('(+) ', style: robotoRegular),
              PriceConverter.convertAnimationPrice(checkoutController.tips, textStyle: robotoRegular)
            ]),
          ],
        ) : const SizedBox.shrink(),
        SizedBox(height: checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in' && (Get.find<SplashController>().configModel?.dmTipsStatus ?? 0) == 1 && !checkoutController.subscriptionOrder ? Dimensions.paddingSizeSmall : 0.0),

        (extraPackagingAmount > 0) ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('extra_packaging'.tr, style: robotoRegular),
            Row(children: [
              Text('(+) ', style: robotoRegular),
              PriceConverter.convertPriceWithSvg(checkoutController.restaurant?.extraPackagingAmount ?? 0, textStyle: robotoRegular, symbolSize: 12),
            ]),
          ],
        ) : const SizedBox.shrink(),
        SizedBox(height: extraPackagingAmount > 0 ? Dimensions.paddingSizeSmall : 0),

        checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('delivery_fee'.tr, style: robotoRegular),
          checkoutController.distance == -1 ? Text(
            'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
          ) : (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon?.couponType == 'free_delivery')) ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('free'.tr, style: robotoMedium.copyWith(color: const Color(0xFF2ECC71), fontSize: Dimensions.fontSizeSmall)),
          ) : Row(children: [
            Text('(+) ', style: robotoRegular),
            PriceConverter.convertPriceWithSvg(deliveryCharge, textStyle: robotoRegular, symbolSize: 12),
          ]),
        ]) : const SizedBox(),
        SizedBox(height: checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in' ? Dimensions.paddingSizeSmall : 0),

        // Per-gateway service fee (from selected payment item's charge_percentage)
        Builder(builder: (context) {
          final configModel = Get.find<SplashController>().configModel;
          final chargeName = configModel?.additionalChargeName ?? 'gateway_fee'.tr;
          final selectedItem = checkoutController.selectedPaymentItem;
          final showFee = additionalCharge > 0;
          if (!showFee) return const SizedBox();
          String label = chargeName;
          if (selectedItem != null && selectedItem.chargePercentage > 0) {
            label += ' (${selectedItem.chargePercentage.toStringAsFixed(selectedItem.chargePercentage == selectedItem.chargePercentage.roundToDouble() ? 0 : 1)}%)';
          } else if (configModel?.additionalChargeType == 'percent') {
            label += ' (${configModel!.additionCharge?.toStringAsFixed(configModel.additionCharge == configModel.additionCharge!.roundToDouble() ? 0 : 1)}%)';
          }
          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text(label, style: robotoRegular),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            ]),
            Row(children: [
              Text('(+) ', style: robotoRegular),
              PriceConverter.convertPriceWithSvg(additionalCharge, textStyle: robotoRegular, symbolSize: 12),
            ]),
          ]);
        }),
        SizedBox(height: additionalCharge > 0 ? Dimensions.paddingSizeSmall : 0),

        // Total divider
        Divider(thickness: 1.5, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),

        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: Text(
            'all_prices_include_vat'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),

        (isDesktop || checkoutController.isPartialPay) && checkoutController.subscriptionOrder ? Column(
          children: [
            Row(children: [
              Text(
                checkoutController.subscriptionOrder ? 'subtotal'.tr : 'total_amount'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: checkoutController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
              (checkoutController.taxIncluded == 1) ? Text(' ${'vat_tax_inc'.tr}', style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
              )) : const SizedBox(),
              const Expanded(child: SizedBox()),
              PriceConverter.convertAnimationPrice(
                total,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: checkoutController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
            ]),
          ],
        ) : const SizedBox(),

        !isDesktop && checkoutController.subscriptionOrder ? Column(
          children: [
            Row(children: [
              Text(
                'subtotal'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: checkoutController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
              const Expanded(child: SizedBox()),
              PriceConverter.convertAnimationPrice(
                total,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: checkoutController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
            ]),
          ],
        ) : const SizedBox(),

        checkoutController.subscriptionOrder ? Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('subscription_order_count'.tr, style: robotoMedium),
            Text(subscriptionQty.toString(), style: robotoMedium),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Divider(thickness: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
          ),
        ]) : const SizedBox(),
        SizedBox(height: checkoutController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

        checkoutController.isPartialPay && !checkoutController.subscriptionOrder ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('paid_by_wallet'.tr, style: robotoRegular),
          Row(children: [
            Text('(-) ', style: robotoRegular),
            PriceConverter.convertPriceWithSvg(Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0, textStyle: robotoRegular, symbolSize: 12),
          ]),
        ]) : const SizedBox(),
        SizedBox(height: checkoutController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

        checkoutController.isPartialPay && !checkoutController.subscriptionOrder ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'due_payment'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !isDesktop ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
          ),
          PriceConverter.convertAnimationPrice(
            checkoutController.viewTotalPrice,
            textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !isDesktop ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
          )
        ]) : const SizedBox(),

        isDesktop && !checkoutController.subscriptionOrder ? Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
        ) : const SizedBox(),

      ]),
    );
  }
}

