import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/home/widgets/restaurants_card_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllRestaurantScreen extends StatefulWidget {
  final bool isPopular;
  final bool isRecentlyViewed;
  final bool isOrderAgain;
  const AllRestaurantScreen({super.key, required this.isPopular, required this.isRecentlyViewed, required this.isOrderAgain});

  @override
  State<AllRestaurantScreen> createState() => _AllRestaurantScreenState();
}

class _AllRestaurantScreenState extends State<AllRestaurantScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if(widget.isPopular) {
      Get.find<RestaurantController>().getPopularRestaurantList(false, 'all', false);
    }else if(widget.isRecentlyViewed){
      Get.find<RestaurantController>().getRecentlyViewedRestaurantList(false, 'all', false);
    } else if(widget.isOrderAgain) {
      Get.find<RestaurantController>().getOrderAgainRestaurantList(false);
    } else{
      Get.find<RestaurantController>().getLatestRestaurantList(false, 'all', false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<RestaurantController>(
      builder: (restController) {
        return Scaffold(
          appBar: CustomAppBarWidget(
            title: widget.isPopular ? 'popular_restaurants'.tr : widget.isRecentlyViewed
                ? 'recently_viewed_restaurants'.tr : widget.isOrderAgain ? 'order_again'.tr
                : '${'new_on'.tr} ${AppConstants.appName}',
            type: restController.type,
            onVegFilterTap: widget.isOrderAgain ? null : (String type) {
              if(widget.isPopular) {
                restController.getPopularRestaurantList(true, type, true);
              }else {
                if(widget.isRecentlyViewed){
                  restController.getRecentlyViewedRestaurantList(true, type, true);
                }else{
                  restController.getLatestRestaurantList(true, type, true);
                }
              }
            },
          ),
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          body: RefreshIndicator(
            onRefresh: () async {
              if(widget.isPopular) {
                await Get.find<RestaurantController>().getPopularRestaurantList(
                  true, Get.find<RestaurantController>().type, false,
                );
              } else if(widget.isRecentlyViewed){
                Get.find<RestaurantController>().getRecentlyViewedRestaurantList(true, Get.find<RestaurantController>().type, false);
              } else if(widget.isOrderAgain) {
                Get.find<RestaurantController>().getOrderAgainRestaurantList(false);
              } else{
                await Get.find<RestaurantController>().getLatestRestaurantList(true, Get.find<RestaurantController>().type, false);
              }
            },
            child: SingleChildScrollView(controller: scrollController, child: FooterViewWidget(
              child: Column(
                children: [
                  WebScreenTitleWidget(title: 'restaurants'.tr),

                  Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Builder(
                      builder: (context) {
                        final restaurants = widget.isPopular
                            ? restController.popularRestaurantList
                            : widget.isRecentlyViewed
                                ? restController.recentlyViewedRestaurantList
                                : widget.isOrderAgain
                                    ? restController.orderAgainRestaurantList
                                    : restController.latestRestaurantList;

                        if (restaurants == null) {
                          return const RestaurantsCardShimmer();
                        } else if (restaurants.isEmpty) {
                          return NoDataScreen(isEmptyRestaurant: true, title: 'no_restaurant_available'.tr);
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: restaurants.length,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                                child: RestaurantsCardWidget(restaurant: restaurants[index]!),
                              );
                            },
                          );
                        }
                      },
                    ),
                  )),
                ],
              ),
            )),
          ),
        );
      }
    );
  }
}
