import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/restaurant/domain/models/vendor_banner_model.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class MidPageOffersWidget extends StatefulWidget {
  final int vendorId;
  const MidPageOffersWidget({super.key, required this.vendorId});

  @override
  State<MidPageOffersWidget> createState() => _MidPageOffersWidgetState();
}

class _MidPageOffersWidgetState extends State<MidPageOffersWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<VendorBannerModel>? banners = restController.vendorBanners;

      // Filter only offer banners (those with discounts)
      List<VendorBannerModel>? offerBanners = banners?.where((b) {
        return (b.discountValue ?? 0) > 0;
      }).toList();

      // Hide widget if no offer banners
      if (offerBanners == null || offerBanners.isEmpty) {
        return const SizedBox();
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: const Icon(HeroiconsOutline.tag, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'hot_deals'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 2.8,
                enlargeFactor: 0.15,
                autoPlay: offerBanners.length > 1,
                enlargeCenterPage: true,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 4),
                viewportFraction: 0.9,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemCount: offerBanners.length,
              itemBuilder: (context, index, _) {
                VendorBannerModel banner = offerBanners[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleBannerTap(context, banner, widget.vendorId),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomImageWidget(
                            image: banner.imageFullUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                          // Discount badge
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Text(
                                _getDiscountText(banner),
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                          // Title overlay
                          if (banner.title != null)
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
                                child: Text(
                                  banner.title!,
                                  style: robotoBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

            // Page indicators
            if (offerBanners.length > 1) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: offerBanners.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.red
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _getDiscountText(VendorBannerModel banner) {
    if (banner.discountType == 'percent') {
      return '${banner.discountValue?.toInt()}% OFF';
    } else if (banner.discountType == 'amount') {
      return '\$${banner.discountValue?.toInt()} OFF';
    } else if (banner.discountType == 'bogo') {
      return 'Buy 1 Get 1';
    }
    return 'OFFER';
  }

  void _handleBannerTap(BuildContext context, VendorBannerModel banner, int vendorId) {
    if (banner.productId != null) {
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
      Get.toNamed(
        RouteHelper.getVendorCategoryProductsRoute(vendorId, banner.categoryId!),
      );
    }
  }
}
