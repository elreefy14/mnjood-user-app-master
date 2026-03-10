import 'package:mnjood_delivery/common/models/response_model.dart';
import 'package:mnjood_delivery/api/api_client.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_cancellation_body_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_details_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/order_model.dart';
import 'package:mnjood_delivery/feature/order/domain/models/substitution_proposal_model.dart';
import 'package:mnjood_delivery/feature/order/domain/repositories/order_repository_interface.dart';
import 'package:mnjood_delivery/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mnjood_delivery/feature/order/domain/models/update_status_body.dart';
import 'package:mnjood_delivery/feature/order/domain/models/ignore_model.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<OrderModel>?> getList() async {
    List<OrderModel>? allOrderList;
    Response response = await apiClient.getData(AppConstants.allOrdersUri + _getUserToken());
    if (response.statusCode == 200) {
      allOrderList = [];
      // Handle both V1 (raw list) and V3 (wrapped in data) formats
      var dataArray = response.body;
      if (dataArray is Map && dataArray['data'] != null) {
        dataArray = dataArray['data'];
      }
      if (dataArray is List) {
        dataArray.forEach((order) => allOrderList!.add(OrderModel.fromJson(order)));
      }
    }
    return allOrderList;
  }

  @override
  Future<PaginatedOrderModel?> getCompletedOrderList(int offset, {required String status}) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient.getData('${AppConstants.allOrdersUri}?token=${_getUserToken()}&offset=$offset&limit=10&status=$status');
    if (response.statusCode == 200) {
      // Handle both V1 and V3 formats
      var data = response.body;
      if (data is Map && data['data'] != null && data['data'] is Map) {
        data = data['data'];
      }
      paginatedOrderModel = PaginatedOrderModel.fromJson(data);
    }
    return paginatedOrderModel;
  }

  @override
  Future<PaginatedOrderModel?> getCurrentOrders({required String status}) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient.getData('${AppConstants.currentOrdersUri}?token=${_getUserToken()}&status=$status');
    if (response.statusCode == 200) {
      // Handle both V1 and V3 formats
      var data = response.body;
      if (data is Map && data['data'] != null && data['data'] is Map) {
        data = data['data'];
      }
      paginatedOrderModel = PaginatedOrderModel.fromJson(data);
    }
    return paginatedOrderModel;
  }

  @override
  Future<List<OrderModel>?> getLatestOrders() async {
    List<OrderModel>? latestOrderList;
    Response response = await apiClient.getData(AppConstants.latestOrdersUri + _getUserToken());
    if(response.statusCode == 200) {
      latestOrderList = [];
      // Handle both V1 (raw list) and V3 (wrapped in data) formats
      var dataArray = response.body;
      if (dataArray is Map && dataArray['data'] != null) {
        dataArray = dataArray['data'];
      }
      if (dataArray is List) {
        dataArray.forEach((order) => latestOrderList!.add(OrderModel.fromJson(order)));
      }
    }
    return latestOrderList;
  }

  @override
  Future<ResponseModel> updateOrderStatus(UpdateStatusBody updateStatusBody, List<MultipartBody> proofAttachment) async {
    updateStatusBody.token = _getUserToken();
    ResponseModel responseModel;
    Response response = await apiClient.postMultipartData(AppConstants.updateOrderStatusUri, updateStatusBody.toJson(), proofAttachment , [], handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  List<SubstitutionProposal>? _lastSubstitutionProposals;

  List<SubstitutionProposal>? get lastSubstitutionProposals => _lastSubstitutionProposals;

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(int? orderID) async {
    List<OrderDetailsModel>? orderDetailsModel;
    _lastSubstitutionProposals = null;
    Response response = await apiClient.getData('${AppConstants.orderDetailsUri}${_getUserToken()}&order_id=$orderID&include_substitutions=1');
    if (response.statusCode == 200) {
      orderDetailsModel = [];
      // Handle both V1 (raw list) and V3 (wrapped in data) formats
      var dataArray = response.body;
      if (dataArray is Map && dataArray['data'] != null) {
        var data = dataArray['data'];
        // New format: {details: [...], substitution_proposals: [...]}
        if (data is Map && data['details'] is List) {
          dataArray = data['details'];
          if (data['substitution_proposals'] is List) {
            _lastSubstitutionProposals = (data['substitution_proposals'] as List)
                .map((s) => SubstitutionProposal.fromJson(Map<String, dynamic>.from(s)))
                .toList();
          }
        } else {
          dataArray = data;
        }
      }
      if (dataArray is List) {
        dataArray.forEach((orderDetails) => orderDetailsModel!.add(OrderDetailsModel.fromJson(orderDetails)));
      }
    }
    return orderDetailsModel;
  }

  @override
  Future<ResponseModel> acceptOrder(int? orderID) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.acceptOrderUri, {"_method": "put", 'token': _getUserToken(), 'order_id': orderID}, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  void setIgnoreList(List<IgnoreModel> ignoreList) {
    List<String> stringList = [];
    for (var ignore in ignoreList) {
      stringList.add(jsonEncode(ignore.toJson()));
    }
    sharedPreferences.setStringList(AppConstants.ignoreList, stringList);
  }

  @override
  List<IgnoreModel> getIgnoreList() {
    List<IgnoreModel> ignoreList = [];
    List<String> stringList = sharedPreferences.getStringList(AppConstants.ignoreList) ?? [];
    for (var ignore in stringList) {
      ignoreList.add(IgnoreModel.fromJson(jsonDecode(ignore)));
    }
    return ignoreList;
  }

  @override
  Future<OrderModel?> getOrderWithId(int? orderId) async {
    OrderModel? orderModel;
    Response response = await apiClient.getData('${AppConstants.currentOrderUri}${_getUserToken()}&order_id=$orderId');
    if (response.statusCode == 200) {
      // Handle both V1 and V3 formats
      var data = response.body;
      if (data is Map && data['data'] != null && data['data'] is Map) {
        data = data['data'];
      }
      orderModel = OrderModel.fromJson(data);
    }
    return orderModel;
  }

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=deliveryman');
    if (response.statusCode == 200) {
      // Handle both V1 and V3 formats
      var data = response.body;
      if (data is Map && data['data'] != null && data['data'] is Map) {
        data = data['data'];
      }
      OrderCancellationBodyModel orderCancellationBody = OrderCancellationBodyModel.fromJson(data);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
  
}