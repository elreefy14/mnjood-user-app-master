import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/restaurants_card_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewOnMnjoodViewWidget extends StatelessWidget {
  final bool isLatest;
  const NewOnMnjoodViewWidget({super.key, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
        return (restController.latestRestaurantList != null && restController.latestRestaurantList!.isEmpty) ? const SizedBox() : Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
          child: Container(
            width: Dimensions.webMaxWidth,
            height: 210,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${'new_on'.tr} ${AppConstants.appName}', style: sectionTitleStyle),

                    ArrowIconButtonWidget(
                      onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(isLatest ? 'latest' : '')),
                    ),
                  ]),
                ),


                restController.latestRestaurantList != null ? SizedBox(
                  height: 130,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                    itemCount: restController.latestRestaurantList!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () {
                              RouteHelper.navigateToStoreOrShowClosedDialog(restController.latestRestaurantList![index], context, businessType: restController.latestRestaurantList![index].businessType);
                            },
                            child: RestaurantsCardWidget(
                              isNewOnMnjood: true,
                              restaurant: restController.latestRestaurantList![index],
                            ),
                          ),
                        );
                      },
                  ),
                ) : const RestaurantsCardShimmer(isNewOnMnjood: false),
             ],
            ),

          ),
        );
      }
    );
  }
}
