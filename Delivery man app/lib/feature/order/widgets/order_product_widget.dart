import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/common/widgets/custom_image_widget.dart';
import 'package:mnjood_delivery/feature/splash/controllers/splash_controller.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_details_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderProductWidgetWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final bool showDivider;
  const OrderProductWidgetWidget({super.key, required this.order, required this.orderDetails, this.showDivider = true});
  
  @override
  Widget build(BuildContext context) {
    try {
      return _buildContent(context);
    } catch (e) {
      return _buildFallback(context);
    }
  }

  Widget _buildFallback(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: const Icon(HeroiconsOutline.cake, color: Colors.grey),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderDetails.foodDetails?.name ?? 'item'.tr, style: robotoMedium),
                const SizedBox(height: 4),
                Text('${orderDetails.quantity ?? 1}x', style: robotoRegular),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Null safety checks
    if (orderDetails.foodDetails == null) {
      return _buildFallback(context);
    }

    String addOnText = '';
    if (orderDetails.addOns != null) {
      for (var addOn in orderDetails.addOns!) {
        addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
      }
    }

    String? variationText = '';

    if(orderDetails.variation != null && orderDetails.variation!.isNotEmpty) {
      for(Variation variation in orderDetails.variation!) {
        variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        if (variation.variationValues != null) {
          for(VariationValue value in variation.variationValues!) {
            variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
          }
        }
        variationText = '${variationText!})';
      }
    }else if(orderDetails.oldVariation != null && orderDetails.oldVariation!.isNotEmpty) {
      variationText = orderDetails.oldVariation![0].type;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: const Icon(HeroiconsOutline.cake, size: 30, color: Colors.grey),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              orderDetails.foodDetails?.name ?? '',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            Row(children: [

              PriceConverter.convertPriceWithSvg(orderDetails.price! - orderDetails.discountOnFood!, textStyle: robotoMedium, symbolSize: 12),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              orderDetails.discountOnFood! > 0 ? Expanded(child: PriceConverter.convertPriceWithSvg(orderDetails.price, textStyle: robotoMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ), symbolSize: 12)) : const Expanded(child: SizedBox()),

              /*Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Text(
                  orderDetails.foodDetails!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                ),
              ) : const SizedBox(),*/
            ]),

            addOnText.isNotEmpty ? Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(children: [
                Text('${'addons'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                Flexible(child: Text(
                  addOnText,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                )),

              ]),
            ) : const SizedBox(),

            (orderDetails.foodDetails!.variations != null && orderDetails.foodDetails!.variations!.isNotEmpty) ? Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(children: [
                Text('${'variations'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                Flexible(child: Text(
                  variationText!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                )),

              ]),
            ) : const SizedBox(),

          ]),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Column(children: [

          Row(children: [
            Text('${'quantity'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

            Text(
              orderDetails.quantity.toString(),
              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
            ),
            if (orderDetails.unitLabel != null) ...[
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '(${orderDetails.unitLabel})',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ),
            ],
          ]),
          SizedBox(height: Dimensions.paddingSizeSmall),

          Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Text(
              orderDetails.foodDetails!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
            ),
          ) : const SizedBox(),

        ]),

      ]),

      showDivider ? Divider(height: 35, color: Theme.of(context).hintColor.withOpacity(0.3)) : const SizedBox(),

    ]);
  }
}