import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/widgets/coupon_bottom_sheet.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
class CouponSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double charge;
  final double total;
  const CouponSection({super.key, required this.checkoutController, required this.price, required this.discount, required this.addOns, required this.deliveryCharge, required this.total, required this.charge});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<CouponController>(
      builder: (couponController) {
        final bool couponApplied = (couponController.discount ?? 0) > 0 || couponController.freeDelivery;
        final Color accentColor = couponApplied ? const Color(0xFF2ECC71) : Theme.of(context).primaryColor;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
          ),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault),
          child: IntrinsicHeight(
            child: Row(children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusLarge),
                    bottomLeft: Radius.circular(Dimensions.radiusLarge),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: !couponApplied ? Row(children: [
                    // Coupon icon in tinted circle
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Icon(HeroiconsOutline.ticket, size: 18, color: Theme.of(context).primaryColor)),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('add_coupon'.tr, style: robotoSemiBold),
                      Text('save_more_on_your_order'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                    ])),

                    InkWell(
                      onTap: () {
                        if(ResponsiveHelper.isDesktop(context)){
                          Get.dialog(Dialog(child: CouponBottomSheet(checkoutController: checkoutController, price: price, discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, charge: charge, total: total))).then((value) {
                            if(value != null) {
                              checkoutController.couponController.text = value.toString();
                            }
                          });
                        }else{
                          Get.bottomSheet(
                            CouponBottomSheet(checkoutController: checkoutController, price: price, discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, charge: charge, total: total),
                            backgroundColor: Colors.transparent, isScrollControlled: true,
                          );
                        }
                      },
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Icon(HeroiconsOutline.chevronRight, size: 18, color: Colors.white)),
                      ),
                    ),
                  ]) : Row(children: [
                    // Green check icon in tinted circle
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Icon(HeroiconsOutline.checkCircle, size: 18, color: Color(0xFF2ECC71))),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${'coupon_applied'.tr}!', style: robotoSemiBold.copyWith(color: const Color(0xFF2ECC71))),
                      Text(checkoutController.couponController.text, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                    ])),

                    InkWell(
                      onTap: () {
                        couponController.removeCouponData(true);
                        checkoutController.couponController.text = '';
                        if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1){
                          checkoutController.checkBalanceStatus((total + charge));
                        }
                      },
                      child: SizedBox(height: 40, width: 40, child: Icon(HeroiconsOutline.xMark, color: Theme.of(context).colorScheme.error)),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
