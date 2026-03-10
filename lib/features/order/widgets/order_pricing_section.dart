import 'package:dotted_border/dotted_border.dart';
import 'package:mnjood/common/widgets/custom_card.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/widgets/bottom_view_widget.dart';
import 'package:mnjood/features/order/widgets/order_product_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPricingSection extends StatelessWidget {
  final double itemsPrice;
  final double addOns;
  final OrderModel order;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double tax;
  final double dmTips;
  final double deliveryCharge;
  final double total;
  final OrderController orderController;
  final int? orderId;
  final String? contactNumber;
  final double extraPackagingAmount;
  final double referrerBonusAmount;
  const OrderPricingSection({super.key, required this.itemsPrice, required this.addOns, required this.order, required this.subTotal, required this.discount,
    required this.couponDiscount, required this.tax, required this.dmTips, required this.deliveryCharge, required this.total, required this.orderController,
    this.orderId, this.contactNumber, required this.extraPackagingAmount, required this.referrerBonusAmount});

  @override
  Widget build(BuildContext context) {
    bool subscription = order.subscription != null;
    bool isDineIn = order.orderType == 'dine_in';

    return CustomCard(
      isBorder: false,
      padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.symmetric(horizontal: 0, vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        ResponsiveHelper.isDesktop(context) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Text('item_info'.tr, style: robotoMedium),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderController.orderDetails!.length,
            itemBuilder: (context, index) {
              return OrderProductWidget(order: order, orderDetails: orderController.orderDetails![index]);
            },
          ),
        ]) : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [

            // Total
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('item_price'.tr, style: robotoRegular),
              PriceConverter.convertPriceWithSvg(itemsPrice, textStyle: robotoRegular, symbolSize: 12),
            ]),
            const SizedBox(height: 10),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('addons'.tr, style: robotoRegular),
              Row(children: [
                Text('(+) ', style: robotoRegular),
                PriceConverter.convertPriceWithSvg(addOns, textStyle: robotoRegular, symbolSize: 12),
              ]),
            ]),

            Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),

            !subscription ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('subtotal'.tr, style: robotoMedium),
              PriceConverter.convertPriceWithSvg(subTotal, textStyle: robotoMedium, symbolSize: 12),
            ]) : const SizedBox(),
            SizedBox(height: !subscription ? Dimensions.paddingSizeSmall : 0),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('discount'.tr, style: robotoRegular),
              Row(children: [
                Text('(-) ', style: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
                PriceConverter.convertPriceWithSvg(discount, textStyle: robotoRegular.copyWith(color: const Color(0xFF2ECC71)), symbolSize: 12),
              ]),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            (order.additionalCharge != null && order.additionalCharge! > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(Get.find<SplashController>().configModel?.additionalChargeName ?? 'gateway_fee'.tr, style: robotoRegular),
              Row(children: [
                Text('(+) ', style: robotoRegular),
                PriceConverter.convertPriceWithSvg(order.additionalCharge, textStyle: robotoRegular, symbolSize: 12),
              ]),
            ]) : const SizedBox(),
            (order.additionalCharge != null && order.additionalCharge! > 0) ? const SizedBox(height: 10) : const SizedBox(),

            couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('coupon_discount'.tr, style: robotoRegular),
              Row(children: [
                Text('(-) ', style: robotoRegular.copyWith(color: const Color(0xFF2ECC71))),
                PriceConverter.convertPriceWithSvg(couponDiscount, textStyle: robotoRegular.copyWith(color: const Color(0xFF2ECC71)), symbolSize: 12),
              ]),
            ]) : const SizedBox(),
            SizedBox(height: couponDiscount > 0 ? Dimensions.paddingSizeSmall : 0),

            (referrerBonusAmount > 0) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('referral_discount'.tr, style: robotoRegular),
                Row(children: [
                  Text('(-) ', style: robotoRegular),
                  PriceConverter.convertPriceWithSvg(referrerBonusAmount, textStyle: robotoRegular, symbolSize: 12),
                ]),
              ],
            ) : const SizedBox(),
            SizedBox(height: referrerBonusAmount > 0 ? 10 : 0),

            const SizedBox(),
            const SizedBox(),

            /*!taxIncluded ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('vat_tax'.tr, style: robotoRegular),
              Text('(+) ${PriceConverter.convertPrice(tax)}', style: robotoRegular, textDirection: TextDirection.ltr),
            ]) : const SizedBox(),
            SizedBox(height: taxIncluded ? 0 : Dimensions.paddingSizeSmall),*/

            (!subscription && !isDineIn && order.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('delivery_man_tips'.tr, style: robotoRegular),
                Row(children: [
                  Text('(+) ', style: robotoRegular),
                  PriceConverter.convertPriceWithSvg(dmTips, textStyle: robotoRegular, symbolSize: 12),
                ]),
              ],
            ) : const SizedBox(),
            SizedBox(height: (order.orderType != 'take_away' && !isDineIn && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? 10 : 0),

            (extraPackagingAmount > 0) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('extra_packaging'.tr, style: robotoRegular),
                Row(children: [
                  Text('(+) ', style: robotoRegular),
                  PriceConverter.convertPriceWithSvg(extraPackagingAmount, textStyle: robotoRegular, symbolSize: 12),
                ]),
              ],
            ) : const SizedBox(),
            SizedBox(height: extraPackagingAmount > 0 ? 10 : 0),

            !isDineIn && order.orderType != 'take_away' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('delivery_fee'.tr, style: robotoRegular),
              deliveryCharge > 0 ? Row(children: [
                Text('(+) ', style: robotoRegular),
                PriceConverter.convertPriceWithSvg(deliveryCharge, textStyle: robotoRegular, symbolSize: 12),
              ]) : Text('free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
            ]) : const SizedBox(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
            ),

            order.paymentMethod == 'partial_payment' ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1,
                  strokeCap: StrokeCap.butt,
                  dashPattern: const [8, 5],
                  padding: const EdgeInsets.all(8),
                  radius: const Radius.circular(Dimensions.radiusDefault),
                ),
                child: Column(children: [

                  Row(children: [
                    Text('total_amount'.tr, style: robotoMedium.copyWith(
                      fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor,
                    )),

                    Text(' ${'vat_tax_inc'.tr}', style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                    )),

                    const Expanded(child: SizedBox()),

                    PriceConverter.convertPriceWithSvg(
                      total,
                      textStyle: robotoMedium.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                      symbolColor: Theme.of(context).primaryColor,
                      symbolSize: 12,
                    ),
                  ]),
                  const SizedBox(height: 10),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('paid_by_wallet'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    PriceConverter.convertPriceWithSvg(
                      order.payments?[0].amount ?? 0,
                      textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      symbolSize: 12,
                    ),
                  ]),
                  const SizedBox(height: 10),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      '${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.toString().replaceAll('_', ' ')})',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    PriceConverter.convertPriceWithSvg(
                      order.payments?[1].amount ?? 0,
                      textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      symbolSize: 12,
                    ),
                  ]),

                ]),
              ),
            ) : Container(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1.5)),
              ),
              child: Row(children: [
                Text(subscription ? 'subtotal'.tr : 'total_amount'.tr, style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor,
                )),

                Text(' ${'vat_tax_inc'.tr}', style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                )),

                const Expanded(child: SizedBox()),

                PriceConverter.convertPriceWithSvg(
                  total,
                  textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                  symbolColor: Theme.of(context).primaryColor,
                  symbolSize: 16,
                ),
              ]),
            ),

            subscription ? Column(children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('subscription_order_count'.tr, style: robotoMedium),
                Text(order.subscription!.quantity.toString(), style: robotoMedium),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  'total_amount'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
                PriceConverter.convertPriceWithSvg(
                  total * order.subscription!.quantity!,
                  textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  symbolColor: Theme.of(context).primaryColor,
                  symbolSize: 14,
                ),
              ]),
            ]) : const SizedBox(),

          ]),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),

        ResponsiveHelper.isDesktop(context) ? BottomViewWidget(orderController: orderController, order: order, orderId: orderId, total: total, contactNumber: contactNumber) : const SizedBox(),

      ]),
    );
  }
}
