import 'package:mnjood/common/widgets/business_type_badge_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:mnjood/features/home/widgets/overflow_container_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/not_available_widget.dart';
import 'package:mnjood/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class RestaurantsCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final bool? isNewOnMnjood;
  const RestaurantsCardWidget({super.key, this.isNewOnMnjood, required this.restaurant});


  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && (restaurant.active ?? false);
    double distance = 0;
    if (restaurant.latitude != null && restaurant.longitude != null) {
      try {
        distance = Get.find<RestaurantController>().getRestaurantDistance(
          LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
        );
      } catch (_) {
        distance = 0;
      }
    }
    String characteristics = '';
    if(restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Stack(
      children: [
        Container(
          width: (isNewOnMnjood ?? false) ? ResponsiveHelper.isMobile(context) ? 330 : 380  : ResponsiveHelper.isMobile(context) ? 330: 355,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: CustomInkWellWidget(
            onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(restaurant, context),
            radius: Dimensions.radiusDefault,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all((isNewOnMnjood ?? false) ? 2 : 3),
                        height: (isNewOnMnjood ?? false) ? 95 : 65, width: (isNewOnMnjood ?? false) ? 95 : 65,
                        decoration:  BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child:  CustomImageWidget(
                            image: '${restaurant.logoFullUrl}',
                                fit: BoxFit.cover, height: (isNewOnMnjood ?? false) ? 95 : 65, width: (isNewOnMnjood ?? false) ? 95 : 65,
                            isRestaurant: true,
                          ),
                        ),
                      ),

                      isAvailable ? const SizedBox() : const NotAvailableWidget(isRestaurant: true),

                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          restaurant.name ?? '',
                          overflow: TextOverflow.ellipsis, maxLines: 1,
                          style: robotoBold,
                        ),
                        const SizedBox(height: 4),

                        BusinessTypeBadgeWidget(
                          businessType: restaurant.getBusinessTypeEnum(),
                          size: 11,
                          showLabel: !(isNewOnMnjood ?? false),
                        ),

                        SizedBox(height: (isNewOnMnjood ?? false) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                        characteristics != '' ? Text(
                          characteristics,
                          overflow: TextOverflow.ellipsis, maxLines: 1,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ) : const SizedBox(),
                        SizedBox(height: (isNewOnMnjood ?? false) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                          (isNewOnMnjood ?? false) ? (restaurant.freeDelivery ?? false) ? ImageWithTextRowWidget(
                            widget: Image.asset(Images.deliveryIcon, height: 20, width: 20),
                            text: 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ) : const SizedBox() : IconWithTextRowWidget(
                            icon: HeroiconsOutline.star, text: (restaurant.avgRating ?? 0).toStringAsFixed(1),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)
                          ),
                          (isNewOnMnjood ?? false) ? const SizedBox(width : Dimensions.paddingSizeExtraSmall) : const SizedBox(width: Dimensions.paddingSizeSmall),

                          (isNewOnMnjood ?? false) ? ImageWithTextRowWidget(
                            widget: Image.asset(Images.distanceKm, height: 20, width: 20),
                            text: '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ) : (restaurant.freeDelivery ?? false) ? ImageWithTextRowWidget(widget: Image.asset(Images.deliveryIcon, height: 20, width: 20),
                              text: 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)) : const SizedBox(),
                          (isNewOnMnjood ?? false) ? const SizedBox(width : Dimensions.paddingSizeExtraSmall) : (restaurant.freeDelivery ?? false) ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),

                          (isNewOnMnjood ?? false) ? ImageWithTextRowWidget(
                            widget: Image.asset(Images.itemCount, height: 20, width: 20),
                            text: '${(restaurant.foodsCount ?? 0) > 8 ? '8 +' : '${restaurant.foodsCount ?? 0}'} ${'item'.tr}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ) : IconWithTextRowWidget(
                            icon: HeroiconsOutline.clock,
                            text: restaurant.deliveryTime ?? '',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),

                        ]),
                      ],
                    ),
                  ),
                ]),

                (isNewOnMnjood ?? false) ? const SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  restaurant.foods != null && restaurant.foods!.isNotEmpty ? Expanded(
                    child: Stack(children: [

                      OverFlowContainerWidget(image: restaurant.foods![0].imageFullUrl ?? ''),

                      restaurant.foods!.length > 1 ? Positioned(
                        left: 22, bottom: 0,
                        child: OverFlowContainerWidget(image: restaurant.foods![1].imageFullUrl ?? ''),
                      ) : const SizedBox(),

                      restaurant.foods!.length > 2 ? Positioned(
                        left: 42, bottom: 0,
                        child: OverFlowContainerWidget(image: restaurant.foods![2].imageFullUrl ?? ''),
                      ) : const SizedBox(),

                      restaurant.foods!.length > 4 ? Positioned(
                        left: 82, bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          height: 30, width: 80,
                          decoration:  BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(restaurant.foodsCount ?? 0) > 11 ? '12 +' : restaurant.foodsCount ?? 0} ',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                              ),
                              Text('items'.tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                      ) : const SizedBox(),

                      restaurant.foods!.length > 3 ?  Positioned(
                        left: 62, bottom: 0,
                        child: OverFlowContainerWidget(image: restaurant.foods![3].imageFullUrl ?? ''),
                      ) : const SizedBox(),
                    ]),
                  ) : const SizedBox(),

                  Icon(HeroiconsOutline.arrowRight, color: Theme.of(context).primaryColor, size: 20),
                ]),
              ]),
            ),
          ),
        ),

        Positioned(
          top: 10, right: 10,
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
    );
  }
}


class RestaurantsCardShimmer extends StatelessWidget {
  final bool? isNewOnMnjood;
  const RestaurantsCardShimmer({super.key, this.isNewOnMnjood});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (isNewOnMnjood ?? false) ? 300 : ResponsiveHelper.isDesktop(context) ? 160 : 130,
      child: (isNewOnMnjood ?? false) ? GridView.builder(
        padding: const EdgeInsets.only(left: 17, right: 17, bottom: 17),
        itemCount: 6,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 17, crossAxisSpacing: 17,
          mainAxisExtent: 130,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            child: Container(
              width: 380, height: 80,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          height: 80, width: 80,
                          decoration:  BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child:  Container(
                              color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                              height: 80, width: 80,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 15, width: 100,
                                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Container(
                                height: 15, width: 200,
                                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ]
              ),
            ),
          );
        },
      ) : ListView.builder(
        itemCount: 3,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            child: Container(
              width: 355, height: 80,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).shadowColor),
                color: Theme.of(context).shadowColor,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    height: 80, width: 80,
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Shimmer(
                        child: Container(
                          color: Theme.of(context).shadowColor,
                          height: 80, width: 80,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Shimmer(child: Container(height: 15, width: 100, color: Theme.of(context).shadowColor)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Shimmer(child: Container(height: 15, width: 200, color: Theme.of(context).shadowColor)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                        Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor)),

                      ]),
                    ]),
                  ),
                ]),
              ]),
            ),
          );
        }
      ),
    );
  }
}
