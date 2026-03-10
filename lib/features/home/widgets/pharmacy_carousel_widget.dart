import 'package:carousel_slider/carousel_slider.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
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

class PharmacyCarouselWidget extends StatefulWidget {
  const PharmacyCarouselWidget({super.key});

  @override
  State<PharmacyCarouselWidget> createState() => _PharmacyCarouselWidgetState();
}

class _PharmacyCarouselWidgetState extends State<PharmacyCarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (productController) {
      List<Product>? allProducts = productController.popularProductList;
      List<Product> pharmacyProducts = [];

      if (allProducts != null && allProducts.isNotEmpty) {
        pharmacyProducts = List.from(allProducts);
      }

      if (allProducts == null) {
        return const PharmacyCarouselShimmer();
      }

      if (pharmacyProducts.isEmpty) {
        return const SizedBox();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header - Plain outlined icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Icon(
                    HeroiconsOutline.beaker,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text('pharmacy'.tr, style: robotoBold.copyWith(fontSize: 16)),
                  const Spacer(),
                  ArrowIconButtonWidget(
                    onTap: () => Get.toNamed(RouteHelper.getBusinessCategoryRoute('pharmacy')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carousel
            CarouselSlider.builder(
              itemCount: pharmacyProducts.length > 10 ? 10 : pharmacyProducts.length,
              options: CarouselOptions(
                height: 240,
                viewportFraction: 0.44,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 6),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: _PharmacyCard(product: pharmacyProducts[index]),
                );
              },
            ),
            const SizedBox(height: 12),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pharmacyProducts.length > 10 ? 10 : pharmacyProducts.length,
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

class _PharmacyCard extends StatelessWidget {
  final Product product;

  const _PharmacyCard({required this.product});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    String vendorInitial = (product.restaurantName ?? 'P').substring(0, 1).toUpperCase();

    return CustomInkWellWidget(
      onTap: () {
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'pharmacy'),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'pharmacy')));
      },
      radius: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  // Product Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CustomImageWidget(
                      image: product.imageFullUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discountType == 'percent' ? '${discount.toInt()}%' : '-${discount.toInt()}',
                          style: robotoBold.copyWith(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  // Prescription badge
                  if (product.prescriptionRequired ?? false)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Rx',
                          style: robotoBold.copyWith(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  // Add to cart button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _AddButton(product: product),
                  ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor row with avatar
                    Row(
                      children: [
                        // Vendor Avatar
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              vendorInitial,
                              style: robotoBold.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.restaurantName ?? 'Pharmacy',
                            style: robotoMedium.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Product name
                    Expanded(
                      child: Text(
                        product.name ?? '',
                        style: robotoMedium.copyWith(fontSize: 13, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Price section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (discountPrice < price) ...[
                          const SizedBox(width: 6),
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
            if (product.prescriptionRequired ?? false) {
              ResponsiveHelper.isMobile(context)
                  ? Get.bottomSheet(
                      ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'pharmacy'),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                    )
                  : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'pharmacy')));
              return;
            }

            if (product.variations == null || (product.variations != null && product.variations!.isEmpty)) {
              Get.find<ProductController>().setExistInCart(product);

              OnlineCart onlineCart = OnlineCart(
                null, product.id, null, (product.price ?? 0).toString(),
                [], 1, [], [], [], 'Food',
                variationOptionIds: [],
                vendorId: product.pharmacyId,
                vendorType: 'pharmacy',
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
                      ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'pharmacy'),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                    )
                  : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'pharmacy')));
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: cartQty > 0
                ? Center(
                    child: Text(
                      '$cartQty',
                      style: robotoBold.copyWith(fontSize: 12, color: Colors.white),
                    ),
                  )
                : const Icon(HeroiconsOutline.plus, color: Colors.white, size: 18),
          ),
        ),
      );
    });
  }
}

class PharmacyCarouselShimmer extends StatelessWidget {
  const PharmacyCarouselShimmer({super.key});

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
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Shimmer(
                    child: Container(
                      width: 155,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(16),
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
