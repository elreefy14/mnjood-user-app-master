import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/review/controllers/review_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class BestReviewItemViewWidget extends StatelessWidget {
  final bool isPopular;
  const BestReviewItemViewWidget({super.key, required this.isPopular});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
        return (reviewController.reviewedProductList !=null && reviewController.reviewedProductList!.isEmpty) ? const SizedBox() : Container(
          margin: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
            horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
          ),
          child: SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 340 : 355, width: Dimensions.webMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Enterprise section header
                ResponsiveHelper.isDesktop(context)
                  ? Row(children: [
                      Text('best_reviewed_food'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const Spacer(),
                      ArrowIconButtonWidget(
                        onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(isPopular)),
                      ),
                    ])
                  : EnterpriseSectionHeaderWidget(
                      icon: HeroiconsSolid.star,
                      
                      
                      title: 'best_reviewed_food'.tr,
                      trailing: ArrowIconButtonWidget(
                        onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(isPopular)),
                      ),
                    ),
                const SizedBox(height: Dimensions.paddingSizeDefault),


               reviewController.reviewedProductList != null ? Expanded(
                  child: SizedBox(
                    height: ResponsiveHelper.isMobile(context) ? 240 : 255,
                    child: ListView.builder(
                      itemCount: reviewController.reviewedProductList!.length,
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : 0,
                            right: Dimensions.paddingSizeDefault,
                          ),
                          child: ItemCardWidget(
                            isBestItem: true,
                            product: reviewController.reviewedProductList![index],
                            width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                          ),
                        );
                      },
                    ),
                  ),
                ) : const ItemCardShimmer(isPopularNearbyItem: false),
              ],
            ),

          ),
        );
      }
    );
  }
}
