import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/checkout/domain/models/offline_method_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckoutRepository implements CheckoutRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CheckoutRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<int?> getDmTipMostTapped() async {
    int mostDmTipAmount = 0;
    Response response = await apiClient.getData(AppConstants.mostTipsUri);
    if(response.statusCode == 200){
      // V3 API returns data as array of popular tip amounts: {data: [5, 10, 15, 20]}
      var data = response.body['data'] ?? response.body;
      if (data is List && data.isNotEmpty) {
        // Return first popular tip amount or 0
        mostDmTipAmount = data[0] is int ? data[0] : (int.tryParse(data[0].toString()) ?? 0);
      } else if (data is Map && data['most_tips_amount'] != null) {
        // Legacy V1 format
        mostDmTipAmount = data['most_tips_amount'];
      }
    }
    return mostDmTipAmount;
  }

  @override
  Future<List<OfflineMethodModel>> getOfflineMethodList() async {
    List<OfflineMethodModel> offlineMethodList = [];
    Response response = await apiClient.getData(AppConstants.offlineMethodListUri);
    if (response.statusCode == 200) {
      // V3 API wraps data in 'data' key: {success: true, data: [...]}
      var data = response.body['data'] ?? response.body;
      if (data is List) {
        data.forEach((method) => offlineMethodList.add(OfflineMethodModel.fromJson(method)));
      }
    }
    return offlineMethodList;
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    double? extraCharge;
    Response response = await apiClient.getData('${AppConstants.vehicleChargeUri}?distance=$distance');
    if (response.statusCode == 200) {
      // Handle V3 API response format: {success: true, data: [{..., extra_charges: 12}]}
      var responseData = response.body;
      if (responseData is Map && responseData.containsKey('data')) {
        var data = responseData['data'];
        if (data is List && data.isNotEmpty) {
          // Extract extra_charges from first item in data array
          var firstItem = data[0];
          if (firstItem is Map && firstItem.containsKey('extra_charges')) {
            extraCharge = double.tryParse(firstItem['extra_charges'].toString()) ?? 0;
          } else {
            extraCharge = 0;
          }
        } else if (data is num) {
          // If data is a direct number
          extraCharge = data.toDouble();
        } else {
          extraCharge = 0;
        }
      } else if (responseData is num) {
        // Legacy format: direct number response
        extraCharge = responseData.toDouble();
      } else {
        extraCharge = double.tryParse(responseData.toString()) ?? 0;
      }
    } else {
      extraCharge = 0;
    }
    return extraCharge;
  }

  @override
  Future<bool> saveOfflineInfo(String data, String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.offlinePaymentSaveInfoUri}/${guestId != null ? '?guest_id=$guestId' : ''}', jsonDecode(data));
    return (response.statusCode == 200);
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody, {XFile? prescriptionImage}) async {
    if (prescriptionImage != null) {
      // Use multipart form data when there's a prescription image
      Map<String, String> body = {};
      orderBody.toJson().forEach((key, value) {
        if (value != null) {
          body[key] = value.toString();
        }
      });

      List<MultipartBody> multipartBody = [
        MultipartBody('prescription_image', prescriptionImage),
      ];

      Response response = await apiClient.postMultipartData(
        AppConstants.placeOrderUri,
        body,
        multipartBody,
        [],
      );
      return response;
    } else {
      Response response = await apiClient.postData(AppConstants.placeOrderUri, orderBody.toJson());
      return response;
    }
  }

  @override
  Future<Response> sendNotificationRequest(String orderId, String? guestId) async {
    return await apiClient.getData('${AppConstants.sendCheckoutNotificationUri}/$orderId${guestId != null ? '?guest_id=$guestId' : ''}');
  }

  @override
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {

    // handleError: false to suppress error toast - we have Geolocator fallback
    final response = await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
        '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=WALK',
      handleError: false,
    );

    return response;
  }

  @override
  Future<bool> updateOfflineInfo(String data, String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.offlinePaymentUpdateInfoUri}${guestId != null ? '?guest_id=$guestId' : ''}', jsonDecode(data));
    return (response.statusCode == 200);
  }

  @override
  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data, String? guestId}) async {
    Response response = await apiClient.postData('${AppConstants.checkRestaurantValidation}${guestId != null ? '?guest_id=$guestId' : ''}', data, handleError: false);
    return (response.statusCode == 200);
  }

  @override
  Future<Response> getOrderTax(PlaceOrderBodyModel orderBody) async {
    Response response = await apiClient.postData(AppConstants.getOrderTaxUri, orderBody.toJson());
    return response;
  }

  @override
  Future<bool> saveDmTipIndex(String index) async {
    return await sharedPreferences.setString(AppConstants.dmTipIndex, index);
  }

  @override
  String getDmTipIndex() {
    return sharedPreferences.getString(AppConstants.dmTipIndex) ?? "";
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
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> verifyMoyasarPayment(String orderId, String paymentId) async {
    Response response = await apiClient.postData(AppConstants.moyasarVerifyUri, {
      'order_id': orderId,
      'moyasar_payment_id': paymentId,
    });
    return response;
  }

  @override
  Future<Response> initializePaymentSession(Map<String, dynamic> data) async {
    Response response = await apiClient.postData(AppConstants.initializePaymentUri, data);
    return response;
  }
}