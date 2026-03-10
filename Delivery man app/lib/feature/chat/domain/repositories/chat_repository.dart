import 'package:mnjood_delivery/api/api_client.dart';
import 'package:mnjood_delivery/feature/chat/domain/models/conversation_model.dart';
import 'package:mnjood_delivery/feature/chat/domain/repositories/chat_repository_interface.dart';
import 'package:mnjood_delivery/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mnjood_delivery/helper/user_type_helper.dart';
import 'dart:async';

class ChatRepository implements ChatRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ChatRepository({required this.apiClient, required this.sharedPreferences});

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<ConversationsModel?> getConversationList(int offset, String type) async {
    ConversationsModel? conversationModel;
    Response response = await apiClient.getData('${AppConstants.getConversationListUri}?token=${_getUserToken()}&offset=$offset&limit=10&type=$type');
    if(response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      conversationModel = ConversationsModel.fromJson(data);
    }
    return conversationModel;
  }

  @override
  Future<ConversationsModel?> searchConversationList(String name) async {
    ConversationsModel? searchConversationModel;
    Response response = await apiClient.getData('${AppConstants.searchConversationListUri}?name=$name&token=${_getUserToken()}&limit=20&offset=1');
    if(response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      searchConversationModel = ConversationsModel.fromJson(data);
    }
    return searchConversationModel;
  }

  @override
  Future<Response> getMessages(int offset, int? userId, UserType userType, int? conversationID) async {
    return await apiClient.getData('${AppConstants.getMessageListUri}?${conversationID != null ?
    'conversation_id' : userType == UserType.admin ? 'admin_id' : userType == UserType.user ? 'user_id' : 'vendor_id'}=${conversationID ?? userId}&token=${_getUserToken()}&offset=$offset&limit=10');
  }

  @override
  Future<Response> sendMessage(String message, List<MultipartBody> file, int? conversationId, int? userId, UserType userType) async {
    return apiClient.postMultipartData(
      AppConstants.sendMessageUri,
      {'message': message, 'receiver_type': userType.name,  conversationId != null ? 'conversation_id' : 'receiver_id': '${conversationId ?? userId}', 'token': _getUserToken(), 'offset': '1', 'limit': '10'},
      file, [],
    );
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
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}