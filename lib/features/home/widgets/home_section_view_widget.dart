import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/custom_favourite_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/enterprise_section_header_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/domain/models/home_section_model.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class HomeSectionViewWidget extends StatelessWidget {
  final HomeSectionModel section;
  const HomeSectionViewWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final hasProducts = section.products != null && section.products!.isNotEmpty;
    final hasVendors = section.vendors != null && section.vendors!.isNotEmpty;
    if (!hasProducts && !hasVendors) return const SizedBox();

    // Get localized title
    final isArabic = Get.find<LocalizationController>().locale.languageCode == 'ar';
    final title = isArabic ? (section.titleAr ?? section.titleEn ?? '') : (section.titleEn ?? '');

    // Parse badge color
    Color badgeColor = const Color(0xFFDA281C);
    if (section.badgeColor != null && section.badgeColor!.isNotEmpty) {
      try {
        String hex = section.badgeColor!.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        badgeColor = Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.isMobile(context) ? 8 : 24,
        horizontal: ResponsiveHelper.isMobile(context) ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EnterpriseSectionHeaderWidget(
            title: title,
            trailing: ArrowIconButtonWidget(onTap: () {
              // Product sections are mart/supermarket; vendor sections fall back to restaurant
              final type = section.businessType ?? (hasProducts ? 'supermarket' : 'restaurant');
              Get.toNamed(RouteHelper.getBusinessCategoryRoute(type));
            }),
          ),
          const SizedBox(height: 12),

          // Products take priority for mart sections
          if (hasProducts)
            _buildProductGrid(context, section.products!)
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: section.vendors!.length > 8 ? 8 : section.vendors!.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildVendorCard(context, section.vendors![index], badgeColor);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    final businessType = section.businessType ?? 'supermarket';
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length > 8 ? 8 : products.length,
      itemBuilder: (context, index) {
        return _SectionProductCard(product: products[index], businessType: businessType);
      },
    );
  }

  Widget _buildVendorCard(BuildContext context, Restaurant vendor, Color badgeColor) {
    // open==null means API didn't provide status — treat as available; open==0 means closed
    bool isAvailable = (vendor.open ?? 1) == 1 && (vendor.active ?? true);
    double distance = 0;
    if (vendor.latitude != null && vendor.longitude != null) {
      try {
        distance = Get.find<RestaurantController>().getRestaurantDistance(
          LatLng(double.parse(vendor.latitude!), double.parse(vendor.longitude!)),
        );
      } catch (_) {}
    }

    String characteristics = '';
    if (vendor.characteristics != null) {
      for (var v in vendor.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    // Determine badge label from business type (fall back to vendor's own type)
    String badgeLabel;
    switch (section.businessType ?? vendor.businessType) {
      case 'pharmacy':
        badgeLabel = 'pharmacy'.tr;
        break;
      case 'coffee_shop':
        badgeLabel = 'coffee_shop'.tr;
        break;
      case 'supermarket':
        badgeLabel = 'supermarket'.tr;
        break;
      default:
        badgeLabel = 'restaurant_singular'.tr;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CustomInkWellWidget(
        onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(vendor, context, businessType: section.businessType ?? vendor.businessType ?? 'restaurant'),
        radius: 16,
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CustomImageWidget(
                      image: '${vendor.coverPhotoFullUrl}',
                      fit: BoxFit.cover,
                      height: 100,
                      width: double.infinity,
                      isRestaurant: true,
                    ),
                  ),

                  // Business type badge
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(HeroiconsSolid.buildingStorefront, size: 10, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            badgeLabel,
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rating badge
                  PositionedDirectional(
                    top: 8,
                    end: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            (vendor.avgRating ?? 0).toStringAsFixed(1),
                            style: robotoMedium.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favourite button
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: GetBuilder<FavouriteController>(
                      builder: (favController) {
                        bool isWished = favController.wishRestIdList.contains(vendor.id);
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: CustomFavouriteWidget(
                            isWished: isWished,
                            isRestaurant: true,
                            restaurant: vendor,
                          ),
                        );
                      },
                    ),
                  ),

                  // Closed overlay
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'closed_now'.tr,
                              style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Logo
                  PositionedDirectional(
                    bottom: -25,
                    start: 12,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).cardColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: CustomImageWidget(
                          image: '${vendor.logoFullUrl}',
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                          isRestaurant: true,
                        ),
                      ),
                    ),
                  ),

                  // Distance badge
                  PositionedDirectional(
                    bottom: 8,
                    end: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} ${'km'.tr}',
                        style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),

              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vendor.name ?? '',
                        style: robotoBold.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (characteristics.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          characteristics,
                          style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom info row
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      (vendor.avgRating ?? 0).toStringAsFixed(1),
                      style: robotoMedium.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    if (vendor.freeDelivery ?? false) ...[
                      Icon(HeroiconsOutline.truck, size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 2),
                      Text(
                        'free'.tr,
                        style: robotoMedium.copyWith(fontSize: 11, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Icon(HeroiconsOutline.clock, size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${vendor.deliveryTime}',
                        style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact product card for section product grids — mirrors _MartCardCompact from MnjoodMartCarouselWidget
class _SectionProductCard extends StatelessWidget {
  final Product product;
  final String businessType;

  const _SectionProductCard({required this.product, required this.businessType});

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
                ProductBottomSheetWidget(product: product, isCampaign: false, businessType: businessType),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: businessType)));
      },
      radius: 12,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CustomImageWidget(
                  image: product.imageFullUrl ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  isFood: true,
                ),
              ),
            ),
            // Info section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
