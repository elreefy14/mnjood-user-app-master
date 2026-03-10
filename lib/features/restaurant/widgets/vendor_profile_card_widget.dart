import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/restaurant/widgets/coupon_view_widget.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class VendorProfileCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;

  const VendorProfileCardWidget({
    super.key,
    required this.restaurant,
    required this.restController,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(
      children: [
        // Cover Photo
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(Dimensions.radiusLarge),
                  bottomRight: Radius.circular(Dimensions.radiusLarge),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(Dimensions.radiusLarge),
                  bottomRight: Radius.circular(Dimensions.radiusLarge),
                ),
                child: CustomImageWidget(
                  image: '${restaurant.coverPhotoFullUrl}',
                  fit: BoxFit.cover,
                  placeholder: Images.restaurantCover,
                  isRestaurant: true,
                ),
              ),
            ),

            // Profile Card positioned at bottom of cover
            Positioned(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              bottom: -80,
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo and Info Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Stack(
                              children: [
                                CustomImageWidget(
                                  image: '${restaurant.logoFullUrl}',
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                if (!restController.isRestaurantOpenNow(restaurant.active ?? false, restaurant.schedules))
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                      child: Text(
                                        'closed_now'.tr,
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        // Name and Address
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name ?? '',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Text(
                                restaurant.address ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Row(
                                children: [
                                  Text(
                                    'start_from'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  PriceConverter.convertPriceWithSvg(restaurant.priceStartFrom, textStyle: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Favorite and Share
                        Column(
                          children: [
                            GetBuilder<FavouriteController>(
                              builder: (favouriteController) {
                                bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                                return CustomFavouriteWidget(
                                  isWished: isWished,
                                  isRestaurant: true,
                                  restaurant: restaurant,
                                  size: 24,
                                );
                              },
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            if (AppConstants.webHostedUrl.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  if (isDesktop) {
                                    String shareUrl = '${AppConstants.webHostedUrl}${restController.filteringUrl(restaurant.slug ?? '')}';
                                    Clipboard.setData(ClipboardData(text: shareUrl));
                                    showCustomSnackBar('restaurant_url_copied'.tr, isError: false);
                                  } else {
                                    String shareUrl = '${AppConstants.webHostedUrl}${restController.filteringUrl(restaurant.slug ?? '')}';
                                    SharePlus.instance.share(ShareParams(text: shareUrl));
                                  }
                                },
                                child: const Icon(HeroiconsOutline.share, size: 20),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Stats Row (Time, Location, Rating, Free Delivery)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Delivery Time
                        _buildStatItem(
                          context,
                          icon: HeroiconsOutline.clock,
                          value: restaurant.deliveryTime ?? '30-45 min',
                          label: null,
                        ),

                        // Location
                        InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getMapRoute(
                            AddressModel(
                              id: restaurant.id,
                              address: restaurant.address,
                              latitude: restaurant.latitude,
                              longitude: restaurant.longitude,
                              contactPersonNumber: '',
                              contactPersonName: '',
                              addressType: '',
                            ),
                            'restaurant',
                            restaurantName: restaurant.name,
                          )),
                          child: _buildStatItem(
                            context,
                            iconWidget: Image.asset(
                              Images.restaurantLocationIcon,
                              height: 20,
                              width: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            value: 'location'.tr,
                            label: null,
                          ),
                        ),

                        // Rating
                        InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getRestaurantReviewRoute(restaurant.id, restaurant.name, restaurant)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(HeroiconsSolid.star, color: Theme.of(context).primaryColor, size: 20),
                                  const SizedBox(width: 2),
                                  Text(
                                    (restaurant.avgRating ?? 0).toStringAsFixed(1),
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ],
                              ),
                              Text(
                                '${restaurant.ratingCount}+ ${'ratings'.tr}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Free Delivery
                        if ((restaurant.delivery ?? false) && (restaurant.freeDelivery ?? false))
                          _buildStatItem(
                            context,
                            icon: HeroiconsOutline.banknotes,
                            value: 'free_delivery'.tr,
                            label: null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Spacer for the overlapping card
        const SizedBox(height: 100),

        // Coupons Section
        GetBuilder<CouponController>(
          builder: (couponController) {
            bool hasCoupons = couponController.couponList != null && couponController.couponList!.isNotEmpty;
            if (hasCoupons) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: CouponViewWidget(scrollingRate: 0),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String value,
    String? label,
  }) {
    return Column(
      children: [
        iconWidget ?? Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        if (label != null)
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
      ],
    );
  }
}
