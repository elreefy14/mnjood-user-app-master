import 'dart:convert';

import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/api/local_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/address/domain/reposotories/address_repo_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get.dart';

class AddressRepo implements AddressRepoInterface<AddressModel> {
  final ApiClient apiClient;

  AddressRepo({required this.apiClient});

  @override
  Future<List<AddressModel>?> getList({int? offset, bool isLocal = false, DataSourceEnum? source}) async {
    List<AddressModel>? addressList;
    String cacheId = AppConstants.addressListUri;

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.addressListUri);
        if (response.statusCode == 200) {
          addressList = [];
          // V3 API: Extract data from response wrapper
          var data = response.body['data'] ?? response.body;
          // data might already be a List (V3 API returns {data: []}) or a Map with 'addresses' key
          var addresses = data is List ? data : (data['addresses'] ?? data);
          if(addresses is List) {
            addresses.forEach((address) {
              addressList!.add(AddressModel.fromJson(address));
            });
            LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(addresses), apiClient.getHeader());
          }
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          addressList = [];
          jsonDecode(cacheResponseData).forEach((address) {
            addressList!.add(AddressModel.fromJson(address));
          });
        }
    }
    return addressList;
  }

  @override
  Future add(AddressModel addressModel) async {
    Response response = await apiClient.postData(AppConstants.addAddressUri, addressModel.toJson(), handleError: false);
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      String? message = response.body["message"] ?? data["message"];
      List<int> zoneIds = [];
      var zoneIdsData = data['zone_ids'] ?? response.body['zone_ids'];
      if(zoneIdsData != null) {
        zoneIdsData.forEach((z) => zoneIds.add(z));
      }
      responseModel = ResponseModel(true, message, zoneIds: zoneIds);
    } else {
      responseModel = ResponseModel(false,
          response.statusText == 'Out of coverage!' ? 'service_not_available_in_this_area'.tr : response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> update(Map<String, dynamic> body, int? addressId) async {
    Response response = await apiClient.putData('${AppConstants.updateAddressUri}$addressId', body, handleError: false);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> delete(int? id) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData('${AppConstants.removeAddressUri}$id', {"_method": "delete"}, handleError: false);
    // V3 API returns 204 No Content for successful DELETE
    if (response.statusCode == 200 || response.statusCode == 204) {
      String message = response.statusCode == 204
          ? 'address_deleted_successfully'.tr
          : (response.body?['message'] ?? 'address_deleted_successfully'.tr);
      responseModel = ResponseModel(true, message);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }
}
