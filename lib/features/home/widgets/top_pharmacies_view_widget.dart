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

class TopPharmaciesViewWidget extends StatelessWidget {
  const TopPharmaciesViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? pharmacyList = restController.topPharmacyList;

      return (pharmacyList != null && pharmacyList.isEmpty) ? const SizedBox() : Container(
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
                    Text('top_pharmacies'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    ArrowIconButtonWidget(onTap: () {
                      Get.toNamed(RouteHelper.getBusinessCategoryRoute('pharmacy'));
                    }),
                  ]),
                )
              : EnterpriseSectionHeaderWidget(
                  title: 'top_pharmacies'.tr,
                  trailing: ArrowIconButtonWidget(onTap: () {
                    Get.toNamed(RouteHelper.getBusinessCategoryRoute('pharmacy'));
                  }),
                ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Pharmacy cards
            pharmacyList != null ? SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: pharmacyList.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildPharmacyCard(context, pharmacyList[index], restController);
                },
              ),
            ) : const TopPharmaciesShimmer(),
          ],
        ),
      );
    });
  }

  Widget _buildPharmacyCard(BuildContext context, Restaurant pharmacy, RestaurantController restController) {
    bool isAvailable = pharmacy.open == 1 && (pharmacy.active ?? false);
    double distance = 0;
    if (pharmacy.latitude != null && pharmacy.longitude != null) {
      distance = restController.getRestaurantDistance(
        LatLng(double.parse(pharmacy.latitude!), double.parse(pharmacy.longitude!)),
      );
    }

    // Build characteristics string
    String characteristics = '';
    if (pharmacy.characteristics != null) {
      for (var v in pharmacy.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CustomInkWellWidget(
        onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(pharmacy, context, businessType: 'pharmacy'),
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
                      image: '${pharmacy.coverPhotoFullUrl}',
                      fit: BoxFit.cover,
                      height: 100,
                      width: double.infinity,
                      isRestaurant: true,
                    ),
                  ),

                  // Pharmacy badge
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor, // Green for pharmacy
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(HeroiconsSolid.buildingStorefront, size: 10, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'pharmacy'.tr,
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rating badge (always show)
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
                            (pharmacy.avgRating ?? 0).toStringAsFixed(1),
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
                        bool isWished = favController.wishRestIdList.contains(pharmacy.id);
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: CustomFavouriteWidget(
                            isWished: isWished,
                            isRestaurant: true,
                            restaurant: pharmacy,
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
                          image: '${pharmacy.logoFullUrl}',
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
                        pharmacy.name ?? '',
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
                    // Rating (always show)
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      (pharmacy.avgRating ?? 0).toStringAsFixed(1),
                      style: robotoMedium.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    // Free delivery
                    if (pharmacy.freeDelivery ?? false) ...[
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
                        '${pharmacy.deliveryTime}',
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


class TopPharmaciesShimmer extends StatelessWidget {
  const TopPharmaciesShimmer({super.key});

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
