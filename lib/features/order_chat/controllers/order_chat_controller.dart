import 'dart:async';
import 'package:mnjood/features/order_chat/domain/models/order_chat_message_model.dart';
import 'package:mnjood/features/order_chat/domain/services/order_chat_service_interface.dart';
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

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  int _previousMessageCount = 0;
  bool _hasNewMessage = false;
  bool get hasNewMessage => _hasNewMessage;

  Timer? _pollingTimer;

  List<String> get quickReplies => [
    'quick_reply_ok'.tr,
    'quick_reply_thanks'.tr,
    'quick_reply_how_long'.tr,
    'quick_reply_on_my_way'.tr,
  ];

  Future<void> loadMessages(int orderId) async {
    _isLoading = true;
    update();
    OrderChatListModel? model = await orderChatServiceInterface.getMessages(orderId);
    if (model != null && model.messages != null) {
      _messages = model.messages!;
      _previousMessageCount = _messages.length;
    }
    _isLoading = false;
    update();
  }

  Future<void> refreshMessages(int orderId) async {
    OrderChatListModel? model = await orderChatServiceInterface.getMessages(orderId);
    if (model != null && model.messages != null) {
      final hadNew = model.messages!.length > _previousMessageCount;
      _messages = model.messages!;
      if (hadNew) {
        _hasNewMessage = true;
        _unreadCount = model.messages!.length - _previousMessageCount;
      }
      _previousMessageCount = _messages.length;
      update();
    }
  }

  Future<void> sendMessage(int orderId, String message) async {
    _isSending = true;
    update();
    OrderChatListModel? model = await orderChatServiceInterface.sendMessage(orderId, message);
    if (model != null && model.messages != null) {
      _messages = model.messages!;
      _previousMessageCount = _messages.length;
    } else {
      await refreshMessages(orderId);
    }
    _isSending = false;
    update();
  }

  Future<void> markAsRead(int orderId) async {
    _unreadCount = 0;
    _hasNewMessage = false;
    update();
    await orderChatServiceInterface.markAsRead(orderId);
  }

  void clearNewMessageFlag() {
    _hasNewMessage = false;
    _unreadCount = 0;
    update();
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
    _unreadCount = 0;
    _hasNewMessage = false;
    _previousMessageCount = 0;
    update();
  }
}
