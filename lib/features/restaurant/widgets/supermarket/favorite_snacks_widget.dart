import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class FavoriteSnacksWidget extends StatelessWidget {
  final int vendorId;
  const FavoriteSnacksWidget({super.key, required this.vendorId});

  // Category ID for Chips & Crackers
  static const int snacksCategoryId = 125;

  bool _hasCategory(dynamic product, int categoryId) {
    // Check single categoryId
    if (product.categoryId == categoryId) return true;
    // Check categoryIds list
    if (product.categoryIds != null) {
      for (var cat in product.categoryIds!) {
        if (cat.id == categoryId.toString()) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      final products = restController.restaurantProducts;
      if (products == null || products.isEmpty) {
        return const SizedBox();
      }

      // Filter products for snacks category
      final snackProducts = products.where((p) =>
        _hasCategory(p, snacksCategoryId)
      ).toList();

      if (snackProducts.isEmpty) {
        return const SizedBox();
      }

      return Container(
        color: Colors.orange.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'favorite_snacks'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        'chips_and_crackers'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                  ArrowIconButtonWidget(onTap: () {
                    // Navigate to snacks category
                    Get.toNamed(RouteHelper.getVendorCategoryProductsRoute(vendorId, snacksCategoryId));
                  }),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(
              height: ResponsiveHelper.isDesktop(context) ? 307 : 305,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: snackProducts.length,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < snackProducts.length - 1 ? Dimensions.paddingSizeSmall : 0,
                    ),
                    child: ItemCardWidget(
                      product: snackProducts[index],
                      isBestItem: false,
                      width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                      inRestaurantPage: true,
                      businessType: 'supermarket',
                      vendorId: vendorId,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
