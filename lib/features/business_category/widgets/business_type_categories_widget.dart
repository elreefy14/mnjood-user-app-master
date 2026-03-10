import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
// ArrowIconButtonWidget import removed - no longer needed in this file
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

// Helper to check if business type is supermarket/mnjood mart
bool _isSupermarketType(String businessType) {
  final type = businessType.toLowerCase();
  return type == 'supermarket' || type == 'mnjood_mart' || type == 'mnjood mart' || type.contains('supermarket');
}

class BusinessTypeCategoriesWidget extends StatelessWidget {
  final String businessType;
  const BusinessTypeCategoriesWidget({super.key, required this.businessType});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final categories = homeController.getCategoriesForBusinessType(businessType);
      bool isArabic = Get.find<LocalizationController>().isLtr == false;

      if (categories == null) {
        return const BusinessTypeCategoriesShimmer();
      }
      if (categories.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title removed per design requirement - only show horizontal scroll of category icons

          SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 80 : 100,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: 10),
                  child: CustomInkWellWidget(
                    onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                      category.id!, category.name!,
                      businessType: businessType,
                    )),
                    radius: 12,
                    child: Container(
                      height: ResponsiveHelper.isMobile(context) ? 70 : 90,
                      width: ResponsiveHelper.isMobile(context) ? 70 : 90,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          image: category.imageFullUrl ?? '',
                          height: ResponsiveHelper.isMobile(context) ? 70 : 90,
                          width: ResponsiveHelper.isMobile(context) ? 70 : 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      );
    });
  }
}

class BusinessTypeCategoriesShimmer extends StatelessWidget {
  const BusinessTypeCategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isMobile(context) ? 80 : 100,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 5,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Shimmer(
              child: Container(
                height: ResponsiveHelper.isMobile(context) ? 70 : 90,
                width: ResponsiveHelper.isMobile(context) ? 70 : 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
