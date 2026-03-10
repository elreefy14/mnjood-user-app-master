import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/product_view_widget.dart';
import 'package:mnjood/features/category/controllers/category_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/cart_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/veg_filter_widget.dart';
import 'package:mnjood/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CategoryProductScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  final String? businessType;
  const CategoryProductScreen({super.key, required this.categoryID, required this.categoryName, this.businessType});

  @override
  CategoryProductScreenState createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController restaurantScrollController = ScrollController();
  TabController? _tabController;

  // Check if this is a supermarket/mnjood mart type
  bool get _isSupermarket {
    final type = (widget.businessType ?? '').toLowerCase();
    return type == 'supermarket' || type == 'mnjood_mart' || type == 'mnjood mart' || type.contains('supermarket');
  }

  // Check if this business type should only show products tab (no vendors tab)
  // Coffee shops use V1 API which doesn't link vendors to categories
  bool get _isProductsOnly {
    final type = (widget.businessType ?? '').toLowerCase();
    return _isSupermarket || type == 'coffee_shop' || type == 'coffee shop' || type == 'coffeeshop';
  }

  // Get tab labels based on business type
  String get _itemsTabLabel {
    final type = (widget.businessType ?? '').toLowerCase();
    if (type == 'pharmacy') return 'products'.tr;
    if (type == 'coffee_shop' || type == 'coffee shop' || type == 'coffeeshop') return 'products'.tr;
    if (_isSupermarket) return 'products'.tr;
    return 'food'.tr; // restaurant
  }

  String get _vendorsTabLabel {
    final type = (widget.businessType ?? '').toLowerCase();
    if (type == 'pharmacy') return 'pharmacies'.tr;
    if (type == 'coffee_shop' || type == 'coffee shop' || type == 'coffeeshop') return 'coffee_shops'.tr;
    return 'restaurants'.tr; // restaurant
  }

  @override
  void initState() {
    super.initState();

    // For supermarket/coffee_shop, only 1 tab (products). For others, 2 tabs.
    _tabController = TabController(length: _isProductsOnly ? 1 : 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().setBusinessType(widget.businessType);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);

    // Pre-load restaurant list so it's ready when user switches to shops tab
    // Skip for products-only types (supermarket, coffee_shop) as they don't have vendors tab
    debugPrint('DEBUG: CategoryProductScreen initState - businessType: ${widget.businessType}, categoryID: ${widget.categoryID}');
    if (!_isProductsOnly) {
      Get.find<CategoryController>().getCategoryRestaurantList(
        widget.categoryID,
        1, 'all', false,
        businessType: widget.businessType,
      );
    }

    // Add listener to load data when tab changes
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        final catController = Get.find<CategoryController>();
        debugPrint('DEBUG: Tab changed to index ${_tabController!.index}, isRestaurant: ${catController.isRestaurant}');
        if (_tabController!.index == 1 && !catController.isRestaurant) {
          catController.setRestaurant(true);
          catController.getCategoryRestaurantList(
            catController.subCategoryIndex == 0 ? widget.categoryID
                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
            1, catController.type, false,
            businessType: widget.businessType,
          );
        } else if (_tabController!.index == 0 && catController.isRestaurant) {
          catController.setRestaurant(false);
        }
      }
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryProductList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          debugPrint('end of the page');
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryProductList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
    restaurantScrollController.addListener(() {
      if (restaurantScrollController.position.pixels == restaurantScrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryRestaurantList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().restaurantPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          debugPrint('end of the page');
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryRestaurantList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
            businessType: widget.businessType,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Product>? products;
      List<Restaurant>? restaurants;
      if(catController.categoryProductList != null && catController.searchProductList != null) {
        products = [];
        if (catController.isSearching) {
          products.addAll(catController.searchProductList!);
        } else {
          products.addAll(catController.categoryProductList!);
        }
      }
      if(catController.categoryRestaurantList != null && catController.searchRestaurantList != null) {
        restaurants = [];
        if (catController.isSearching) {
          restaurants.addAll(catController.searchRestaurantList!);
        } else {
          restaurants.addAll(catController.categoryRestaurantList!);
        }
      }

      return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) async{
          if(catController.isSearching) {
            catController.toggleSearch();
          }else {}
        },
        child: Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ?  const WebMenuBar() : AppBar(
            title: catController.isSearching ? TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              onSubmitted: (String query) => catController.searchData(
                query, catController.subCategoryIndex == 0 ? widget.categoryID
                  : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                catController.type,
              ),
            ) : Text(widget.categoryName, style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(HeroiconsOutline.chevronLeft),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else {
                  Get.back();
                }
              },
            ),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 6,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).shadowColor,
            actions: [
              IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? HeroiconsOutline.xMark : HeroiconsOutline.magnifyingGlass,
                  color: catController.isSearching ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor,
                ),
              ),

              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                icon: CartWidget(color: Theme.of(context).primaryColor, size: 25),
              ),

              VegFilterWidget(
                iconColor: Theme.of(context).primaryColor,
                type: catController.type, fromAppBar: true,
                onSelected: (String type) {
                  if(catController.isSearching) {
                      catController.searchData(
                        catController.subCategoryIndex == 0 ? widget.categoryID
                            : catController.subCategoryList![catController.subCategoryIndex].id.toString(), '1', type,
                      );
                    }else {
                      if(catController.isRestaurant) {
                        catController.getCategoryRestaurantList(
                          catController.subCategoryIndex == 0 ? widget.categoryID
                              : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                          businessType: widget.businessType,
                        );
                      }else {
                        catController.getCategoryProductList(
                          catController.subCategoryIndex == 0 ? widget.categoryID
                              : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                        );
                      }
                    }
                  },
              ),

              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
          ),
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          body: Column(children: [

            (catController.subCategoryList != null && !catController.isSearching) ? Center(child: Container(
              height: 40, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: catController.subCategoryList!.length,
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          catController.subCategoryList![index].name!,
                          style: index == catController.subCategoryIndex
                              ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                              : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            )) : const SizedBox(),

            // Only show TabBar if not products-only type (supermarket/coffee_shop only have products)
            if (!_isProductsOnly) Center(child: Container(
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).cardColor,
              child: Align(
                alignment: ResponsiveHelper.isDesktop(context) ? Alignment.centerLeft : Alignment.center,
                child: Container(
                  width: ResponsiveHelper.isDesktop(context) ? 350 : Dimensions.webMaxWidth,
                  color: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).disabledColor,
                    unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                    labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                    tabs: [
                      Tab(text: _itemsTabLabel),
                      Tab(text: _vendorsTabLabel),
                    ],
                  ),
                ),
              ),
            )),

            Expanded(child: NotificationListener(
              onNotification: (dynamic scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  if((_tabController!.index == 1 && !catController.isRestaurant) || _tabController!.index == 0 && catController.isRestaurant) {
                    catController.setRestaurant(_tabController!.index == 1);
                    if(catController.isSearching) {
                      catController.searchData(
                        catController.searchText, catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), catController.type,
                      );
                    }else {
                      if(_tabController!.index == 1) {
                        catController.getCategoryRestaurantList(
                          catController.subCategoryIndex == 0 ? widget.categoryID
                              : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                          1, catController.type, false,
                          businessType: widget.businessType,
                        );
                      }else {
                        catController.getCategoryProductList(
                          catController.subCategoryIndex == 0 ? widget.categoryID
                              : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                          1, catController.type, false,
                        );
                      }
                    }
                  }
                }
                return false;
              },
              child: _isProductsOnly
                // Products-only types (supermarket/coffee_shop): Only show products (no TabBarView needed)
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: FooterViewWidget(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              ProductViewWidget(
                                isRestaurant: false, products: products, restaurants: null, noDataText: 'no_products_found'.tr,
                                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                                businessType: widget.businessType,
                                useGridLayout: true,
                              ),

                              catController.isLoading ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                // Restaurant/Pharmacy: Show both tabs (products + vendors)
                : TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: FooterViewWidget(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              ProductViewWidget(
                                isRestaurant: false, products: products, restaurants: null, noDataText: 'no_category_food_found'.tr,
                                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                                businessType: widget.businessType,
                                useGridLayout: true,
                              ),

                              catController.isLoading ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    controller: restaurantScrollController,
                    child: FooterViewWidget(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              ProductViewWidget(
                                isRestaurant: true, products: null, restaurants: restaurants, noDataText: 'no_category_restaurant_found'.tr,
                                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                                businessType: widget.businessType,
                              ),

                              catController.isLoading ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ]),
        ),
      );
    });
  }
}
