import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A consistent empty state widget for when there's no data to display
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? image;
  final Widget? action;
  final double? iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.image,
    this.action,
    this.iconSize,
    this.iconColor,
  });

  /// Factory constructors for common empty states
  factory EmptyStateWidget.noOrders({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      title: 'no_orders_yet'.tr,
      subtitle: 'new_orders_will_appear_here'.tr,
      icon: HeroiconsOutline.clipboardDocumentList,
      action: onRefresh != null
          ? _RefreshButton(onTap: onRefresh)
          : null,
    );
  }

  factory EmptyStateWidget.noProducts({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      title: 'no_items_found'.tr,
      subtitle: 'add_items_to_start_selling'.tr,
      icon: HeroiconsOutline.shoppingBag,
      action: onAdd != null
          ? _ActionButton(
              label: 'add_item'.tr,
              icon: HeroiconsOutline.plus,
              onTap: onAdd,
            )
          : null,
    );
  }

  factory EmptyStateWidget.noNotifications() {
    return EmptyStateWidget(
      title: 'no_notifications'.tr,
      subtitle: 'you_re_all_caught_up'.tr,
      icon: HeroiconsOutline.bellSlash,
    );
  }

  factory EmptyStateWidget.noMessages() {
    return EmptyStateWidget(
      title: 'no_messages'.tr,
      subtitle: 'start_a_conversation'.tr,
      icon: HeroiconsOutline.chatBubbleLeftRight,
    );
  }

  factory EmptyStateWidget.noResults({String? searchQuery}) {
    return EmptyStateWidget(
      title: 'no_results_found'.tr,
      subtitle: searchQuery != null
          ? '${'no_results_for'.tr} "$searchQuery"'
          : 'try_different_keywords'.tr,
      icon: HeroiconsOutline.magnifyingGlass,
    );
  }

  factory EmptyStateWidget.error({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      title: 'something_went_wrong'.tr,
      subtitle: message ?? 'please_try_again'.tr,
      icon: HeroiconsOutline.exclamationCircle,
      iconColor: const Color(0xFFEF4444),
      action: onRetry != null
          ? _ActionButton(
              label: 'retry'.tr,
              icon: HeroiconsOutline.arrowPath,
              onTap: onRetry,
            )
          : null,
    );
  }

  factory EmptyStateWidget.noCoupons({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      title: 'no_coupons'.tr,
      subtitle: 'create_coupons_to_attract_customers'.tr,
      icon: HeroiconsOutline.ticket,
      action: onAdd != null
          ? _ActionButton(
              label: 'add_coupon'.tr,
              icon: HeroiconsOutline.plus,
              onTap: onAdd,
            )
          : null,
    );
  }

  factory EmptyStateWidget.noCategories({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      title: 'no_categories'.tr,
      subtitle: 'organize_your_items_with_categories'.tr,
      icon: HeroiconsOutline.squares2x2,
      action: onAdd != null
          ? _ActionButton(
              label: 'add_category'.tr,
              icon: HeroiconsOutline.plus,
              onTap: onAdd,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeOverLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Image.asset(
                image!,
                width: 150,
                height: 150,
              )
            else if (icon != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(isDark ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize ?? 48,
                  color: iconColor ??
                      (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              title,
              style: robotoSemiBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Dimensions.paddingSizeLarge),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: robotoMedium),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RefreshButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(HeroiconsOutline.arrowPath, size: 18),
      label: Text('refresh'.tr, style: robotoMedium),
    );
  }
}

/// A simple inline empty state for smaller spaces
class InlineEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey[400]),
            const SizedBox(width: 8),
          ],
          Text(
            message,
            style: robotoRegular.copyWith(
              color: Colors.grey[500],
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ],
      ),
    );
  }
}
