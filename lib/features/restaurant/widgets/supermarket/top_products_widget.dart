import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class TopProductsWidget extends StatelessWidget {
  final int vendorId;
  const TopProductsWidget({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      // Get products with highest ratings
      final products = restController.restaurantProducts;
      if (products == null || products.isEmpty) {
        return const SizedBox();
      }

      // Sort by rating and take top items
      final topProducts = List.from(products)
        ..sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));
      final displayProducts = topProducts.take(10).toList();

      if (displayProducts.isEmpty) {
        return const SizedBox();
      }

      return Container(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'top_picks_for_you'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        'our_best_rated_products'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                  ArrowIconButtonWidget(onTap: () {
                    // Navigate to popular products page
                    Get.toNamed(RouteHelper.getPopularFoodRoute(true, fromIsRestaurantFood: true, restaurantId: vendorId));
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
                      isBestItem: true,
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
