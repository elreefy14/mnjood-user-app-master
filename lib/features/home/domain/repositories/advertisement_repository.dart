import 'dart:convert';
import 'package:get/get.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/home/domain/models/advertisement_model.dart';
import 'package:mnjood/features/home/domain/repositories/advertisement_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';

class AdvertisementRepository implements AdvertisementRepositoryInterface {
  final ApiClient apiClient;
  AdvertisementRepository({required this.apiClient});

  @override
  Future<List<AdvertisementModel>?> getList({int? offset, DataSourceEnum? source, String? businessType}) async {
    List<AdvertisementModel>? advertisementList;

    // Build URL with optional business_type parameter
    String url = AppConstants.advertisementListUri;
    if (businessType != null && businessType.isNotEmpty && businessType != 'all') {
      url = '$url?business_type=$businessType';
    }

    // Cache ID includes businessType for separate caching per type
    String cacheId = businessType != null && businessType != 'all'
        ? '${AppConstants.advertisementListUri}-$businessType'
        : AppConstants.advertisementListUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(url);
        if(response.statusCode == 200) {
          advertisementList = [];
          // V3 API: Extract data array from response wrapper
          var dataList = response.body['data'] ?? response.body;
          if(dataList is List) {
            for (var data in dataList) {
              advertisementList?.add(AdvertisementModel.fromJson(data));
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(dataList), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          advertisementList = [];
          var dataList = jsonDecode(cacheResponseData);
          if(dataList is List) {
            for (var data in dataList) {
              advertisementList?.add(AdvertisementModel.fromJson(data));
            }
          }
        }
    }

    return advertisementList;
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

}