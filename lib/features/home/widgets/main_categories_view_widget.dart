import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/domain/models/main_category_model.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class MainCategoriesViewWidget extends StatelessWidget {
  const MainCategoriesViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      List<MainCategoryModel>? categories = homeController.mainCategoriesList;

      if (categories != null && categories.isEmpty) {
        return const SizedBox();
      }

      return Container(
        width: Dimensions.webMaxWidth,
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            categories != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: categories.map((category) {
                    return Expanded(
                      child: _CategoryCard(category: category),
                    );
                  }).toList(),
                )
              : const _MainCategoriesShimmer(),
          ],
        ),
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  final MainCategoryModel category;

  const _CategoryCard({required this.category});

  // Get colors based on category type
  List<Color> _getCategoryColors(String? slug) {
    switch (slug?.toLowerCase()) {
      case 'restaurant':
        return [const Color(0xFFDA281C), const Color(0xFFFFEBEE)];
      case 'supermarket':
        return [const Color(0xFF4ECDC4), const Color(0xFFE0F7FA)];
      case 'pharmacy':
        return [const Color(0xFF66BB6A), const Color(0xFFE8F5E9)];
      default:
        return [const Color(0xFFFF9800), const Color(0xFFFFF3E0)];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';
    String displayName = isArabic && category.nameAr != null && category.nameAr!.isNotEmpty
      ? category.nameAr!
      : category.name ?? '';

    double iconSize = ResponsiveHelper.isMobile(context) ? 72 : 88;
    List<Color> colors = _getCategoryColors(category.slug);

    return CustomInkWellWidget(
      onTap: () {
        Get.toNamed(RouteHelper.getBusinessCategoryRoute(category.slug ?? 'restaurant'));
      },
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium card with colored background
            Container(
              height: iconSize,
              width: iconSize,
              decoration: BoxDecoration(
                color: colors[1],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors[0].withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: category.imageFullUrl != null && category.imageFullUrl!.isNotEmpty
                  ? CustomImageWidget(
                      image: category.imageFullUrl!,
                      fit: BoxFit.cover,
                      height: iconSize,
                      width: iconSize,
                    )
                  : Container(
                      height: iconSize,
                      width: iconSize,
                      color: colors[1],
                      child: Icon(
                        HeroiconsOutline.squares2x2,
                        size: iconSize * 0.4,
                        color: colors[0],
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 10),
            // Category name
            Text(
              displayName,
              style: robotoMedium.copyWith(
                fontSize: 12,
                color: const Color(0xFF495057),
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCategoriesShimmer extends StatelessWidget {
  const _MainCategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    double iconSize = ResponsiveHelper.isMobile(context) ? 72 : 88;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: iconSize,
                  width: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Shimmer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 300],
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 14,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Shimmer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
