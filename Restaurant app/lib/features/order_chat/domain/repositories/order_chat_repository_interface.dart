import 'package:mnjood_vendor/features/order_chat/domain/models/order_chat_message_model.dart';

abstract class OrderChatRepositoryInterface {
  Future<OrderChatListModel?> getMessages(int orderId);
  Future<OrderChatListModel?> sendMessage(int orderId, String message);
  Future<bool> markAsRead(int orderId);
}
