import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class SupermarketProductsWidget extends StatelessWidget {
  const SupermarketProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final products = homeController.mnjoodMartProducts;
      final hasMore = homeController.mnjoodMartHasMore;
      final isLoading = homeController.mnjoodMartLoading;

      if (products == null) {
        return const _ProductsShimmer();
      }

      if (products.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Text(
              'no_products_available'.tr,
              style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              'all_products'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
              childAspectRatio: 2.5,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ItemCardWidget(
                product: products[index],
                isBestItem: false,
                isPopularNearbyItem: false,
                width: double.infinity,
                businessType: 'supermarket',
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Load More Button
          if (hasMore)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    homeController.loadMoreMnjoodMartProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'load_more'.tr,
                          style: robotoMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                ),
              ),
            ),

          const SizedBox(height: Dimensions.paddingSizeOverLarge),
        ],
      );
    });
  }
}

class _ProductsShimmer extends StatelessWidget {
  const _ProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: Dimensions.paddingSizeDefault,
            mainAxisSpacing: Dimensions.paddingSizeDefault,
            childAspectRatio: 2.5,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
