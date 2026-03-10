import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/restaurant/screens/restaurant_screen.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class NearestStoresViewWidget extends StatefulWidget {
  const NearestStoresViewWidget({super.key});

  @override
  State<NearestStoresViewWidget> createState() => _NearestStoresViewWidgetState();
}

class _NearestStoresViewWidgetState extends State<NearestStoresViewWidget> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'key': 'restaurant', 'label': 'restaurants_tab'},
    {'key': 'cafe', 'label': 'cafes_tab'},
    {'key': 'pharmacy', 'label': 'pharmacies_tab'},
    {'key': 'grocery', 'label': 'groceries_tab'},
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      List<Restaurant>? restaurants = restaurantController.restaurantList;

      if (restaurants == null || restaurants.isEmpty) {
        return const SizedBox();
      }

      // Filter restaurants based on selected tab
      List<Restaurant> filteredRestaurants = _filterRestaurants(restaurants);

      return Container(
        width: Dimensions.webMaxWidth,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text(
                'nearest_stores'.tr,
                style: sectionTitleStyle,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Filter tabs
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedTabIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFDA281C) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFDA281C) : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Text(
                          _tabs[index]['label'].toString().tr,
                          style: robotoMedium.copyWith(
                            fontSize: 12,
                            color: isSelected ? Colors.white : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Store cards
            SizedBox(
              height: 200,
              child: filteredRestaurants.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _StoreCard(restaurant: filteredRestaurants[index]),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'no_stores_available'.tr,
                        style: robotoRegular.copyWith(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> restaurants) {
    String selectedKey = _tabs[_selectedTabIndex]['key'];

    switch (selectedKey) {
      case 'restaurant':
        return restaurants.where((r) => r.businessType == 'restaurant' || r.businessType == null).toList();
      case 'cafe':
        return restaurants.where((r) => r.businessType == 'cafe').toList();
      case 'pharmacy':
        return restaurants.where((r) => r.businessType == 'pharmacy').toList();
      case 'grocery':
        return restaurants.where((r) => r.businessType == 'grocery' || r.businessType == 'supermarket').toList();
      default:
        return restaurants;
    }
  }
}

class _StoreCard extends StatelessWidget {
  final Restaurant restaurant;

  const _StoreCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && (restaurant.active ?? false);

    return GestureDetector(
      onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(restaurant, context),
      child: Container(
        width: ResponsiveHelper.isMobile(context) ? 200 : 220,
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
            // Cover image with logo overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      CustomImageWidget(
                        image: '${restaurant.coverPhotoFullUrl}',
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                        isRestaurant: true,
                      ),
                      if (!isAvailable)
                        Container(
                          height: 100,
                          color: Colors.black.withValues(alpha: 0.4),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'closed_now'.tr,
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Logo overlay
                Positioned(
                  bottom: -20,
                  left: 12,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CustomImageWidget(
                        image: '${restaurant.logoFullUrl}',
                        fit: BoxFit.cover,
                        isRestaurant: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Store details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    // Rating and location
                    Row(
                      children: [
                        // Rating
                        if ((restaurant.ratingCount ?? 0) > 0) ...[
                          Icon(
                            HeroiconsSolid.star,
                            color: const Color(0xFFFF9E1B),
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            (restaurant.avgRating ?? 0).toStringAsFixed(1),
                            style: robotoMedium.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Location
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                HeroiconsOutline.mapPin,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  restaurant.address ?? '',
                                  style: robotoRegular.copyWith(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

class NearestStoresShimmer extends StatelessWidget {
  const NearestStoresShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Shimmer(
              child: Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Shimmer(
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Shimmer(
                    child: Container(
                      width: 200,
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
