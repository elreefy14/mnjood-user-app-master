import 'package:mnjood/features/order_chat/controllers/order_chat_controller.dart';
import 'package:mnjood/features/order_chat/widgets/order_chat_bubble_widget.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class OrderChatScreen extends StatefulWidget {
  final int orderId;
  const OrderChatScreen({super.key, required this.orderId});

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<OrderChatController>();
    controller.loadMessages(widget.orderId).then((_) {
      controller.markAsRead(widget.orderId);
      controller.startPolling(widget.orderId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    Get.find<OrderChatController>().stopPolling();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${'order_chat'.tr} #${widget.orderId}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(HeroiconsOutline.chevronLeft),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
        elevation: 2,
      ),
      body: GetBuilder<OrderChatController>(builder: (controller) {
        // Auto-scroll when new messages arrive
        if (controller.hasNewMessage) {
          controller.clearNewMessageFlag();
          _scrollToBottom();
        }

        return Column(
          children: [
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.messages.isEmpty
                      ? Center(child: Text('no_messages_yet'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)))
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msg = controller.messages[controller.messages.length - 1 - index];
                            return OrderChatBubbleWidget(message: msg, ownSenderType: 'customer');
                          },
                        ),
            ),

            // Quick reply chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.quickReplies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(reply, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: controller.isSending ? null : () {
                          controller.sendMessage(widget.orderId, reply).then((_) => _scrollToBottom());
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Input area
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -1))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(controller),
                        decoration: InputDecoration(
                          hintText: 'type_message'.tr,
                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                            borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                            borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    controller.isSending
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : InkWell(
                            onTap: () => _send(controller),
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                              child: const Icon(HeroiconsSolid.paperAirplane, color: Colors.white, size: 20),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _send(OrderChatController controller) {
    String text = _inputController.text.trim();
    if (text.isEmpty || controller.isSending) return;
    _inputController.clear();
    controller.sendMessage(widget.orderId, text).then((_) => _scrollToBottom());
  }
}
