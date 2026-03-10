import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/not_available_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
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
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

/// Supermarket/Grocery product card with retail theme
class SupermarketItemCardWidget extends StatelessWidget {
  final Product product;
  final bool isCampaignItem;
  final double width;
  final bool inRestaurantPage;
  final int? vendorId;

  const SupermarketItemCardWidget({
    super.key,
    required this.product,
    this.isCampaignItem = false,
    this.width = 190,
    this.inRestaurantPage = false,
    this.vendorId,
  });

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
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomInkWellWidget(
        onTap: () {
          ResponsiveHelper.isMobile(context)
              ? Get.bottomSheet(
                  ProductBottomSheetWidget(
                    product: product,
                    isCampaign: isCampaignItem,
                    inRestaurantPage: inRestaurantPage,
                    businessType: 'supermarket',
                    vendorId: vendorId,
                  ),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                )
              : Get.dialog(
                  Dialog(
                    child: ProductBottomSheetWidget(
                      product: product,
                      isCampaign: isCampaignItem,
                      inRestaurantPage: inRestaurantPage,
                      businessType: 'supermarket',
                      vendorId: vendorId,
                    ),
                  ),
                );
        },
        radius: 16,
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 50,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Product image
                  Padding(
                    padding: isCampaignItem
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: ClipRRect(
                      borderRadius: isCampaignItem
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            )
                          : BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImageWidget(
                        image: '${product.imageFullUrl}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        isFood: true,
                      ),
                    ),
                  ),

                  // Favourite button
                  if (!isCampaignItem)
                    Positioned(
                      top: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      child: GetBuilder<FavouriteController>(
                        builder: (favouriteController) {
                          bool isWished = favouriteController.wishProductIdList.contains(product.id);
                          return CustomFavouriteWidget(
                            product: product,
                            isRestaurant: false,
                            isWished: isWished,
                            businessType: 'supermarket',
                          );
                        },
                      ),
                    ),

                  // Supermarket badge (shopping cart icon)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        HeroiconsSolid.shoppingCart,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),


                  // Add to cart button (hidden when out of stock)
                  if (!isOutOfStock)
                    Positioned(
                      bottom: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      child: GetBuilder<ProductController>(
                        builder: (productController) {
                          return GetBuilder<CartController>(
                            builder: (cartController) {
                              int cartQty = cartController.cartQuantity(product.id ?? 0);
                              int cartIndex = cartController.isExistInCart(product.id, null);

                              return cartQty != 0
                                  ? _buildQuantityControls(context, cartController, cartModel, cartIndex, cartQty)
                                  : _buildAddButton(context, cartController, cartModel, productController);
                            },
                          );
                        },
                      ),
                    ),

                  // Not available overlay (time-based or out of stock)
                  if (!isAvailable || isOutOfStock)
                    NotAvailableWidget(
                      opacity: 0.3,
                      fontSize: 14,
                      isOutOfStock: isOutOfStock,
                    ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Store name with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            HeroiconsSolid.buildingStorefront,
                            size: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            product.restaurantName ?? '',
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Product name
                    Text(
                      product.name ?? '',
                      style: robotoBold.copyWith(
                        fontSize: 12,
                        height: 1.15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),

                    // Price section
                    Column(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    CartController cartController,
    CartModel cartModel,
    int cartIndex,
    int cartQty,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: cartController.isLoading
                ? null
                : () {
                    if ((cartController.cartList[cartIndex].quantity ?? 0) > 1) {
                      cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                    } else {
                      cartController.removeFromCart(cartIndex);
                    }
                  },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Icon(HeroiconsOutline.minus, size: 16, color: Theme.of(context).primaryColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Text(
              cartQty.toString(),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          InkWell(
            onTap: cartController.isLoading
                ? null
                : () {
                    cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                  },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Icon(HeroiconsOutline.plus, size: 16, color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    CartController cartController,
    CartModel cartModel,
    ProductController productController,
  ) {
    return InkWell(
      onTap: () {
        // Guest check - redirect to login screen if not logged in
        if(!Get.find<AuthController>().isLoggedIn()) {
          Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
          return;
        }
        if (isCampaignItem) {
          ResponsiveHelper.isMobile(context)
              ? Get.bottomSheet(
                  ProductBottomSheetWidget(
                    product: product,
                    isCampaign: true,
                    inRestaurantPage: inRestaurantPage,
                    businessType: 'supermarket',
                    vendorId: vendorId,
                  ),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                )
              : Get.dialog(
                  Dialog(
                    child: ProductBottomSheetWidget(
                      product: product,
                      isCampaign: true,
                      inRestaurantPage: inRestaurantPage,
                      businessType: 'supermarket',
                      vendorId: vendorId,
                    ),
                  ),
                );
        } else {
          if (product.variations == null || (product.variations != null && product.variations!.isEmpty)) {
            productController.setExistInCart(product);
            OnlineCart onlineCart = OnlineCart(
              null,
              product.id,
              null,
              (product.price ?? 0).toString(),
              [],
              1,
              [],
              [],
              [],
              'Food',
              variationOptionIds: [],
              vendorId: vendorId ?? product.supermarketId,
              vendorType: 'supermarket',
            );

            if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product?.restaurantId)) {
              Get.dialog(
                ConfirmationDialogWidget(
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
                ),
                barrierDismissible: false,
              );
            } else {
              Get.find<CartController>().addToCartOnline(onlineCart, fromDirectlyAdd: true);
            }
          } else {
            ResponsiveHelper.isMobile(context)
                ? Get.bottomSheet(
                    ProductBottomSheetWidget(
                      product: product,
                      isCampaign: false,
                      inRestaurantPage: inRestaurantPage,
                      businessType: 'supermarket',
                      vendorId: vendorId,
                    ),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  )
                : Get.dialog(
                    Dialog(
                      child: ProductBottomSheetWidget(
                        product: product,
                        isCampaign: false,
                        inRestaurantPage: inRestaurantPage,
                        businessType: 'supermarket',
                        vendorId: vendorId,
                      ),
                    ),
                  );
          }
        }
      },
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        child: Icon(HeroiconsOutline.plus, color: Theme.of(context).primaryColor, size: 18),
      ),
    );
  }
}
