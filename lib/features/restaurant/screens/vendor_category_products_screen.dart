import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/product_widget.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class VendorCategoryProductsScreen extends StatefulWidget {
  final int vendorId;
  final int categoryId;

  const VendorCategoryProductsScreen({
    super.key,
    required this.vendorId,
    required this.categoryId,
  });

  @override
  State<VendorCategoryProductsScreen> createState() => _VendorCategoryProductsScreenState();
}

class _VendorCategoryProductsScreenState extends State<VendorCategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadData() async {
    final restController = Get.find<RestaurantController>();

    // Load vendor details first to get categories
    await restController.getRestaurantDetails(
      Restaurant(id: widget.vendorId, businessType: 'supermarket'),
      slug: '',
      businessType: 'supermarket',
    );

    // Find the index of the selected category
    if (restController.categoryList != null) {
      for (int i = 0; i < restController.categoryList!.length; i++) {
        if (restController.categoryList![i].id == widget.categoryId) {
          _selectedCategoryIndex = i;
          break;
        }
      }
    }
    // Set the category index on the controller first, then load products
    restController.setCategoryIndex(_selectedCategoryIndex);
  }

  void _onScroll() {
    // Trigger pagination when near bottom (200px threshold for better UX)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final restController = Get.find<RestaurantController>();
      if (!restController.foodPaginate &&
          restController.restaurantProducts != null &&
          restController.restaurantProducts!.length < (restController.foodPageSize ?? 0)) {
        restController.showFoodBottomLoader();
        restController.getRestaurantProductList(
          widget.vendorId,
          restController.foodOffset + 1,
          restController.type,
          false,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<RestaurantController>(builder: (restController) {
          String title = 'products'.tr;
          if (restController.categoryList != null && _selectedCategoryIndex < restController.categoryList!.length) {
            title = restController.categoryList![_selectedCategoryIndex].name ?? 'products'.tr;
          }
          return Text(title, style: robotoMedium);
        }),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: const Icon(HeroiconsOutline.chevronLeft),
          onPressed: () => Get.back(),
        ),
      ),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        List<CategoryModel>? categories = restController.categoryList;
        List<Product>? products = restController.restaurantProducts;

        return Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              color: Theme.of(context).cardColor,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_products'.tr,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  prefixIcon: Icon(HeroiconsOutline.magnifyingGlass, color: Theme.of(context).hintColor),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(HeroiconsOutline.xMark),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _isSearching = false);
                            restController.initSearchData();
                            _selectCategory(_selectedCategoryIndex);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() => _isSearching = true);
                    restController.getRestaurantSearchProductList(
                      value,
                      widget.vendorId.toString(),
                      1,
                      restController.type,
                    );
                  }
                },
              ),
            ),

            // Category Slider
            if (categories != null && categories.length > 1)
              Container(
                height: 50,
                color: Theme.of(context).cardColor,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == _selectedCategoryIndex;
                    return InkWell(
                      onTap: () => _selectCategory(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            categories[index].name ?? '',
                            style: robotoMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Products Grid
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(restController)
                  : _buildProductsGrid(products, restController),
            ),
          ],
        );
      }),
    );
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _isSearching = false;
      _searchController.clear();
    });
    final restController = Get.find<RestaurantController>();
    restController.setCategoryIndex(index);
  }

  Widget _buildProductsGrid(List<Product>? products, RestaurantController restController) {
    if (products == null) {
      return _buildShimmer();
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HeroiconsOutline.shoppingBag,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'no_products_found'.tr,
              style: robotoMedium.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    final bool hasMore = products.length < (restController.foodPageSize ?? 0);
    final int itemCount = products.length + (restController.foodPaginate ? 1 : (hasMore ? 1 : 0));

    return RefreshIndicator(
      onRefresh: () async {
        await restController.getRestaurantProductList(
          widget.vendorId,
          1,
          restController.type,
          true,
        );
      },
      child: ResponsiveHelper.isDesktop(context)
          ? SingleChildScrollView(
              controller: _scrollController,
              child: FooterViewWidget(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductWidget(
                            product: products[index],
                            isRestaurant: false,
                            restaurant: null,
                            index: index,
                            length: products.length,
                            inRestaurant: true,
                            businessType: restController.restaurant?.businessType,
                            vendorId: widget.vendorId,
                          );
                        },
                      ),
                      if (restController.foodPaginate)
                        const Padding(
                          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == products.length) {
                  // Loading indicator at the bottom
                  return restController.foodPaginate
                      ? const Padding(
                          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox();
                }
                return SizedBox(
                  height: 120,
                  child: ProductWidget(
                    product: products[index],
                    isRestaurant: false,
                    restaurant: null,
                    index: index,
                    length: products.length,
                    inRestaurant: true,
                    businessType: restController.restaurant?.businessType,
                    vendorId: widget.vendorId,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSearchResults(RestaurantController restController) {
    ProductModel? searchModel = restController.restaurantSearchProductModel;

    if (searchModel == null) {
      return _buildShimmer();
    }

    if (searchModel.products == null || searchModel.products!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HeroiconsOutline.magnifyingGlass,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'no_results_found'.tr,
              style: robotoMedium.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: searchModel.products!.length,
      itemBuilder: (context, index) {
        return ProductWidget(
          product: searchModel.products![index],
          isRestaurant: false,
          restaurant: null,
          index: index,
          length: searchModel.products!.length,
          inRestaurant: true,
          businessType: Get.find<RestaurantController>().restaurant?.businessType,
          vendorId: widget.vendorId,
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer(
          child: Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
          ),
        );
      },
    );
  }
}
