import 'dart:convert';

import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/product/domain/models/basic_campaign_model.dart';
import 'package:mnjood/features/product/domain/repositories/campaign_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';

class CampaignRepository implements CampaignRepositoryInterface {
  final ApiClient apiClient;

  CampaignRepository({required this.apiClient});

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<BasicCampaignModel?> get(String? id) {
    return _getCampaignDetails(id!);
  }

  Future<BasicCampaignModel?> _getCampaignDetails(String campaignID) async {
    BasicCampaignModel? campaign;
    Response response = await apiClient.getData('${AppConstants.basicCampaignDetailsUri}$campaignID');
    if (response.statusCode == 200) {
      // V3 API: Extract data object from response wrapper
      var data = response.body['data'] ?? response.body;
      campaign = BasicCampaignModel.fromJson(data);
    }
    return campaign;
  }

  @override
  Future<dynamic> getList({int? offset, bool basicCampaign = false, DataSourceEnum? source, String? businessType}) {
   if(basicCampaign) {
     return _getBasicCampaignList();
   } else {
     return _getItemCampaignList(source: source, businessType: businessType);
   }
  }
  Future<List<BasicCampaignModel>?> _getBasicCampaignList() async {
    List<BasicCampaignModel>? basicCampaignList;
    Response response = await apiClient.getData(AppConstants.basicCampaignUri);
    if (response.statusCode == 200) {
      basicCampaignList = [];
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'] ?? response.body;
      if (dataArray is List) {
        dataArray.forEach((campaign) => basicCampaignList!.add(BasicCampaignModel.fromJson(campaign)));
      }
    }
    return basicCampaignList;
  }

  Future<List<Product>?> _getItemCampaignList({DataSourceEnum? source, String? businessType}) async {
    List<Product>? itemCampaignList;

    // Build URL with optional business_type parameter
    String url = AppConstants.itemCampaignUri;
    if (businessType != null && businessType.isNotEmpty && businessType != 'all') {
      url = '$url?business_type=$businessType';
    }

    // Cache ID includes businessType for separate caching per type
    String cacheId = businessType != null && businessType != 'all'
        ? '${AppConstants.itemCampaignUri}-$businessType'
        : AppConstants.itemCampaignUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(url);
        if(response.statusCode == 200){
          itemCampaignList = [];
          // V3 API: Extract data array from response wrapper
          var dataArray = response.body['data'] ?? response.body;
          if (dataArray is List) {
            dataArray.forEach((campaign) => itemCampaignList!.add(Product.fromJson(campaign)));
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body['data'] ?? response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          itemCampaignList = [];
          jsonDecode(cacheResponseData).forEach((campaign) {
            itemCampaignList!.add(Product.fromJson(campaign));
          });
        }
    }
    return itemCampaignList;
  }


  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}