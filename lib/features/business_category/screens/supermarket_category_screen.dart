import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:mnjood/features/home/widgets/home_section_view_widget.dart';
import 'package:mnjood/features/business_category/widgets/product_filter_bar_widget.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/home/widgets/supermarket_item_card_widget.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class SupermarketCategoryScreen extends StatefulWidget {
  const SupermarketCategoryScreen({super.key});

  @override
  State<SupermarketCategoryScreen> createState() => _SupermarketCategoryScreenState();
}

class _SupermarketCategoryScreenState extends State<SupermarketCategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  // Filter state
  ProductSortOption _sortBy = ProductSortOption.popular;
  bool _onSaleFilter = false;
  bool _newArrivalsFilter = false;
  bool _inStockFilter = false;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      final homeController = Get.find<HomeController>();
      if (!homeController.mnjoodMartLoading && homeController.mnjoodMartHasMore) {
        // loadMoreMnjoodMartProducts uses _currentMartCategoryId stored in controller
        homeController.loadMoreMnjoodMartProducts();
      }
    }
  }

  Future<void> _loadData() async {
    final homeController = Get.find<HomeController>();

    // Load categories for supermarket
    homeController.getBusinessTypeCategories('supermarket', dataSource: DataSourceEnum.client, fromRecall: true);

    // Load Mnjood Mart products
    homeController.getMnjoodMartProducts(dataSource: DataSourceEnum.client, fromRecall: true);

    // Load home sections (for supermarket sections)
    homeController.getHomeSections(dataSource: DataSourceEnum.client, fromRecall: true);
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    List<Product> filtered = List.from(products);

    // Category filtering is now done server-side via category_id query param

    // Apply on sale filter
    if (_onSaleFilter) {
      filtered = filtered.where((p) => (p.discount ?? 0) > 0).toList();
    }

    // Apply new arrivals filter (show items from last 30 days or first 20% of list)
    if (_newArrivalsFilter) {
      final newCount = (filtered.length * 0.2).ceil().clamp(1, 20);
      filtered = filtered.reversed.take(newCount).toList();
    }

    // Apply in stock filter
    if (_inStockFilter) {
      filtered = filtered.where((p) => (p.itemStock ?? 0) > 0 || p.stockType == 'unlimited').toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case ProductSortOption.popular:
        // Keep original order (assumed to be by popularity from API)
        break;
      case ProductSortOption.latest:
        // Reverse to show newest first (assuming API returns oldest first)
        filtered = filtered.reversed.toList();
        break;
      case ProductSortOption.rating:
        filtered.sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));
        break;
      case ProductSortOption.priceLowHigh:
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case ProductSortOption.priceHighLow:
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'mnjood_mart'.tr),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: RefreshIndicator(
        onRefresh: () async => await _loadData(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar
            SliverToBoxAdapter(child: _buildSearchBar(context)),

            // Main Content
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Home Sections (supermarket)
                      _buildHomeSections(),

                      // 2. Categories (2-row horizontal carousel)
                      _buildCategoriesSection(context),

                      const SizedBox(height: 16),

                      // 3. All Products Section
                      _buildAllProductsSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () => Get.toNamed(RouteHelper.getSearchRoute(businessType: 'supermarket')),
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
                'search_products'.tr,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeSections() {
    return GetBuilder<HomeController>(builder: (homeController) {
      final sections = homeController.homeSections;
      if (sections == null || sections.isEmpty) return const SizedBox();

      // Show product-based sections (supermarket/mart) — exclude restaurant/pharmacy/coffee vendor sections
      final martSections = sections.where((s) {
        final type = s.businessType;
        if (type == 'restaurant' || type == 'pharmacy' || type == 'coffee_shop') return false;
        return true;
      }).toList();

      if (martSections.isEmpty) return const SizedBox();

      return Column(
        children: martSections
            .map((section) => HomeSectionViewWidget(section: section))
            .toList(),
      );
    });
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final categories = homeController.getCategoriesForBusinessType('supermarket');

      if (categories == null) {
        return _buildCategoriesShimmer(context);
      }

      if (categories.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Text('categories'.tr, style: robotoBold.copyWith(fontSize: 16)),
                const Spacer(),
                ArrowIconButtonWidget(
                  onTap: () => Get.toNamed(RouteHelper.getCategoryRoute(businessType: 'supermarket')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Categories grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(context, categories[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryItem(BuildContext context, dynamic category) {
    return CustomInkWellWidget(
      onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
        category.id!, category.name!,
        businessType: 'supermarket',
      )),
      radius: 12,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  image: category.imageFullUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name ?? '',
            style: robotoMedium.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Shimmer(
            child: Container(
              height: 24,
              width: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 8,
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
        ),
      ],
    );
  }

  Widget _buildAllProductsSection(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final products = homeController.mnjoodMartProducts;

      if (products == null) {
        return _buildProductsShimmer(context);
      }

      if (products.isEmpty) {
        return const SizedBox();
      }

      final filteredProducts = _getFilteredProducts(products);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header (no icon)
            Text('all_products'.tr, style: robotoBold.copyWith(fontSize: 16)),
            const SizedBox(height: 12),

            // Filter bar
            ProductFilterBarWidget(
              selectedSort: _sortBy,
              onSaleFilter: _onSaleFilter,
              newArrivalsFilter: _newArrivalsFilter,
              inStockFilter: _inStockFilter,
              categories: homeController.getCategoriesForBusinessType('supermarket'),
              selectedCategoryId: _selectedCategoryId,
              onCategoryChanged: (value) {
                setState(() => _selectedCategoryId = value);
                Get.find<HomeController>().getMnjoodMartProducts(
                  categoryId: value,
                  dataSource: DataSourceEnum.client,
                  fromRecall: true,
                );
              },
              onSortChanged: (option) {
                setState(() => _sortBy = option);
              },
              onSaleFilterChanged: (value) {
                setState(() => _onSaleFilter = value);
              },
              onNewArrivalsChanged: (value) {
                setState(() => _newArrivalsFilter = value);
              },
              onInStockChanged: (value) {
                setState(() => _inStockFilter = value);
              },
            ),
            const SizedBox(height: 12),

            // Products grid (3 columns)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return SupermarketItemCardWidget(
                  product: product,
                  vendorId: product.supermarketId,
                  width: double.infinity,
                );
              },
            ),

            // Loading indicator for pagination
            if (homeController.mnjoodMartLoading)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                ),
              ),

            // No more products message
            if (!homeController.mnjoodMartHasMore && filteredProducts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'no_more_products'.tr,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildProductsShimmer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
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
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return Shimmer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(16),
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
