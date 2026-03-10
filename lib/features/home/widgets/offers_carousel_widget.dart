import 'package:flutter/foundation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OffersCarouselWidget extends StatefulWidget {
  const OffersCarouselWidget({super.key});

  @override
  State<OffersCarouselWidget> createState() => _OffersCarouselWidgetState();
}

class _OffersCarouselWidgetState extends State<OffersCarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      // Show Mnjood Mart products, prioritizing discounted ones
      List<Product> offerProducts = [];
      if (homeController.mnjoodMartProducts != null) {
        // First try to get discounted products
        offerProducts = homeController.mnjoodMartProducts!
            .where((p) => (p.discount ?? 0) > 0)
            .toList();
        offerProducts.sort((a, b) => (b.discount ?? 0).compareTo(a.discount ?? 0));

        // If no discounted products, show all products
        if (offerProducts.isEmpty) {
          offerProducts = List.from(homeController.mnjoodMartProducts!);
        }
      }

      if (homeController.mnjoodMartProducts == null) {
        return const OffersCarouselShimmer();
      }

      if (offerProducts.isEmpty) {
        return const SizedBox();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header (no icon per design requirement)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Text('best_offers'.tr, style: robotoBold.copyWith(fontSize: 16)),
                  const Spacer(),
                  ArrowIconButtonWidget(
                    onTap: () => Get.toNamed(RouteHelper.getBusinessCategoryRoute('supermarket')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carousel - shows 4 cards at a time
            CarouselSlider.builder(
              itemCount: offerProducts.length > 10 ? 10 : offerProducts.length,
              options: CarouselOptions(
                height: 180,
                viewportFraction: 0.24,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: _OfferCard(product: offerProducts[index]),
                );
              },
            ),
            const SizedBox(height: 12),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                offerProducts.length > 10 ? 10 : offerProducts.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentIndex ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == _currentIndex
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _OfferCard extends StatelessWidget {
  final Product product;

  const _OfferCard({required this.product});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    return GestureDetector(
      onTap: () {
        debugPrint('=== OFFER CARD TAPPED: ${product.name} ===');
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket'),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket')));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: CustomImageWidget(
                      image: product.imageFullUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      isFood: true,
                    ),
                  ),
                  if (discount > 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discountType == 'percent' ? '${discount.toInt()}%' : '-${discount.toInt()}',
                          style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: _AddButton(product: product),
                  ),
                ],
              ),
            ),
            // Info section - compact for smaller cards
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name ?? '',
                        style: robotoMedium.copyWith(fontSize: 10, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                        ),
                        if (discountPrice < price)
                          PriceConverter.convertPriceWithSvg(
                            price,
                            textStyle: robotoRegular.copyWith(
                              fontSize: 8,
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
}

class _AddButton extends StatelessWidget {
  final Product product;

  const _AddButton({required this.product});

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

    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(product.id ?? 0);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Guest check - redirect to login screen if not logged in
            if(!Get.find<AuthController>().isLoggedIn()) {
              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
              return;
            }
            if (product.variations == null || (product.variations != null && product.variations!.isEmpty)) {
              Get.find<ProductController>().setExistInCart(product);

              OnlineCart onlineCart = OnlineCart(
                null, product.id, null, (product.price ?? 0).toString(),
                [], 1, [], [], [], 'Food',
                variationOptionIds: [],
                vendorId: product.supermarketId,
                vendorType: 'supermarket',
              );

              if (cartController.existAnotherRestaurantProduct(cartModel.product?.restaurantId)) {
                Get.dialog(ConfirmationDialogWidget(
                  icon: Images.warning,
                  title: 'are_you_sure_to_reset'.tr,
                  description: 'if_you_continue'.tr,
                  onYesPressed: () {
                    cartController.clearCartOnline().then((success) async {
                      if (success) {
                        await cartController.addToCartOnline(onlineCart, fromDirectlyAdd: true);
                        Get.back();
                      }
                    });
                  },
                ), barrierDismissible: false);
              } else {
                cartController.addToCartOnline(onlineCart, fromDirectlyAdd: true);
              }
            } else {
              ResponsiveHelper.isMobile(context)
                  ? Get.bottomSheet(
                      ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket'),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                    )
                  : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket')));
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: cartQty > 0
                ? Center(
                    child: Text(
                      '$cartQty',
                      style: robotoBold.copyWith(fontSize: 10, color: Colors.white),
                    ),
                  )
                : const Icon(HeroiconsOutline.plus, color: Colors.white, size: 14),
          ),
        ),
      );
    });
  }
}

class OffersCarouselShimmer extends StatelessWidget {
  const OffersCarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Shimmer(
              child: Container(
                height: 24,
                width: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Shimmer(
                    child: Container(
                      width: 85,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
