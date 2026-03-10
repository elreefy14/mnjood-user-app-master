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

class MnjoodMartCarouselWidget extends StatefulWidget {
  const MnjoodMartCarouselWidget({super.key});

  @override
  State<MnjoodMartCarouselWidget> createState() => _MnjoodMartCarouselWidgetState();
}

class _MnjoodMartCarouselWidgetState extends State<MnjoodMartCarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      List<Product>? products = homeController.mnjoodMartProducts;

      if (products == null) {
        return const MnjoodMartCarouselShimmer();
      }

      if (products.isEmpty) {
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
                  Text('mnjood_mart'.tr, style: robotoBold.copyWith(fontSize: 16)),
                  const Spacer(),
                  ArrowIconButtonWidget(
                    onTap: () => Get.toNamed(RouteHelper.getBusinessCategoryRoute('supermarket')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid with 4 items per row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length > 8 ? 8 : products.length,
                itemBuilder: (context, index) {
                  return _MartCardCompact(product: products[index]);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MartCard extends StatelessWidget {
  final Product product;

  const _MartCard({required this.product});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    String vendorInitial = (product.restaurantName ?? 'M').substring(0, 1).toUpperCase();

    return CustomInkWellWidget(
      onTap: () {
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket'),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket')));
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
              flex: 5,
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
                            product.restaurantName ?? 'MnjoodMart',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(
                            fontSize: 14,
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

// Compact card for 4-column grid layout
class _MartCardCompact extends StatelessWidget {
  final Product product;

  const _MartCardCompact({required this.product});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    return CustomInkWellWidget(
      onTap: () {
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket'),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket')));
      },
      radius: 12,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              flex: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CustomImageWidget(
                      image: product.imageFullUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      isFood: true,
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name ?? '',
                      style: robotoMedium.copyWith(fontSize: 10, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).primaryColor,
                          ),
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

class MnjoodMartCarouselShimmer extends StatelessWidget {
  const MnjoodMartCarouselShimmer({super.key});

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
