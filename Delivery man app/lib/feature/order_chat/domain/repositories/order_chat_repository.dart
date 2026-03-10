import 'package:mnjood_delivery/api/api_client.dart';
import 'package:mnjood_delivery/feature/order_chat/domain/models/order_chat_message_model.dart';
import 'package:mnjood_delivery/feature/order_chat/domain/repositories/order_chat_repository_interface.dart';
import 'package:mnjood_delivery/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderChatRepository implements OrderChatRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderChatRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<OrderChatListModel?> getMessages(int orderId) async {
    String token = sharedPreferences.getString(AppConstants.token) ?? '';
    OrderChatListModel? model;
    Response response = await apiClient.getData('${AppConstants.orderChatListUri}?order_id=$orderId&token=$token');
    if (response.statusCode == 200) {
      model = _parseResponse(response.body);
    }
    return model;
  }

  @override
  Future<OrderChatListModel?> sendMessage(int orderId, String message) async {
    String token = sharedPreferences.getString(AppConstants.token) ?? '';
    OrderChatListModel? model;
    Response response = await apiClient.postData(AppConstants.orderChatSendUri, {
      'order_id': orderId,
      'message': message,
      'token': token,
    });
    if (response.statusCode == 200) {
      model = _parseResponse(response.body);
    }
    return model;
  }

  @override
  Future<bool> markAsRead(int orderId) async {
    String token = sharedPreferences.getString(AppConstants.token) ?? '';
    Response response = await apiClient.postData(AppConstants.orderChatMarkReadUri, {
      'order_id': orderId,
      'token': token,
    });
    return response.statusCode == 200;
  }

  OrderChatListModel _parseResponse(dynamic body) {
    List<dynamic> messageList;
    if (body is List) {
      messageList = body;
    } else if (body is Map) {
      var data = body['data'];
      if (data is List) {
        messageList = data;
      } else if (data is Map && data['messages'] is List) {
        messageList = data['messages'];
      } else {
        messageList = [];
      }
    } else {
      messageList = [];
    }
    return OrderChatListModel(
      messages: messageList.map((m) => OrderChatMessage.fromJson(Map<String, dynamic>.from(m))).toList(),
    );
  }
}
