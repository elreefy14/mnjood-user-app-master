import 'package:mnjood/features/order_chat/domain/models/order_chat_message_model.dart';
import 'package:mnjood/features/order_chat/domain/repositories/order_chat_repository_interface.dart';
import 'package:mnjood/features/order_chat/domain/services/order_chat_service_interface.dart';

class OrderChatService implements OrderChatServiceInterface {
  final OrderChatRepositoryInterface orderChatRepositoryInterface;
  OrderChatService({required this.orderChatRepositoryInterface});

  @override
  Future<OrderChatListModel?> getMessages(int orderId) async {
    return await orderChatRepositoryInterface.getMessages(orderId);
  }

  @override
  Future<OrderChatListModel?> sendMessage(int orderId, String message) async {
    return await orderChatRepositoryInterface.sendMessage(orderId, message);
  }

  @override
  Future<bool> markAsRead(int orderId) async {
    return await orderChatRepositoryInterface.markAsRead(orderId);
  }
}
