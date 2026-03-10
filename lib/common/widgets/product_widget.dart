import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/not_available_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/home/widgets/overflow_container_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/helper/date_converter.dart';
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
import 'package:mnjood/common/widgets/discount_tag_without_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ProductWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? restaurant;
  final bool isRestaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool fromCartSuggestion;
  final String? businessType;
  final int? vendorId;
  const ProductWidget({super.key, required this.product, required this.isRestaurant, required this.restaurant, required this.index,
    required this.length, this.inRestaurant = false, this.isCampaign = false, this.fromCartSuggestion = false, this.businessType, this.vendorId});

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    String? image ;
    double price = 0;
    double discountPrice = 0;
    if(isRestaurant) {
      image = restaurant?.logoFullUrl;
      discount = restaurant?.discount?.discount ?? 0;
      discountType = restaurant?.discount?.discountType ?? 'percent';
      isAvailable = (restaurant?.open ?? 0) == 1 && (restaurant?.active ?? false);
    }else {
      image = product!.imageFullUrl;
      discount = product!.discount;
      discountType = product!.discountType;
      isAvailable = ProductHelper.isAvailable(product!);
      price = product!.price!;
      discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType)!;
    }
    bool isOutOfStock = !isRestaurant && product != null && product!.stockType != null && product!.stockType != 'unlimited' && (product!.itemStock ?? 0) <= 0;

    return Padding(
      padding: EdgeInsets.only(bottom: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
      child: Container(
        margin: desktop ? null : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        child: CustomInkWellWidget(
          onTap: () {
            if(isRestaurant) {
              if(restaurant != null) {
                final effectiveBusinessType = businessType ?? restaurant!.businessType ?? 'restaurant';
                RouteHelper.navigateToStoreOrShowClosedDialog(restaurant!, context, businessType: effectiveBusinessType);
              }
            }else {
              if(ProductHelper.isAvailable(product!) || isOutOfStock){
                ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                  ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurant, isCampaign: isCampaign, businessType: businessType, vendorId: vendorId),
                  backgroundColor: Colors.transparent, isScrollControlled: true,
                ) : Get.dialog(
                  Dialog(child: ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurant, businessType: businessType, vendorId: vendorId)),
                );
              }else{
                showCustomSnackBar('item_is_not_available'.tr);
              }
            }
          },
          radius: Dimensions.radiusDefault,
          child: Padding(
            padding: desktop ? EdgeInsets.all(fromCartSuggestion ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall)
                : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
                child: Row(children: [

                  Stack(clipBehavior: Clip.none, children: [
                    ((image != null && image.isNotEmpty) || isRestaurant) ? ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImageWidget(
                        image: '${isRestaurant ? restaurant!.logoFullUrl : product!.imageFullUrl}',
                        height: desktop ? 120 : length == null ? 100 : isRestaurant ? 120 : 100, width: desktop ? 120 : isRestaurant ? 110 : 90, fit: BoxFit.cover,
                        isFood: !isRestaurant, isRestaurant: isRestaurant,
                      ),
                    ) : isAvailable ? const SizedBox() : Container(
                      height: desktop ? 120 : length == null ? 100 : isRestaurant ? 120 : 100, width: desktop ? 120 : isRestaurant ? 110 : 90,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? Theme.of(context).disabledColor : null,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),

                    ((image != null && image.isNotEmpty) || isRestaurant) ? DiscountTagWidget(
                      discount: discount, discountType: discountType,
                      freeDelivery: isRestaurant ? (restaurant?.freeDelivery ?? false) : false,
                      fromTop: Dimensions.paddingSizeExtraSmall, fromLeft: isAvailable ? -7 : -3, paddingVertical: ResponsiveHelper.isDesktop(context) ? 5 : 10,
                    ) : const SizedBox(),

                    (isAvailable && !isOutOfStock) ? const SizedBox() : NotAvailableWidget(
                      isRestaurant: isRestaurant,
                      isOutOfStock: isOutOfStock,
                      opacity: ((image != null && image.isNotEmpty) || isRestaurant) ? 0.6 : 0.15,
                      color: ((image != null && image.isNotEmpty) || isRestaurant) ? Colors.white : Colors.black,
                    ),

                    if(!isRestaurant && product != null && product!.maxQtyPerUser != null && product!.maxQtyPerUser! > 0)
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${'max'.tr} ${product!.maxQtyPerUser}',
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                  ]),
                  SizedBox(width: ((image != null && image.isNotEmpty) || isRestaurant || !isAvailable) ? Dimensions.paddingSizeSmall : 0),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: isRestaurant ? MainAxisAlignment.center : MainAxisAlignment.start, children: [

                      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Flexible(
                          child: Text(
                            isRestaurant ? (restaurant?.name ?? '') : (product?.name ?? ''),
                            style: robotoMedium.copyWith(fontSize: 12, height: 1.15),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        // Veg/Non-veg indicator removed

                        SizedBox(width: !isRestaurant && (product!.isRestaurantHalalActive ?? false) && (product!.isHalalFood ?? false) ? 5 : 0),

                        !isRestaurant && (product!.isRestaurantHalalActive ?? false) && (product!.isHalalFood ?? false) ? const CustomAssetImageWidget(
                          Images.halalIcon, height: 13, width: 13) : const SizedBox(),

                        const SizedBox(width: Dimensions.paddingSizeLarge),
                      ]),

                      SizedBox(height: isRestaurant ? Dimensions.paddingSizeExtraSmall : 10),

                      /*if(!isRestaurant)
                        Text(
                          isRestaurant ? '' : product!.restaurantName ?? '',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),*/

                      if(isRestaurant && (restaurant!.ratingCount ?? 0) > 0)
                        Row(children: [
                          Icon(HeroiconsSolid.star, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text(isRestaurant ? (restaurant!.avgRating ?? 0).toStringAsFixed(1) : (product!.avgRating ?? 0).toStringAsFixed(1), style: robotoMedium),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('(${isRestaurant ? (restaurant!.ratingCount ?? 0) > 25 ? '25+' : restaurant!.ratingCount : (product!.ratingCount ?? 0) > 25 ? '25+' : product!.ratingCount})',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                        ]),

                      SizedBox(height: (isRestaurant && (restaurant!.ratingCount ?? 0) > 0) ? Dimensions.paddingSizeExtraSmall : 0),

                      if(!isRestaurant && (product!.ratingCount ?? 0) > 0)
                        Row(children: [
                          Icon(HeroiconsSolid.star, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text((product!.avgRating ?? 0).toStringAsFixed(1), style: robotoMedium),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('(${product!.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                        ]),

                      SizedBox(height: !isRestaurant && (product!.ratingCount ?? 0) > 0 ? isRestaurant ? Dimensions.paddingSizeExtraSmall : 9 : 0),

                      isRestaurant ? Row(children: [

                        restaurant?.foods != null && restaurant!.foods!.isNotEmpty ? Text(
                          'start_from'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                        ) : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        restaurant?.foods != null && restaurant!.foods!.isNotEmpty ? PriceConverter.convertPriceWithSvg(
                          restaurant?.priceStartFrom ?? 0,
                          textStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge!.color),
                          symbolColor: Theme.of(context).textTheme.bodyLarge!.color,
                          symbolSize: 12,
                        ) : const SizedBox(),

                      ]) : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PriceConverter.convertPriceWithSvg(
                            discountPrice,
                            textStyle: robotoBold.copyWith(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          if (discountPrice < price)
                            PriceConverter.convertPriceWithSvg(
                              price,
                              textStyle: robotoRegular.copyWith(
                                fontSize: 11,
                                color: Theme.of(context).hintColor,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Theme.of(context).hintColor,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      restaurant?.foods != null && restaurant!.foods!.isNotEmpty ? isRestaurant ? SizedBox(
                        width: double.infinity,
                        child: Stack(children: [

                          OverFlowContainerWidget(image: restaurant?.foods![0].imageFullUrl ?? ''),

                          restaurant!.foods!.length > 1 ? Positioned(
                            left: 22, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant!.foods![1].imageFullUrl ?? ''),
                          ) : const SizedBox(),

                          restaurant!.foods!.length > 2 ? Positioned(
                            left: 42, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant!.foods![2].imageFullUrl ?? ''),
                          ) : const SizedBox(),

                          restaurant!.foods!.length > 4 ? Positioned(
                            left: 82, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              height: 30, width: 80,
                              decoration:  BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  '${restaurant!.foodsCount! > 11 ? '12 +' : '${restaurant!.foodsCount! - 4} +'} ',
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                ),

                                Text('items'.tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                              ]),
                            ),
                          ) : const SizedBox(),

                          restaurant!.foods!.length > 3 ?  Positioned(
                            left: 62, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant!.foods![3].imageFullUrl ?? ''),
                          ) : const SizedBox(),
                        ]),
                      ) : const SizedBox() : !isRestaurant ? SizedBox() : Text(
                        // Dynamic label based on business type
                        businessType?.toLowerCase() == 'pharmacy'
                          ? 'no_medicines_available'.tr
                          : businessType?.toLowerCase() == 'supermarket'
                            ? 'no_products_available'.tr
                            : 'no_food_available'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

                    ]),
                  ),

                  Column(mainAxisAlignment: isRestaurant ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [

                    fromCartSuggestion ? const SizedBox() : GetBuilder<FavouriteController>(builder: (favouriteController) {
                      bool isWished = isRestaurant ? favouriteController.wishRestIdList.contains(restaurant!.id)
                          : favouriteController.wishProductIdList.contains(product!.id);
                      return CustomFavouriteWidget(
                        isWished: isWished,
                        isRestaurant: isRestaurant,
                        restaurant: restaurant,
                        product: product,
                        businessType: businessType,
                      );
                    }),

                    (!isRestaurant && !isOutOfStock) ? GetBuilder<CartController>(
                      builder: (cartController) {
                        int cartQty = cartController.cartQuantity(product!.id!);
                        int cartIndex = cartController.isExistInCart(product!.id, null);
                        CartModel cartModel = CartModel(
                          null, price, discountPrice, (price - discountPrice),
                          1, [], [], false, product, [], product?.cartQuantityLimit,[],
                        );
                        return cartQty != 0 ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          ),
                          child: Row(children: [
                            InkWell(
                              onTap: cartController.isLoading ? null : () {
                                if (cartController.cartList[cartIndex].quantity! > 1) {
                                  cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                                }else {
                                  cartController.removeFromCart(cartIndex);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).primaryColor),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Icon(
                                  HeroiconsOutline.minus, size: 16, color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Text(
                                cartQty.toString(),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                              ),
                            ),

                            InkWell(
                              onTap: cartController.isLoading ? null : () {
                                cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).primaryColor),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Icon(
                                  HeroiconsOutline.plus, size: 16, color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ]),
                        ) : InkWell(
                          onTap: () => Get.find<ProductController>().productDirectlyAddToCart(product, context, businessType: businessType, vendorId: vendorId),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                            ),
                            child: Icon(HeroiconsOutline.plus, size: desktop ? 30 : 25, color: Theme.of(context).primaryColor),
                          ),
                        );
                      }
                    ) : const SizedBox(),

                  ]),

                ]),
              )),

            ]),
          ),
        ),
      ),
    );
  }

}
