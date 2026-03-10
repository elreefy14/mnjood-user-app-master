import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:mnjood_vendor/util/app_colors.dart';

/// Notification type enum
enum NotificationType {
  order,
  system,
  promotion,
  alert,
  chat,
  payment,
}

/// Extension for notification type
extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.order:
        return HeroiconsOutline.shoppingBag;
      case NotificationType.system:
        return HeroiconsOutline.cog6Tooth;
      case NotificationType.promotion:
        return HeroiconsOutline.megaphone;
      case NotificationType.alert:
        return HeroiconsOutline.exclamationTriangle;
      case NotificationType.chat:
        return HeroiconsOutline.chatBubbleLeftRight;
      case NotificationType.payment:
        return HeroiconsOutline.banknotes;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.order:
        return AppColors.info;
      case NotificationType.system:
        return AppColors.gray500;
      case NotificationType.promotion:
        return AppColors.success;
      case NotificationType.alert:
        return AppColors.warning;
      case NotificationType.chat:
        return AppColors.primary;
      case NotificationType.payment:
        return AppColors.success;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.order:
        return 'order'.tr;
      case NotificationType.system:
        return 'system'.tr;
      case NotificationType.promotion:
        return 'promotion'.tr;
      case NotificationType.alert:
        return 'alert'.tr;
      case NotificationType.chat:
        return 'message'.tr;
      case NotificationType.payment:
        return 'payment'.tr;
    }
  }
}

/// A rich notification card widget
class NotificationCard extends StatelessWidget {
  final String title;
  final String? body;
  final String? timestamp;
  final NotificationType type;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Widget? image;
  final Map<String, dynamic>? data;

  const NotificationCard({
    super.key,
    required this.title,
    this.body,
    this.timestamp,
    this.type = NotificationType.system,
    this.isRead = false,
    this.onTap,
    this.onDismiss,
    this.image,
    this.data,
  });

  /// Factory for order notification
  factory NotificationCard.order({
    required String title,
    String? body,
    String? timestamp,
    String? orderId,
    bool isRead = false,
    VoidCallback? onTap,
  }) {
    return NotificationCard(
      title: title,
      body: body ?? (orderId != null ? 'Order #$orderId' : null),
      timestamp: timestamp,
      type: NotificationType.order,
      isRead: isRead,
      onTap: onTap,
      data: orderId != null ? {'order_id': orderId} : null,
    );
  }

  /// Factory for system notification
  factory NotificationCard.system({
    required String title,
    String? body,
    String? timestamp,
    bool isRead = false,
    VoidCallback? onTap,
  }) {
    return NotificationCard(
      title: title,
      body: body,
      timestamp: timestamp,
      type: NotificationType.system,
      isRead: isRead,
      onTap: onTap,
    );
  }

  /// Factory for promotion notification
  factory NotificationCard.promotion({
    required String title,
    String? body,
    String? timestamp,
    Widget? image,
    bool isRead = false,
    VoidCallback? onTap,
  }) {
    return NotificationCard(
      title: title,
      body: body,
      timestamp: timestamp,
      type: NotificationType.promotion,
      image: image,
      isRead: isRead,
      onTap: onTap,
    );
  }

  /// Factory for alert notification
  factory NotificationCard.alert({
    required String title,
    String? body,
    String? timestamp,
    bool isRead = false,
    VoidCallback? onTap,
  }) {
    return NotificationCard(
      title: title,
      body: body,
      timestamp: timestamp,
      type: NotificationType.alert,
      isRead: isRead,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    Widget card = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: isRead
            ? Theme.of(context).cardColor
            : type.color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: Border.all(
          color: isRead
              ? (isDark ? Colors.grey[800]! : Colors.grey[200]!)
              : type.color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(isDark),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildTypeBadge(),
                          const Spacer(),
                          if (timestamp != null)
                            Text(
                              timestamp!,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Colors.grey[400],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: (isRead ? robotoRegular : robotoMedium).copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          body!,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (image != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: image!,
                        ),
                      ],
                      if (_hasOrderData()) ...[
                        const SizedBox(height: 8),
                        _buildOrderPreview(context),
                      ],
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    decoration: BoxDecoration(
                      color: type.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onDismiss != null) {
      return Dismissible(
        key: Key(title + (timestamp ?? '')),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          ),
          child: const Icon(
            HeroiconsOutline.trash,
            color: Colors.white,
          ),
        ),
        onDismissed: (_) => onDismiss!(),
        child: card,
      );
    }

    return card;
  }

  Widget _buildIcon(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: type.color.withOpacity(isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        type.icon,
        size: 20,
        color: type.color,
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: robotoMedium.copyWith(
          fontSize: 10,
          color: type.color,
        ),
      ),
    );
  }

  bool _hasOrderData() {
    return data != null && data!['order_id'] != null;
  }

  Widget _buildOrderPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            HeroiconsOutline.documentText,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            'Order #${data!['order_id']}',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Icon(
            HeroiconsOutline.chevronRight,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

/// A grouped list of notifications by date
class NotificationGroup extends StatelessWidget {
  final String date;
  final List<Widget> notifications;

  const NotificationGroup({
    super.key,
    required this.date,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Text(
            date,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ...notifications,
      ],
    );
  }
}
