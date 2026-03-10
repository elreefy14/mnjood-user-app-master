import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/product/domain/repositories/product_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get.dart';

class ProductRepository implements ProductRepositoryInterface {
  final ApiClient apiClient;
  ProductRepository({required this.apiClient});

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Product?> get(String? id, {bool isCampaign = false, int? vendorId, String? businessType}) async {
    Product? product;
    // Determine endpoint based on business type
    String endpoint;
    if (businessType == 'supermarket' && vendorId != null) {
      endpoint = '${AppConstants.supermarketProductsUri}$vendorId/products/$id';
    } else if (businessType == 'pharmacy' && vendorId != null) {
      endpoint = '${AppConstants.pharmacyProductsUri}$vendorId/products/$id';
    } else if (isCampaign) {
      endpoint = '${AppConstants.itemCampaignUri}/$id';
    } else {
      endpoint = '${AppConstants.productDetailsUri}$id';
    }

    debugPrint('ProductRepository.get - endpoint: $endpoint, vendorId: $vendorId, businessType: $businessType');
    Response response = await apiClient.getData(endpoint);
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      product = Product.fromJson(data);
    } else {
      debugPrint('ProductRepository.get - primary endpoint failed: ${response.statusCode}');
      // Fallback: Try regular product endpoint
      if (endpoint != '${AppConstants.productDetailsUri}$id') {
        debugPrint('ProductRepository.get - trying fallback to regular endpoint');
        response = await apiClient.getData('${AppConstants.productDetailsUri}$id');
        if (response.statusCode == 200) {
          var data = response.body['data'] ?? response.body;
          product = Product.fromJson(data);
        } else {
          debugPrint('ProductRepository.get - fallback also failed: ${response.statusCode}');
        }
      }
    }
    return product;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>?> getList({int? offset, String? type, DataSourceEnum? source}) async {
    List<Product>? popularProductList;
    String cacheId = '${AppConstants.popularProductUri}&type=$type';

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.popularProductUri}&type=$type');
        if (response.statusCode == 200) {
          popularProductList = [];
          // V3 API: data is a List, wrap it for ProductModel
          var data = response.body['data'] ?? response.body;
          if(data is List) {
            // Wrap list in a map with 'products' key for ProductModel parsing
            popularProductList.addAll(ProductModel.fromJson({'products': data}).products!);
          } else {
            popularProductList.addAll(ProductModel.fromJson(data).products!);
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body['data']), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          var data = jsonDecode(cacheResponseData);
          popularProductList = [];
          if(data is List) {
            popularProductList.addAll(ProductModel.fromJson({'products': data}).products!);
          } else {
            popularProductList.addAll(ProductModel.fromJson(data).products!);
          }
        }
    }
    return popularProductList;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  /// Get pharmacy products from pharmacy-specific endpoint
  /// This fetches products from all pharmacies and aggregates them
  Future<List<Product>?> getPharmacyProducts({DataSourceEnum? source}) async {
    List<Product> allProducts = [];
    String cacheId = 'pharmacy_products_aggregated';

    try {
      if (source == DataSourceEnum.local) {
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          var data = jsonDecode(cacheResponseData);
          if (data is List) {
            for (var item in data) {
              allProducts.add(Product.fromJson(item));
            }
          }
          return allProducts;
        }
      }

      // Fetch from client - get pharmacies list first
      Response pharmaciesResponse = await apiClient.getData(AppConstants.pharmaciesUri);
      if (pharmaciesResponse.statusCode == 200) {
        var pharmaciesData = pharmaciesResponse.body['data'] ?? pharmaciesResponse.body;
        if (pharmaciesData is List && pharmaciesData.isNotEmpty) {
          // Fetch products from first 3 pharmacies to limit API calls
          int pharmacyCount = pharmaciesData.length > 3 ? 3 : pharmaciesData.length;
          for (int i = 0; i < pharmacyCount; i++) {
            int pharmacyId = pharmaciesData[i]['id'];
            Response productsResponse = await apiClient.getData(
              '${AppConstants.pharmacyProductsUri}$pharmacyId/products?per_page=20'
            );
            if (productsResponse.statusCode == 200) {
              var productsData = productsResponse.body['data'] ?? productsResponse.body;
              if (productsData is List) {
                for (var item in productsData) {
                  // Add pharmacy_id to each product
                  item['pharmacy_id'] = pharmacyId;
                  item['business_type'] = 'pharmacy';
                  allProducts.add(Product.fromJson(item));
                }
              }
            }
          }

          // Sort by rating (descending) and remove duplicates
          allProducts.sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));

          // Remove duplicates by product ID
          final seen = <int>{};
          allProducts = allProducts.where((product) => seen.add(product.id ?? 0)).toList();

          // Cache the results
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(allProducts.map((p) => p.toJson()).toList()), apiClient.getHeader());
        }
      }
    } catch (e) {
      debugPrint('ProductRepository.getPharmacyProducts error: $e');
    }

    return allProducts.isNotEmpty ? allProducts : null;
  }
}