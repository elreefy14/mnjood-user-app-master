import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/business_category/widgets/business_type_categories_widget.dart';
import 'package:mnjood/features/business_category/widgets/category_filter_bar_widget.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CoffeeShopCategoryScreen extends StatefulWidget {
  const CoffeeShopCategoryScreen({super.key});

  @override
  State<CoffeeShopCategoryScreen> createState() => _CoffeeShopCategoryScreenState();
}

class _CoffeeShopCategoryScreenState extends State<CoffeeShopCategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Restaurant>? _coffeeShops;
  List<Restaurant>? _filteredCoffeeShops;
  bool _isLoading = false;

  // Filter state
  SortOption _sortBy = SortOption.popular;
  bool _openNowFilter = false;
  bool _freeDeliveryFilter = false;

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
      if (!_isLoading) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    // Pagination logic can be added here if needed
  }

  /// Normalize coffee shop API response to match Restaurant model structure
  Map<String, dynamic> _normalizeCoffeeShopData(Map<String, dynamic> data) {
    final rawId = data['id'] ?? data['store_id'];
    final id = rawId is String ? int.tryParse(rawId) : rawId;
    final name = data['name'] ?? data['store_name'];
    final rawRating = data['avg_rating'] ?? data['rating'] ?? 0;
    final rating = rawRating is String ? double.tryParse(rawRating) ?? 0 : rawRating;

    return {
      ...data,
      'id': id,
      'name': name,
      'business_type': 'coffee_shop',
      'logo_full_url': data['logo_full_url'] ?? data['logo'],
      'logoFullUrl': data['logo_full_url'] ?? data['logo'],
      'cover_photo_full_url': data['cover_photo_full_url'] ?? data['cover_photo'],
      'coverPhotoFullUrl': data['cover_photo_full_url'] ?? data['cover_photo'],
      'latitude': data['latitude'] ?? '24.7136',
      'longitude': data['longitude'] ?? '46.6753',
      'delivery_time': data['delivery_time'] ?? '20-30 min',
      'deliveryTime': data['delivery_time'] ?? '20-30 min',
      'open': data['open'] ?? 1,
      'active': data['active'] ?? true,
      'avg_rating': rating,
      'avgRating': rating,
      'free_delivery': data['free_delivery'] ?? false,
      'freeDelivery': data['free_delivery'] ?? false,
      'minimum_order': data['minimum_order'] ?? 0,
      'zone_id': data['zone_id'] ?? 7,
    };
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final homeController = Get.find<HomeController>();
    homeController.getBusinessTypeCategories('coffee_shop', dataSource: DataSourceEnum.client, fromRecall: true);

    // Direct V1 API call — bypasses all controller/service/repository routing
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getData(AppConstants.coffeeShopListUri);
      if (response.statusCode == 200 && mounted) {
        final dataArray = response.body['coffee_shops'] ?? response.body['data'];
        if (dataArray is List) {
          final shops = dataArray.map((item) {
            final data = _normalizeCoffeeShopData(Map<String, dynamic>.from(item));
            return Restaurant.fromJson(data);
          }).toList();
          setState(() {
            _coffeeShops = shops;
            _isLoading = false;
          });
          _applyFilters();
          return;
        }
      }
    } catch (e) {
      debugPrint('Coffee shop direct API call failed: $e');
    }

    // Fallback
    if (mounted) {
      setState(() {
        _coffeeShops = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    if (_coffeeShops == null) {
      _filteredCoffeeShops = null;
      return;
    }

    List<Restaurant> filtered = List<Restaurant>.from(_coffeeShops!);

    // Apply Open Now filter
    if (_openNowFilter) {
      filtered = filtered.where((shop) {
        return shop.open == 1 && (shop.active ?? true);
      }).toList();
    }

    // Apply Free Delivery filter
    if (_freeDeliveryFilter) {
      filtered = filtered.where((shop) {
        return shop.freeDelivery ?? false;
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case SortOption.popular:
        // Keep default order (already sorted by popularity from API)
        break;
      case SortOption.latest:
        filtered.sort((a, b) {
          final aId = a.id ?? 0;
          final bId = b.id ?? 0;
          return bId.compareTo(aId); // Higher ID = newer
        });
        break;
      case SortOption.rating:
        filtered.sort((a, b) {
          final aRating = a.avgRating ?? 0.0;
          final bRating = b.avgRating ?? 0.0;
          return bRating.compareTo(aRating); // Higher rating first
        });
        break;
    }

    setState(() {
      _filteredCoffeeShops = filtered;
    });
  }

  void _onSortChanged(SortOption option) {
    setState(() {
      _sortBy = option;
    });
    _applyFilters();
  }

  void _onOpenNowChanged(bool value) {
    setState(() {
      _openNowFilter = value;
    });
    _applyFilters();
  }

  void _onFreeDeliveryChanged(bool value) {
    setState(() {
      _freeDeliveryFilter = value;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'coffee_shops'.tr),
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
                      // Categories
                      BusinessTypeCategoriesWidget(businessType: 'coffee_shop'),

                      // All Coffee Shops with pagination
                      _buildAllCoffeeShopsSection(context),

                      const SizedBox(height: 20),
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
        onTap: () => Get.toNamed(RouteHelper.getSearchRoute(businessType: 'coffee_shop')),
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
                'search_coffee'.tr,
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

  Widget _buildAllCoffeeShopsSection(BuildContext context) {
    if (_filteredCoffeeShops == null || _isLoading) {
      return _buildCoffeeShopsShimmer();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'all_coffee_shops'.tr,
              style: robotoBold.copyWith(fontSize: 16),
            ),
          ),

          // Filter Bar (under title)
          CategoryFilterBarWidget(
            selectedSort: _sortBy,
            openNowFilter: _openNowFilter,
            freeDeliveryFilter: _freeDeliveryFilter,
            onSortChanged: _onSortChanged,
            onOpenNowChanged: _onOpenNowChanged,
            onFreeDeliveryChanged: _onFreeDeliveryChanged,
          ),

          if (_filteredCoffeeShops!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('no_restaurant_available'.tr, style: robotoRegular),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredCoffeeShops!.length,
              itemBuilder: (context, index) {
                final coffeeShop = _filteredCoffeeShops![index];
                return _buildCoffeeShopCard(context, coffeeShop);
              },
            ),
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCoffeeShopCard(BuildContext context, Restaurant coffeeShop) {
    bool isAvailable = coffeeShop.open == 1 && (coffeeShop.active ?? false);
    String characteristics = '';
    if (coffeeShop.characteristics != null) {
      for (var v in coffeeShop.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    // Get image URLs with fallbacks
    final coverUrl = coffeeShop.coverPhotoFullUrl ?? '';
    final logoUrl = coffeeShop.logoFullUrl ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => RouteHelper.navigateToStoreOrShowClosedDialog(coffeeShop, context, businessType: 'coffee_shop'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CustomImageWidget(
                      image: coverUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      isRestaurant: true,
                    ),
                  ),
                  // Closed overlay
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'closed_now'.tr,
                              style: robotoBold.copyWith(color: Colors.white, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            (coffeeShop.avgRating ?? 0).toStringAsFixed(1),
                            style: robotoMedium.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Logo
                  Positioned(
                    bottom: -25,
                    left: 12,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          image: logoUrl,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          isRestaurant: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Info section
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffeeShop.name ?? '',
                      style: robotoBold.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (characteristics.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        characteristics,
                        style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(HeroiconsOutline.clock, size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 4),
                        Text(
                          coffeeShop.deliveryTime ?? '',
                          style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor),
                        ),
                        if (coffeeShop.freeDelivery ?? false) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'free_delivery'.tr,
                              style: robotoMedium.copyWith(fontSize: 10, color: Colors.green),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildCoffeeShopsShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(3, (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(16),
          ),
        )),
      ),
    );
  }
}
