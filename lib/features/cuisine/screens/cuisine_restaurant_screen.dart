import 'package:mnjood/features/cuisine/controllers/cuisine_controller.dart';
import 'package:mnjood/features/home/widgets/restaurants_card_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/paginated_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CuisineRestaurantScreen extends StatefulWidget {
  final int cuisineId;
  final String? name;
  const CuisineRestaurantScreen({super.key, required this.cuisineId, required this.name});

  @override
  State<CuisineRestaurantScreen> createState() => _CuisineRestaurantScreenState();
}

class _CuisineRestaurantScreenState extends State<CuisineRestaurantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().initialize();
    Get.find<CuisineController>().getCuisineRestaurantList(widget.cuisineId, 1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(title: '${widget.name ?? ''} ${'cuisine'.tr}'),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,

      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterViewWidget(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: GetBuilder<CuisineController>(builder: (cuisineController) {
                if(cuisineController.cuisineRestaurantsModel != null){}
                return PaginatedListViewWidget(
                  scrollController: _scrollController,
                  totalSize: cuisineController.cuisineRestaurantsModel?.totalSize,
                  offset: cuisineController.cuisineRestaurantsModel?.offset != null ? int.tryParse(cuisineController.cuisineRestaurantsModel!.offset!) ?? 1 : null,
                  onPaginate: (int? offset) async => await cuisineController.getCuisineRestaurantList(widget.cuisineId, offset!, false),
                  productView: Builder(
                    builder: (context) {
                      final restaurants = cuisineController.cuisineRestaurantsModel?.restaurants;

                      if (restaurants == null) {
                        return const RestaurantsCardShimmer();
                      } else if (restaurants.isEmpty) {
                        return NoDataScreen(isEmptyRestaurant: true, title: 'no_restaurant_available'.tr);
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: restaurants.length,
                          padding: EdgeInsets.only(
                            left: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                            right: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                            top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                            bottom: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                          ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                              child: RestaurantsCardWidget(restaurant: restaurants[index]),
                            );
                          },
                        );
                      }
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
