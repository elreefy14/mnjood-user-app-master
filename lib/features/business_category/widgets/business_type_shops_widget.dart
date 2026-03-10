import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_distance_cliper_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/restaurant/screens/restaurant_screen.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class BusinessTypeShopsWidget extends StatelessWidget {
  final String businessType;
  const BusinessTypeShopsWidget({super.key, required this.businessType});

  String _getTitle() {
    switch (businessType.toLowerCase()) {
      case 'restaurant':
        return 'restaurants'.tr;
      case 'pharmacy':
        return 'pharmacies'.tr;
      case 'coffee_shop':
        return 'coffee_shops'.tr;
      default:
        return 'shops'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      // Use latest restaurant list which is filtered by business type
      List<Restaurant>? restaurantList = restController.latestRestaurantList;

      return (restaurantList != null && restaurantList.isEmpty)
        ? const SizedBox()
        : Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeDefault
              : Dimensions.paddingSizeLarge
          ),
          child: SizedBox(
            height: 260,
            width: Dimensions.webMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeLarge
                  ),
                  child: Text(
                    _getTitle(),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),

                restaurantList != null
                  ? SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: restaurantList.length,
                        padding: EdgeInsets.only(
                          right: ResponsiveHelper.isMobile(context)
                            ? Dimensions.paddingSizeDefault
                            : 0
                        ),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isAvailable = restaurantList[index].open == 1 &&
                            (restaurantList[index].active ?? false);
                          String characteristics = '';
                          if (restaurantList[index].characteristics != null) {
                            for (var v in restaurantList[index].characteristics!) {
                              characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
                            }
                          }
                          return Padding(
                            padding: EdgeInsets.only(
                              left: (ResponsiveHelper.isDesktop(context) &&
                                index == 0 &&
                                Get.find<LocalizationController>().isLtr)
                                  ? 0
                                  : Dimensions.paddingSizeDefault
                            ),
                            child: Container(
                              height: 200,
                              width: ResponsiveHelper.isDesktop(context)
                                ? 180
                                : 165,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CustomInkWellWidget(
                                onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(restaurantList[index], context),
                                radius: 16,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Cover image section
                                        SizedBox(
                                          height: 100,
                                          width: double.infinity,
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                                child: CustomImageWidget(
                                                  image: '${restaurantList[index].coverPhotoFullUrl}',
                                                  fit: BoxFit.cover,
                                                  height: 100,
                                                  width: double.infinity,
                                                  isRestaurant: true,
                                                ),
                                              ),
                                              // Closed overlay
                                              if (!isAvailable)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                                      color: Colors.black.withOpacity(0.5),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.error,
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                          'closed_now'.tr,
                                                          style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              // Rating badge
                                              if ((restaurantList[index].ratingCount ?? 0) > 0)
                                                Positioned(
                                                  top: 8,
                                                  left: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.star, size: 12, color: Colors.white),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          (restaurantList[index].avgRating ?? 0).toStringAsFixed(1),
                                                          style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // Favourite button
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GetBuilder<FavouriteController>(
                                                  builder: (favouriteController) {
                                                    bool isWished = favouriteController.wishRestIdList.contains(restaurantList[index].id);
                                                    return Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).cardColor,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.1),
                                                            blurRadius: 4,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        isWished ? HeroiconsSolid.heart : HeroiconsOutline.heart,
                                                        size: 14,
                                                        color: isWished ? Colors.red : Theme.of(context).hintColor,
                                                      ),
                                                    );
                                                  }
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Bottom info
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(55, 8, 8, 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  restaurantList[index].name ?? '',
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: robotoBold.copyWith(fontSize: 12),
                                                ),
                                                if (characteristics.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    characteristics,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: robotoRegular.copyWith(
                                                      fontSize: 9,
                                                      color: Theme.of(context).hintColor,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(HeroiconsOutline.clock, size: 11, color: Theme.of(context).hintColor),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${restaurantList[index].deliveryTime}',
                                                      style: robotoRegular.copyWith(fontSize: 9, color: Theme.of(context).hintColor),
                                                    ),
                                                    if (restaurantList[index].freeDelivery ?? false) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          'free'.tr,
                                                          style: robotoMedium.copyWith(fontSize: 8, color: Colors.green),
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
                                    // Logo overlay at bottom-left
                                    Positioned(
                                      left: 8,
                                      top: 75,
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Theme.of(context).cardColor,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CustomImageWidget(
                                            image: '${restaurantList[index].logoFullUrl}',
                                            fit: BoxFit.cover,
                                            height: 45,
                                            width: 45,
                                            isRestaurant: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const BusinessTypeShopsShimmer()
              ],
            ),
          ),
        );
    });
  }
}

class BusinessTypeShopsShimmer extends StatelessWidget {
  const BusinessTypeShopsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0,
          right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
            height: 185, width: 253,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).shadowColor),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 85, width: 253,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault)
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault)
                    ),
                    child: Shimmer(
                      child: Container(
                        height: 85, width: 253,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 90, left: 10, right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: Shimmer(
                          child: Container(
                            height: 15, width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).shadowColor
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: Shimmer(
                          child: Container(
                            height: 10, width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).shadowColor
                            )
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ]
            ),
          );
        },
      ),
    );
  }
}
