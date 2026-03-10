import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/features/profile/domain/models/profile_model.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_details_model.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/features/order/widgets/price_widget.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

class InvoiceDialogWidget extends StatelessWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  final ScreenshotController screenshotController;
  const InvoiceDialogWidget({super.key, required this.order, required this.orderDetails, required this.screenshotController});

  String _priceDecimal(double price) {
    return PriceConverter.convertPrice(price, asFixed: Get.find<SplashController>().configModel?.digitAfterDecimalPoint ?? 2);
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = View.of(context).physicalSize.width > 1000 ? Dimensions.fontSizeExtraSmall : Dimensions.paddingSizeSmall;

    Restaurant? restaurant = Get.find<ProfileController>().profileModel?.restaurants?.isNotEmpty == true
        ? Get.find<ProfileController>().profileModel!.restaurants![0]
        : null;

    double itemsPrice = 0;
    double addOns = 0;
    if (orderDetails != null) {
      for (OrderDetailsModel detail in orderDetails!) {
        for (AddOn addOn in detail.addOns ?? []) {
          addOns = addOns + ((addOn.price ?? 0) * (addOn.quantity ?? 0));
        }
        itemsPrice = itemsPrice + ((detail.price ?? 0) * (detail.quantity ?? 1));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
          ),
          width: context.width - ((View.of(context).physicalSize.width - 700) * 0.4),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Screenshot(
            controller: screenshotController,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [

              Text(restaurant?.name ?? '', style: robotoMedium.copyWith(fontSize: fontSize)),
              Text(restaurant?.address ?? '', style: robotoRegular.copyWith(fontSize: fontSize)),
              Text(restaurant?.phone ?? '', style: robotoRegular.copyWith(fontSize: fontSize)),
              Text(restaurant?.email ?? '', style: robotoRegular.copyWith(fontSize: fontSize)),
              const SizedBox(height: 10),

              Wrap(children: [

                Row(children: [
                  Text('${'order_id'.tr}:', style: robotoRegular.copyWith(fontSize: fontSize)),
                  const SizedBox(width: 5),
                  Text(order?.id?.toString() ?? '', style: robotoMedium.copyWith(fontSize: fontSize)),
                ]),

                Text(order?.createdAt != null ? DateConverter.dateTimeStringToMonthAndTime(order!.createdAt!) : '', style: robotoRegular.copyWith(fontSize: fontSize)),
              ]),

              order?.scheduled == 1 && order?.scheduleAt != null ? Text(
                '${'scheduled_order_time'.tr} ${DateConverter.dateTimeStringToDateTime(order!.scheduleAt!)}',
                style: robotoRegular.copyWith(fontSize: fontSize),
              ) : const SizedBox(),
              const SizedBox(height: 5),

              order?.orderType == 'dine_in' ? Align(
                alignment: Alignment.centerLeft,
                child: Column(children: [
                  order?.orderReference?.tableNumber != null ? Text('${'table_number'.tr}: ${order?.orderReference?.tableNumber ?? ''}', style: robotoRegular.copyWith(fontSize: fontSize)) : const SizedBox(),
                  order?.orderReference?.tokenNumber != null ? Text('${'token_number'.tr}: ${order?.orderReference?.tokenNumber ?? ''}', style: robotoRegular.copyWith(fontSize: fontSize)) : const SizedBox(),
                ]),
              ) : const SizedBox(),
              SizedBox(height: order?.orderType == 'dine_in' ? 5 : 0),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(order?.orderType?.tr ?? '', style: robotoRegular.copyWith(fontSize: fontSize)),
                Text(order?.paymentMethod?.tr ?? '', style: robotoRegular.copyWith(fontSize: fontSize)),
              ]),
              Divider(color: Theme.of(context).textTheme.bodyLarge?.color, thickness: 1),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${order?.customer?.fName ?? 'guest'.tr} ${order?.customer?.lName ?? 'user'.tr}', style: robotoRegular.copyWith(fontSize: fontSize)),
                  order?.orderType == 'delivery' ? Text(order?.deliveryAddress?.address ?? '', style: robotoRegular.copyWith(fontSize: fontSize)) : const SizedBox(),
                  Text(order?.deliveryAddress?.contactPersonNumber ?? '', style: robotoRegular.copyWith(fontSize: fontSize)),
                ]),
              ),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(flex: 1, child: Text('sl'.tr.toUpperCase(), style: robotoMedium.copyWith(fontSize: fontSize))),
                Expanded(flex: 5, child: Text('item_info'.tr, style: robotoMedium.copyWith(fontSize: fontSize))),
                Expanded(flex: 2, child: Text(
                  'qty'.tr, style: robotoMedium.copyWith(fontSize: fontSize),
                  textAlign: TextAlign.center,
                )),
                Expanded(flex: 2, child: Text(
                  'price'.tr, style: robotoMedium.copyWith(fontSize: fontSize),
                  textAlign: TextAlign.right,
                )),
              ]),
              Divider(color: Theme.of(context).textTheme.bodyLarge?.color, thickness: 1),

              ListView.builder(
                itemCount: orderDetails?.length ?? 0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final detail = orderDetails![index];

                  String addOnText = '';
                  for (var addOn in detail.addOns ?? []) {
                    addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name ?? ''} X ${addOn.quantity ?? 0} = ${(addOn.price ?? 0) * (addOn.quantity ?? 0)}';
                  }

                  String? variationText = '';
                  if (detail.variation != null && detail.variation!.isNotEmpty) {
                    for (Variation variation in detail.variation!) {
                      variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name ?? ''} (';
                      for (VariationOption value in variation.variationValues ?? []) {
                        variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level ?? ''}';
                      }
                      variationText = '${variationText!})';
                    }
                  } else if (detail.oldVariation != null && detail.oldVariation!.isNotEmpty) {
                    variationText = detail.oldVariation![0].type;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 1, child: Text(
                        (index+1).toString(),
                        style: robotoRegular.copyWith(fontSize: fontSize),
                      )),
                      Expanded(flex: 5, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          detail.foodDetails?.name ?? '',
                          style: robotoMedium.copyWith(fontSize: fontSize),
                        ),
                        const SizedBox(height: 2),

                        addOnText.isNotEmpty ? Text(
                          '${'addons'.tr}: $addOnText',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                        ) : const SizedBox(),

                        (detail.foodDetails?.variations != null && detail.foodDetails!.variations!.isNotEmpty) ? Text(
                          '${'variations'.tr}: ${variationText ?? ''}',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                        ) : const SizedBox(),

                      ])),
                      Expanded(flex: 2, child: Text(
                        (detail.quantity ?? 0).toString(), textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(fontSize: fontSize),
                      )),
                      Expanded(flex: 2, child: Text(
                        _priceDecimal(detail.price ?? 0), textAlign: TextAlign.right,
                        style: robotoRegular.copyWith(fontSize: fontSize),
                      )),
                    ]),
                  );
                },
              ),
              Divider(color: Theme.of(context).textTheme.bodyLarge?.color, thickness: 1),

              PriceWidget(title: 'item_price'.tr, value: _priceDecimal(itemsPrice), fontSize: fontSize),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              addOns > 0 ? PriceWidget(title: 'add_ons'.tr, value: _priceDecimal(addOns), fontSize: fontSize) : const SizedBox(),
              SizedBox(height: addOns > 0 ? Dimensions.paddingSizeExtraSmall : 0),

              PriceWidget(title: 'subtotal'.tr, value: _priceDecimal(itemsPrice + addOns), fontSize: fontSize),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              PriceWidget(title: 'discount'.tr, value: _priceDecimal(order?.restaurantDiscountAmount ?? 0), fontSize: fontSize),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              PriceWidget(title: 'coupon_discount'.tr, value: _priceDecimal(order?.couponDiscountAmount ?? 0), fontSize: fontSize),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              (order?.referrerBonusAmount ?? 0) > 0 ? PriceWidget(title: 'referral_discount'.tr, value: _priceDecimal(order?.referrerBonusAmount ?? 0), fontSize: fontSize) : const SizedBox(),
              SizedBox(height: (order?.referrerBonusAmount ?? 0) > 0 ? 5 : 0),

              PriceWidget(
                title: '${'vat_tax'.tr} ${(order?.taxStatus ?? false) ? 'vat_tax_inc'.tr : ''}',
                value: _priceDecimal(order?.totalTaxAmount ?? 0), fontSize: fontSize,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              PriceWidget(title: 'delivery_man_tips'.tr, value: _priceDecimal(order?.dmTips ?? 0), fontSize: fontSize),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              (order?.extraPackagingAmount ?? 0) > 0 && order?.orderType != 'dine_in' ? PriceWidget(title: 'extra_packaging'.tr, value: _priceDecimal(order?.extraPackagingAmount ?? 0), fontSize: fontSize) : const SizedBox(),
              SizedBox(height: (order?.extraPackagingAmount ?? 0) > 0 && order?.orderType != 'dine_in' ? 5 : 0),

              PriceWidget(title: 'delivery_fee'.tr, value: _priceDecimal(order?.deliveryCharge ?? 0), fontSize: fontSize),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              (order?.additionalCharge != null && order!.additionalCharge! > 0) ? PriceWidget(
                title: Get.find<SplashController>().configModel?.additionalChargeName ?? 'gateway_fee'.tr,
                value: _priceDecimal(order!.additionalCharge!), fontSize: fontSize,
              ) : const SizedBox(),

              order?.paymentMethod == 'partial_payment' && order?.payments != null && order!.payments!.length >= 2 ? Column(children: [

                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                PriceWidget(title: 'paid_by_wallet'.tr, value: _priceDecimal(order!.payments![0].amount ?? 0), fontSize: fontSize),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                PriceWidget(title: '${order!.payments![1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order!.payments![1].paymentMethod?.toString().replaceAll('_', ' ') ?? ''})',
                    value: _priceDecimal(order!.payments![1].amount ?? 0), fontSize: fontSize),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              ]) : const SizedBox(),

              Divider(color: Theme.of(context).textTheme.bodyLarge?.color, thickness: 1),
              PriceWidget(title: 'total_amount'.tr, value: _priceDecimal(order?.orderAmount ?? 0), fontSize: fontSize+2),
              Divider(color: Theme.of(context).textTheme.bodyLarge?.color, thickness: 1),

              Text('thank_you'.tr, style: robotoRegular.copyWith(fontSize: fontSize)),
              Divider(color: Theme.of(context).textTheme.bodyLarge?.color, thickness: 1),

              Text(
                '${Get.find<SplashController>().configModel?.businessName ?? ''}. ${Get.find<SplashController>().configModel?.footerText ?? ''}',
                style: robotoRegular.copyWith(fontSize: fontSize),
              ),

            ]),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

      ]),
    );
  }
}
