import 'dart:convert';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/cuisine/domain/models/cuisine_model.dart';
import 'package:mnjood/features/cuisine/domain/models/cuisine_restaurants_model.dart';
import 'package:mnjood/features/cuisine/domain/repositories/cuisine_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class CuisineRepository implements CuisineRepositoryInterface {
  final ApiClient apiClient;
  CuisineRepository({required this.apiClient});

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
  Future<CuisineModel?> getList({int? offset, DataSourceEnum? source}) async {
    CuisineModel? cuisineModel;
    String cacheId = AppConstants.cuisineUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.cuisineUri);
        if(response.statusCode == 200){
          // Handle different API response formats
          var responseBody = response.body;
          Map<String, dynamic> data;

          if (responseBody is List) {
            // API returns list directly: [{cuisine1}, {cuisine2}]
            data = {'data': responseBody};
          } else if (responseBody is Map) {
            // API returns wrapped: {data: [...]} or {Cuisines: [...]}
            data = Map<String, dynamic>.from(responseBody);
          } else {
            data = {'data': []};
          }

          cuisineModel = CuisineModel.fromJson(data);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(data), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          cuisineModel = CuisineModel.fromJson(jsonDecode(cacheResponseData));
        }
    }

    return cuisineModel;
  }

  @override
  Future<CuisineRestaurantModel?> getRestaurantList(int offset, int cuisineId) async {
    CuisineRestaurantModel? cuisineRestaurantsModel;
    // V3 API endpoint: /api/v3/cuisines/{id}/vendors (BACKEND NEEDS TO IMPLEMENT THIS)
    Response response = await apiClient.getData('${AppConstants.cuisineRestaurantUri}$cuisineId/vendors?offset=$offset&limit=10');
    if(response.statusCode == 200) {
      // Handle V3 API response wrapper
      var responseData = response.body;
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      cuisineRestaurantsModel = CuisineRestaurantModel.fromJson(responseData);
    }
    return cuisineRestaurantsModel;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}