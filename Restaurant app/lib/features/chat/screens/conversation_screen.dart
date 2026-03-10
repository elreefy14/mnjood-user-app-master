import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/empty_state_widget.dart';
import 'package:mnjood_vendor/common/widgets/paginated_list_view_widget.dart';
import 'package:mnjood_vendor/features/chat/controllers/chat_controller.dart';
import 'package:mnjood_vendor/features/chat/domain/models/notification_body_model.dart';
import 'package:mnjood_vendor/features/chat/domain/models/conversation_model.dart';
import 'package:mnjood_vendor/features/chat/widgets/search_field_widget.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/helper/user_type.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    Get.find<ChatController>().setType('delivery_man', willUpdate: false);
    Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);
    _scrollController.addListener(() {
      if (_scrollController.offset < 105) {
        Get.find<ChatController>().canShowFloatingButton(false);
      } else {
        Get.find<ChatController>().canShowFloatingButton(true);
      }
    });
  }

  void _decideResult(ConversationsModel? conversation) {
    // Only delivery_man conversations now — no tab switching needed
  }

  int _getUnreadCount(ConversationsModel? model) {
    if (model?.conversations == null) return 0;
    return model!.conversations!.where((c) => (c.unreadMessageCount ?? 0) > 0).length;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      ConversationsModel? conversation0;
      if (chatController.searchConversationModel != null) {
        conversation0 = chatController.searchConversationModel;
        _decideResult(chatController.searchConversationModel);
      } else {
        conversation0 = chatController.conversationModel;
      }

      final unreadCount = _getUnreadCount(conversation0);
      final adminUnread = chatController.adminConversationModel.unreadMessageCount ?? 0;
      final totalUnread = unreadCount + (adminUnread > 0 ? 1 : 0);

      return Scaffold(
        appBar: CustomAppBarWidget(title: 'conversation_list'.tr),
        floatingActionButton: (chatController.conversationModel != null && chatController.showFloatingButton)
            ? FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 5,
                onPressed: () => Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: NotificationBodyModel(
                  notificationType: NotificationType.message,
                  adminId: 0,
                ))),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CustomImageWidget(
                      image: '${Get.find<SplashController>().configModel!.logoFullUrl}',
                    ),
                  ),
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(
            children: [
              // Search bar
              if (conversation0 != null && conversation0.conversations != null)
                Center(
                  child: Container(
                    width: Dimensions.webMaxWidth,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: SearchFieldWidget(
                      controller: _searchController,
                      hint: '${'search'.tr}...',
                      suffixIcon: chatController.searchConversationModel != null
                          ? HeroiconsOutline.xMark
                          : HeroiconsOutline.magnifyingGlass,
                      onSubmit: (String text) {
                        if (_searchController.text.trim().isNotEmpty) {
                          chatController.searchConversation(_searchController.text.trim());
                        } else {
                          showCustomSnackBar('write_something'.tr);
                        }
                      },
                      iconPressed: () {
                        if (chatController.searchConversationModel != null) {
                          _searchController.text = '';
                          chatController.removeSearchMode();
                          chatController.getConversationList(1, type: 'delivery_man');
                        } else {
                          if (_searchController.text.trim().isNotEmpty) {
                            chatController.searchConversation(_searchController.text.trim());
                          } else {
                            showCustomSnackBar('write_something'.tr);
                          }
                        }
                      },
                    ),
                  ),
                ),

              // Unread filter chip
              if (totalUnread > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _showUnreadOnly,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              HeroiconsOutline.chatBubbleLeftRight,
                              size: 14,
                              color: _showUnreadOnly
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${'unread'.tr} ($totalUnread)',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: _showUnreadOnly
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        onSelected: (value) => setState(() => _showUnreadOnly = value),
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        checkmarkColor: Colors.white,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      const Spacer(),
                      // Total conversations count
                      Text(
                        '${conversation0?.totalSize ?? 0} ${'conversations'.tr}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Get.find<ChatController>().getConversationList(1, type: chatController.type);
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Admin chat card
                      SliverToBoxAdapter(
                        child: chatController.conversationModel != null
                            ? (!_showUnreadOnly || adminUnread > 0)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeDefault,
                                      right: Dimensions.paddingSizeDefault,
                                      bottom: Dimensions.paddingSizeSmall,
                                      top: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: _EnhancedMessageCard(
                                      userTypeImage: '${Get.find<SplashController>().configModel!.logoFullUrl}',
                                      userType: '${Get.find<SplashController>().configModel!.businessName}',
                                      count: adminUnread,
                                      message: chatController.adminConversationModel.lastMessage?.message ??
                                          'chat_with_admin'.tr,
                                      time: _lastMessage(chatController.adminConversationModel) ?? '',
                                      isAdmin: true,
                                      onTap: () {
                                        Get.toNamed(RouteHelper.getChatRoute(
                                                notificationBody: NotificationBodyModel(
                                          notificationType: NotificationType.message,
                                          adminId: 0,
                                        )))
                                            ?.then((value) => Get.find<ChatController>()
                                                .getConversationList(1, type: chatController.type));
                                      },
                                    ),
                                  )
                                : const SizedBox()
                            : const SizedBox(),
                      ),


                      // Conversation list
                      SliverToBoxAdapter(
                        child: (conversation0 != null && conversation0.conversations != null)
                            ? conversation0.conversations!.isNotEmpty
                                ? _buildConversationList(chatController, conversation0)
                                : Padding(
                                    padding: EdgeInsets.only(top: context.height * 0.15),
                                    child: EmptyStateWidget.noMessages(),
                                  )
                            : Padding(
                                padding: EdgeInsets.only(top: context.height * 0.25),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildConversationList(ChatController chatController, ConversationsModel? conversation0) {
    return !chatController.tabLoading
        ? Container(
            width: Dimensions.webMaxWidth,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: PaginatedListViewWidget(
              scrollController: _scrollController,
              onPaginate: (int? offset) =>
                  chatController.getConversationList(offset!, type: chatController.type),
              totalSize: conversation0?.totalSize,
              offset: conversation0?.offset,
              enabledPagination: chatController.searchConversationModel == null,
              productView: ListView.builder(
                itemCount: conversation0?.conversations!.length,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Conversation conversation = conversation0!.conversations![index];

                  User? user;
                  String? type;

                  if (conversation.senderType == UserType.vendor.name ||
                      conversation.senderType == UserType.user.name) {
                    user = conversation.receiver;
                    type = conversation.receiverType;
                  } else {
                    user = conversation.sender;
                    type = conversation.senderType;
                  }

                  String? lastMessage = _lastMessage(conversation0.conversations![index]);

                  bool isUnread = conversation.unreadMessageCount! > 0 &&
                      conversation.lastMessage != null &&
                      conversation.lastMessage!.senderId == user?.id;

                  // Filter for unread only
                  if (_showUnreadOnly && !isUnread) {
                    return const SizedBox();
                  }

                  return (type == UserType.admin.name)
                      ? const SizedBox()
                      : (type == chatController.type)
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              child: _EnhancedConversationCard(
                                conversation: conversation,
                                user: user,
                                type: type,
                                lastMessage: lastMessage,
                                isUnread: isUnread,
                                onTap: () async {
                                  if (user != null) {
                                    await Get.toNamed(RouteHelper.getChatRoute(
                                      notificationBody: NotificationBodyModel(
                                        type: conversation.senderType,
                                        notificationType: NotificationType.message,
                                        deliveryManId: user.id,
                                      ),
                                      conversationId: conversation.id,
                                      index: index,
                                    ));
                                    chatController.getConversationList(
                                        1, type: Get.find<ChatController>().type);
                                  } else {
                                    showCustomSnackBar('${type!.tr} ${'deleted'.tr}');
                                  }
                                },
                              ),
                            )
                          : const SizedBox();
                },
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: context.height * 0.25),
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  String? _lastMessage(Conversation? conversation) {
    if (conversation != null && conversation.lastMessage != null) {
      if (conversation.lastMessage!.message != null) {
        return conversation.lastMessage!.message;
      } else if (conversation.lastMessage!.files!.isNotEmpty) {
        return '${conversation.lastMessage!.files!.length} ${'attachment'.tr}';
      }
    }
    return null;
  }
}

// Enhanced Message Card for Admin
class _EnhancedMessageCard extends StatelessWidget {
  final String userTypeImage;
  final String userType;
  final String message;
  final String time;
  final Function()? onTap;
  final int count;
  final bool isAdmin;

  const _EnhancedMessageCard({
    required this.userTypeImage,
    required this.userType,
    required this.message,
    required this.time,
    this.onTap,
    required this.count,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = count > 0;

    return CustomInkWellWidget(
      onTap: onTap!,
      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
      radius: Dimensions.radiusDefault,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isUnread
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isUnread
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Theme.of(context).primaryColor.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      height: 55,
                      width: 55,
                      image: userTypeImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Admin badge
                if (isAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                      ),
                      child: Icon(
                        HeroiconsOutline.shieldCheck,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userType,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            'admin'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Right side: time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Text(
                      count.toString(),
                      style: robotoMedium.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Conversation Card
class _EnhancedConversationCard extends StatelessWidget {
  final Conversation conversation;
  final User? user;
  final String? type;
  final String? lastMessage;
  final bool isUnread;
  final VoidCallback onTap;

  const _EnhancedConversationCard({
    required this.conversation,
    this.user,
    this.type,
    this.lastMessage,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: onTap,
      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
      radius: Dimensions.radiusDefault,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isUnread
              ? Theme.of(context).primaryColor.withOpacity(0.03)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isUnread
                ? Theme.of(context).primaryColor.withOpacity(0.15)
                : Theme.of(context).hintColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                ClipOval(
                  child: CustomImageWidget(
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    image: '${user != null ? user!.imageFullUrl : ''}',
                  ),
                ),
                // User type indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).cardColor, width: 2),
                    ),
                    child: Icon(
                      HeroiconsOutline.truck,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: user != null
                            ? Text(
                                '${user!.fName} ${user!.lName}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                '${type!.tr} ${'deleted'.tr}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (user != null)
                    Row(
                      children: [
                        if (conversation.lastMessage?.files?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              HeroiconsOutline.paperClip,
                              size: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            lastMessage ?? 'start_conversion'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Right side: time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateConverter.localDateToIsoStringAM(
                    DateConverter.dateTimeStringToDate(conversation.lastMessageTime!),
                  ),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Text(
                      conversation.unreadMessageCount.toString(),
                      style: robotoMedium.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
