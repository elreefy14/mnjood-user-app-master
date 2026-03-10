import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:mnjood/common/widgets/not_available_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/common/widgets/product_shimmer_widget.dart';
import 'package:mnjood/common/widgets/product_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/home/widgets/pharmacy_item_card_widget.dart';
import 'package:mnjood/features/home/widgets/theme1/restaurant_widget.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/web_restaurant_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ProductViewWidget extends StatelessWidget {
  final List<Product?>? products;
  final List<Restaurant?>? restaurants;
  final bool isRestaurant;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inRestaurantPage;
  final bool showTheme1Restaurant;
  final bool? isWebRestaurant;
  final bool? fromFavorite;
  final bool? fromSearch;
  final String? businessType;
  final int? vendorId;
  final bool useGridLayout;
  const ProductViewWidget({super.key, required this.restaurants, required this.products, required this.isRestaurant, this.isScrollable = false,
    this.shimmerLength = 20, this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault), this.noDataText,
    this.isCampaign = false, this.inRestaurantPage = false, this.showTheme1Restaurant = false, this.isWebRestaurant = false, this.fromFavorite = false, this.fromSearch = false, this.businessType, this.vendorId, this.useGridLayout = false});

  // Check if this is a pharmacy business type
  bool get _isPharmacy => businessType?.toLowerCase() == 'pharmacy';

  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if(isRestaurant) {
      isNull = restaurants == null;
      if(!isNull) {
        length = restaurants!.length;
      }
    }else {
      isNull = products == null;
      if(!isNull) {
        length = products!.length;
      }
    }

    // Use pharmacy card grid for pharmacy products (not restaurants)
    if (_isPharmacy && !isRestaurant) {
      return _buildPharmacyProductGrid(context, isNull, length);
    }

    // Use 2-column grid layout for products when requested (mobile only)
    if (useGridLayout && !isRestaurant && ResponsiveHelper.isMobile(context)) {
      return _buildGridProductLayout(context, isNull, length);
    }

    return Column(children: [

      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) && !isWebRestaurant! ? Dimensions.paddingSizeLarge : isWebRestaurant! ? Dimensions.paddingSizeLarge : 0.01,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) && !isWebRestaurant! ? 142 : isWebRestaurant! ? 280 : showTheme1Restaurant ? 200 : isRestaurant ? 150 : 120,
          crossAxisCount: ResponsiveHelper.isMobile(context) && !isWebRestaurant! ? 1 : isWebRestaurant! ? 4 : 3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: length,
        padding: padding,
        itemBuilder: (context, index) {
          return showTheme1Restaurant ? RestaurantWidget(restaurant: restaurants![index], index: index, inStore: inRestaurantPage)
          : isWebRestaurant! ? WebRestaurantWidget(restaurant: restaurants![index]) : ProductWidget(
            isRestaurant: isRestaurant, product: isRestaurant ? null : products![index],
            restaurant: isRestaurant ? restaurants![index] : null, index: index, length: length, isCampaign: isCampaign,
            inRestaurant: inRestaurantPage, businessType: businessType,
            // Extract vendorId from product based on business type, fallback to prop
            vendorId: !isRestaurant && products![index] != null
                ? (products![index]!.pharmacyId ?? products![index]!.supermarketId ?? products![index]!.restaurantId ?? vendorId)
                : vendorId,
          );
        },
      ) : NoDataScreen(
        isEmptyRestaurant: isRestaurant ? true : false,
        isEmptyWishlist: fromFavorite! ? true : false,
        isEmptySearchFood: fromSearch! ? true : false,
        title: noDataText ?? (isRestaurant ? 'there_is_no_restaurant'.tr : 'there_is_no_food'.tr),
      ) : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) && !isWebRestaurant! ? 142 : isWebRestaurant! ? 280 : showTheme1Restaurant ? 200 : 150,
          crossAxisCount: ResponsiveHelper.isMobile(context) && !isWebRestaurant! ? 1 : isWebRestaurant! ? 4 : 3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return showTheme1Restaurant ? RestaurantShimmer(isEnable: isNull)
              : isWebRestaurant! ? const WebRestaurantShimmer() : ProductShimmer(isEnabled: isNull, isRestaurant: isRestaurant, hasDivider: index != shimmerLength-1);
        },
      ),

    ]);
  }

  /// Build 3-column grid layout with vertical product cards
  Widget _buildGridProductLayout(BuildContext context, bool isNull, int length) {
    return Column(children: [
      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.55,
          crossAxisCount: 3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: length,
        padding: padding,
        itemBuilder: (context, index) {
          final product = products![index];
          if (product == null) return const SizedBox();
          return _buildGridProductCard(context, product);
        },
      ) : NoDataScreen(
        isEmptyWishlist: fromFavorite! ? true : false,
        isEmptySearchFood: fromSearch! ? true : false,
        title: noDataText ?? 'there_is_no_food'.tr,
      ) : GridView.builder(
        key: UniqueKey(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.55,
          crossAxisCount: 3,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return ProductShimmer(isEnabled: isNull, isRestaurant: false, hasDivider: false);
        },
      ),
    ]);
  }

  /// Build a single vertical product card for grid layout
  Widget _buildGridProductCard(BuildContext context, Product product) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    bool isAvailable = ProductHelper.isAvailable(product);
    bool isOutOfStock = product.stockType != null && product.stockType != 'unlimited' && (product.itemStock ?? 0) <= 0;
    int? effectiveVendorId = product.pharmacyId ?? product.supermarketId ?? product.restaurantId ?? vendorId;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: CustomInkWellWidget(
        onTap: () {
          if (isAvailable || isOutOfStock) {
            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
              ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurantPage, isCampaign: isCampaign, businessType: businessType, vendorId: effectiveVendorId),
              backgroundColor: Colors.transparent, isScrollControlled: true,
            ) : Get.dialog(
              Dialog(child: ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurantPage, businessType: businessType, vendorId: effectiveVendorId)),
            );
          }
        },
        radius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 55,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: CustomImageWidget(
                          image: product.imageFullUrl ?? '',
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          fit: BoxFit.cover,
                          isFood: true,
                        ),
                      ),
                      if (!isOutOfStock)
                        Positioned(
                          bottom: Dimensions.paddingSizeSmall,
                          right: Dimensions.paddingSizeSmall,
                          child: _buildGridCartButton(context, product, price, discountPrice, effectiveVendorId),
                        ),
                      if (!isAvailable || isOutOfStock)
                        NotAvailableWidget(opacity: 0.3, fontSize: 14, isOutOfStock: isOutOfStock),
                    ],
                  );
                },
              ),
            ),

            // Info section
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name ?? '',
                      style: robotoBold.copyWith(fontSize: 12, height: 1.15),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).primaryColor),
                        ),
                        if (discountPrice < price)
                          PriceConverter.convertPriceWithSvg(
                            price,
                            textStyle: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor, decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).hintColor),
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

  /// Build cart add/quantity button for grid card
  Widget _buildGridCartButton(BuildContext context, Product product, double price, double discountPrice, int? effectiveVendorId) {
    CartModel cartModel = CartModel(
      null, price, discountPrice, (price - discountPrice),
      1, [], [], false, product, [], product.cartQuantityLimit, [],
    );
    return GetBuilder<CartController>(
      builder: (cartController) {
        int cartQty = cartController.cartQuantity(product.id ?? 0);
        int cartIndex = cartController.isExistInCart(product.id, null);
        return cartQty != 0 ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                } else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(HeroiconsOutline.minus, size: 14, color: Theme.of(context).primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(cartQty.toString(), style: robotoMedium.copyWith(fontSize: 11, color: Theme.of(context).cardColor)),
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
                padding: const EdgeInsets.all(2),
                child: Icon(HeroiconsOutline.plus, size: 14, color: Theme.of(context).primaryColor),
              ),
            ),
          ]),
        ) : InkWell(
          onTap: () => Get.find<ProductController>().productDirectlyAddToCart(product, context, businessType: businessType, vendorId: effectiveVendorId),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5)],
            ),
            padding: const EdgeInsets.all(4),
            child: Icon(HeroiconsOutline.plus, size: 20, color: Theme.of(context).primaryColor),
          ),
        );
      },
    );
  }

  /// Build pharmacy-specific product grid with vertical cards
  Widget _buildPharmacyProductGrid(BuildContext context, bool isNull, int length) {
    return Column(children: [
      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeSmall,
          mainAxisSpacing: Dimensions.paddingSizeSmall,
          // Pharmacy cards - single column layout
          childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.72 : 2.5,
          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 1,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: length,
        padding: padding,
        itemBuilder: (context, index) {
          final product = products![index];
          if (product == null) return const SizedBox();
          return PharmacyItemCardWidget(
            product: product,
            isCampaignItem: isCampaign,
            inRestaurantPage: inRestaurantPage,
            vendorId: product.pharmacyId ?? product.restaurantId ?? vendorId,
          );
        },
      ) : NoDataScreen(
        isEmptyWishlist: fromFavorite! ? true : false,
        isEmptySearchFood: fromSearch! ? true : false,
        title: noDataText ?? 'no_products_found'.tr,
      ) : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeSmall,
          mainAxisSpacing: Dimensions.paddingSizeSmall,
          childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.72 : 2.5,
          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 1,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return ProductShimmer(isEnabled: isNull, isRestaurant: false, hasDivider: false);
        },
      ),
    ]);
  }
}
