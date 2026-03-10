import 'package:mnjood_delivery/feature/order_chat/domain/models/order_chat_message_model.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class OrderChatBubbleWidget extends StatelessWidget {
  final OrderChatMessage message;
  final String ownSenderType;
  const OrderChatBubbleWidget({super.key, required this.message, required this.ownSenderType});

  @override
  Widget build(BuildContext context) {
    bool isOwn = message.senderType == ownSenderType && !(message.isBotResponse ?? false);
    bool isSystem = message.senderType == 'system' && !(message.isBotResponse ?? false);
    bool isBot = message.isBotResponse ?? false;

    if (isBot) return _buildCenterBubble(context, isBot: true);
    if (isSystem) return _buildCenterBubble(context, isBot: false);
    if (isOwn) return _buildOwnBubble(context);
    return _buildOtherBubble(context);
  }

  Widget _buildOwnBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault), bottomLeft: Radius.circular(Dimensions.radiusDefault)),
          ),
          child: Text(message.message ?? '', style: robotoRegular.copyWith(color: Colors.white)),
        ),
        const SizedBox(height: 2),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_formatTime(message.createdAt), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
          if (message.isRead == true) ...[
            const SizedBox(width: 4),
            Icon(HeroiconsSolid.checkCircle, size: 12, color: Theme.of(context).primaryColor),
          ],
        ]),
      ]),
    );
  }

  Widget _buildOtherBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (message.senderBadge != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2, left: 4),
            child: Text('${message.senderName ?? ''} (${message.senderBadge})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
          ),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
          ),
          child: Text(message.message ?? '', style: robotoRegular),
        ),
        const SizedBox(height: 2),
        Text(_formatTime(message.createdAt), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
      ]),
    );
  }

  Widget _buildCenterBubble(BuildContext context, {required bool isBot}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
      child: Center(child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (isBot) ...[
            Icon(HeroiconsSolid.sparkles, size: 14, color: Theme.of(context).disabledColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          ],
          Flexible(child: Text(message.message ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor), textAlign: TextAlign.center)),
        ]),
      )),
    );
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      DateTime dt = DateTime.parse(dateTime).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
