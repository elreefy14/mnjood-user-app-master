import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class CategoryPopUpWidget extends StatelessWidget {
  final HomeController homeController;
  const CategoryPopUpWidget({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final categoryList = homeController.restaurantCategories;

    return Center(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
              child:
              TitleWidget(title: 'categories'.tr),
            ),
            Expanded(
              child: SizedBox(
                height: 80,
                child: categoryList != null ? GridView.builder(
                  itemCount: categoryList.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.2,
                    crossAxisCount: GetPlatform.isDesktop ? 5 : 4,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                          categoryList[index].id, categoryList[index].name!,
                        )),
                        child: SizedBox(
                          width: 50,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50, width: 50,
                                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
                                  ),
                                  child: CustomImageWidget(
                                    image: '${categoryList[index].imageFullUrl}',
                                    height: 50, width: 50, fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  categoryList[index].name!,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                ),
                              ]),
                        ),
                      ),
                    );
                  },
                ) : CategoryShimmer(isLoading: categoryList == null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  final bool isLoading;
  const CategoryShimmer({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: isLoading,
              child: Column(children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                    height: 10, width: 50, color: Colors.grey[300]),
              ]),
            ),
          );
        },
      ),
    );
  }
}
