import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/order/domain/models/order_details_model.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderProductWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final int? itemLength;
  final int? index;
  const OrderProductWidget({super.key, required this.order, required this.orderDetails, this.itemLength, this.index});
  
  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';
    if(orderDetails.variation!.isNotEmpty) {
      for(Variation variation in orderDetails.variation!) {
        variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        for(VariationValue value in variation.variationValues!) {
          variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
        }
        variationText = '${variationText!})';
      }
    }else if(orderDetails.oldVariation!.isNotEmpty) {
      List<String> variationTypes = orderDetails.oldVariation![0].type!.split('-');
      if(variationTypes.length == orderDetails.foodDetails!.choiceOptions!.length) {
        int index = 0;
        for (var choice in orderDetails.foodDetails!.choiceOptions!) {
          variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      }else {
        variationText = orderDetails.oldVariation![0].type;
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          orderDetails.foodDetails!.imageFullUrl != null && orderDetails.foodDetails!.imageFullUrl!.isNotEmpty ? Padding(
            padding: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                height: 80, width: 80, fit: BoxFit.cover,
                image: '${orderDetails.foodDetails!.imageFullUrl}',
                isFood: true,
              ),
            ),
          ) : const SizedBox.shrink(),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                orderDetails.foodDetails?.name ?? '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

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
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              PriceConverter.convertPriceWithSvg(
                orderDetails.price,
                textStyle: robotoMedium,
                symbolSize: 12,
              ),

              (orderDetails.foodDetails?.isRestaurantHalalActive ?? false) && (orderDetails.foodDetails?.isHalalFood ?? false) ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                child: const CustomAssetImageWidget(Images.halalIcon, height: 13, width: 13),
              ) : const SizedBox(),

              addOnText.isNotEmpty ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'addons'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  Flexible(child: Text(
                      addOnText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                      ))),
                ]),
              ) : const SizedBox(),

              variationText != '' ? (orderDetails.foodDetails!.variations != null && orderDetails.foodDetails!.variations!.isNotEmpty) ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'variations'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  Flexible(child: Text(
                      variationText!,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                      ))),
                ]),
              ) : const SizedBox() : const SizedBox(),

            ]),
          ),
        ]),

      ]),
    );
  }
}
