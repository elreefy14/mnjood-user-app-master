import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/common/widgets/bottom_cart_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/paginated_list_view_widget.dart';
import 'package:mnjood/common/widgets/product_view_widget.dart';
import 'package:mnjood/common/widgets/veg_filter_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/item_card_widget.dart';
import 'package:mnjood/features/home/widgets/pharmacy_item_card_widget.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/restaurant/widgets/shop_by_category_widget.dart';
import 'package:mnjood/features/restaurant/widgets/supermarket/favorite_snacks_widget.dart';
import 'package:mnjood/features/restaurant/widgets/supermarket/fresh_products_widget.dart';
import 'package:mnjood/features/restaurant/widgets/supermarket/mid_page_offers_widget.dart';
import 'package:mnjood/features/restaurant/widgets/supermarket/recently_reviewed_widget.dart';
import 'package:mnjood/features/restaurant/widgets/supermarket/top_products_widget.dart';
import 'package:mnjood/features/restaurant/widgets/vendor_banner_carousel_widget.dart';
import 'package:mnjood/features/restaurant/widgets/vendor_profile_card_widget.dart';
import 'package:mnjood/features/search/controllers/search_controller.dart' as search;
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class PharmacySupermarketLayoutWidget extends StatefulWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final bool fromDineIn;

  const PharmacySupermarketLayoutWidget({
    super.key,
    required this.restaurant,
    required this.restController,
    this.fromDineIn = false,
  });

  @override
  State<PharmacySupermarketLayoutWidget> createState() => _PharmacySupermarketLayoutWidgetState();
}

class _PharmacySupermarketLayoutWidgetState extends State<PharmacySupermarketLayoutWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      final trimmedQuery = query.trim().toLowerCase();
      final restController = Get.find<RestaurantController>();

      // Check if query matches a category name
      final categoryList = restController.categoryList;
      if (categoryList != null && categoryList.isNotEmpty) {
        final matchingCategoryIndex = categoryList.indexWhere(
          (cat) => cat.name?.toLowerCase() == trimmedQuery ||
                   cat.name?.toLowerCase().contains(trimmedQuery) == true
        );

        if (matchingCategoryIndex != -1) {
          // Found matching category - select it and show its products
          restController.setCategoryIndex(matchingCategoryIndex);
          _searchController.clear();
          restController.changeSearchStatus(isUpdate: true);
          return;
        }
      }

      // No category match - proceed with normal product search
      Get.find<search.SearchController>().saveSearchHistory(query.trim());
      restController.getRestaurantSearchProductList(
        query.trim(),
        widget.restaurant.vendorId?.toString() ?? widget.restaurant.id?.toString() ?? '',
        1,
        restController.type,
        businessType: widget.restaurant.businessType,
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    widget.restController.initSearchData();
    widget.restController.changeSearchStatus(isUpdate: true);
  }

  String _getSearchHint() {
    switch (widget.restaurant.businessType) {
      case 'pharmacy':
        return 'search_medicines'.tr;
      case 'supermarket':
        return 'search_products'.tr;
      default:
        return 'search_item_in_store'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final restaurant = widget.restaurant;
    final restController = widget.restController;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          height: 70 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  alignment: Alignment.center,
                  child: Icon(HeroiconsOutline.chevronLeft, color: Theme.of(context).cardColor, size: 18),
                ),
                onPressed: () {
                  if (restController.isSearching) {
                    _clearSearch();
                  } else {
                    Get.back();
                  }
                },
              ),

              // Search Bar
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                    textInputAction: TextInputAction.search,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      hintText: _getSearchHint(),
                      hintStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      border: InputBorder.none,
                      suffixIcon: restController.isSearching
                          ? IconButton(
                              icon: const Icon(HeroiconsOutline.xMark),
                              onPressed: _clearSearch,
                            )
                          : IconButton(
                              icon: const Icon(HeroiconsOutline.magnifyingGlass),
                              onPressed: () => _onSearch(_searchController.text),
                            ),
                    ),
                    onSubmitted: _onSearch,
                  ),
                ),
              ),

              // Veg Filter
              if (restController.type.isNotEmpty)
                VegFilterWidget(
                  type: restController.type,
                  iconColor: Theme.of(context).primaryColor,
                  onSelected: (String type) {
                    if (restController.isSearching) {
                      restController.getRestaurantSearchProductList(
                        restController.searchText,
                        restaurant.vendorId?.toString() ?? restaurant.id?.toString() ?? '',
                        1,
                        type,
                        businessType: restaurant.businessType,
                      );
                    } else {
                      restController.getRestaurantProductList(
                        restaurant.vendorId ?? restaurant.id,
                        1,
                        type,
                        true,
                      );
                    }
                  },
                ),

              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
          ),
        ),
      ),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: restController.isSearching
          ? _buildSearchResults(restController, restaurant)
          : _buildMainContent(restController, restaurant, isDesktop),
      bottomNavigationBar: GetBuilder<CartController>(
        builder: (cartController) {
          return cartController.cartList.isNotEmpty && !isDesktop
              ? BottomCartWidget(
                  restaurantId: cartController.cartList[0].product?.restaurantId ?? 0,
                  fromDineIn: widget.fromDineIn,
                )
              : const SizedBox();
        },
      ),
    );
  }

  Widget _buildSearchResults(RestaurantController restController, Restaurant restaurant) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: PaginatedListViewWidget(
            scrollController: _scrollController,
            onPaginate: (int? offset) => restController.getRestaurantSearchProductList(
              restController.searchText,
              restaurant.vendorId?.toString() ?? restaurant.id?.toString() ?? '',
              offset!,
              restController.type,
              businessType: restaurant.businessType,
            ),
            totalSize: restController.restaurantSearchProductModel?.totalSize,
            offset: restController.restaurantSearchProductModel?.offset ?? 1,
            productView: ProductViewWidget(
              isRestaurant: false,
              restaurants: null,
              products: restController.restaurantSearchProductModel?.products,
              inRestaurantPage: true,
              businessType: restaurant.businessType,
              vendorId: restaurant.id,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(RestaurantController restController, Restaurant restaurant, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: () async {
        await restController.getRestaurantDetails(
          Restaurant(id: restaurant.id),
          slug: '',
          businessType: restaurant.businessType,
        );
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Vendor Profile Card
          SliverToBoxAdapter(
            child: VendorProfileCardWidget(
              restaurant: restaurant,
              restController: restController,
            ),
          ),

          // Discount Banner
          if (restaurant.discount != null)
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  margin: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: Dimensions.paddingSizeLarge,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).primaryColor,
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        restaurant.discount?.discountType == 'percent'
                            ? '${restaurant.discount?.discount}% ${'off'.tr}'
                            : '${PriceConverter.convertPrice(restaurant.discount?.discount)} ${'off'.tr}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      Text(
                        restaurant.discount?.discountType == 'percent'
                            ? '${'enjoy'.tr} ${restaurant.discount?.discount}% ${'off_on_all_categories'.tr}'
                            : '${'enjoy'.tr} ${PriceConverter.convertPrice(restaurant.discount?.discount)} ${'off_on_all_categories'.tr}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      if ((restaurant.discount?.minPurchase ?? 0) != 0)
                        Text(
                          '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(restaurant.discount?.minPurchase)} ]',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                      if ((restaurant.discount?.maxDiscount ?? 0) != 0)
                        Text(
                          '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount?.maxDiscount)} ]',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                      Text(
                        '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(restaurant.discount?.startTime ?? '')} '
                        '- ${DateConverter.convertTimeToTime(restaurant.discount?.endTime ?? '')} ]',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Announcement Banner
          if ((restaurant.announcementActive ?? false) && restaurant.announcementMessage != null)
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(color: Colors.green),
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Row(
                  children: [
                    Image.asset(Images.announcement, height: 26, width: 26),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Flexible(
                      child: Text(
                        restaurant.announcementMessage ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Vendor Banner Carousel
          SliverToBoxAdapter(
            child: VendorBannerCarouselWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
          ),

          // Prescription Upload Section (Pharmacy only)
          if (restaurant.businessType == 'pharmacy')
            SliverToBoxAdapter(
              child: _buildPrescriptionSection(context),
            ),

          // Recommended Products
          if (restController.recommendedProductModel?.products?.isNotEmpty ?? false)
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeLarge,
                        left: Dimensions.paddingSizeLarge,
                        bottom: Dimensions.paddingSizeSmall,
                        right: Dimensions.paddingSizeLarge,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'recommend_for_you'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  'here_is_what_you_might_like_to_test'.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ArrowIconButtonWidget(
                            onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(
                              false,
                              fromIsRestaurantFood: true,
                              restaurantId: restaurant.id ?? 0,
                            )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: restaurant.businessType == 'pharmacy'
                          ? (ResponsiveHelper.isDesktop(context) ? 280 : 260)
                          : (ResponsiveHelper.isDesktop(context) ? 307 : 305),
                      width: context.width,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: restController.recommendedProductModel?.products?.length ?? 0,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeExtraSmall,
                          bottom: Dimensions.paddingSizeExtraSmall,
                          right: Dimensions.paddingSizeDefault,
                        ),
                        itemBuilder: (context, index) {
                          final product = restController.recommendedProductModel!.products![index];
                          // Use PharmacyItemCardWidget for pharmacy, ItemCardWidget for others
                          if (restaurant.businessType == 'pharmacy') {
                            return Padding(
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                              child: PharmacyItemCardWidget(
                                product: product,
                                inRestaurantPage: true,
                                vendorId: restaurant.id,
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 180
                                    : MediaQuery.of(context).size.width * 0.45,
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                            child: ItemCardWidget(
                              product: product,
                              isBestItem: false,
                              isPopularNearbyItem: false,
                              width: ResponsiveHelper.isDesktop(context)
                                  ? 200
                                  : MediaQuery.of(context).size.width * 0.53,
                              inRestaurantPage: true,
                              businessType: restaurant.businessType,
                              vendorId: restaurant.id,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ),
            ),

          // Shop by Category
          SliverToBoxAdapter(
            child: ShopByCategoryWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
          ),

          // Supermarket-specific sections
          if (restaurant.businessType == 'supermarket') ...[
            // Mid-Page Hot Deals/Offers
            SliverToBoxAdapter(
              child: MidPageOffersWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
            ),

            // Top Products Section
            SliverToBoxAdapter(
              child: TopProductsWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
            ),

            // Fresh Products (Vegetables & Fruits)
            SliverToBoxAdapter(
              child: FreshProductsWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
            ),

            // Favorite Snacks
            SliverToBoxAdapter(
              child: FavoriteSnacksWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
            ),

            // Recently Reviewed Products
            SliverToBoxAdapter(
              child: RecentlyReviewedWidget(vendorId: restaurant.vendorId ?? restaurant.id ?? 0),
            ),
          ],

          // All Items Section for Pharmacy (similar to restaurant)
          if (restaurant.businessType == 'pharmacy' && (restController.categoryList?.isNotEmpty ?? false))
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverDelegate(
                height: 98,
                child: Center(
                  child: Container(
                    width: Dimensions.webMaxWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                            top: Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'all_items'.tr,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                        const Divider(thickness: 0.2, height: 10),
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: restController.categoryList?.length ?? 0,
                            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => restController.setCategoryIndex(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    color: index == restController.categoryIndex
                                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        restController.categoryList?[index].name ?? '',
                                        style: index == restController.categoryIndex
                                            ? robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color: Theme.of(context).primaryColor,
                                              )
                                            : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Product List for Pharmacy
          if (restaurant.businessType == 'pharmacy')
            SliverToBoxAdapter(
              child: FooterViewWidget(
                child: Center(
                  child: Container(
                    width: Dimensions.webMaxWidth,
                    decoration: BoxDecoration(color: Theme.of(context).cardColor),
                    child: PaginatedListViewWidget(
                      scrollController: _scrollController,
                      onPaginate: (int? offset) {
                        restController.getRestaurantProductList(
                          restaurant.vendorId ?? restaurant.id,
                          offset!,
                          restController.type,
                          false,
                        );
                      },
                      totalSize: restController.restaurantProducts != null ? restController.foodPageSize : null,
                      offset: restController.restaurantProducts != null ? restController.foodPageOffset : null,
                      productView: ProductViewWidget(
                        isRestaurant: false,
                        restaurants: null,
                        products: restController.restaurantProducts,
                        inRestaurantPage: true,
                        businessType: restaurant.businessType,
                        vendorId: restaurant.id,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      final hasPrescription = checkoutController.prescriptionImage != null;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFDA281C),
        ),
        child: Row(
          children: [
            Icon(
              hasPrescription ? HeroiconsSolid.checkCircle : HeroiconsSolid.documentText,
              size: 22,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasPrescription ? 'prescription_uploaded'.tr : 'upload_prescription'.tr,
                style: robotoMedium.copyWith(color: Colors.white, fontSize: 13),
              ),
            ),
            if (hasPrescription) ...[
              InkWell(
                onTap: () => _showPrescriptionUploadOptions(context, checkoutController),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('change'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  checkoutController.setPrescriptionOnlyMode(true);
                  checkoutController.setPrescriptionRestaurantId(widget.restaurant.id);
                  checkoutController.setRestaurantDetails(restaurantId: widget.restaurant.id, businessType: 'pharmacy');
                  Get.toNamed(RouteHelper.getCheckoutRoute('prescription'));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Text('order_prescription'.tr, style: robotoBold.copyWith(color: const Color(0xFFDA281C), fontSize: 12)),
                ),
              ),
            ] else
              InkWell(
                onTap: () => _showPrescriptionUploadOptions(context, checkoutController),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(HeroiconsSolid.camera, size: 14, color: Color(0xFFDA281C)),
                      const SizedBox(width: 6),
                      Text('upload'.tr, style: robotoBold.copyWith(color: const Color(0xFFDA281C), fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showPrescriptionUploadOptions(BuildContext context, CheckoutController checkoutController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'upload_prescription'.tr,
              style: robotoBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'select_upload_method'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      checkoutController.pickPrescriptionImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                      ),
                      child: Column(
                        children: [
                          Icon(HeroiconsOutline.camera, color: Theme.of(context).primaryColor, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'camera'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      checkoutController.pickPrescriptionImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                      ),
                      child: Column(
                        children: [
                          Icon(HeroiconsOutline.photo, color: Theme.of(context).primaryColor, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'gallery'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
