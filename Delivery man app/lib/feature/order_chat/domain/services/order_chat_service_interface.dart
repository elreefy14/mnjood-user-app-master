import 'package:mnjood_delivery/feature/order_chat/domain/models/order_chat_message_model.dart';

abstract class OrderChatServiceInterface {
  Future<OrderChatListModel?> getMessages(int orderId);
  Future<OrderChatListModel?> sendMessage(int orderId, String message);
  Future<bool> markAsRead(int orderId);
}
