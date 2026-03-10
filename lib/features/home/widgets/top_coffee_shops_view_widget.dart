import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class TopCoffeeShopsViewWidget extends StatefulWidget {
  const TopCoffeeShopsViewWidget({super.key});

  @override
  State<TopCoffeeShopsViewWidget> createState() => _TopCoffeeShopsViewWidgetState();
}

class _TopCoffeeShopsViewWidgetState extends State<TopCoffeeShopsViewWidget> {
  bool _openNowFilter = false;
  bool _freeDeliveryFilter = false;
  bool _topRatedFilter = false;

  List<Restaurant> _applyFilters(List<Restaurant> coffeeShops) {
    List<Restaurant> filtered = List.from(coffeeShops);

    if (_openNowFilter) {
      filtered = filtered.where((r) => r.open == 1 && (r.active ?? false)).toList();
    }

    if (_freeDeliveryFilter) {
      filtered = filtered.where((r) => r.freeDelivery ?? false).toList();
    }

    if (_topRatedFilter) {
      filtered = filtered.where((r) => (r.avgRating ?? 0) >= 4.0).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      // Use dedicated top coffee shops list
      List<Restaurant>? coffeeShopList = restController.topCoffeeShopList;

      if (coffeeShopList == null) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
            horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EnterpriseSectionHeaderWidget(
                title: 'popular_cafes'.tr,
                trailing: ArrowIconButtonWidget(onTap: () {
                  Get.toNamed(RouteHelper.getBusinessCategoryRoute('coffee_shop'));
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              const TopCoffeeShopsShimmer(),
            ],
          ),
        );
      }

      if (coffeeShopList.isEmpty) {
        return const SizedBox();
      }

      final filteredList = _applyFilters(coffeeShopList);

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ResponsiveHelper.isDesktop(context)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('popular_cafes'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    ArrowIconButtonWidget(onTap: () {
                      Get.toNamed(RouteHelper.getBusinessCategoryRoute('coffee_shop'));
                    }),
                  ]),
                )
              : EnterpriseSectionHeaderWidget(
                  title: 'popular_cafes'.tr,
                  trailing: ArrowIconButtonWidget(onTap: () {
                    Get.toNamed(RouteHelper.getBusinessCategoryRoute('coffee_shop'));
                  }),
                ),
            const SizedBox(height: 8),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'open_now'.tr,
                    icon: HeroiconsOutline.clock,
                    selectedIcon: HeroiconsSolid.clock,
                    isSelected: _openNowFilter,
                    color: Colors.green,
                    onSelected: (val) => setState(() => _openNowFilter = val),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'free_delivery'.tr,
                    icon: HeroiconsOutline.truck,
                    selectedIcon: HeroiconsSolid.truck,
                    isSelected: _freeDeliveryFilter,
                    color: const Color(0xFF6F4E37),
                    onSelected: (val) => setState(() => _freeDeliveryFilter = val),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'top_rated'.tr,
                    icon: HeroiconsOutline.star,
                    selectedIcon: HeroiconsSolid.star,
                    isSelected: _topRatedFilter,
                    color: Colors.amber,
                    onSelected: (val) => setState(() => _topRatedFilter = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Coffee shop cards
            filteredList.isEmpty
              ? Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    'no_coffee_shops_found'.tr,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: filteredList.length > 8 ? 8 : filteredList.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildCoffeeShopCard(context, filteredList[index], restController);
                    },
                  ),
                ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required Color color,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      avatar: Icon(
        isSelected ? selectedIcon : icon,
        size: 14,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: 11,
          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color,
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCoffeeShopCard(BuildContext context, Restaurant coffeeShop, RestaurantController restController) {
    bool isAvailable = coffeeShop.open == 1 && (coffeeShop.active ?? false);
    double distance = 0;
    if (coffeeShop.latitude != null && coffeeShop.longitude != null) {
      distance = restController.getRestaurantDistance(
        LatLng(double.parse(coffeeShop.latitude!), double.parse(coffeeShop.longitude!)),
      );
    }

    // Build characteristics string
    String characteristics = '';
    if (coffeeShop.characteristics != null) {
      for (var v in coffeeShop.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CustomInkWellWidget(
        onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(coffeeShop, context, businessType: 'coffee_shop'),
        radius: 16,
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CustomImageWidget(
                      image: '${coffeeShop.coverPhotoFullUrl}',
                      fit: BoxFit.cover,
                      height: 100,
                      width: double.infinity,
                      isRestaurant: true,
                    ),
                  ),

                  // Coffee shop badge
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6F4E37), // Coffee brown color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(HeroiconsSolid.buildingStorefront, size: 10, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'coffee_shops'.tr,
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rating badge
                  PositionedDirectional(
                    top: 8,
                    end: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            (coffeeShop.avgRating ?? 0).toStringAsFixed(1),
                            style: robotoMedium.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favourite button
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: GetBuilder<FavouriteController>(
                      builder: (favController) {
                        bool isWished = favController.wishRestIdList.contains(coffeeShop.id);
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: CustomFavouriteWidget(
                            isWished: isWished,
                            isRestaurant: true,
                            restaurant: coffeeShop,
                          ),
                        );
                      },
                    ),
                  ),

                  // Closed overlay
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'closed_now'.tr,
                              style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Logo at bottom start overlapping
                  PositionedDirectional(
                    bottom: -25,
                    start: 12,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).cardColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: CustomImageWidget(
                          image: '${coffeeShop.logoFullUrl}',
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                          isRestaurant: true,
                        ),
                      ),
                    ),
                  ),

                  // Distance badge at end of image
                  PositionedDirectional(
                    bottom: 8,
                    end: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} ${'km'.tr}',
                        style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),

              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        coffeeShop.name ?? '',
                        style: robotoBold.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (characteristics.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          characteristics,
                          style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom info row
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
                child: Row(
                  children: [
                    // Rating
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      (coffeeShop.avgRating ?? 0).toStringAsFixed(1),
                      style: robotoMedium.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    // Free delivery
                    if (coffeeShop.freeDelivery ?? false) ...[
                      Icon(HeroiconsOutline.truck, size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 2),
                      Text(
                        'free'.tr,
                        style: robotoMedium.copyWith(fontSize: 11, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 10),
                    ],
                    // Delivery time
                    Icon(HeroiconsOutline.clock, size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${coffeeShop.deliveryTime}',
                        style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class TopCoffeeShopsShimmer extends StatelessWidget {
  const TopCoffeeShopsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover image shimmer
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Shimmer(
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                ),
                // Info shimmer
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer(
                        child: Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer(
                        child: Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
