import 'package:mnjood_vendor/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_details_model.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderProductWidget extends StatelessWidget {
  final OrderModel? order;
  final OrderDetailsModel orderDetails;
  const OrderProductWidget({super.key, required this.order, required this.orderDetails});
  
  @override
  Widget build(BuildContext context) {

    String addOnText = '';
    String variationText = '';

    for (var addOn in orderDetails.addOns ?? []) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    if((orderDetails.variation ?? []).isNotEmpty) {
      for(Variation variation in orderDetails.variation ?? []) {
        variationText = '$variationText${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        for(VariationOption value in variation.variationValues ?? []) {
          variationText = '$variationText${variationText.endsWith('(') ? '' : ', '}${value.level}';
        }
        variationText = '$variationText)';
      }
    }else if((orderDetails.oldVariation ?? []).isNotEmpty) {
      variationText = orderDetails.oldVariation?[0].type ?? '';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Product image with better styling
        if (orderDetails.foodDetails?.imageFullUrl != null && orderDetails.foodDetails!.imageFullUrl!.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                height: 70, width: 70, fit: BoxFit.cover,
                image: '${orderDetails.foodDetails?.imageFullUrl ?? ''}',
              ),
            ),
          ),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Product name row
            Row(children: [
              Expanded(
                child: Row(children: [
                  Flexible(
                    child: Text(
                      orderDetails.foodDetails?.name ?? '',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  if (Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false)
                    CustomAssetImageWidget(
                      image: (orderDetails.foodDetails?.veg ?? 0) == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 12, width: 12,
                    ),
                ]),
              ),
            ]),
            const SizedBox(height: 4),

            // Price and quantity
            Row(children: [
              PriceConverter.convertPriceWithSvg(
                orderDetails.unitSellingPrice ?? orderDetails.price,
                textStyle: robotoMedium.copyWith(color: Theme.of(context).primaryColor), symbolSize: 12,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'x${orderDetails.quantity}${orderDetails.unitLabel != null ? ' ${orderDetails.unitLabel}' : ''}',
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
            ]),

            // Addons
            if (addOnText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${'addons'.tr}: $addOnText',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Variations
            if (variationText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${'variations'.tr}: $variationText',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

          ]),
        ),
      ]),
    );
  }
}