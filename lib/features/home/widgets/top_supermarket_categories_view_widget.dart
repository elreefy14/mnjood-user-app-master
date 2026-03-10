import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/category/controllers/category_controller.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class TopSupermarketCategoriesViewWidget extends StatelessWidget {
  const TopSupermarketCategoriesViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      List<CategoryModel>? categoryList =
          categoryController.topSupermarketCategories;

      return (categoryList != null && categoryList.isEmpty)
          ? const SizedBox()
          : Padding(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.isMobile(context)
                    ? Dimensions.paddingSizeDefault
                    : Dimensions.paddingSizeLarge,
              ),
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveHelper.isDesktop(context)
                        ? Padding(
                            padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeLarge),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'top_supermarket_categories'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ArrowIconButtonWidget(onTap: () {
                                  Get.toNamed(RouteHelper.getRestaurantRoute(12, businessType: 'supermarket')); // Navigate to Mnjood Mart
                                }),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeLarge,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'top_supermarket_categories'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ArrowIconButtonWidget(onTap: () {
                                  Get.toNamed(RouteHelper.getRestaurantRoute(12, businessType: 'supermarket')); // Navigate to Mnjood Mart
                                }),
                              ],
                            ),
                          ),
                    categoryList != null
                        ? SizedBox(
                            height: 130,
                            child: ListView.builder(
                              itemCount: categoryList.length,
                              padding: EdgeInsets.only(
                                left: ResponsiveHelper.isMobile(context)
                                    ? Dimensions.paddingSizeDefault
                                    : 0,
                                right: ResponsiveHelper.isMobile(context)
                                    ? Dimensions.paddingSizeDefault
                                    : 0,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: (ResponsiveHelper.isDesktop(context) &&
                                            index == 0 &&
                                            Get.find<LocalizationController>()
                                                .isLtr)
                                        ? 0
                                        : (index == 0 ? 0 : Dimensions.paddingSizeDefault),
                                  ),
                                  child: _CategoryCard(
                                    category: categoryList[index],
                                  ),
                                );
                              },
                            ),
                          )
                        : const TopSupermarketCategoriesShimmer(),
                  ],
                ),
              ),
            );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: () {
        Get.toNamed(RouteHelper.getCategoryProductRoute(
          category.id,
          category.name ?? '',
          businessType: 'supermarket',
        ));
      },
      radius: Dimensions.radiusDefault,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
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
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraSmall),
              child: Text(
                category.name ?? '',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopSupermarketCategoriesShimmer extends StatelessWidget {
  const TopSupermarketCategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeDefault
              : 0,
          right: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeDefault
              : 0,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
                left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).shadowColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color:
                        Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                    shape: BoxShape.circle,
                  ),
                  child: Shimmer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[Get.find<ThemeController>().darkTheme ? 600 : 300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Shimmer(
                    child: Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
