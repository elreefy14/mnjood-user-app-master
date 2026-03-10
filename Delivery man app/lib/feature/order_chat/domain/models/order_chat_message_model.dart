class OrderChatListModel {
  List<OrderChatMessage>? messages;

  OrderChatListModel({this.messages});

  OrderChatListModel.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <OrderChatMessage>[];
      json['messages'].forEach((v) {
        messages!.add(OrderChatMessage.fromJson(v));
      });
    }
  }
}

class OrderChatMessage {
  int? id;
  String? senderType;
  String? senderName;
  String? senderBadge;
  String? message;
  String? messageType;
  bool? isBotResponse;
  String? createdAt;
  bool? isRead;
  String? readAt;

  OrderChatMessage({
    this.id,
    this.senderType,
    this.senderName,
    this.senderBadge,
    this.message,
    this.messageType,
    this.isBotResponse,
    this.createdAt,
    this.isRead,
    this.readAt,
  });

  OrderChatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderType = json['sender_type'];
    senderName = json['sender_name'];
    senderBadge = json['sender_badge'];
    message = json['message'];
    messageType = json['message_type'];
    isBotResponse = json['is_bot_response'] == true || json['is_bot_response'] == 1;
    createdAt = json['created_at'];
    isRead = json['is_read'] == true || json['is_read'] == 1;
    readAt = json['read_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_type'] = senderType;
    data['sender_name'] = senderName;
    data['sender_badge'] = senderBadge;
    data['message'] = message;
    data['message_type'] = messageType;
    data['is_bot_response'] = isBotResponse;
    data['created_at'] = createdAt;
    data['is_read'] = isRead;
    data['read_at'] = readAt;
    return data;
  }
}
