import 'dart:convert';

import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:mnjood/features/restaurant/domain/models/vendor_banner_model.dart';
import 'package:mnjood/features/restaurant/domain/repositories/restaurant_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantRepository implements RestaurantRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RestaurantRepository({required this.apiClient, required this.sharedPreferences});

  /// Normalize coffee shop API response to match Restaurant model structure
  /// Handles both /list format (id, name) and /info format (store_id, store_name)
  Map<String, dynamic> _normalizeCoffeeShopData(Map<String, dynamic> data) {
    // Handle both /list format (id, name) and /info format (store_id, store_name)
    // Ensure id is an int (API may return as string)
    final rawId = data['id'] ?? data['store_id'];
    final id = rawId is String ? int.tryParse(rawId) : rawId;
    final name = data['name'] ?? data['store_name'];

    // Convert rating to double/num
    final rawRating = data['avg_rating'] ?? data['rating'] ?? 0;
    final rating = rawRating is String ? double.tryParse(rawRating) ?? 0 : rawRating;

    return {
      ...data,
      'id': id,
      'name': name,
      'business_type': 'coffee_shop',
      // Map logo to logo_full_url if not present
      'logo_full_url': data['logo_full_url'] ?? data['logo'],
      'logoFullUrl': data['logo_full_url'] ?? data['logo'],
      // Map cover_photo to cover_photo_full_url if not present
      'cover_photo_full_url': data['cover_photo_full_url'] ?? data['cover_photo'],
      'coverPhotoFullUrl': data['cover_photo_full_url'] ?? data['cover_photo'],
      // Set default values for missing fields
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

  @override
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId, {String? businessType}) async {
    RecommendedProductModel? recommendedProductModel;

    // Use business-type specific endpoint for supermarkets, pharmacies, and coffee shops
    String uri;
    bool isCoffeeShop = false;
    if (businessType == 'supermarket') {
      uri = '${AppConstants.supermarketProductsUri}$restaurantId/products/recommended?page=1&per_page=50';
    } else if (businessType == 'pharmacy') {
      uri = '${AppConstants.pharmacyProductsUri}$restaurantId/products/recommended?page=1&per_page=50';
    } else if (businessType == 'coffee_shop') {
      // V1 coffee API: /api/v1/coffee/products/recommended
      uri = AppConstants.coffeeShopRecommendedProductsUri;
      isCoffeeShop = true;
    } else {
      // Default for restaurants - include vendor_type if specified
      String vendorTypeParam = businessType != null ? '&vendor_type=$businessType' : '';
      uri = '${AppConstants.restaurantRecommendedItemUri}?vendor_id=$restaurantId&page=1&per_page=50$vendorTypeParam';
    }

    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200 && response.body != null) {
      // V3 API: Handle both List and Map responses
      // V1 coffee API: data is in 'products' or 'data' key
      var data = isCoffeeShop ? (response.body['products'] ?? response.body['data']) : response.body['data'];
      if (data != null) {
        if (data is List) {
          recommendedProductModel = RecommendedProductModel.fromJson({'products': data});
        } else if (data is Map<String, dynamic>) {
          recommendedProductModel = RecommendedProductModel.fromJson(data);
        }
      }
    }
    return recommendedProductModel;
  }

  @override
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    List<Product> suggestedItems = [];  // Initialize to empty list instead of null
    // Backend now filters by vendor_id automatically
    Response response = await apiClient.getData('${AppConstants.cartRestaurantSuggestedItemsUri}?vendor_id=$restaurantID');
    if (response.statusCode == 200) {
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'];
      if(dataArray is List) {
        dataArray.forEach((product) {
          try {
            suggestedItems.add(Product.fromJson(product));
          } catch (e) {
            // Skip products that fail to parse
          }
        });
      }
    }
    // Return empty list even on 404/error - prevents null pointer exceptions
    return suggestedItems;
  }

  @override
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, String type, {String? businessType}) async {
    ProductModel? productModel;
    // V3 API: Use page-based pagination (offset is already the page number)
    int page = offset;
    // V3 API: Don't send category_id when it's 0 or null (means "all categories")
    String categoryParam = (categoryID != null && categoryID != 0) ? '&category_id=$categoryID' : '';

    // Use business-type specific endpoint for supermarkets, pharmacies, and coffee shops
    String uri;
    bool isCoffeeShop = false;
    if (businessType == 'supermarket') {
      // Use larger per_page for supermarkets to load all products for section filtering
      uri = '${AppConstants.supermarketProductsUri}$restaurantID/products?page=$page&per_page=100&type=$type$categoryParam';
    } else if (businessType == 'pharmacy') {
      uri = '${AppConstants.pharmacyProductsUri}$restaurantID/products?page=$page&per_page=100&type=$type$categoryParam';
    } else if (businessType == 'coffee_shop') {
      // V1 coffee API: /api/v1/coffee/{shop_id}/products
      uri = '${AppConstants.coffeeShopItemsUri}$restaurantID/products?page=$page&per_page=100$categoryParam';
      isCoffeeShop = true;
    } else {
      // Default for restaurants - use vendor_id parameter with vendor_type filter
      String vendorTypeParam = businessType != null ? '&vendor_type=$businessType' : '';
      uri = '${AppConstants.restaurantProductUri}&vendor_id=$restaurantID$categoryParam&page=$page&per_page=10&type=$type$vendorTypeParam';
    }

    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200 && response.body != null) {
      // V3 API: Handle both List and Map responses
      // V1 coffee API: data is in 'products' or 'data' key
      var data = isCoffeeShop ? (response.body['products'] ?? response.body['data']) : response.body['data'];
      if (data != null) {
        if (data is List) {
          // Preserve pagination metadata from response
          productModel = ProductModel.fromJson({
            'products': data,
            'total_size': response.body['meta']?['pagination']?['total'] ?? response.body['meta']?['total'] ?? response.body['total'] ?? data.length,
            'offset': response.body['meta']?['pagination']?['current_page'] ?? response.body['meta']?['current_page'] ?? page,
          });
        } else if (data is Map<String, dynamic>) {
          // Check for different possible keys for products array
          var products = data['products'] ?? data['items'] ?? data['foods'];
          if (data['products'] == null && products != null && products is List) {
            data['products'] = products;
          }
          // If no products key exists but data itself contains product array keys
          if (data['products'] == null && data.containsKey('id')) {
            // Single product, wrap in array
            data = {'products': [data], 'total_size': 1};
          }
          productModel = ProductModel.fromJson(data);
        }
      }
    }
    return productModel;
  }

  @override
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type, {String? businessType}) async {
    ProductModel? restaurantSearchProductModel;
    // V3 API: Use GET with query parameter for vendor-specific product search
    int page = offset;

    // Build endpoint based on business type - use product list endpoint with search query
    String uri;
    bool isCoffeeShop = false;
    if (businessType == 'supermarket') {
      uri = '${AppConstants.supermarketProductsUri}$storeID/products?page=$page&per_page=10&type=$type&search=${Uri.encodeQueryComponent(searchText)}';
    } else if (businessType == 'pharmacy') {
      uri = '${AppConstants.pharmacyProductsUri}$storeID/products?page=$page&per_page=10&type=$type&search=${Uri.encodeQueryComponent(searchText)}';
    } else if (businessType == 'coffee_shop') {
      // V1 coffee API: /api/v1/coffee/{shop_id}/products with search
      uri = '${AppConstants.coffeeShopItemsUri}$storeID/products?page=$page&per_page=10&search=${Uri.encodeQueryComponent(searchText)}';
      isCoffeeShop = true;
    } else {
      // Default for restaurants - use vendor_id parameter with search and vendor_type filter
      String vendorTypeParam = businessType != null ? '&vendor_type=$businessType' : '';
      uri = '${AppConstants.restaurantProductUri}&vendor_id=$storeID&page=$page&per_page=10&type=$type&search=${Uri.encodeQueryComponent(searchText)}$vendorTypeParam';
    }

    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200 && response.body != null) {
      // V3 API: Handle both List and Map responses
      // V1 coffee API: data is in 'products' or 'data' key
      var data = isCoffeeShop ? (response.body['products'] ?? response.body['data']) : response.body['data'];
      if (data != null) {
        if (data is List) {
          // Preserve pagination metadata from response
          restaurantSearchProductModel = ProductModel.fromJson({
            'products': data,
            'total_size': response.body['meta']?['pagination']?['total'] ?? response.body['meta']?['total'] ?? response.body['total'] ?? data.length,
            'offset': response.body['meta']?['pagination']?['current_page'] ?? response.body['meta']?['current_page'] ?? page,
          });
        } else if (data is Map<String, dynamic>) {
          restaurantSearchProductModel = ProductModel.fromJson(data);
        }
      }
    }
    return restaurantSearchProductModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode, String? businessType}) async {
    return await _getRestaurantDetails(id!, slug, languageCode, businessType);
  }

  Future<Restaurant?> _getRestaurantDetails(String restaurantID, String slug, String? languageCode, String? businessType) async {
    Restaurant? restaurant;
    Map<String, String>? header;
    if(slug.isNotEmpty){
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token), [],
        languageCode, '', '', setHeader: false,
      );
    }

    // Select endpoint based on business type
    String endpoint;
    bool isCoffeeShop = false;
    switch(businessType) {
      case 'pharmacy':
        endpoint = AppConstants.pharmacyDetailsUri;
        break;
      case 'supermarket':
        endpoint = AppConstants.supermarketDetailsUri;
        break;
      case 'coffee_shop':
        endpoint = AppConstants.coffeeShopDetailsUri;
        isCoffeeShop = true;
        break;
      default:
        endpoint = AppConstants.restaurantDetailsUri;
    }

    // V3 API: Restaurant details endpoint - use business-type-specific endpoint
    // V1 coffee API: endpoint format is /api/v1/coffee/{shop_id}/info
    String url = isCoffeeShop
        ? '$endpoint${slug.isNotEmpty ? slug : restaurantID}/info'
        : '$endpoint${slug.isNotEmpty ? slug : restaurantID}';
    Response response = await apiClient.getData(url, headers: header);
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      // V1 coffee API: /info endpoint returns data directly in response body
      var data = isCoffeeShop
          ? (response.body['coffee_shop'] ?? response.body['data'] ?? response.body)
          : (response.body['data'] ?? response.body);
      // Normalize coffee shop data or inject business_type
      if (data is Map<String, dynamic>) {
        data = isCoffeeShop
            ? _normalizeCoffeeShopData(data)
            : {...data, 'business_type': businessType ?? 'restaurant'};
      }
      restaurant = Restaurant.fromJson(data);
    }
    return restaurant;
  }

  @override
  Future<RestaurantModel?> getList({int? offset, String? filterBy, int? topRated, int? discount, int? veg, int? nonVeg, bool fromMap = false, DataSourceEnum? source, String? businessType}) async {
    RestaurantModel? restaurantModel;

    // Select endpoint based on business type
    String baseEndpoint = AppConstants.restaurantUri;  // Default to restaurants
    if(businessType != null && businessType != 'all') {
      switch(businessType) {
        case 'restaurant':
          baseEndpoint = AppConstants.restaurantUri;
          break;
        case 'supermarket':
          baseEndpoint = AppConstants.supermarketsUri;
          break;
        case 'pharmacy':
          baseEndpoint = AppConstants.pharmaciesUri;
          break;
      }
    }

    String cacheId = '$baseEndpoint-$businessType';

    switch(source!){
      case DataSourceEnum.client:
        // V3 API: Use query parameters for pagination and filters
        String url = '$baseEndpoint?page=${((offset ?? 0) ~/ 12) + 1}&per_page=${fromMap ? 20 : 12}';
        if(filterBy != null && filterBy != 'all') {
          url += '&filter_by=$filterBy';
        }
        if(topRated == 1) {
          url += '&top_rated=1';
        }
        if(discount == 1) {
          url += '&discount=1';
        }
        if(veg == 1) {
          url += '&veg=1';
        }
        if(nonVeg == 1) {
          url += '&non_veg=1';
        }

        Response response = await apiClient.getData(url);
        if(response.statusCode == 200){
          // V3 API: Inject business_type into each vendor before parsing
          var body = response.body;
          if (body['data'] is List && businessType != null) {
            for (var vendor in body['data']) {
              vendor['business_type'] = businessType;
            }
          }
          restaurantModel = RestaurantModel.fromJson(body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return restaurantModel;
  }

  @override
  Future<List<Restaurant>?> getRestaurantList({String? type, bool isRecentlyViewed = false, bool isOrderAgain = false, bool isPopular = false, bool isLatest = false, DataSourceEnum? source, String? businessType}) async {
    if(isRecentlyViewed) {
      return _getRecentlyViewedRestaurantList(type!, source: source, businessType: businessType);
    } else if(isOrderAgain) {
      return _getOrderAgainRestaurantList(source: source, businessType: businessType);
    } else if(isPopular) {
      return _getPopularRestaurantList(type!, source: source, businessType: businessType);
    } else if(isLatest) {
      return _getLatestRestaurantList(type!, source: source, businessType: businessType);
    }
    return null;
  }

  Future<List<Restaurant>?> _getLatestRestaurantList(String type, {DataSourceEnum? source, String? businessType}) async {
    List<Restaurant>? latestRestaurantList;

    // Select endpoint based on business type
    String baseEndpoint = AppConstants.restaurantUri;
    bool isCoffeeShop = false;
    if(businessType != null && businessType != 'all') {
      switch(businessType) {
        case 'restaurant':
          baseEndpoint = AppConstants.restaurantUri;
          break;
        case 'supermarket':
          baseEndpoint = AppConstants.supermarketsUri;
          break;
        case 'pharmacy':
          baseEndpoint = AppConstants.pharmaciesUri;
          break;
        case 'coffee_shop':
          baseEndpoint = AppConstants.coffeeShopListUri;
          isCoffeeShop = true;
          break;
      }
    }

    String cacheId = '$baseEndpoint-latest-$businessType';

    switch(source!){
      case DataSourceEnum.client:
        // V3 API: Use sort_by parameter, V1 coffee API: use direct endpoint
        String url = isCoffeeShop ? baseEndpoint : '$baseEndpoint?sort_by=latest&type=$type';

        Response response = await apiClient.getData(url);
        if(response.statusCode == 200){
          latestRestaurantList = [];
          // V3 API: Extract data array from response wrapper
          // V1 coffee API: data is in 'coffee_shops' or 'data' key
          var dataArray = response.body['coffee_shops'] ?? response.body['data'];
          if(dataArray is List) {
            dataArray.forEach((restaurant) {
              // Normalize coffee shop data or inject business_type
              Map<String, dynamic> normalizedData;
              if (isCoffeeShop) {
                normalizedData = _normalizeCoffeeShopData(Map<String, dynamic>.from(restaurant));
              } else {
                normalizedData = Map<String, dynamic>.from(restaurant);
                normalizedData['business_type'] = businessType ?? 'restaurant';
              }
              latestRestaurantList!.add(Restaurant.fromJson(normalizedData));
            });
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataArray), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          latestRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            // Normalize coffee shop data or inject business_type
            Map<String, dynamic> normalizedData;
            if (isCoffeeShop) {
              normalizedData = _normalizeCoffeeShopData(Map<String, dynamic>.from(restaurant));
            } else {
              normalizedData = Map<String, dynamic>.from(restaurant);
              normalizedData['business_type'] = businessType ?? 'restaurant';
            }
            latestRestaurantList!.add(Restaurant.fromJson(normalizedData));
          });
        }
    }
    return latestRestaurantList;
  }

  Future<List<Restaurant>?> _getPopularRestaurantList(String type, {DataSourceEnum? source, String? businessType}) async {
    List<Restaurant>? popularRestaurantList;

    // Select endpoint based on business type
    String baseEndpoint = AppConstants.restaurantUri;
    bool isCoffeeShop = false;
    if(businessType != null && businessType != 'all') {
      switch(businessType) {
        case 'restaurant':
          baseEndpoint = AppConstants.restaurantUri;
          break;
        case 'supermarket':
          baseEndpoint = AppConstants.supermarketsUri;
          break;
        case 'pharmacy':
          baseEndpoint = AppConstants.pharmaciesUri;
          break;
        case 'coffee_shop':
          baseEndpoint = AppConstants.coffeeShopListUri;
          isCoffeeShop = true;
          break;
      }
    }

    String cacheId = '$baseEndpoint-popular-$businessType';

    switch(source!){
      case DataSourceEnum.client:
        // V3 API: Use sort_by parameter, V1 coffee API: use direct endpoint
        String url = isCoffeeShop ? baseEndpoint : '$baseEndpoint?sort_by=popular&type=$type';

        Response response = await apiClient.getData(url);
        if(response.statusCode == 200){
          popularRestaurantList = [];
          // V3 API: Extract data array from response wrapper
          // V1 coffee API: data is in 'coffee_shops' or 'data' key
          var dataArray = response.body['coffee_shops'] ?? response.body['data'];
          if(dataArray is List) {
            dataArray.forEach((restaurant) {
              // Normalize coffee shop data or inject business_type
              Map<String, dynamic> normalizedData;
              if (isCoffeeShop) {
                normalizedData = _normalizeCoffeeShopData(Map<String, dynamic>.from(restaurant));
              } else {
                normalizedData = Map<String, dynamic>.from(restaurant);
                normalizedData['business_type'] = businessType ?? 'restaurant';
              }
              popularRestaurantList!.add(Restaurant.fromJson(normalizedData));
            });
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataArray), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          popularRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            // Normalize coffee shop data or inject business_type
            Map<String, dynamic> normalizedData;
            if (isCoffeeShop) {
              normalizedData = _normalizeCoffeeShopData(Map<String, dynamic>.from(restaurant));
            } else {
              normalizedData = Map<String, dynamic>.from(restaurant);
              normalizedData['business_type'] = businessType ?? 'restaurant';
            }
            popularRestaurantList!.add(Restaurant.fromJson(normalizedData));
          });
        }
    }

    return popularRestaurantList;
  }

  Future<List<Restaurant>?> _getRecentlyViewedRestaurantList(String type, {DataSourceEnum? source, String? businessType}) async {
    List<Restaurant>? recentlyViewedRestaurantList;

    // Select endpoint based on business type
    String baseEndpoint = AppConstants.recentlyViewedRestaurantUri;
    if(businessType != null && businessType != 'all') {
      switch(businessType) {
        case 'restaurant':
          baseEndpoint = AppConstants.recentlyViewedRestaurantUri;
          break;
        case 'supermarket':
          baseEndpoint = '${AppConstants.supermarketsUri}/recently-viewed';
          break;
        case 'pharmacy':
          baseEndpoint = '${AppConstants.pharmaciesUri}/recently-viewed';
          break;
      }
    }

    String cacheId = '$baseEndpoint-$businessType';

    switch(source!){
      case DataSourceEnum.client:
        String url = '$baseEndpoint?type=$type';

        Response response = await apiClient.getData(url);
        if(response.statusCode == 200){
          recentlyViewedRestaurantList = [];
          // V3 API: Extract data array from response wrapper
          var dataArray = response.body['data'];
          if(dataArray is List) {
            dataArray.forEach((restaurant) {
              // Inject business_type before parsing
              restaurant['business_type'] = businessType ?? 'restaurant';
              recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
            });
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body['data']), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          recentlyViewedRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            // Inject business_type before parsing
            restaurant['business_type'] = businessType ?? 'restaurant';
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return recentlyViewedRestaurantList;
  }

  Future<List<Restaurant>?> _getOrderAgainRestaurantList({DataSourceEnum? source, String? businessType}) async {
    List<Restaurant>? orderAgainRestaurantList;
    String cacheId = '${AppConstants.orderAgainUri}-$businessType';

    switch(source!){
      case DataSourceEnum.client:
        String url = AppConstants.orderAgainUri;
        // V3 API: Add business_type query parameter if specified
        if(businessType != null && businessType != 'all') {
          url += '?vendor_type=$businessType';
        }

        Response response = await apiClient.getData(url);
        if(response.statusCode == 200){
          orderAgainRestaurantList = [];
          // V3 API: Extract data array from response wrapper
          var dataArray = response.body['data'];
          if(dataArray is List) {
            dataArray.forEach((restaurant) {
              // Inject business_type before parsing
              restaurant['business_type'] = businessType ?? 'restaurant';
              orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
            });
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body['data']), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          orderAgainRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            // Inject business_type before parsing
            restaurant['business_type'] = businessType ?? 'restaurant';
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return orderAgainRestaurantList;
  }

  @override
  Future<List<Restaurant>?> getDiscountRestaurantList({required String businessType, required DataSourceEnum source}) async {
    List<Restaurant>? discountRestaurantList;

    // Select endpoint based on business type
    String endpoint;
    switch(businessType) {
      case 'restaurant':
        endpoint = AppConstants.restaurantDiscountsUri;
        break;
      case 'supermarket':
        endpoint = AppConstants.supermarketDiscountsUri;
        break;
      case 'pharmacy':
        endpoint = AppConstants.pharmacyDiscountsUri;
        break;
      default:
        endpoint = AppConstants.restaurantDiscountsUri;
    }

    String cacheId = '$endpoint-$businessType';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(endpoint);
        if(response.statusCode == 200) {
          discountRestaurantList = [];
          // V3 API: Extract data array from response wrapper
          var dataArray = response.body['data'];
          if(dataArray is List) {
            for (var restaurant in dataArray) {
              // Inject business_type before parsing
              restaurant['business_type'] = businessType;
              discountRestaurantList.add(Restaurant.fromJson(restaurant));
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body['data']), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          discountRestaurantList = [];
          var dataArray = jsonDecode(cacheResponseData);
          if(dataArray is List) {
            for (var restaurant in dataArray) {
              // Inject business_type before parsing
              restaurant['business_type'] = businessType;
              discountRestaurantList.add(Restaurant.fromJson(restaurant));
            }
          }
        }
    }
    return discountRestaurantList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<VendorBannerModel>?> getVendorBanners(int vendorId) async {
    List<VendorBannerModel>? vendorBanners;
    Response response = await apiClient.getData('${AppConstants.vendorBannersUri}$vendorId/banners');
    if (response.statusCode == 200) {
      vendorBanners = [];
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'];
      if (dataArray is List) {
        for (var banner in dataArray) {
          vendorBanners.add(VendorBannerModel.fromJson(banner));
        }
      }
    }
    return vendorBanners;
  }

  @override
  Future<List<CategoryModel>?> getVendorCategories(int vendorId, String? businessType) async {
    List<CategoryModel>? categories;

    // Build endpoint based on business type - use V1 filter endpoints
    // All filter endpoints return: { "categories": [...], "price_range": {...}, "sort_options": [...], "veg_filter": true }
    String uri;
    if (businessType == 'pharmacy') {
      // Pharmacy filter: /api/v1/pharmacy/{id}/filters
      uri = '${AppConstants.pharmacyFiltersUri}$vendorId/filters';
    } else if (businessType == 'supermarket') {
      // Supermarket filter: /api/v1/mnjood-mart/filters (no ID needed)
      uri = AppConstants.supermarketFiltersUri;
    } else if (businessType == 'coffee_shop') {
      // Coffee shop filter: /api/v1/coffee/{id}/filters
      uri = '${AppConstants.coffeeShopFiltersUri}$vendorId/filters';
    } else if (businessType == 'restaurant') {
      // Restaurant filter: /api/v1/restaurant-food/{id}/filters
      uri = '${AppConstants.restaurantFiltersUri}$vendorId/filters';
    } else {
      return null; // Unknown business type
    }

    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200) {
      categories = [];
      // All V1 filter endpoints return categories in 'categories' key
      var dataArray = response.body['categories'] ?? response.body['data'];
      if (dataArray is List) {
        for (var category in dataArray) {
          categories.add(CategoryModel.fromJson(category));
        }
      }
    }
    return categories;
  }
}