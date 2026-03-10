import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class ShopByCategoryWidget extends StatelessWidget {
  final int vendorId;
  const ShopByCategoryWidget({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<CategoryModel>? categories = restController.categoryList;

      // Hide widget if no categories or only "All" category
      if (categories != null && categories.length <= 1) {
        return const SizedBox();
      }

      // Filter out "All" category (id == 0)
      List<CategoryModel> displayCategories = categories != null
          ? categories.where((cat) => cat.id != 0).toList()
          : [];

      return Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: categories != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'shop_by_category'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.getVendorCategoryProductsRoute(vendorId, 0));
                    },
                    child: Text(
                      'view_all'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Horizontal slider of categories
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemCount: displayCategories.length,
                itemBuilder: (context, index) {
                  CategoryModel category = displayCategories[index];
                  return _buildCategoryItem(context, category);
                },
              ),
            ),
          ],
        ) : _buildShimmer(context),
      );
    });
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteHelper.getVendorCategoryProductsRoute(vendorId, category.id!));
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: SizedBox(
          width: 80,
          child: Column(
            children: [
              // Category Image
              Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    image: category.imageFullUrl ?? '',
                    fit: BoxFit.cover,
                    height: 65,
                    width: 65,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              // Category Name
              Expanded(
                child: Text(
                  category.name ?? '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  Shimmer(
                    child: Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Shimmer(
                    child: Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
