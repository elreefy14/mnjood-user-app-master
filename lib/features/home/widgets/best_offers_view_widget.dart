import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/review/controllers/review_controller.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class BestOffersViewWidget extends StatelessWidget {
  const BestOffersViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      // Use reviewed products that have discounts
      List<Product>? products = reviewController.reviewedProductList;
      List<Product>? discountedProducts = products?.where((p) => (p.discount ?? 0) > 0).toList();

      // If no discounted products, use regular products
      if (discountedProducts?.isEmpty ?? true) {
        discountedProducts = products?.take(4).toList();
      }

      if (discountedProducts == null || discountedProducts.isEmpty) {
        return const SizedBox();
      }

      // Take only first 4 products for the 2x2 grid
      final displayProducts = discountedProducts.take(4).toList();

      return Container(
        width: Dimensions.webMaxWidth,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with lightning icon
            Row(
              children: [
                Icon(
                  HeroiconsSolid.bolt,
                  color: const Color(0xFFFF9E1B),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'best_offers'.tr,
                  style: sectionTitleStyle,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // 2x2 Grid of product cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: ResponsiveHelper.isMobile(context) ? 0.65 : 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: displayProducts.length,
              itemBuilder: (context, index) {
                return _OfferProductCard(product: displayProducts[index]);
              },
            ),
          ],
        ),
      );
    });
  }
}

class _OfferProductCard extends StatelessWidget {
  final Product product;

  const _OfferProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    CartModel cartModel = CartModel(
      null, price, discountPrice, (price - discountPrice),
      1, [], [], false, product, [], product.cartQuantityLimit, [],
    );

    return GestureDetector(
      onTap: () {
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ProductBottomSheetWidget(product: product, isCampaign: false),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(
                Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false)),
              );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with discount badge
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CustomImageWidget(
                      image: '${product.imageFullUrl}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      isFood: true,
                    ),
                  ),
                  // Discount badge
                  if (discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDA281C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discountType == 'percent'
                              ? '${discount.toInt()}% ${'off'.tr}'
                              : '-${PriceConverter.convertPrice(discount)}',
                          style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product details
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name ?? '',
                      style: robotoMedium.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          double rating = product.avgRating ?? 0;
                          return Icon(
                            index < rating.floor()
                                ? HeroiconsSolid.star
                                : (index < rating ? HeroiconsSolid.star : HeroiconsOutline.star),
                            color: const Color(0xFFFF9E1B),
                            size: 12,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.ratingCount ?? 0})',
                          style: robotoRegular.copyWith(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Row(
                      children: [
                        if (discount > 0)
                          PriceConverter.convertPriceWithSvg(
                            price,
                            textStyle: robotoRegular.copyWith(
                              fontSize: 10,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                            symbolColor: Colors.grey,
                            symbolSize: 10,
                          ),
                        if (discount > 0) const SizedBox(width: 4),
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(
                            fontSize: 12,
                            color: const Color(0xFFDA281C),
                          ),
                          symbolColor: const Color(0xFFDA281C),
                          symbolSize: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Store name
                    Row(
                      children: [
                        Icon(
                          HeroiconsOutline.buildingStorefront,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.restaurantName ?? '',
                            style: robotoRegular.copyWith(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Add to cart button
                    GetBuilder<CartController>(builder: (cartController) {
                      int cartQty = cartController.cartQuantity(product.id ?? 0);

                      return SizedBox(
                        width: double.infinity,
                        child: cartQty > 0
                            ? _buildQuantityControls(context, cartController, cartModel, cartQty)
                            : ElevatedButton(
                                onPressed: () {
                                  // Open product bottom sheet for proper add to cart handling
                                  ResponsiveHelper.isMobile(context)
                                      ? Get.bottomSheet(
                                          ProductBottomSheetWidget(product: product, isCampaign: false),
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                        )
                                      : Get.dialog(
                                          Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false)),
                                        );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9E1B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(HeroiconsOutline.shoppingBag, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'add_to_cart'.tr,
                                      style: robotoMedium.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartController cartController, CartModel cartModel, int cartQty) {
    int cartIndex = cartController.isExistInCart(product.id, null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9E1B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(HeroiconsOutline.minus, size: 14, color: Color(0xFFFF9E1B)),
            ),
          ),
          Text(
            cartQty.toString(),
            style: robotoBold.copyWith(fontSize: 12, color: Colors.white),
          ),
          InkWell(
            onTap: cartController.isLoading
                ? null
                : () {
                    cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                  },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(HeroiconsOutline.plus, size: 14, color: Color(0xFFFF9E1B)),
            ),
          ),
        ],
      ),
    );
  }
}

class BestOffersShimmer extends StatelessWidget {
  const BestOffersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Shimmer(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Shimmer(
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
