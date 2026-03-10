import 'package:mnjood/features/home/widgets/filter_view_widget.dart';
import 'package:mnjood/features/home/widgets/restaurant_filter_button_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllRestaurantFilterWidget extends StatelessWidget {
  final String? businessType;
  const AllRestaurantFilterWidget({super.key, this.businessType});

  // Get the heading based on business type
  String _getHeadingKey() {
    switch (businessType) {
      case 'supermarket':
        return 'all_supermarkets';
      case 'pharmacy':
        return 'all_pharmacies';
      default:
        return 'all_restaurants';
    }
  }

  // Get the "near you" text based on business type
  String _getNearYouKey() {
    switch (businessType) {
      case 'supermarket':
        return 'supermarkets_near_you';
      case 'pharmacy':
        return 'pharmacies_near_you';
      default:
        return 'restaurants_near_you';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(
      builder: (restaurantController) {
        return Center(
          child: ResponsiveHelper.isDesktop(context) ? Container(
              height: 70,
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).colorScheme.surface,

              child: Row(
                children: [

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_getHeadingKey().tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),

                    Text(
                      '${restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : 0} ${_getNearYouKey().tr}',
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),

                  const Expanded(child: SizedBox()),

                  filter(context, restaurantController),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                ],
              )

          ) : Container(
            transform: Matrix4.translationValues(0, -2, 0),
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, /*vertical: Dimensions.paddingSizeExtraSmall*/),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_getHeadingKey().tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                Flexible(
                  child: Text(
                    '${restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : 0} ${_getNearYouKey().tr}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              filter(context, restaurantController),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Divider(),
            ]),
          ),
        );
      }
    );
  }

  Widget filter(BuildContext context, RestaurantController restaurantController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          ResponsiveHelper.isDesktop(context) ? const SizedBox() : const FilterViewWidget(),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          RestaurantsFilterButtonWidget(
            buttonText: 'top_rated'.tr,
            onTap: () => restaurantController.setTopRated(),
            isSelected: restaurantController.topRated == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          RestaurantsFilterButtonWidget(
            buttonText: 'discounted'.tr,
            onTap: () => restaurantController.setDiscount(),
            isSelected: restaurantController.discount == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          // Veg/Non-veg filters removed

          ResponsiveHelper.isDesktop(context) ? const FilterViewWidget() : const SizedBox(),

        ],
      ),
    );
  }
}
