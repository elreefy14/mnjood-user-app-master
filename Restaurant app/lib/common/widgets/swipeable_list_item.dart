import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A swipe action configuration
class SwipeAction {
  final IconData icon;
  final String? label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final bool autoClose;

  const SwipeAction({
    required this.icon,
    this.label,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    required this.onTap,
    this.autoClose = true,
  });

  /// Factory constructors for common actions
  factory SwipeAction.delete({required VoidCallback onTap}) {
    return SwipeAction(
      icon: HeroiconsOutline.trash,
      label: 'delete'.tr,
      backgroundColor: const Color(0xFFEF4444),
      onTap: onTap,
    );
  }

  factory SwipeAction.archive({required VoidCallback onTap}) {
    return SwipeAction(
      icon: HeroiconsOutline.archiveBox,
      label: 'archive'.tr,
      backgroundColor: const Color(0xFF6B7280),
      onTap: onTap,
    );
  }

  factory SwipeAction.edit({required VoidCallback onTap}) {
    return SwipeAction(
      icon: HeroiconsOutline.pencil,
      label: 'edit'.tr,
      backgroundColor: const Color(0xFF3B82F6),
      onTap: onTap,
    );
  }

  factory SwipeAction.markRead({required VoidCallback onTap}) {
    return SwipeAction(
      icon: HeroiconsOutline.check,
      label: 'mark_read'.tr,
      backgroundColor: const Color(0xFF10B981),
      onTap: onTap,
    );
  }

  factory SwipeAction.pin({required VoidCallback onTap, bool isPinned = false}) {
    return SwipeAction(
      icon: isPinned ? HeroiconsSolid.star : HeroiconsOutline.star,
      label: isPinned ? 'unpin'.tr : 'pin'.tr,
      backgroundColor: const Color(0xFFF59E0B),
      onTap: onTap,
    );
  }
}

/// A list item with swipe actions
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final List<SwipeAction>? startActions;
  final List<SwipeAction>? endActions;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.startActions,
    this.endActions,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || (startActions == null && endActions == null)) {
      return _buildContent(context);
    }

    return Slidable(
      startActionPane: startActions != null
          ? ActionPane(
              motion: const DrawerMotion(),
              children: startActions!
                  .map((action) => _buildAction(action))
                  .toList(),
            )
          : null,
      endActionPane: endActions != null
          ? ActionPane(
              motion: const DrawerMotion(),
              children: endActions!
                  .map((action) => _buildAction(action))
                  .toList(),
            )
          : null,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }

  SlidableAction _buildAction(SwipeAction action) {
    return SlidableAction(
      onPressed: (_) => action.onTap(),
      backgroundColor: action.backgroundColor,
      foregroundColor: action.foregroundColor,
      icon: action.icon,
      label: action.label,
      autoClose: action.autoClose,
    );
  }
}

/// A notification-style list item with swipe actions
class NotificationListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? timestamp;
  final IconData? icon;
  final Color? iconColor;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkRead;
  final Widget? leading;
  final Widget? trailing;

  const NotificationListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.timestamp,
    this.icon,
    this.iconColor,
    this.isRead = false,
    this.onTap,
    this.onDelete,
    this.onMarkRead,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    final List<SwipeAction> actions = [];
    if (onMarkRead != null && !isRead) {
      actions.add(SwipeAction.markRead(onTap: onMarkRead!));
    }
    if (onDelete != null) {
      actions.add(SwipeAction.delete(onTap: onDelete!));
    }

    return SwipeableListItem(
      endActions: actions.isNotEmpty ? actions : null,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.transparent
              : (isDark
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Theme.of(context).primaryColor.withOpacity(0.05)),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null)
              leading!
            else if (icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? Theme.of(context).primaryColor,
                ),
              ),
            if (leading != null || icon != null)
              const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: (isRead ? robotoRegular : robotoMedium).copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      timestamp!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
