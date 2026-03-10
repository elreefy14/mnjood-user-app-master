import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class WhatOnYourMindViewWidget extends StatelessWidget {
  const WhatOnYourMindViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final categories = homeController.restaurantCategories;
      bool isArabic = Get.find<LocalizationController>().isLtr == false;

      return categories != null && categories.isNotEmpty ? Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enterprise section header
            ResponsiveHelper.isDesktop(context)
              ? Text('what_on_your_mind'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))
              : EnterpriseSectionHeaderWidget(
                  icon: HeroiconsSolid.lightBulb,
                  title: 'what_on_your_mind'.tr,
                  trailing: ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getCategoryRoute(businessType: 'restaurant'))),
                ),

            const SizedBox(height: 16),

            SizedBox(
              height: ResponsiveHelper.isMobile(context) ? 120 : 170,
              child: ListView.builder(
                physics: ResponsiveHelper.isMobile(context) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  // Use Arabic name if available and locale is Arabic
                  String displayName = isArabic && category.nameAr != null && category.nameAr!.isNotEmpty
                    ? category.nameAr!
                    : category.name ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                    child: CustomInkWellWidget(
                      onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                        category.id!, category.name!,
                      )),
                      radius: Dimensions.radiusDefault,
                      child: SizedBox(
                        width: ResponsiveHelper.isMobile(context) ? 80 : 110,
                        child: Column(
                          children: [
                            Container(
                              height: ResponsiveHelper.isMobile(context) ? 70 : 90,
                              width: ResponsiveHelper.isMobile(context) ? 70 : 90,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    spreadRadius: 0,
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: CustomImageWidget(
                                  image: category.imageFullUrl ?? '',
                                  height: ResponsiveHelper.isMobile(context) ? 70 : 90,
                                  width: ResponsiveHelper.isMobile(context) ? 70 : 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Text(
                                displayName,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ) : const WhatOnYourMindShimmer();
    });
  }
}

class WhatOnYourMindShimmer extends StatelessWidget {
  const WhatOnYourMindShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 20,
                width: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 120 : 170,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 7,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                  child: SizedBox(
                    width: ResponsiveHelper.isMobile(context) ? 80 : 110,
                    child: Column(
                      children: [
                        Shimmer(
                          child: Container(
                            height: ResponsiveHelper.isMobile(context) ? 70 : 90,
                            width: ResponsiveHelper.isMobile(context) ? 70 : 90,
                            decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
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
          ),
        ],
      ),
    );
  }
}
