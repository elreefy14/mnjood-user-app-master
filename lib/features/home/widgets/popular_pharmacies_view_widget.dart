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
import 'package:heroicons_flutter/heroicons_flutter.dart';

class PopularPharmaciesViewWidget extends StatelessWidget {
  const PopularPharmaciesViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? pharmacyList = restController.popularRestaurantList?.where((r) =>
          r.businessType == 'pharmacy'
        ).toList();

      return (pharmacyList == null || pharmacyList.isEmpty) ? const SizedBox() : Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            EnterpriseSectionHeaderWidget(
              icon: HeroiconsSolid.heart,
              title: 'popular_pharmacies'.tr,
              trailing: ArrowIconButtonWidget(onTap: () {
                Get.toNamed(RouteHelper.getAllRestaurantRoute('popular'));
              }),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Horizontal scrolling pharmacy cards
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: pharmacyList.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildPharmacyCard(context, pharmacyList[index], restController);
                },
              ),
            ),
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

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CustomInkWellWidget(
        onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(pharmacy, context, businessType: 'pharmacy'),
        radius: 16,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo with health badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageWidget(
                        image: '${pharmacy.logoFullUrl}',
                        fit: BoxFit.cover,
                        height: 80,
                        width: 80,
                        isRestaurant: true,
                      ),
                    ),
                  ),
                  // Health badge
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(HeroiconsSolid.heart, size: 14, color: Colors.white),
                    ),
                  ),
                  // Closed overlay
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'closed'.tr,
                            style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name and favourite
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pharmacy.name ?? '',
                            style: robotoBold.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        GetBuilder<FavouriteController>(
                          builder: (favController) {
                            bool isWished = favController.wishRestIdList.contains(pharmacy.id);
                            return CustomFavouriteWidget(
                              isWished: isWished,
                              isRestaurant: true,
                              restaurant: pharmacy,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Pharmacy badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pharmacy',
                        style: robotoMedium.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Info row: Rating, Distance, Delivery
                    Row(
                      children: [
                        // Rating
                        if ((pharmacy.ratingCount ?? 0) > 0) ...[
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            (pharmacy.avgRating ?? 0).toStringAsFixed(1),
                            style: robotoMedium.copyWith(fontSize: 11),
                          ),
                          const SizedBox(width: 10),
                        ],
                        // Distance
                        Icon(HeroiconsOutline.mapPin, size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 2),
                        Text(
                          '${distance.toStringAsFixed(1)} ${'km'.tr}',
                          style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(width: 10),
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
