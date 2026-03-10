import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood/common/widgets/custom_distance_cliper_widget.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/paginated_list_view_widget.dart';
import 'package:mnjood/features/dine_in/controllers/dine_in_controller.dart';
import 'package:mnjood/features/dine_in/widgets/dine_in_restaurant_filter_bottom_sheet.dart';
import 'package:mnjood/features/dine_in/widgets/dine_in_restaurant_shimmer_widget.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class DineInRestaurantScreen extends StatefulWidget {
  const DineInRestaurantScreen({super.key});

  @override
  State<DineInRestaurantScreen> createState() => _DineInRestaurantScreenState();
}

class _DineInRestaurantScreenState extends State<DineInRestaurantScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<DineInController>().initSetup(willUpdate: false);
    Get.find<DineInController>().getDineInRestaurantList(1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'restaurant_list'.tr,
        actions: [
          IconButton(
            onPressed: () {
              showCustomBottomSheet(child: const DineRestaurantFilterBottomSheet());
            },
            icon: Icon(HeroiconsOutline.funnel, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      floatingActionButton: ResponsiveHelper.isDesktop(context) ? null : Align(
        alignment: ResponsiveHelper.isDesktop(context) ? Alignment.bottomRight : Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            onPressed: () {
              Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true));
            },
            label: Row(children: [

              Icon(HeroiconsSolid.map, color: Colors.white, size: 22),
              SizedBox(width: Dimensions.paddingSizeSmall),

              Text('view_from_map'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),

            ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterViewWidget(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(height: Dimensions.paddingSizeSmall),

                  ResponsiveHelper.isDesktop(context) ? Container(
                    height: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Text(
                        'restaurant_list'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                      ),

                      Spacer(),

                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true)),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          // alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                            Icon(HeroiconsSolid.map, color: Colors.white, size: 20),
                            SizedBox(width: Dimensions.paddingSizeSmall),

                            Text('view_from_map'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),

                          ]),
                        ),
                      ),

                      SizedBox(width: Dimensions.paddingSizeSmall),

                      InkWell(
                        onTap: () {
                          Get.dialog(Dialog(child: const DineRestaurantFilterBottomSheet()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).primaryColor),
                            color: Theme.of(context).cardColor,
                          ),
                          padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: Icon(HeroiconsOutline.funnel, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ]),
                  ) : const SizedBox(),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                  GetBuilder<DineInController>(builder: (dineInController) {
                    return dineInController.dineInModel != null
                        ? (dineInController.dineInModel!.restaurants != null &&
                           dineInController.dineInModel!.restaurants!.isNotEmpty)
                            ? PaginatedListViewWidget(
                                scrollController: _scrollController,
                                totalSize: dineInController.dineInModel?.totalSize ?? 0,
                                offset: dineInController.dineInModel?.offset ?? 1,
                                onPaginate: (int? offset) async => await dineInController.getDineInRestaurantList(offset ?? 1, false),
                                productView: dineInRestaurant(dineInController.dineInModel!.restaurants!),
                              )
                            : Center(child: Padding(
                                padding: EdgeInsets.only(top: context.height * 0.3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                    Text('there_is_no_restaurant'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                                  ],
                                ),
                              ))
                        : DineInRestaurantShimmerWidget();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dineInRestaurant(List<Restaurant> restaurants) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: restaurants.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 200,
      ),
      padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.only(left: 16, right: 16, bottom: 100),
      itemBuilder: (context, index) {

        Restaurant restaurant = restaurants[index];
        bool isAvailable = restaurant.open == 1 && (restaurant.active ?? false);
        double distance = Get.find<RestaurantController>().getRestaurantDistance(
          LatLng(double.parse(restaurant.latitude ?? '0'), double.parse(restaurant.longitude ?? '0')),
        );

        // Build characteristics string
        String characteristics = '';
        if (restaurant.characteristics != null) {
          for (var v in restaurant.characteristics!) {
            characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
          }
        }

        return CustomInkWellWidget(
          onTap: () {
            RouteHelper.navigateToStoreOrShowClosedDialog(restaurant, context, fromDinIn: true);
          },
          radius: 16,
          child: Container(
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
                        image: '${restaurant.coverPhotoFullUrl}',
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                        isRestaurant: true,
                      ),
                    ),

                    // Dine-in badge
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(HeroiconsSolid.buildingStorefront, size: 10, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'dine_in'.tr,
                              style: robotoMedium.copyWith(color: Colors.white, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rating badge
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
                              (restaurant.avgRating ?? 0).toStringAsFixed(1),
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
                          bool isWished = favController.wishRestIdList.contains(restaurant.id);
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: CustomFavouriteWidget(
                              isWished: isWished,
                              isRestaurant: true,
                              restaurant: restaurant,
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
                            image: '${restaurant.logoFullUrl}',
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
                          restaurant.name ?? '',
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
                      // Rating
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        (restaurant.avgRating ?? 0).toStringAsFixed(1),
                        style: robotoMedium.copyWith(fontSize: 11),
                      ),
                      const Spacer(),
                      // Delivery time
                      Icon(HeroiconsOutline.clock, size: 14, color: Theme.of(context).hintColor),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${restaurant.deliveryTime}',
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
        );
      },
    );
  }
}
