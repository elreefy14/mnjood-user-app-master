import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/order/domain/models/delivery_log_model.dart';
import 'package:mnjood/features/order/domain/models/order_cancellation_body.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/order/domain/models/pause_log_model.dart';
import 'package:mnjood/features/order/domain/models/refund_model.dart';
import 'package:mnjood/features/order/domain/models/substitution_proposal_model.dart';
import 'package:mnjood/features/order/domain/repositories/order_repository_interface.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:image_picker/image_picker.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  OrderRepository({required this.apiClient});

  @override
  Future<OrderModel?> trackOrder(String? orderID, String? guestId, {String? contactNumber}) async {
    OrderModel? trackModel;

    String formatPhoneNumber(String contactNumber) {
      final number = contactNumber.trim().replaceAll(' ', '');
      return number.startsWith('+') ? number : '+$number';
    }

    // Build query parameters properly
    List<String> queryParams = [];
    if (guestId != null) queryParams.add('guest_id=$guestId');
    if (contactNumber != null && contactNumber != 'null' && contactNumber.isNotEmpty) {
      queryParams.add('contact_number=${formatPhoneNumber(contactNumber)}');
    }
    String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

    Response response = await apiClient.getData(
      '${AppConstants.trackUri}$orderID/track$queryString',
    );
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;

      // DEBUG: Log raw coordinate data from API
      debugPrint('🗺️ TRACK API RAW - delivery_man: ${data['delivery_man']}');
      debugPrint('🗺️ TRACK API RAW - delivery_address: ${data['delivery_address']}');
      debugPrint('🗺️ TRACK API RAW - restaurant lat/lng: ${data['restaurant']?['latitude']}, ${data['restaurant']?['longitude']}');
      debugPrint('🗺️ TRACK API RAW - vendor lat/lng: ${data['vendor']?['latitude']}, ${data['vendor']?['longitude']}');

      trackModel = OrderModel.fromJson(data);

      // DEBUG: Log parsed values
      debugPrint('🗺️ PARSED - deliveryMan: lat=${trackModel.deliveryMan?.lat}, lng=${trackModel.deliveryMan?.lng}');
      debugPrint('🗺️ PARSED - deliveryAddress: lat=${trackModel.deliveryAddress?.latitude}, lng=${trackModel.deliveryAddress?.longitude}');
      debugPrint('🗺️ PARSED - restaurant: lat=${trackModel.restaurant?.latitude}, lng=${trackModel.restaurant?.longitude}');
    }
    return trackModel;
  }

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer');
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;

      // Handle both formats: List (V3) or Map with reasons key (legacy)
      if (data is List) {
        // V3 format: data is directly a list of reasons
        orderCancelReasons = [];
        for (var item in data) {
          orderCancelReasons.add(CancellationData.fromJson(item));
        }
      } else if (data is Map<String, dynamic>) {
        // Legacy format: data has 'reasons' key
        OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(data);
        orderCancelReasons = orderCancellationBody.reasons ?? [];
      }
    }
    return orderCancelReasons;
  }

  @override
  Future<ResponseModel> switchToCOD(String? orderID) async {
    Map<String, String> data = {'_method': 'put', 'order_id': orderID!};
    if(AuthHelper.isGuestLoggedIn()) {
      data.addAll({'guest_id': AuthHelper.getGuestId()});
    }
    Response response = await apiClient.postData(AppConstants.codSwitchUri, data);
    if(response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<List<Product>?> getFoodsFromFoodIds(List<int?> ids) async {
    List<Product>? foods;
    Response response = await apiClient.postData(AppConstants.productListWithIdsUri, {'food_id': jsonEncode(ids)});
    if (response.statusCode == 200) {
      foods = [];
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'] ?? response.body;
      if(dataArray is List) {
        dataArray.forEach((food) => foods!.add(Product.fromJson(food)));
      }
    }
    return foods;
  }

  @override
  Future<List<String?>?> getRefundReasons() async {
    List<String?>? refundReasons;
    Response response = await apiClient.getData(AppConstants.refundReasonsUri);
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      RefundModel refundModel = RefundModel.fromJson(data);
      refundReasons = [];
      refundReasons.insert(0, 'select_an_option');
      for (var element in refundModel.refundReasons!) {
        refundReasons.add(element.reason);
      }
    }
    return refundReasons;
  }

  @override
  Future<ResponseModel> submitRefundRequest(Map<String, String> body, XFile? data, String? guestId) async {
    Response response = await apiClient.postMultipartData('${AppConstants.refundRequestUri}${guestId != null ? '?guest_id=$guestId' : ''}', body,  [MultipartBody('image[]', data)], []);
    if(response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<ResponseModel> cancelOrder(String orderID, String? reason, {int? reasonId, String? customReason}) async {
    Map<String, String> data = {'_method': 'patch', 'reason': reason ?? ''};
    if (reasonId != null) {
      data['reason_id'] = reasonId.toString();
    }
    if (customReason != null && customReason.isNotEmpty) {
      data['custom_reason'] = customReason;
    }
    if(AuthHelper.isGuestLoggedIn()){
      data.addAll({'guest_id': AuthHelper.getGuestId()});
    }
    Response response = await apiClient.postData('${AppConstants.orderCancelUri}$orderID/cancel', data);
    if(response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<PaginatedDeliveryLogModel?> getSubscriptionDeliveryLog(int? subscriptionID, int offset) async {
    PaginatedDeliveryLogModel? deliverLogs;
    Response response = await apiClient.getData('${AppConstants.subscriptionListUri}/$subscriptionID/delivery-log?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      deliverLogs = PaginatedDeliveryLogModel.fromJson(data);
    }
    return deliverLogs;
  }

  @override
  Future<PaginatedPauseLogModel?> getSubscriptionPauseLog(int? subscriptionID, int offset) async {
    PaginatedPauseLogModel? pauseLogs;
    Response response = await apiClient.getData('${AppConstants.subscriptionListUri}/$subscriptionID/pause-log?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      pauseLogs = PaginatedPauseLogModel.fromJson(data);
    }
    return pauseLogs;
  }

  @override
  Future<ResponseModel> updateSubscriptionStatus(int? subscriptionID, String? startDate, String? endDate, String status, String note, String? reason) async {
    Response response = await apiClient.postData(
      '${AppConstants.subscriptionListUri}/update/$subscriptionID',
      {'_method': 'put', 'status': status, 'note': note, 'cancellation_reason': reason, 'start_date': startDate, 'end_date': endDate},
    );
    if(response.statusCode == 200) {
      return ResponseModel(true, response.statusText);
    } else {
      return ResponseModel(false, response.statusText);
    }
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
  Future<Response> get(String? id, {String? guestId}) async {
    return await apiClient.getData('${AppConstants.orderDetailsUri}$id${guestId != null ? '?guest_id=$guestId' : ''}');
  }



  @override
  Future<PaginatedOrderModel?> getList({int? offset, String? guestId, bool isRunningOrder = false, bool isSubscriptionOrder = false, int? limit}) {
    if(isRunningOrder) {
      return _getRunningOrderList(offset!, guestId, limit: limit!);
    }
    else if(isSubscriptionOrder) {
      return _getRunningSubscriptionOrderList(offset!);
    }
    else {
      return _getHistoryOrderList(offset!);
    }
  }

  Future<PaginatedOrderModel?> _getRunningOrderList(int offset, String? guestId, {required int limit}) async {
    PaginatedOrderModel? paginateOrderModel;
    final url = '${AppConstants.runningOrderListUri}?offset=$offset&limit=$limit${guestId != null ? '&guest_id=$guestId' : ''}';
    debugPrint('🔵 Running Orders API: $url');
    Response response = await apiClient.getData(url);
    debugPrint('🔵 Running Orders Response: ${response.statusCode} - ${response.body?.toString().substring(0, (response.body?.toString().length ?? 0) > 200 ? 200 : response.body?.toString().length ?? 0)}');
    if (response.statusCode == 200) {
      paginateOrderModel = _parseOrderResponse(response.body, offset, limit);
      debugPrint('🔵 Parsed ${paginateOrderModel?.orders?.length ?? 0} running orders');
    }
    return paginateOrderModel;
  }

  /// Parse V3 API order response - handles both List and Map formats
  PaginatedOrderModel? _parseOrderResponse(dynamic responseBody, int offset, int limit) {
    if (responseBody == null) return null;

    // V3 API wraps response in {success, data, meta}
    if (responseBody is Map && responseBody.containsKey('data')) {
      var data = responseBody['data'];
      var meta = responseBody['meta'];

      // V3 API returns orders directly as array in 'data'
      if (data is List) {
        return PaginatedOrderModel(
          totalSize: meta?['pagination']?['total'] ?? data.length,
          limit: '${meta?['pagination']?['per_page'] ?? limit}',
          offset: '$offset',
          orders: data.map<OrderModel>((e) => OrderModel.fromJson(e)).toList(),
        );
      }
      // Legacy format: data contains {orders: [...], total_size, ...}
      else if (data is Map<String, dynamic>) {
        return PaginatedOrderModel.fromJson(data);
      }
    }
    // Direct response without wrapper
    else if (responseBody is Map<String, dynamic>) {
      return PaginatedOrderModel.fromJson(responseBody);
    }

    return null;
  }

  Future<PaginatedOrderModel?> _getRunningSubscriptionOrderList(int offset) async {
    PaginatedOrderModel? paginateOrderModel;
    Response response = await apiClient.getData('${AppConstants.runningSubscriptionOrderListUri}?offset=$offset&limit=${10}');
    if (response.statusCode == 200) {
      paginateOrderModel = _parseOrderResponse(response.body, offset, 10);
    } else if (response.statusCode == 404) {
      // Endpoint doesn't exist - return empty list instead of null
      paginateOrderModel = PaginatedOrderModel(totalSize: 0, limit: '10', offset: '$offset', orders: []);
    }
    return paginateOrderModel;
  }

  Future<PaginatedOrderModel?> _getHistoryOrderList(int offset) async {
    PaginatedOrderModel? paginateOrderModel;
    final url = '${AppConstants.historyOrderListUri}?offset=$offset&limit=10';
    debugPrint('🟢 History Orders API: $url');
    Response response = await apiClient.getData(url);
    debugPrint('🟢 History Orders Response: ${response.statusCode} - ${response.body?.toString().substring(0, (response.body?.toString().length ?? 0) > 200 ? 200 : response.body?.toString().length ?? 0)}');
    if (response.statusCode == 200) {
      paginateOrderModel = _parseOrderResponse(response.body, offset, 10);
      debugPrint('🟢 Parsed ${paginateOrderModel?.orders?.length ?? 0} history orders');
    }
    return paginateOrderModel;
  }

  @override
  Future<List<SubstitutionProposal>?> getSubstitutionProposals(int orderId) async {
    List<SubstitutionProposal>? proposals;
    Response response = await apiClient.getData('${AppConstants.substitutionProposalsUri}?order_id=$orderId');
    if (response.statusCode == 200) {
      proposals = [];
      final data = response.body['proposals'] ?? response.body['data'] ?? [];
      for (var item in data) {
        proposals.add(SubstitutionProposal.fromJson(item));
      }
    }
    return proposals;
  }

  @override
  Future<ResponseModel> respondToSubstitution(int proposalId, String action) async {
    Response response = await apiClient.postData(
      AppConstants.substitutionRespondUri,
      {'proposal_id': proposalId, 'action': action},
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message'] ?? 'Success');
    }
    return ResponseModel(false, response.statusText ?? 'Failed');
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}