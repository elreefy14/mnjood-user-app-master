import 'package:mnjood_delivery/api/api_client.dart';
import 'package:mnjood_delivery/helper/user_type_helper.dart';
import 'package:mnjood_delivery/interface/repository_interface.dart';

abstract class ChatRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getConversationList(int offset, String type);
  Future<dynamic> searchConversationList(String name);
  Future<dynamic> getMessages(int offset, int? userId, UserType userType, int? conversationID);
  Future<dynamic> sendMessage(String message, List<MultipartBody> file, int? conversationId, int? userId, UserType userType);
}