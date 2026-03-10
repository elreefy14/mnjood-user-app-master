import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class DiscountsViewWidget extends StatefulWidget {
  final String businessType;
  const DiscountsViewWidget({super.key, required this.businessType});

  @override
  State<DiscountsViewWidget> createState() => _DiscountsViewWidgetState();
}

class _DiscountsViewWidgetState extends State<DiscountsViewWidget> {
  @override
  void initState() {
    super.initState();
    // Load discount data for the specific business type
    Get.find<RestaurantController>().getDiscountRestaurantList(false, widget.businessType, false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = restController.getDiscountRestaurantListByType(widget.businessType);

      return (restaurantList != null && restaurantList.isEmpty) ? const SizedBox() : Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
        child: SizedBox(
          height: 230, width: Dimensions.webMaxWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
              child: Text('special_offers'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),
            ),

            restaurantList != null ? Expanded(
              child: ListView.builder(
                itemCount: restaurantList.length,
                padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  Restaurant restaurant = restaurantList[index];
                  bool isAvailable = restaurant.open == 1 && (restaurant.active ?? false);

                  // Get discount info
                  String discountText = '';
                  if (restaurant.discount != null && restaurant.discount!.discount != null && restaurant.discount!.discount! > 0) {
                    if (restaurant.discount!.discountType == 'percent') {
                      discountText = '${restaurant.discount!.discount!.toStringAsFixed(0)}% OFF';
                    } else {
                      discountText = '\$${restaurant.discount!.discount!.toStringAsFixed(0)} OFF';
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomInkWellWidget(
                        onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(restaurant, context, businessType: restaurant.businessType),
                        radius: Dimensions.radiusDefault,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with discount badge
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(Dimensions.radiusDefault),
                                    topRight: Radius.circular(Dimensions.radiusDefault),
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
                                          alignment: Alignment.center,
                                          child: Text(
                                            'closed_now'.tr,
                                            style: robotoMedium.copyWith(color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Discount badge
                                if (discountText.isNotEmpty)
                                  Positioned(
                                    top: Dimensions.paddingSizeExtraSmall,
                                    left: Dimensions.paddingSizeExtraSmall,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeExtraSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      ),
                                      child: Text(
                                        discountText,
                                        style: robotoBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Favorite button
                                Positioned(
                                  top: Dimensions.paddingSizeExtraSmall,
                                  right: Dimensions.paddingSizeExtraSmall,
                                  child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                                    bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                                    return CustomFavouriteWidget(
                                      isWished: isWished,
                                      isRestaurant: true,
                                      restaurant: restaurant,
                                    );
                                  }),
                                ),
                              ],
                            ),

                            // Restaurant info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      restaurant.name ?? '',
                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    // Rating and delivery time
                                    Row(
                                      children: [
                                        if ((restaurant.ratingCount ?? 0) > 0) ...[
                                          Icon(HeroiconsSolid.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 2),
                                          Text(
                                            (restaurant.avgRating ?? 0).toStringAsFixed(1),
                                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                        ],
                                        Icon(HeroiconsOutline.clock, size: 14, color: Theme.of(context).hintColor),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${restaurant.deliveryTime}',
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).hintColor,
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
                    ),
                  );
                },
              ),
            ) : const DiscountsShimmer(),
          ]),
        ),
      );
    });
  }
}

class DiscountsShimmer extends StatelessWidget {
  const DiscountsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: Dimensions.paddingSizeDefault),
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusDefault),
                        topRight: Radius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer(
                        child: Container(
                          height: 15,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Shimmer(
                        child: Container(
                          height: 12,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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
