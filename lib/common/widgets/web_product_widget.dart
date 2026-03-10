import 'package:mnjood/common/widgets/hover_widgets/on_hover_widget.dart';
import 'package:mnjood/common/widgets/rating_bar_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/common/widgets/discount_tag_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class WebProductWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? restaurant;
  final bool isRestaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  const WebProductWidget({super.key, required this.product, required this.isRestaurant, required this.restaurant, required this.index,
    required this.length, this.inRestaurant = false, this.isCampaign = false, this.isFeatured = false, this.fromCartSuggestion = false});

  @override
  Widget build(BuildContext context) {
    // final bool ltr = Get.find<LocalizationController>().isLtr;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    // bool isAvailable;
    if(isRestaurant) {
      discount = restaurant!.discount != null ? restaurant!.discount!.discount : 0;
      discountType = restaurant!.discount != null ? restaurant!.discount!.discountType : 'percent';
      // bool _isClosedToday = Get.find<StoreController>().isRestaurantClosed(true, store.active, store.offDay);
      // _isAvailable = DateConverter.isAvailable(store.openingTime, store.closeingTime) && store.active && !_isClosedToday;
      // isAvailable = store!.open == 1 && store!.active!;
    }else {
      discount = (product!.restaurantDiscount == 0 || isCampaign) ? product!.discount : product!.restaurantDiscount;
      discountType = (product!.restaurantDiscount == 0 || isCampaign) ? product!.discountType : 'percent';
      // isAvailable = DateConverter.isAvailable(item!.availableTimeStarts, item!.availableTimeEnds);
    }

    return InkWell(
      onTap: () {
        if(isRestaurant) {
          if(restaurant != null) {
            RouteHelper.navigateToStoreOrShowClosedDialog(restaurant!, context, businessType: restaurant!.businessType);
          }
        }else {
          if(ProductHelper.isAvailable(product!)){
            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
              ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurant, isCampaign: isCampaign),
              backgroundColor: Colors.transparent, isScrollControlled: true,
            ) : Get.dialog(
              Dialog(child: ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurant)),
            );
          }else{
            showCustomSnackBar('item_is_not_available'.tr);
          }
        }
      },
      child: OnHoverWidget(
        isItem: true,
        child: Stack(
          children: [
            Container(
              margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(1),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                Expanded(child: Column(children: [
                  Stack(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusSmall), topRight: Radius.circular(Dimensions.radiusSmall)),
                      child: CustomImageWidget(
                        image: '${isRestaurant ? restaurant != null ? restaurant!.logoFullUrl : '' : product!.imageFullUrl}',
                        height: desktop ? 160 : length == null ? 100 : 65, width: desktop ? isRestaurant ? 275 : 300 : 80, fit: BoxFit.cover,
                        isFood: !isRestaurant, isRestaurant: isRestaurant,
                      ),
                    ),

                    DiscountTagWidget(
                      discount: product!.discount, discountType: product!.discountType,
                    ),
                  ]),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: SizedBox(
                        width: desktop ? isRestaurant ? 275 :219 : 80,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max ,mainAxisAlignment: MainAxisAlignment.center, children: [

                          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                            Text(
                              isRestaurant ? restaurant!.name! : product!.name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: desktop ? 1 : 1, overflow: TextOverflow.ellipsis,
                            ),
                            // Veg/Non-veg indicator removed
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          (isRestaurant ? restaurant!.address != null : product!.restaurantName != null) ? Text(
                            isRestaurant ? restaurant!.address ?? '' : product!.restaurantName ?? '',
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ) : const SizedBox(),
                          SizedBox(height: ((desktop || isRestaurant) && (isRestaurant ? restaurant!.address != null : product!.restaurantName != null)) ? 5 : 0),

                          // !isStore ? RatingBar(
                          //   rating: isStore ? store!.avgRating : item!.avgRating, size: desktop ? 15 : 12,
                          //   ratingCount: isStore ? store!.ratingCount : item!.ratingCount,
                          // ) : const SizedBox(),
                          // SizedBox(height: (!isStore && desktop) ? Dimensions.paddingSizeExtraSmall : 0),

                          // (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item != null && item!.unitType != null) ? Text(
                          //   '(${ item!.unitType ?? ''})',
                          //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                          // ) : const SizedBox(),

                          isRestaurant ? RatingBarWidget(
                            rating: isRestaurant ? restaurant!.avgRating : product!.avgRating, size: desktop ? 15 : 12,
                            ratingCount: isRestaurant ? restaurant!.ratingCount : product!.ratingCount,
                          ) : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PriceConverter.convertPriceWithSvg(product!.price, discount: discount, discountType: discountType,
                                  textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                ),
                                SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                                discount > 0 ? PriceConverter.convertPriceWithSvg(product!.price,
                                  textStyle: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ) : const SizedBox(),
                              ],
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(HeroiconsSolid.star, color: Theme.of(context).primaryColor, size: 12),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    product!.ratingCount.toString(),
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            )


                          ]),
                        ]),
                      ),
                    ),
                  ),

                ])),

              ]),
            ),

          ],
        ),
      ),
    );
  }
}