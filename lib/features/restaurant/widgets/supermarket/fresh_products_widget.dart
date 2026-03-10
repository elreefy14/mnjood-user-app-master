import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class FreshProductsWidget extends StatelessWidget {
  final int vendorId;
  const FreshProductsWidget({super.key, required this.vendorId});

  // Category IDs for vegetables and fruits
  static const int vegetablesCategoryId = 27;
  static const int fruitsCategoryId = 28;
  static const int maxDisplayItems = 7;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      final products = restController.restaurantProducts;
      if (products == null || products.isEmpty) {
        return const SizedBox();
      }

      // Filter products for vegetables and fruits categories
      final freshProducts = products.where((p) {
        final catId = p.categoryId;
        return catId == vegetablesCategoryId || catId == fruitsCategoryId;
      }).toList();

      if (kDebugMode) {
        print('FreshProductsWidget: Total products: ${products.length}, Fresh products: ${freshProducts.length}');
        for (var p in freshProducts.take(5)) {
          print('  - ${p.name} (categoryId: ${p.categoryId})');
        }
      }

      if (freshProducts.isEmpty) {
        return const SizedBox();
      }

      // Limit to maxDisplayItems for the main page view
      final displayProducts = freshProducts.take(maxDisplayItems).toList();

      return Container(
        color: Colors.green.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(
                          'FRESH',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'fresh_products'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'vegetables_and_fruits'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ArrowIconButtonWidget(onTap: () {
                    // Navigate to vegetables category (shows both vegetables and fruits)
                    Get.toNamed(RouteHelper.getVendorCategoryProductsRoute(vendorId, vegetablesCategoryId));
                  }),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(
              height: ResponsiveHelper.isDesktop(context) ? 307 : 305,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayProducts.length,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < displayProducts.length - 1 ? Dimensions.paddingSizeSmall : 0,
                    ),
                    child: ItemCardWidget(
                      product: displayProducts[index],
                      isBestItem: false,
                      width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                      inRestaurantPage: true,
                      businessType: 'supermarket',
                      vendorId: vendorId,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
