import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/home/domain/models/banner_model.dart';
import 'package:mnjood/features/home/domain/models/cashback_model.dart';
import 'package:mnjood/features/home/domain/models/home_section_model.dart';
import 'package:mnjood/features/home/domain/models/main_category_model.dart';
import 'package:mnjood/features/home/domain/models/slider_model.dart';
import 'package:mnjood/features/home/domain/repositories/home_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';

class HomeRepository implements HomeRepositoryInterface {
  final ApiClient apiClient;
  HomeRepository({required this.apiClient});

  @override
  Future<BannerModel?> getList({int? offset, DataSourceEnum? source}) async {
    return await _getBannerList(source: source!);
  }

  Future<BannerModel?> _getBannerList({required DataSourceEnum source}) async {
    BannerModel? bannerModel;
    String cacheId = AppConstants.bannerUri;

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.bannerUri);
        if(response.statusCode == 200) {
          // V3 API: Extract data from response wrapper
          var data = response.body['data'] ?? response.body;
          bannerModel = BannerModel.fromJson(data);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(data), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          bannerModel = BannerModel.fromJson(jsonDecode(cacheResponseData));
        }
    }

    return bannerModel;
  }

  @override
  Future<List<CashBackModel>?> getCashBackOfferList({DataSourceEnum? source}) async {
    List<CashBackModel>? cashBackModelList;
    String cacheId = AppConstants.cashBackOfferListUri;

    switch(source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.cashBackOfferListUri);
        if(response.statusCode == 200) {
          cashBackModelList = [];
          // V3 API: Extract data array from response wrapper
          var dataArray = response.body['data'] ?? response.body;
          if (dataArray is List) {
            for (var data in dataArray) {
              cashBackModelList!.add(CashBackModel.fromJson(data));
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataArray), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          cashBackModelList = [];
          jsonDecode(cacheResponseData).forEach((data) {
            cashBackModelList!.add(CashBackModel.fromJson(data));
          });
        }
    }
    return cashBackModelList;
  }

  @override
  Future<CashBackModel?> getCashBackData(double amount) async {
    CashBackModel? cashBackModel;
    Response response = await apiClient.getData('${AppConstants.getCashBackAmountUri}?amount=$amount');
    if(response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      if (data is Map<String, dynamic>) {
        cashBackModel = CashBackModel.fromJson(data);
      }
    }
    return cashBackModel;
  }

  @override
  Future<List<MainCategoryModel>?> getMainCategories({DataSourceEnum? source}) async {
    List<MainCategoryModel>? mainCategoriesList;
    String cacheId = AppConstants.mainCategoriesUri;

    switch(source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.mainCategoriesUri);
        if(response.statusCode == 200) {
          mainCategoriesList = [];
          // V3 API: Extract data array from response
          var dataArray = response.body['data'] ?? response.body['categories'] ?? response.body;
          if (dataArray is List) {
            for (var data in dataArray) {
              mainCategoriesList.add(MainCategoryModel.fromJson(data));
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataArray), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          mainCategoriesList = [];
          jsonDecode(cacheResponseData).forEach((data) {
            mainCategoriesList!.add(MainCategoryModel.fromJson(data));
          });
        }
    }
    return mainCategoriesList;
  }

  @override
  Future<ProductModel?> getMnjoodMartProducts({int page = 1, int? categoryId, DataSourceEnum? source}) async {
    ProductModel? productModel;
    // V1 API uses offset/limit instead of page/per_page
    int limit = 10;
    int offset = (page - 1) * limit;
    String mnjoodMartUri = '${AppConstants.mnjoodMartProductsUri}?limit=$limit&offset=$offset';
    if (categoryId != null) {
      mnjoodMartUri += '&category_id=$categoryId';
    }
    String cacheId = 'mnjood_mart_products_page_${page}_cat_${categoryId ?? 'all'}';

    switch(source!) {
      case DataSourceEnum.client:
        debugPrint('=== getMnjoodMartProducts: Calling API: $mnjoodMartUri ===');
        Response response = await apiClient.getData(mnjoodMartUri);
        debugPrint('=== getMnjoodMartProducts: Response status: ${response.statusCode} ===');
        if(response.statusCode == 200) {
          // V1 API returns data directly (total_size, limit, offset, products)
          productModel = ProductModel.fromJson(response.body);
          // Mnjood Mart is supermarket ID 12 - set this for all products since V1 API may not include it
          for (var product in productModel?.products ?? []) {
            product.supermarketId ??= 12;
            product.restaurantId ??= 12;
          }
          debugPrint('=== getMnjoodMartProducts: Parsed ${productModel?.products?.length ?? 0} products ===');
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        } else {
          debugPrint('=== getMnjoodMartProducts: API Error: ${response.body} ===');
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          productModel = ProductModel.fromJson(jsonDecode(cacheResponseData));
          // Mnjood Mart is supermarket ID 12 - set this for all products since V1 API may not include it
          for (var product in productModel?.products ?? []) {
            product.supermarketId ??= 12;
            product.restaurantId ??= 12;
          }
        }
    }
    return productModel;
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
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<SlidersResponse?> getSliders({DataSourceEnum? source}) async {
    SlidersResponse? slidersResponse;
    String cacheId = AppConstants.slidersUri;

    switch(source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.slidersUri);
        if(response.statusCode == 200) {
          slidersResponse = SlidersResponse.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          slidersResponse = SlidersResponse.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return slidersResponse;
  }

  @override
  Future<List<CategoryModel>?> getRestaurantCategories({DataSourceEnum? source}) async {
    List<CategoryModel>? categoryList;
    String cacheId = AppConstants.restaurantCategoriesUri;

    switch(source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.restaurantCategoriesUri);
        if(response.statusCode == 200) {
          categoryList = [];
          // V1 API: Extract categories array from response
          var dataArray = response.body['categories'] ?? response.body['data'] ?? response.body;
          if (dataArray is List) {
            for (var data in dataArray) {
              categoryList.add(CategoryModel.fromJson(data));
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataArray), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((data) {
            categoryList!.add(CategoryModel.fromJson(data));
          });
        }
    }
    return categoryList;
  }

  @override
  Future<List<CategoryModel>?> getCategoriesByBusinessType(String businessType, {DataSourceEnum? source}) async {
    List<CategoryModel>? categoryList;

    // Get the appropriate URI based on business type
    String uri;
    String normalizedType = businessType.toLowerCase();

    // Handle supermarket/mnjood_mart type
    if (normalizedType == 'supermarket' || normalizedType == 'mnjood_mart' || normalizedType == 'mnjood mart' || normalizedType.contains('supermarket')) {
      uri = AppConstants.supermarketCategoriesUri;
    } else if (normalizedType == 'restaurant' || normalizedType == 'food') {
      uri = AppConstants.restaurantCategoriesUri;
    } else if (normalizedType == 'pharmacy') {
      uri = AppConstants.pharmacyCategoriesUri;
    } else if (normalizedType == 'coffee_shop' || normalizedType == 'coffee shop' || normalizedType == 'coffeeshop') {
      uri = AppConstants.coffeeShopCategoriesUri;
    } else {
      uri = AppConstants.restaurantCategoriesUri;
    }

    String cacheId = uri;

    switch(source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if(response.statusCode == 200) {
          categoryList = [];
          // V1 API: Extract categories array from response
          var dataArray = response.body['categories'] ?? response.body['data'] ?? response.body;
          if (dataArray is List) {
            for (var data in dataArray) {
              final category = CategoryModel.fromJson(data);
              // Filter categories: only include those matching the business type
              final categoryType = (data['type'] as String?)?.toLowerCase() ?? 'all';
              // Pharmacy and Coffee shop APIs are already filtered by backend (v1 endpoints), include all
              // Other types: include matching type or 'all'
              if (normalizedType == 'pharmacy' ||
                  normalizedType == 'coffee_shop' ||
                  categoryType == normalizedType ||
                  categoryType == 'all') {
                categoryList.add(category);
              }
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataArray), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((data) {
            final category = CategoryModel.fromJson(data);
            final categoryType = (data['type'] as String?)?.toLowerCase() ?? 'all';
            // Pharmacy and Coffee shop APIs are already filtered by backend (v1 endpoints), include all
            // Other types: include matching type or 'all'
            if (normalizedType == 'pharmacy' ||
                normalizedType == 'coffee_shop' ||
                categoryType == normalizedType ||
                categoryType == 'all') {
              categoryList!.add(category);
            }
          });
        }
    }
    return categoryList;
  }

  @override
  Future<List<HomeSectionModel>?> getHomeSections({DataSourceEnum? source}) async {
    List<HomeSectionModel>? sectionList;
    String cacheId = AppConstants.homeSectionsUri;

    switch(source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.homeSectionsUri);
        if(response.statusCode == 200) {
          sectionList = [];
          var sectionsArray = response.body['sections'] ?? response.body['data'] ?? response.body;
          if (sectionsArray is List) {
            for (var data in sectionsArray) {
              sectionList.add(HomeSectionModel.fromJson(data));
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(sectionsArray), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          sectionList = [];
          jsonDecode(cacheResponseData).forEach((data) {
            sectionList!.add(HomeSectionModel.fromJson(data));
          });
        }
    }
    return sectionList;
  }
}