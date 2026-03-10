import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_tool_tip_widget.dart';
import 'package:mnjood_vendor/common/widgets/discount_tag_widget.dart';
import 'package:mnjood_vendor/common/widgets/not_available_widget.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood_vendor/features/restaurant/widgets/product_delete_bottom_sheet.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/features/restaurant/screens/product_details_screen.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final int index;
  final int length;
  final bool inRestaurant;
  final bool isCampaign;
  const ProductWidget({super.key, required this.product, required this.index, required this.length, this.inRestaurant = false,
    this.isCampaign = false});

  @override
  Widget build(BuildContext context) {

    double? discount;
    String? discountType;
    bool isAvailable;
    bool isOutOfStock = false;

    discount = (product.restaurantDiscount == 0 || isCampaign) ? product.discount : product.restaurantDiscount;
    discountType = (product.restaurantDiscount == 0 || isCampaign) ? product.discountType : 'percent';
    isAvailable = DateConverter.isAvailable(product.availableTimeStarts, product.availableTimeEnds)
        && DateConverter.isAvailable(product.restaurantOpeningTime, product.restaurantClosingTime);

    if(product.variations != null && product.variations!.isNotEmpty) {
      for(int i=0; i<product.variations!.length; i++) {
        for(int j=0; j<product.variations![i].variationValues!.length; j++) {
          if(_stringToInt(product.variations![i].variationValues![j].currentStock)! > 0) {
            isOutOfStock = false;
          }else {
            isOutOfStock = true;
            break;
          }
        }
      }
    }


    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return Slidable(
        key: UniqueKey(),
        enabled: !restaurantController.isLoading,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: context.width > 400 ? 0.2 : 0.21,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 13),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(Dimensions.radiusDefault)),
              ),
              child: Column(children: [

                InkWell(
                  onTap: () {
                    if(Get.find<ProfileController>().profileModel!.restaurants![0].foodSection!) {
                      showCustomBottomSheet(
                        child: ProductDeleteBottomSheet(productId: product.id!),
                      );
                    }else {
                      showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                    ),
                    child: Icon(HeroiconsSolid.trash, color: Theme.of(context).colorScheme.error, size: 15),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  height: 1, width: 50,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.25),
                ),

                InkWell(
                  onTap: () {
                    if(Get.find<ProfileController>().profileModel!.restaurants![0].foodSection!) {
                      Get.find<RestaurantController>().getProductDetails(product.id!).then((itemDetails) {
                        if(itemDetails != null){
                          Get.toNamed(RouteHelper.getAddProductRoute(itemDetails));
                        }
                      });
                    }else {
                      showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                    ),
                    child: Image.asset(Images.penIcon, height: 15, width: 15, color: Colors.blue),
                  ),
                ),

              ]),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getProductDetailsRoute(product), arguments: ProductDetailsScreen(product: product, isCampaign: isCampaign)),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(children: [

              // Product image
              Stack(children: [
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
                      image: '${product.imageFullUrl}',
                      height: 80, width: 80, fit: BoxFit.cover,
                    ),
                  ),
                ),

                DiscountTagWidget(
                  discount: discount, discountType: discountType,
                  freeDelivery: false,
                ),

                isAvailable ? const SizedBox() : const NotAvailableWidget(isRestaurant: false),
              ]),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  // Product name row
                  Row(children: [
                    Expanded(
                      child: Text(
                        product.name ?? '',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    CustomAssetImageWidget(
                      image: product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 12, width: 12,
                    ),
                  ]),
                  const SizedBox(height: 6),

                  // Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(HeroiconsSolid.star, color: Theme.of(context).primaryColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        product.avgRating!.toStringAsFixed(1),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        ' (${product.ratingCount})',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),

                  // Price row
                  Row(children: [
                    if (discount! > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: PriceConverter.convertPriceWithSvg(
                          product.price,
                          textStyle: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),

                    PriceConverter.convertPriceWithSvg(
                      product.price,
                      discount: discount,
                      discountType: discountType,
                      textStyle: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    const Spacer(),

                    // Out of stock badge
                    if (!((product.stockType == 'unlimited' || product.itemStock! > 0) && (product.stockType == 'unlimited' || !isOutOfStock)))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            'out_of_stock'.tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                          const SizedBox(width: 4),
                          CustomToolTip(
                            message: (product.stockType == 'unlimited' || product.itemStock! <= 0)
                                ? 'your_main_stock_is_out_of_stock'.tr
                                : 'one_or_more_variations_are_out_of_stock'.tr,
                            preferredDirection: AxisDirection.down,
                            child: Icon(
                              HeroiconsOutline.informationCircle,
                              color: Theme.of(context).colorScheme.error,
                              size: 14,
                            ),
                          ),
                        ]),
                      ),
                  ]),

                ]),
              ),

            ]),
          ),
        ),
      );
    });
  }

  int? _stringToInt(String? value) {
    if (value == null) return 0;
    return int.parse(value);

  }

}