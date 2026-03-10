import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;

  CategoryRepository({required this.apiClient});

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryModel>?> getList({int? offset, DataSourceEnum? source, String? search}) async {
    // Generic category listing removed — use business-type-specific endpoints instead
    return null;
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID) async {
    List<CategoryModel>? subCategoryList;
    Response response = await apiClient.getData('${AppConstants.subCategoryUri}$parentID/children');
    if (response.statusCode == 200) {
      subCategoryList= [];
      subCategoryList.add(CategoryModel(id: int.parse(parentID!), name: 'all'.tr));
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'] ?? response.body;
      if(dataArray is List) {
        dataArray.forEach((category) => subCategoryList!.add(CategoryModel.fromJson(category)));
      }
    }
    return subCategoryList;
  }

  @override
  Future<ProductModel?> getCategoryProductList(String? categoryID, int offset, String type) async {
    ProductModel? productModel;
    Response response = await apiClient.getData('${AppConstants.categoryProductUri}$categoryID/products?limit=10&offset=$offset&type=$type');
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;

      // Handle different API response formats
      if (data is Map<String, dynamic>) {
        // Format 1: Standard ProductModel format with products array
        if (data['products'] != null) {
          productModel = ProductModel.fromJson(data);
        }
        // Format 2: Direct array of products without wrapper
        else if (data is List) {
          productModel = ProductModel(
            products: (data as List).map((p) => Product.fromJson(p)).toList(),
            totalSize: (data as List).length,
            limit: '10',
            offset: offset,
          );
        }
      }
      // Format 3: Direct array response in body['data']
      else if (data is List) {
        List<Product> products = [];
        for (var item in data) {
          try {
            products.add(Product.fromJson(item));
          } catch (e) {
            print('Error parsing product: $e');
          }
        }
        // Extract total from meta.pagination if available, fallback to products.length
        int totalSize = products.length;
        if (response.body['meta']?['pagination']?['total'] != null) {
          totalSize = response.body['meta']['pagination']['total'];
        } else if (response.body['total'] != null) {
          totalSize = response.body['total'];
        } else if (products.length >= 10) {
          // No total provided, but we got a full page — assume more exist
          totalSize = (offset * 10) + 10;
        }
        productModel = ProductModel(
          products: products,
          totalSize: totalSize,
          limit: '10',
          offset: offset,
        );
      }
    }
    return productModel;
  }

  @override
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, int offset, String type, {String? businessType}) async {
    RestaurantModel? restaurantModel;
    // Use businessType for filtering vendors, fallback to 'restaurant' if not provided
    String vendorType = businessType ?? 'restaurant';
    String url = '${AppConstants.categoryRestaurantUri}$categoryID/vendors?limit=10&offset=$offset&type=$vendorType';
    print('DEBUG: getCategoryRestaurantList URL: $url');
    print('DEBUG: businessType param: $businessType, vendorType: $vendorType');
    Response response = await apiClient.getData(url);
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');
    if (response.statusCode == 200) {
      // Use RestaurantModel.fromJson which handles V3 format (with 'data' array)
      try {
        restaurantModel = RestaurantModel.fromJson(response.body);
        print('DEBUG: Parsed ${restaurantModel.restaurants?.length ?? 0} restaurants');
      } catch (e) {
        print('DEBUG: Error parsing RestaurantModel: $e');
        // Fallback: try parsing data array directly
        var data = response.body['data'] ?? response.body;
        if (data is List) {
          List<Restaurant> restaurants = [];
          for (var item in data) {
            try {
              restaurants.add(Restaurant.fromJson(item));
            } catch (e2) {
              print('Error parsing restaurant: $e2');
            }
          }
          // Extract total from meta.pagination if available, fallback to restaurants.length
          int totalSize = restaurants.length;
          if (response.body['meta'] != null &&
              response.body['meta']['pagination'] != null &&
              response.body['meta']['pagination']['total'] != null) {
            totalSize = response.body['meta']['pagination']['total'];
          }
          restaurantModel = RestaurantModel(
            restaurants: restaurants,
            totalSize: totalSize,
          );
        }
      }
    }
    return restaurantModel;
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, String type) async {
    String url;
    if (isRestaurant) {
      url = '${AppConstants.searchUri}restaurants/search?search=${Uri.encodeQueryComponent(query ?? '')}&category_id=$categoryID&type=$type&offset=1&limit=50';
    } else {
      url = '${AppConstants.productSearchUri}?search=${Uri.encodeQueryComponent(query ?? '')}&category_id=$categoryID&type=$type&offset=1&limit=50';
    }
    return await apiClient.getData(url);
  }

  @override
  Future<List<CategoryModel>?> getTopSupermarketCategories() async {
    List<CategoryModel>? categoryList;
    Response response = await apiClient.getData(AppConstants.popularSupermarketCategoriesUri);
    if (response.statusCode == 200) {
      categoryList = [];
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'] ?? response.body;
      if (dataArray is List) {
        for (var category in dataArray) {
          categoryList.add(CategoryModel.fromJson(category));
        }
      }
    }
    return categoryList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}