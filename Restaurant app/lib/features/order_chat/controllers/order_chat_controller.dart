import 'dart:async';
import 'package:mnjood_vendor/features/order_chat/domain/models/order_chat_message_model.dart';
import 'package:mnjood_vendor/features/order_chat/domain/services/order_chat_service_interface.dart';
import 'package:get/get.dart';

class OrderChatController extends GetxController implements GetxService {
  final OrderChatServiceInterface orderChatServiceInterface;
  OrderChatController({required this.orderChatServiceInterface});

  List<OrderChatMessage> _messages = [];
  List<OrderChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSending = false;
  bool get isSending => _isSending;

  Timer? _pollingTimer;

  Future<void> loadMessages(int orderId) async {
    _isLoading = true;
    update();
    OrderChatListModel? model = await orderChatServiceInterface.getMessages(orderId);
    if (model != null && model.messages != null) {
      _messages = model.messages!;
    }
    _isLoading = false;
    update();
  }

  Future<void> refreshMessages(int orderId) async {
    OrderChatListModel? model = await orderChatServiceInterface.getMessages(orderId);
    if (model != null && model.messages != null) {
      _messages = model.messages!;
      update();
    }
  }

  Future<void> sendMessage(int orderId, String message) async {
    _isSending = true;
    update();
    OrderChatListModel? model = await orderChatServiceInterface.sendMessage(orderId, message);
    if (model != null && model.messages != null) {
      _messages = model.messages!;
    } else {
      await refreshMessages(orderId);
    }
    _isSending = false;
    update();
  }

  Future<void> markAsRead(int orderId) async {
    await orderChatServiceInterface.markAsRead(orderId);
  }

  void startPolling(int orderId) {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      refreshMessages(orderId);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void resetChat() {
    stopPolling();
    _messages = [];
    _isLoading = false;
    _isSending = false;
    update();
  }
}
