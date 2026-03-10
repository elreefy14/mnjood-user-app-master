import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/features/cuisine/controllers/cuisine_controller.dart';
import 'package:mnjood/features/home/controllers/advertisement_controller.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/widgets/cuisine_view_widget.dart';
import 'package:mnjood/features/home/widgets/highlight_widget_view.dart';
import 'package:mnjood/features/home/widgets/today_trends_view_widget.dart';
import 'package:mnjood/features/business_category/widgets/business_type_categories_widget.dart';
import 'package:mnjood/features/business_category/widgets/business_type_shops_widget.dart';
import 'package:mnjood/features/business_category/widgets/supermarket_products_widget.dart';
import 'package:mnjood/features/business_category/screens/restaurant_category_screen.dart';
import 'package:mnjood/features/business_category/screens/pharmacy_category_screen.dart';
import 'package:mnjood/features/business_category/screens/coffee_shop_category_screen.dart';
import 'package:mnjood/features/business_category/screens/supermarket_category_screen.dart';
import 'package:mnjood/features/product/controllers/campaign_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/review/controllers/review_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class BusinessCategoryScreen extends StatefulWidget {
  final String businessType;
  const BusinessCategoryScreen({super.key, required this.businessType});

  @override
  State<BusinessCategoryScreen> createState() => _BusinessCategoryScreenState();
}

class _BusinessCategoryScreenState extends State<BusinessCategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  // Check if this is a supermarket/mnjood mart type
  bool get _isSupermarket {
    final type = widget.businessType.toLowerCase();
    return type == 'supermarket' || type == 'mnjood_mart' || type == 'mnjood mart' || type.contains('supermarket');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Dedicated screens handle their own data loading — skip parent API calls
    // to avoid race conditions where V3 calls overwrite V1 data.
    final type = widget.businessType.toLowerCase();
    if (type == 'restaurant' || type == 'food' ||
        type == 'pharmacy' ||
        type == 'coffee_shop' || type == 'coffee-shop' || type == 'coffee shop' || type == 'coffeeshop' ||
        type == 'supermarket' || type == 'mnjood_mart' || type == 'mnjood mart' || type.contains('supermarket')) {
      return;
    }

    final restaurantController = Get.find<RestaurantController>();
    final campaignController = Get.find<CampaignController>();
    final advertisementController = Get.find<AdvertisementController>();
    final splashController = Get.find<SplashController>();
    final homeController = Get.find<HomeController>();

    // Set business type and reload data
    restaurantController.setBusinessType(widget.businessType, reload: false);

    // Load categories for this business type
    homeController.getBusinessTypeCategories(widget.businessType, dataSource: DataSourceEnum.client, fromRecall: true);

    // Load campaigns/trends for specific business type
    campaignController.getItemCampaignList(true, businessType: widget.businessType);

    // Load highlights/advertisements for specific business type
    advertisementController.getAdvertisementList(businessType: widget.businessType);

    // Load popular vendors
    if (splashController.configModel!.popularRestaurant == 1) {
      restaurantController.getPopularRestaurantList(true, widget.businessType, false);
    }

    // Load popular foods
    if (splashController.configModel!.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(true, widget.businessType, false);
    }

    // Load latest vendors
    if (splashController.configModel!.newRestaurant == 1) {
      restaurantController.getLatestRestaurantList(true, widget.businessType, false);
    }

    // Load reviewed items
    if (splashController.configModel!.mostReviewedFoods == 1) {
      Get.find<ReviewController>().getReviewedProductList(true, widget.businessType, false);
    }
  }

  String _getTitle() {
    if (_isSupermarket) {
      return 'Mnjood Mart';
    }
    switch (widget.businessType.toLowerCase()) {
      case 'restaurant':
        return 'restaurants'.tr;
      case 'pharmacy':
        return 'pharmacies'.tr;
      case 'coffee_shop':
        return 'coffee_shops'.tr;
      default:
        return 'restaurants'.tr;
    }
  }

  String _getSearchHint() {
    if (_isSupermarket) {
      return 'search_products'.tr;
    }
    switch (widget.businessType.toLowerCase()) {
      case 'restaurant':
        return 'search_food_or_restaurant'.tr;
      case 'pharmacy':
        return 'search_medicines'.tr;
      case 'coffee_shop':
        return 'search_coffee'.tr;
      default:
        return 'search_food_or_restaurant'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Route to tailored screens for specific business types
    final type = widget.businessType.toLowerCase();

    // Restaurant - tailored screen
    if (type == 'restaurant' || type == 'food') {
      return const RestaurantCategoryScreen();
    }

    // Pharmacy - tailored screen
    if (type == 'pharmacy') {
      return const PharmacyCategoryScreen();
    }

    // Coffee Shop - tailored screen (API slug is 'coffee-shop', code uses 'coffee_shop')
    if (type == 'coffee_shop' || type == 'coffee-shop' || type == 'coffee shop' || type == 'coffeeshop') {
      return const CoffeeShopCategoryScreen();
    }

    // Supermarket / Mnjood Mart - tailored screen
    if (type == 'supermarket' || type == 'mnjood_mart' || type == 'mnjood mart' || type.contains('supermarket')) {
      return const SupermarketCategoryScreen();
    }

    // Default fallback layout
    return Scaffold(
      appBar: CustomAppBarWidget(title: _getTitle()),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getSearchRoute(businessType: widget.businessType)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall + 2,
                    ),
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
                    child: Row(
                      children: [
                        Icon(HeroiconsOutline.magnifyingGlass, color: Theme.of(context).hintColor),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          _getSearchHint(),
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // SUPERMARKET: Only Categories + Products
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories Section
                      BusinessTypeCategoriesWidget(businessType: widget.businessType),
                    ],
                  ),
                ),
              ),
            ),

            // Products Grid for Supermarket
            SliverToBoxAdapter(
              child: Center(
                child: FooterViewWidget(
                  child: Padding(
                    padding: ResponsiveHelper.isDesktop(context)
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(bottom: Dimensions.paddingSizeOverLarge),
                    child: const SupermarketProductsWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
