import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/not_available_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/discount_tag_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ItemCardWidget extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  final double width;
  final String? businessType;
  final bool inRestaurantPage;
  final int? vendorId;
  const ItemCardWidget({super.key, required this.product, this.isBestItem, this.isPopularNearbyItem = false, this.isCampaignItem = false, this.width = 190, this.businessType, this.inRestaurantPage = false, this.vendorId});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    bool isAvailable = ProductHelper.isAvailable(product);
    // Check stock availability
    bool isOutOfStock = product.stockType != null && product.stockType != 'unlimited' && (product.itemStock ?? 0) <= 0;

    CartModel cartModel = CartModel(
      null, price, discountPrice, (price - discountPrice),
      1, [], [], isCampaignItem, product, [], product.cartQuantityLimit, [],
    );

    return Container(
      width: (isPopularNearbyItem ?? false) ? double.infinity : width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomInkWellWidget(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
            ProductBottomSheetWidget(product: product, isCampaign: isCampaignItem, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: vendorId),
            backgroundColor: Colors.transparent, isScrollControlled: true,
          ) : Get.dialog(
            Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: isCampaignItem, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: vendorId)),
          );
        },
        radius: 16,
        child: Column(children: [
          Expanded(
            flex: ResponsiveHelper.isDesktop(context) ? 5 : 55,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: isCampaignItem ? const EdgeInsets.all(0) : const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, left: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall),
                  child: ClipRRect(
                    borderRadius: isCampaignItem
                        ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                        : BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImageWidget(
                      image: '${product.imageFullUrl}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                      isFood: true,
                    ),
                  ),
                ),

                !isCampaignItem ? Positioned(
                  top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                    bool isWished = favouriteController.wishProductIdList.contains(product.id);
                    return CustomFavouriteWidget(
                      product: product,
                      isRestaurant: false,
                      isWished: isWished,
                      businessType: businessType,
                    );
                  }),
                ) : const SizedBox(),

                (product.isRestaurantHalalActive ?? false) && (product.isHalalFood ?? false) ? Positioned(
                  top: isCampaignItem ? 10 : 40, right: 9,
                  child: const CustomAssetImageWidget(
                    Images.halalIcon,
                    height: 30, width: 30,
                  ),
                ) : const SizedBox(),

                // Enhanced gradient discount badge
                discount > 0 ? Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDA281C), Color(0xFFFF4136)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDA281C).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${discount.toStringAsFixed(0)}${discountType == 'percent' ? '%' : ' SAR'} ${'off'.tr}',
                      style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ) : const SizedBox(),

                // Add to cart button (hidden when out of stock)
                if (!isOutOfStock) Positioned(
                  bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<ProductController>(builder: (productController) {
                    return GetBuilder<CartController>(builder: (cartController) {
                      int cartQty = cartController.cartQuantity(product.id ?? 0);
                      int cartIndex = cartController.isExistInCart(product.id, null);

                      return cartQty != 0 ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        child: Row(children: [
                          InkWell(
                            onTap: cartController.isLoading ? null : () {
                              if ((cartController.cartList[cartIndex].quantity ?? 0) > 1) {
                                cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                              }else {
                                cartController.removeFromCart(cartIndex);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(
                                HeroiconsOutline.minus, size: 16, color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: /*!cartController.isLoading ? */Text(
                              cartQty.toString(),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                            )/* : const Center(child: SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white)))*/,
                          ),

                          InkWell(
                            onTap: cartController.isLoading ? null : () {
                              cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(
                                HeroiconsOutline.plus, size: 16, color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ]),
                      ) : InkWell(
                        onTap: () {
                          // Guest check - redirect to login screen if not logged in
                          if(!Get.find<AuthController>().isLoggedIn()) {
                            Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                            return;
                          }
                          if(isCampaignItem) {
                            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                              ProductBottomSheetWidget(product: product, isCampaign: true, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: vendorId),
                              backgroundColor: Colors.transparent, isScrollControlled: true,
                            ) : Get.dialog(
                              Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: true, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: vendorId)),
                            );
                          } else {
                            if(product.variations == null || (product.variations != null && product.variations!.isEmpty)) {

                              productController.setExistInCart(product);

                              OnlineCart onlineCart = OnlineCart(null, product.id, null, (product.price ?? 0).toString(), [], 1, [], [], [], 'Food', variationOptionIds: [], vendorId: vendorId ?? (product.supermarketId != null && product.supermarketId != 0 ? product.supermarketId : (product.pharmacyId != null && product.pharmacyId != 0 ? product.pharmacyId : product.restaurantId)), vendorType: businessType ?? 'restaurant');

                              if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product?.restaurantId)) {
                                Get.dialog(ConfirmationDialogWidget(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: 'if_you_continue'.tr,
                                  onYesPressed: () {
                                    Get.find<CartController>().clearCartOnline().then((success) async {
                                      if (success) {
                                        await Get.find<CartController>().addToCartOnline(onlineCart, fromDirectlyAdd: true);
                                        Get.back();
                                      }
                                    });
                                  },
                                ), barrierDismissible: false);
                              } else {
                                Get.find<CartController>().addToCartOnline(onlineCart, fromDirectlyAdd: true);
                              }

                            } else {
                              ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                ProductBottomSheetWidget(product: product, isCampaign: false, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: vendorId),
                                backgroundColor: Colors.transparent, isScrollControlled: true,
                              ) : Get.dialog(
                                Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: vendorId)),
                              );
                            }
                          }

                        },
                        child: Container(
                          height: 24, width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                          ),
                          child: Icon(HeroiconsOutline.plus, color: Theme.of(context).primaryColor, size: 20),
                        ),
                      );
                    });
                  }),
                ),

                // Not available overlay (time-based or out of stock)
                (isAvailable && !isOutOfStock) ? const SizedBox() : NotAvailableWidget(
                  opacity: 0.3,
                  fontSize: 14,
                  isOutOfStock: isOutOfStock,
                ),

              ],
            ),
          ),
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: isBestItem == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Store name with logo
                Row(
                  mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    // Vendor logo or avatar fallback
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: product.restaurantLogoUrl != null && product.restaurantLogoUrl!.isNotEmpty
                          ? CustomImageWidget(
                              image: product.restaurantLogoUrl!,
                              height: 18,
                              width: 18,
                              fit: BoxFit.cover,
                              isRestaurant: true,
                            )
                          : Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                (product.restaurantName ?? 'S').isNotEmpty
                                    ? (product.restaurantName ?? 'S')[0].toUpperCase()
                                    : 'S',
                                style: robotoBold.copyWith(
                                  fontSize: 9,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 5),
                    // Store name
                    Expanded(
                      child: Text(
                        product.restaurantName ?? '',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Product name - prominent
                Text(
                  product.name ?? '',
                  style: robotoBold.copyWith(
                    fontSize: 12,
                    height: 1.15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 2),

                // Price section - enhanced
                Row(
                  mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (discountPrice < price) ...[
                      PriceConverter.convertPriceWithSvg(
                        price,
                        textStyle: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).hintColor,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    PriceConverter.convertPriceWithSvg(
                      discountPrice,
                      textStyle: robotoBold.copyWith(
                        fontSize: 15,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),

              ],
            ),
            ),
          ),
        ]),
      ),
    );
  }
}

class ItemCardShimmer extends StatelessWidget {
  final bool? isPopularNearbyItem;
  const ItemCardShimmer({super.key, this.isPopularNearbyItem});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 285 : 280,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: ((isPopularNearbyItem ?? false) && ResponsiveHelper.isMobile(context)) ? 1 : 5,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                    height: ResponsiveHelper.isDesktop(context) ? 285 : 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).shadowColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: ResponsiveHelper.isDesktop(context) ? 5 : 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                              child: Shimmer(child: Container(color: Theme.of(context).shadowColor)),
                            ),
                          ),
                        ),
              
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 15, width: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 10, width: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 12, width: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 10, width: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}
