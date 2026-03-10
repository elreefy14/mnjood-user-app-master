import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class RecentlyReviewedWidget extends StatelessWidget {
  final int vendorId;
  const RecentlyReviewedWidget({super.key, required this.vendorId});

  static const int maxDisplayItems = 10;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      final products = restController.restaurantProducts;
      if (products == null || products.isEmpty) {
        return const SizedBox();
      }

      // Filter products with reviews (ratingCount > 0 or avgRating > 0)
      final reviewedProducts = products.where((p) {
        return (p.ratingCount ?? 0) > 0 || (p.avgRating ?? 0) > 0;
      }).toList();

      if (reviewedProducts.isEmpty) {
        return const SizedBox();
      }

      // Sort by rating count (most reviewed first), then by avg rating
      reviewedProducts.sort((a, b) {
        int ratingCountComparison = (b.ratingCount ?? 0).compareTo(a.ratingCount ?? 0);
        if (ratingCountComparison != 0) return ratingCountComparison;
        return (b.avgRating ?? 0).compareTo(a.avgRating ?? 0);
      });

      final displayProducts = reviewedProducts.take(maxDisplayItems).toList();

      return Container(
        color: Colors.amber.withValues(alpha: 0.05),
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: const Icon(HeroiconsSolid.star, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'reviewed_recently'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'top_rated_by_customers'.tr,
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
                    // Navigate to reviewed products page
                    Get.toNamed(RouteHelper.getPopularFoodRoute(
                      false,
                      fromIsRestaurantFood: true,
                      restaurantId: vendorId,
                    ));
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
