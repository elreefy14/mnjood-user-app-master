import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/empty_state_widget.dart';
import 'package:mnjood_vendor/common/widgets/filter_chip_row.dart';
import 'package:mnjood_vendor/features/notification/controllers/notification_controller.dart';
import 'package:mnjood_vendor/features/notification/domain/models/notification_model.dart';
import 'package:mnjood_vendor/features/notification/widgets/notification_dialog_widget.dart';
import 'package:mnjood_vendor/helper/date_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:mnjood_vendor/util/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Get.find<NotificationController>().getNotificationList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'notification'.tr,
          onBackPressed: () {
            if (widget.fromNotification) {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else {
              Get.back();
            }
          },
        ),
        body: GetBuilder<NotificationController>(
          builder: (notificationController) {
            if (notificationController.notificationList != null) {
              notificationController.saveSeenNotificationCount(
                notificationController.notificationList!.length,
              );
            }

            if (notificationController.notificationList == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notificationController.notificationList!.isEmpty) {
              return EmptyStateWidget.noNotifications();
            }

            // Filter notifications
            final filteredNotifications = _getFilteredNotifications(
              notificationController.notificationList!,
            );

            // Group by date
            final groupedNotifications = _groupByDate(filteredNotifications);

            return Column(
              children: [
                // Filter tabs
                _buildFilterTabs(notificationController.notificationList!),

                // Notification list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await notificationController.getNotificationList();
                    },
                    child: filteredNotifications.isEmpty
                        ? _buildEmptyFilterState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeLarge,
                            ),
                            itemCount: groupedNotifications.length,
                            itemBuilder: (context, index) {
                              final group = groupedNotifications[index];
                              return _buildNotificationGroup(
                                context,
                                group['date'] as String,
                                group['notifications'] as List<NotificationModel>,
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTabs(List<NotificationModel> allNotifications) {
    final orderCount = allNotifications
        .where((n) => _getNotificationType(n) == 'order')
        .length;
    final systemCount = allNotifications
        .where((n) => _getNotificationType(n) == 'system')
        .length;
    final promoCount = allNotifications
        .where((n) => _getNotificationType(n) == 'promotion')
        .length;

    final filters = [
      FilterChipItem(
        id: 'all',
        label: 'all'.tr,
        count: allNotifications.length,
        icon: HeroiconsOutline.bell,
      ),
      FilterChipItem(
        id: 'order',
        label: 'orders'.tr,
        count: orderCount,
        icon: HeroiconsOutline.shoppingBag,
      ),
      FilterChipItem(
        id: 'system',
        label: 'system'.tr,
        count: systemCount,
        icon: HeroiconsOutline.cog6Tooth,
      ),
      FilterChipItem(
        id: 'promotion',
        label: 'promotions'.tr,
        count: promoCount,
        icon: HeroiconsOutline.megaphone,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: FilterChipRow(
        items: filters,
        selectedId: _selectedFilter,
        onSelected: (id) => setState(() => _selectedFilter = id),
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications(
    List<NotificationModel> notifications,
  ) {
    if (_selectedFilter == 'all') return notifications;

    return notifications.where((notification) {
      final type = _getNotificationType(notification);
      return type == _selectedFilter;
    }).toList();
  }

  String _getNotificationType(NotificationModel notification) {
    final type = notification.data?.type?.toLowerCase() ?? '';

    if (type.contains('order') || type == 'new_order' || type == 'assign') {
      return 'order';
    } else if (type == 'push_notification' || type.contains('promo')) {
      return 'promotion';
    }
    return 'system';
  }

  List<Map<String, dynamic>> _groupByDate(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> groups = {};

    for (final notification in notifications) {
      final dateLabel = _getDateLabel(notification.createdAt);
      groups.putIfAbsent(dateLabel, () => []);
      groups[dateLabel]!.add(notification);
    }

    return groups.entries
        .map((e) => {'date': e.key, 'notifications': e.value})
        .toList();
  }

  String _getDateLabel(String? dateTime) {
    if (dateTime == null) return 'older'.tr;

    try {
      final date = DateConverter.dateTimeStringToDate(dateTime);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final notificationDate = DateTime(date.year, date.month, date.day);

      if (notificationDate == today) {
        return 'today'.tr;
      } else if (notificationDate == yesterday) {
        return 'yesterday'.tr;
      } else if (now.difference(date).inDays < 7) {
        return 'this_week'.tr;
      } else {
        return 'older'.tr;
      }
    } catch (e) {
      return 'older'.tr;
    }
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            HeroiconsOutline.funnel,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'no_notifications_for_filter'.tr,
            style: robotoMedium.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          TextButton(
            onPressed: () => setState(() => _selectedFilter = 'all'),
            child: Text('show_all'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(
    BuildContext context,
    String date,
    List<NotificationModel> notifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeSmall,
          ),
          child: Text(
            date,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ...notifications.map(
          (notification) => _buildNotificationItem(context, notification),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
  ) {
    final bool isDark = Get.isDarkMode;
    final notificationType = _getNotificationType(notification);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 3,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => _deleteNotification(notification),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: HeroiconsOutline.trash,
              label: 'delete'.tr,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onNotificationTap(context, notification),
            borderRadius: BorderRadius.circular(12),
            splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
            highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(context, notification, notificationType),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTypeBadge(notificationType),
                            const Spacer(),
                            Text(
                              _getTimeAgo(notification.createdAt),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.title ?? '',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (notification.description != null &&
                            notification.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            notification.description!,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.grey[500],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (notification.data?.orderId != null) ...[
                          const SizedBox(height: 8),
                          _buildOrderPreview(notification.data!.orderId!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    BuildContext context,
    NotificationModel notification,
    String notificationType,
  ) {
    final type = notification.data?.type;
    final hasImage = notification.imageFullUrl != null &&
        notification.imageFullUrl!.isNotEmpty;

    if (type == 'push_notification' && hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: CustomImageWidget(
          image: '${notification.imageFullUrl}',
          height: 44,
          width: 44,
          fit: BoxFit.cover,
        ),
      );
    }

    final config = _getIconConfig(notificationType, notification.data?.type);

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: config.color.withOpacity(Get.isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(
        config.icon,
        color: config.color,
        size: 22,
      ),
    );
  }

  _IconConfig _getIconConfig(String notificationType, String? dataType) {
    switch (dataType?.toLowerCase()) {
      case 'new_order':
        return _IconConfig(HeroiconsOutline.shoppingBag, AppColors.success);
      case 'order_status':
        return _IconConfig(HeroiconsOutline.truck, AppColors.info);
      case 'assign':
        return _IconConfig(HeroiconsOutline.userPlus, const Color(0xFF8B5CF6));
      case 'push_notification':
        return _IconConfig(HeroiconsOutline.megaphone, Theme.of(context).primaryColor);
      default:
        switch (notificationType) {
          case 'order':
            return _IconConfig(HeroiconsOutline.shoppingBag, AppColors.info);
          case 'promotion':
            return _IconConfig(HeroiconsOutline.megaphone, AppColors.success);
          default:
            return _IconConfig(HeroiconsOutline.bellAlert, AppColors.warning);
        }
    }
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;

    switch (type) {
      case 'order':
        color = AppColors.info;
        label = 'order'.tr;
        break;
      case 'promotion':
        color = AppColors.success;
        label = 'promo'.tr;
        break;
      default:
        color = AppColors.gray500;
        label = 'system'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOrderPreview(int orderId) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HeroiconsOutline.documentText,
            size: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 6),
          Text(
            '${'order'.tr} #$orderId',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            HeroiconsOutline.chevronRight,
            size: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(BuildContext context, NotificationModel notification) {
    final orderId = notification.data?.orderId;

    if (orderId != null && orderId > 0) {
      Get.toNamed(RouteHelper.getOrderDetailsRoute(orderId));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return NotificationDialogWidget(notificationModel: notification);
        },
      );
    }
  }

  void _deleteNotification(NotificationModel notification) {
    // Show confirmation snackbar
    Get.snackbar(
      'deleted'.tr,
      'notification_deleted'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      mainButton: TextButton(
        onPressed: () {
          // Undo logic would go here
          Get.closeCurrentSnackbar();
        },
        child: Text('undo'.tr),
      ),
    );
    // TODO: Implement actual deletion via controller when backend supports it
  }

  String _getTimeAgo(String? dateTime) {
    if (dateTime == null) return '';

    try {
      final date = DateConverter.dateTimeStringToDate(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'just_now'.tr;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return DateConverter.dateTimeStringToDateOnly(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}

class _IconConfig {
  final IconData icon;
  final Color color;

  _IconConfig(this.icon, this.color);
}
