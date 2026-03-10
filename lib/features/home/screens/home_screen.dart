import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/features/dine_in/controllers/dine_in_controller.dart';
import 'package:mnjood/features/home/controllers/advertisement_controller.dart';
import 'package:mnjood/features/home/widgets/dine_in_widget.dart';
import 'package:mnjood/features/home/widgets/highlight_widget_view.dart';
import 'package:mnjood/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:mnjood/features/product/controllers/campaign_controller.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/screens/web_home_screen.dart';
import 'package:mnjood/features/home/widgets/bad_weather_widget.dart';
import 'package:mnjood/features/home/widgets/banner_view_widget.dart';
import 'package:mnjood/features/home/widgets/best_review_item_view_widget.dart';
import 'package:mnjood/features/home/widgets/cuisine_view_widget.dart';
import 'package:mnjood/features/home/widgets/main_categories_view_widget.dart';
import 'package:mnjood/features/home/widgets/enjoy_off_banner_view_widget.dart';
import 'package:mnjood/features/home/widgets/location_banner_view_widget.dart';
import 'package:mnjood/features/home/widgets/new_on_mnjood_view_widget.dart';
import 'package:mnjood/features/home/widgets/order_again_view_widget.dart';
import 'package:mnjood/features/home/widgets/popular_foods_nearby_view_widget.dart';
import 'package:mnjood/features/home/widgets/popular_restaurants_view_widget.dart';
import 'package:mnjood/features/home/widgets/popular_pharmacies_view_widget.dart';
import 'package:mnjood/features/home/widgets/popular_supermarkets_view_widget.dart';
import 'package:mnjood/features/home/widgets/refer_banner_view_widget.dart';
import 'package:mnjood/features/home/widgets/home_section_view_widget.dart';
import 'package:mnjood/features/home/widgets/top_restaurants_view_widget.dart';
import 'package:mnjood/features/home/widgets/mnjood_mart_offers_widget.dart';
import 'package:mnjood/features/home/widgets/active_order_card_widget.dart';
import 'package:mnjood/features/home/widgets/top_supermarket_categories_view_widget.dart';
import 'package:mnjood/features/home/screens/theme1_home_screen.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/notification/controllers/notification_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/common/widgets/customizable_space_bar_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/splash/domain/models/config_model.dart';
import 'package:mnjood/features/address/controllers/address_controller.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/category/controllers/category_controller.dart';
import 'package:mnjood/features/cuisine/controllers/cuisine_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/features/review/controllers/review_controller.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/helper/address_helper.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/util/images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  static Future<void> loadData(bool reload, {String businessType = 'restaurant'}) async {
    // Reload cart data for logged-in or guest users (fixes cart empty after hot restart)
    if(Get.find<AuthController>().isLoggedIn() || Get.find<AuthController>().isGuestLoggedIn()) {
      Get.find<CartController>().getCartDataOnline();
    }

    // Set business type first (without triggering reload)
    Get.find<RestaurantController>().setBusinessType(businessType, reload: false);

    Get.find<HomeController>().getBannerList(reload);
    Get.find<HomeController>().getSliders();
    Get.find<HomeController>().getMainCategoriesList();
    Get.find<HomeController>().getRestaurantCategories();
    Get.find<HomeController>().getMnjoodMartProducts();
    // Load dynamic home sections (replaces hardcoded top restaurants/coffee/pharmacy)
    Get.find<HomeController>().getHomeSections();
    Get.find<CategoryController>().getTopSupermarketCategories(reload, notify: false);
    Get.find<CuisineController>().getCuisineList();
    Get.find<AdvertisementController>().getAdvertisementList();
    Get.find<DineInController>().getDineInRestaurantList(1, reload);
    if(Get.find<SplashController>().configModel!.popularRestaurant == 1) {
      Get.find<RestaurantController>().getPopularRestaurantList(reload, businessType, false);
    }
    Get.find<CampaignController>().getItemCampaignList(reload);
    if(Get.find<SplashController>().configModel!.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(reload, businessType, false);
    }
    if(Get.find<SplashController>().configModel!.newRestaurant == 1) {
      Get.find<RestaurantController>().getLatestRestaurantList(reload, businessType, false);
    }
    if(Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
      Get.find<ReviewController>().getReviewedProductList(reload, businessType, false);
    }
    Get.find<RestaurantController>().getRestaurantList(1, reload);
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      Get.find<RestaurantController>().getRecentlyViewedRestaurantList(reload, businessType, false);
      Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<AddressController>().getAddressList();
      // Get.find<HomeController>().getCashBackOfferList(); // Disabled for now
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();
    HomeScreen.loadData(false, businessType: 'restaurant').then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ?? false) && Get.find<SplashController>().showReferBottomSheet) {
        Future.delayed(const Duration(milliseconds: 500), () => _showReferBottomSheet());
      }

    });

    _scrollController.addListener(() {
      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), ()=> Get.find<HomeController>().changeFavVisibility());
        }
      }else {
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), ()=> Get.find<HomeController>().changeFavVisibility());
        }
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context) ? Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: const ReferBottomSheetWidget(),
    ),
      useSafeArea: false,
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false)) : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }


  @override
  Widget build(BuildContext context) {

    double scrollPoint = 0.0;

    return GetBuilder<HomeController>(builder: (homeController) {
      return GetBuilder<LocalizationController>(builder: (localizationController) {
        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            top: (Get.find<SplashController>().configModel!.theme == 2),
            child: RefreshIndicator(
              onRefresh: () async {
                // Get current business type from RestaurantController
                String currentType = Get.find<RestaurantController>().businessType;

                // Reload cart data
                if(Get.find<AuthController>().isLoggedIn() || Get.find<AuthController>().isGuestLoggedIn()) {
                  Get.find<CartController>().getCartDataOnline();
                }

                await Get.find<HomeController>().getBannerList(true);
                await Get.find<HomeController>().getSliders(dataSource: DataSourceEnum.client, fromRecall: true);
                await Get.find<HomeController>().getMainCategoriesList(dataSource: DataSourceEnum.client, fromRecall: true);
                await Get.find<HomeController>().getRestaurantCategories(dataSource: DataSourceEnum.client, fromRecall: true);
                await Get.find<HomeController>().getMnjoodMartProducts(dataSource: DataSourceEnum.client, fromRecall: true);
                await Get.find<CuisineController>().getCuisineList();
                Get.find<AdvertisementController>().getAdvertisementList();
                await Get.find<RestaurantController>().getPopularRestaurantList(true, currentType, false);
                await Get.find<HomeController>().getHomeSections(dataSource: DataSourceEnum.client, fromRecall: true);
                await Get.find<CampaignController>().getItemCampaignList(true);
                await Get.find<ProductController>().getPopularProductList(true, currentType, false);
                await Get.find<RestaurantController>().getLatestRestaurantList(true, currentType, false);
                await Get.find<ReviewController>().getReviewedProductList(true, currentType, false);
                await Get.find<RestaurantController>().getRestaurantList(1, true);
                if(Get.find<AuthController>().isLoggedIn()) {
                  await Get.find<ProfileController>().getUserInfo();
                  await Get.find<NotificationController>().getNotificationList(true);
                  await Get.find<RestaurantController>().getRecentlyViewedRestaurantList(true, currentType, false);
                  await Get.find<RestaurantController>().getOrderAgainRestaurantList(true);

                }
              },
              child: ResponsiveHelper.isDesktop(context) ? WebHomeScreen(
                scrollController: _scrollController,
              ) : (Get.find<SplashController>().configModel!.theme == 2) ? Theme1HomeScreen(
                scrollController: _scrollController,
              ) : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  /// App Bar - Enterprise Premium Design
                  SliverAppBar(
                    pinned: true, toolbarHeight: 10,
                    expandedHeight: ResponsiveHelper.isTab(context) ? 80 : GetPlatform.isWeb ? 80 : 72,
                    floating: false, elevation: 0,
                    backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                        titlePadding: EdgeInsets.zero,
                        centerTitle: true,
                        expandedTitleScale: 1,
                        title: CustomizableSpaceBarWidget(
                          builder: (context, scrollingRate) {
                            scrollPoint = scrollingRate;
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: scrollPoint > 0.1 ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              padding: const EdgeInsets.only(top: 28, left: 16, right: 16, bottom: 6),
                              child: ClipRect(
                                child: Opacity(
                                  opacity: 1 - scrollPoint,
                                  child: Row(
                                  children: [
                                    // Logo
                                    SizedBox(
                                      width: 46, height: 46,
                                      child: Image.asset(Images.favicon, fit: BoxFit.contain),
                                    ),

                                    const SizedBox(width: 12),

                                    // Location info - Premium pill design
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                                        borderRadius: BorderRadius.circular(12),
                                        child: GetBuilder<LocationController>(builder: (locationController) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8F9FA),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  HeroiconsSolid.mapPin,
                                                  size: 24,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Flexible(child: Text(
                                                        'deliver_to'.tr,
                                                        style: robotoRegular.copyWith(color: const Color(0xFF6C757D), fontSize: 10, height: 1.0),
                                                      )),
                                                      Flexible(child: Text(
                                                        AddressHelper.getAddressFromSharedPref()?.address ?? 'your_location'.tr,
                                                        style: robotoMedium.copyWith(color: const Color(0xFF212529), fontSize: 12, height: 1.0),
                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                      )),
                                                    ],
                                                  ),
                                                ),
                                                const Icon(HeroiconsOutline.chevronDown, color: Color(0xFF6C757D), size: 16),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Cart button - Premium gradient design
                                    GetBuilder<CartController>(builder: (cartController) {
                                      int cartCount = cartController.cartList.length;
                                      double cartTotal = 0;
                                      for (var item in cartController.cartList) {
                                        cartTotal += (item.discountedPrice ?? item.price ?? 0) * (item.quantity ?? 1);
                                      }
                                      return InkWell(
                                        onTap: () => AuthHelper.isLoggedIn()
                                            ? Get.toNamed(RouteHelper.getCartRoute())
                                            : Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.cart)),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFDA281C), Color(0xFFE53935)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFDA281C).withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  const Icon(HeroiconsOutline.shoppingBag, size: 20, color: Colors.white),
                                                  if (cartCount > 0)
                                                    Positioned(
                                                      top: -5,
                                                      right: -5,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Text(
                                                          '$cartCount',
                                                          style: robotoBold.copyWith(color: const Color(0xFFDA281C), fontSize: 8),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${cartTotal.toStringAsFixed(0)}',
                                                style: robotoBold.copyWith(color: Colors.white, fontSize: 13),
                                              ),
                                              const SizedBox(width: 2),
                                              PriceConverter.sarSymbolWidget(size: 11, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            );
                          },
                        )
                    ),
                    actions: const [SizedBox()],
                  ),

                  // Search Button - Enterprise Design
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDelegate(height: 60, child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                          ),
                          child: Row(children: [
                            Icon(HeroiconsOutline.magnifyingGlass, size: 22, color: const Color(0xFF6C757D)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(
                              'search_for_any_product'.tr,
                              style: robotoRegular.copyWith(fontSize: 14, color: const Color(0xFF9CA3AF)),
                            )),
                          ]),
                        ),
                      ),
                    )),
                  ),

                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        // Active order card (if any running orders)
                        if (_isLogin) const ActiveOrderCardWidget(),

                        // 1. Banner slider
                        const BannerViewWidget(),

                        // 2. Categories
                        const MainCategoriesViewWidget(),

                        // Dynamic vendor sections from API
                        GetBuilder<HomeController>(builder: (hc) {
                          if (hc.homeSections == null) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: TopRestaurantsShimmer(),
                            );
                          }
                          return Column(
                            children: hc.homeSections!.map((section) =>
                              HomeSectionViewWidget(section: section)
                            ).toList(),
                          );
                        }),

                        const BadWeatherWidget(),

                        const HighlightWidgetView(),

                        Get.find<AuthController>().isLoggedIn() ? const OrderAgainViewWidget() : const SizedBox(),

                        // Removed sections
                        // const PopularPharmaciesViewWidget(),
                        // const PopularSupermarketsViewWidget(),

                        // Recently viewed restaurants section removed
                        // Get.find<AuthController>().isLoggedIn() ? const PopularRestaurantsViewWidget(isRecentlyViewed: true) : const SizedBox(),

                        // New restaurants section removed
                        // _configModel.newRestaurant == 1 ? const NewOnMnjoodViewWidget(isLatest: true) : const SizedBox(),

                        // Promotional banner / Find Nearby section removed per user request
                        // const PromotionalBannerViewWidget(),

                      ]),
                    )),
                  ),

                  SliverToBoxAdapter(child: Center(child: ResponsiveHelper.isDesktop(context)
                    ? FooterViewWidget(child: const SizedBox())
                    : const SizedBox(height: Dimensions.paddingSizeOverLarge),
                  )),

                ],
              ),
            ),
          ),

          // Cash Back floating button removed

        );
      });
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
