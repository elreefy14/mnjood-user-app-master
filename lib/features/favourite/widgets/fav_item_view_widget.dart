import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/home/widgets/restaurants_card_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavItemViewWidget extends StatelessWidget {
  final bool isRestaurant;
  const FavItemViewWidget({super.key, required this.isRestaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FavouriteController>(builder: (favouriteController) {
        return RefreshIndicator(
          onRefresh: () async {
            await favouriteController.getFavouriteList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterViewWidget(
              child: Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: isRestaurant
                  ? Builder(
                      builder: (context) {
                        final restaurants = favouriteController.wishRestList;

                        if (restaurants == null) {
                          return const RestaurantsCardShimmer();
                        } else if (restaurants.isEmpty) {
                          return NoDataScreen(isEmptyRestaurant: true, title: 'you_have_not_add_any_restaurant_to_wishlist'.tr);
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
                    )
                  : Builder(
                      builder: (context) {
                        final products = favouriteController.wishProductList;

                        if (products == null) {
                          return const ItemCardShimmer();
                        } else if (products.isEmpty) {
                          return NoDataScreen(
                            isEmptyWishlist: true,
                            title: 'you_have_not_add_any_food_to_wishlist'.tr,
                          );
                        } else {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.72 : 0.68,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              if (product == null) return const SizedBox();
                              return ItemCardWidget(
                                product: product,
                                width: double.infinity,
                                vendorId: product.restaurantId,
                              );
                            },
                          );
                        }
                      },
                    ),
              )),
            ),
          ),
        );
      }),
    );
  }
}
