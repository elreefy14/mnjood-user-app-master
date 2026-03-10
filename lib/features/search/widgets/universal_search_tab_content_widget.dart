import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/no_data_screen_widget.dart' as no_data;
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:mnjood/features/search/controllers/search_controller.dart' as search;
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class UniversalSearchTabContentWidget extends StatelessWidget {
  final String businessType;
  final search.SearchController searchController;

  const UniversalSearchTabContentWidget({
    super.key,
    required this.businessType,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final vendors = searchController.getVendorResults(businessType);
    final products = searchController.getProductResults(businessType);

    bool hasVendors = vendors != null && vendors.isNotEmpty;
    bool hasProducts = products != null && products.isNotEmpty;

    if (!hasVendors && !hasProducts) {
      return no_data.NoDataScreen(
        title: 'no_results_found'.tr,
        isEmptySearchFood: true,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendors Section
          if (hasVendors) ...[
            _buildSectionHeader(
              context,
              _getVendorSectionTitle(businessType),
              vendors!.length,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildVendorsList(context, vendors),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],

          // Products Section
          if (hasProducts) ...[
            _buildSectionHeader(
              context,
              _getProductSectionTitle(businessType),
              products!.length,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildProductsGrid(context, products),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text(
            '$count ${'found'.tr}',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorsList(BuildContext context, List<Restaurant> vendors) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          return _buildVendorCard(context, vendors[index]);
        },
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, Restaurant vendor) {
    return InkWell(
      onTap: () => _navigateToVendor(vendor),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Logo
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
              child: CustomImageWidget(
                image: vendor.logoFullUrl ?? '',
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        HeroiconsSolid.star,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vendor.avgRating?.toStringAsFixed(1) ?? '0.0',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, products[index]);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    double price = product.price ?? 0;
    double discount = product.discount ?? 0;
    String discountType = product.discountType ?? 'percent';
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    return InkWell(
      onTap: () {
        // Open product bottom sheet
        Get.bottomSheet(
          ProductBottomSheetWidget(product: product, inRestaurantPage: false, businessType: businessType),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (top)
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusDefault),
                  topRight: Radius.circular(Dimensions.radiusDefault),
                ),
                child: CustomImageWidget(
                  image: product.imageFullUrl ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Product Info (bottom)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      product.name ?? '',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Price Row
                    Row(
                      children: [
                        // Discounted Price
                        Text(
                          PriceConverter.convertPrice(discountPrice),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Original Price (if discounted)
                        if (discount > 0)
                          Text(
                            PriceConverter.convertPrice(price),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
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

  void _navigateToVendor(Restaurant vendor) {
    String route = RouteHelper.getVendorRoute(vendor.id, businessType: businessType);
    Get.toNamed(route);
  }

  String _getVendorSectionTitle(String type) {
    switch (type.toLowerCase()) {
      case 'coffee_shop':
        return 'coffee_shops'.tr;
      case 'supermarket':
        return 'supermarkets'.tr;
      case 'pharmacy':
        return 'pharmacies'.tr;
      default:
        return 'restaurants'.tr;
    }
  }

  String _getProductSectionTitle(String type) {
    switch (type.toLowerCase()) {
      case 'coffee_shop':
        return 'drinks'.tr;
      case 'supermarket':
        return 'products'.tr;
      case 'pharmacy':
        return 'medicines'.tr;
      default:
        return 'food'.tr;
    }
  }
}
