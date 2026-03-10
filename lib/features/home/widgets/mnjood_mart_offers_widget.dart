import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MnjoodMartOffersWidget extends StatelessWidget {
  const MnjoodMartOffersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      List<Product>? products = homeController.mnjoodMartProducts;

      // Filter for discounted products only
      List<Product>? discountedProducts = products
          ?.where((p) => (p.discount ?? 0) > 0)
          .toList();

      if (discountedProducts == null) {
        return const MnjoodMartOffersShimmer();
      }

      if (discountedProducts.isEmpty) {
        return const SizedBox();
      }

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context) ? 16 : 24,
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (no icon per design requirement)
            EnterpriseSectionHeaderWidget(
              title: 'special_offers'.tr,
              trailing: ArrowIconButtonWidget(onTap: () {
                Get.toNamed(RouteHelper.getBusinessCategoryRoute('supermarket'));
              }),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Grid with 4 items per row
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: discountedProducts.length > 8 ? 8 : discountedProducts.length,
              itemBuilder: (context, index) {
                return _MartOfferCard(product: discountedProducts[index]);
              },
            ),
          ],
        ),
      );
    });
  }
}

class _MartOfferCard extends StatelessWidget {
  final Product product;

  const _MartOfferCard({required this.product});

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    return CustomInkWellWidget(
      onTap: () {
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket'),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: 'supermarket')));
      },
      radius: 12,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CustomImageWidget(
                      image: product.imageFullUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      isFood: true,
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name ?? '',
                      style: robotoMedium.copyWith(fontSize: 10, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceConverter.convertPriceWithSvg(
                          discountPrice,
                          textStyle: robotoBold.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (discountPrice < price)
                          PriceConverter.convertPriceWithSvg(
                            price,
                            textStyle: robotoRegular.copyWith(
                              fontSize: 8,
                              color: Theme.of(context).hintColor,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Theme.of(context).hintColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MnjoodMartOffersShimmer extends StatelessWidget {
  const MnjoodMartOffersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            child: Container(
              height: 24,
              width: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
