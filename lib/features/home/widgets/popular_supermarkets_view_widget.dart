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

class PopularSupermarketsViewWidget extends StatelessWidget {
  const PopularSupermarketsViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? supermarketList = restController.popularRestaurantList?.where((r) =>
          r.businessType == 'supermarket' || r.businessType == 'grocery' || r.businessType == 'mart'
        ).toList();

      return (supermarketList == null || supermarketList.isEmpty) ? const SizedBox() : Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            EnterpriseSectionHeaderWidget(
              icon: HeroiconsSolid.shoppingCart,
              title: 'popular_supermarkets'.tr,
              trailing: ArrowIconButtonWidget(onTap: () {
                Get.toNamed(RouteHelper.getAllRestaurantRoute('popular'));
              }),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Compact vertical cards
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: supermarketList.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final isFirst = index == 0;
                  final isLast = index == supermarketList.length - 1;
                  return _buildSupermarketCard(context, supermarketList[index], restController, isFirst, isLast);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSupermarketCard(BuildContext context, Restaurant supermarket, RestaurantController restController, bool isFirst, bool isLast) {
    bool isAvailable = supermarket.open == 1 && (supermarket.active ?? false);
    double distance = 0;
    if (supermarket.latitude != null && supermarket.longitude != null) {
      distance = restController.getRestaurantDistance(
        LatLng(double.parse(supermarket.latitude!), double.parse(supermarket.longitude!)),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 0 : 8,
        right: isLast ? 0 : 8,
      ),
      child: CustomInkWellWidget(
        onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(supermarket, context, businessType: 'supermarket'),
        radius: 16,
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image section with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover/Logo image
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CustomImageWidget(
                        image: '${supermarket.coverPhotoFullUrl}',
                        fit: BoxFit.cover,
                        height: 90,
                        width: double.infinity,
                        isRestaurant: true,
                      ),
                    ),
                  ),

                  // Mart badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(HeroiconsSolid.shoppingCart, size: 10, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Mart',
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 9),
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
                      builder: (favController) {
                        bool isWished = favController.wishRestIdList.contains(supermarket.id);
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: CustomFavouriteWidget(
                            isWished: isWished,
                            isRestaurant: true,
                            restaurant: supermarket,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'closed'.tr,
                              style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Logo overlay at bottom
                  Positioned(
                    bottom: -20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: 45,
                        width: 45,
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
                            image: '${supermarket.logoFullUrl}',
                            fit: BoxFit.cover,
                            height: 45,
                            width: 45,
                            isRestaurant: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        supermarket.name ?? '',
                        style: robotoBold.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Info row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(HeroiconsOutline.mapPin, size: 12, color: Theme.of(context).hintColor),
                          const SizedBox(width: 2),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(width: 8),
                          Icon(HeroiconsOutline.clock, size: 12, color: Theme.of(context).hintColor),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${supermarket.deliveryTime}',
                              style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
                              overflow: TextOverflow.ellipsis,
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
  }
}
