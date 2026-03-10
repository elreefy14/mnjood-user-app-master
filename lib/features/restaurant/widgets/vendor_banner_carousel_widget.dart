import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/restaurant/domain/models/vendor_banner_model.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class VendorBannerCarouselWidget extends StatelessWidget {
  final int vendorId;
  const VendorBannerCarouselWidget({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<VendorBannerModel>? banners = restController.vendorBanners;

      // Hide widget when list is empty
      if (banners != null && banners.isEmpty) {
        return const SizedBox();
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: banners != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text(
                'special_offers'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 2.5,
                enlargeFactor: 0.2,
                autoPlay: banners.length > 1,
                enlargeCenterPage: true,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, reason) {
                  restController.setVendorBannerIndex(index, true);
                },
              ),
              itemCount: banners.isEmpty ? 1 : banners.length,
              itemBuilder: (context, index, _) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleBannerTap(context, banners[index], vendorId),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomImageWidget(
                            image: banners[index].imageFullUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                          // Gradient overlay for text visibility
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (banners[index].title != null)
                                    Text(
                                      banners[index].title!,
                                      style: robotoBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (banners[index].discountValue != null && banners[index].discountValue! > 0)
                                    Text(
                                      _getDiscountText(banners[index]),
                                      style: robotoMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            if (banners.length > 1) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: banners.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: index == restController.vendorBannerIndex
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            child: Text(
                              '${index + 1}/${banners.length}',
                              style: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
                            ),
                          )
                        : Container(
                            height: 4.18,
                            width: 5.57,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                          ),
                  );
                }).toList(),
              ),
            ],
          ],
        ) : _buildShimmer(context),
      );
    });
  }

  String _getDiscountText(VendorBannerModel banner) {
    if (banner.discountType == 'percent') {
      return '${banner.discountValue?.toInt()}% OFF';
    } else if (banner.discountType == 'amount') {
      return '${banner.discountValue?.toInt()} OFF';
    } else if (banner.discountType == 'bogo') {
      return 'Buy & Get Free';
    }
    return '';
  }

  void _handleBannerTap(BuildContext context, VendorBannerModel banner, int vendorId) async {
    if (banner.productId != null) {
      // Navigate to product
      Get.find<ProductController>().getProductDetails(banner.productId!, null, isCampaign: false);
      ResponsiveHelper.isMobile(context)
          ? showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (con) => ProductBottomSheetWidget(
                product: null,
                isCampaign: false,
              ),
            )
          : showDialog(
              context: context,
              builder: (con) => Dialog(
                child: ProductBottomSheetWidget(
                  product: null,
                  isCampaign: false,
                ),
              ),
            );
    } else if (banner.categoryId != null) {
      // Navigate to category products page
      Get.toNamed(
        RouteHelper.getVendorCategoryProductsRoute(vendorId, banner.categoryId!),
      );
    }
  }

  Widget _buildShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Shimmer(
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).shadowColor,
            ),
          ),
        ),
      ),
    );
  }
}
