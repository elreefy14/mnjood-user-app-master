import 'package:carousel_slider/carousel_slider.dart';
import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class PopularFoodNearbyViewWidget extends StatefulWidget {
  const PopularFoodNearbyViewWidget({super.key});

  @override
  State<PopularFoodNearbyViewWidget> createState() => _PopularFoodNearbyViewWidgetState();
}

class _PopularFoodNearbyViewWidgetState extends State<PopularFoodNearbyViewWidget> {

  CarouselSliderController carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (productController) {
        return (productController.popularProductList !=null && productController.popularProductList!.isEmpty) ? const SizedBox() : Container(
          margin: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
            horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
          ),
          child: SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 360 : 375, width: Dimensions.webMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enterprise section header
                ResponsiveHelper.isDesktop(context)
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 45),
                      child: Text('popular_foods_nearby'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    )
                  : EnterpriseSectionHeaderWidget(
                      icon: HeroiconsSolid.fire,
                      
                      
                      title: 'popular_foods_nearby'.tr,
                      trailing: ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(true))),
                    ),

                SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),

                Row(children: [
                    ResponsiveHelper.isDesktop(context) ? ArrowIconButtonWidget(
                      isLeft: true,
                      onTap: ()=> carouselController.previousPage(),
                    ) : const SizedBox(),

                    productController.popularProductList != null ? Expanded(
                      child: CarouselSlider.builder(
                        carouselController: carouselController,
                        options: CarouselOptions(
                          height: ResponsiveHelper.isMobile(context) ? 300 : 300,
                          viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.47,
                          enlargeFactor: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.35,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          disableCenter: true,
                        ),
                        itemCount: productController.popularProductList!.length,
                        itemBuilder: (context, index, _) {

                          return productController.popularProductList != null ? ItemCardWidget(
                            product: productController.popularProductList![index],
                            isBestItem: true,
                            isPopularNearbyItem: true,
                          ) : const ItemCardShimmer(isPopularNearbyItem: true);
                        },
                      ),
                    ) : const ItemCardShimmer(isPopularNearbyItem: true),

                    ResponsiveHelper.isDesktop(context) ? ArrowIconButtonWidget(
                      onTap: () => carouselController.nextPage(),
                    ) : const SizedBox(),
                  ],
                ),

             ],
            )
          ),
        );
      }
    );
  }
}
