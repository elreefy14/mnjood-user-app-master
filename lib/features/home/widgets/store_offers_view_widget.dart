import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class StoreOffersViewWidget extends StatelessWidget {
  const StoreOffersViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      List<Restaurant>? restaurants = restaurantController.popularRestaurantList;

      // Filter restaurants with discounts or free delivery
      List<Restaurant>? offersRestaurants = restaurants?.where((r) {
        return (r.discount != null && (r.discount?.discount ?? 0) > 0) || (r.freeDelivery ?? false);
      }).toList();

      // If no specific offers, show some restaurants anyway
      if (offersRestaurants?.isEmpty ?? true) {
        offersRestaurants = restaurants?.take(5).toList();
      }

      if (offersRestaurants == null || offersRestaurants.isEmpty) {
        return const SizedBox();
      }

      return Container(
        width: Dimensions.webMaxWidth,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with lightning icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Icon(
                    HeroiconsSolid.bolt,
                    color: const Color(0xFFFF9E1B),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'store_offers'.tr,
                    style: sectionTitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Offer cards
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemCount: offersRestaurants.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _StoreOfferCard(restaurant: offersRestaurants![index]),
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

class _StoreOfferCard extends StatelessWidget {
  final Restaurant restaurant;

  const _StoreOfferCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    // Generate a mock coupon code based on restaurant name
    String couponCode = 'MNJOOD${restaurant.id ?? ''}';

    // Get discount info
    double discountPercent = restaurant.discount?.discount ?? 0;
    bool hasFreeDelivery = restaurant.freeDelivery ?? false;

    String offerText = '';
    if (discountPercent > 0) {
      offerText = '${discountPercent.toInt()}% ${'off'.tr}';
    } else if (hasFreeDelivery) {
      offerText = 'free_delivery'.tr;
    } else {
      offerText = 'special_offer'.tr;
    }

    return GestureDetector(
      onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(restaurant, context, businessType: restaurant.businessType),
      child: Container(
        width: ResponsiveHelper.isMobile(context) ? 280 : 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFDA281C).withValues(alpha: 0.1),
              const Color(0xFFFF9E1B).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFDA281C).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Store logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomImageWidget(
                  image: '${restaurant.logoFullUrl}',
                  fit: BoxFit.cover,
                  isRestaurant: true,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Store info and offer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Store name
                  Text(
                    restaurant.name ?? '',
                    style: robotoBold.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Offer text
                  Text(
                    offerText,
                    style: robotoMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFFDA281C),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Coupon code button
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: couponCode));
                      showCustomSnackBar('coupon_copied'.tr, isError: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDA281C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'get_discount'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            HeroiconsOutline.clipboard,
                            size: 12,
                            color: Colors.white,
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
      ),
    );
  }
}

class StoreOffersShimmer extends StatelessWidget {
  const StoreOffersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
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
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Shimmer(
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                        borderRadius: BorderRadius.circular(12),
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
