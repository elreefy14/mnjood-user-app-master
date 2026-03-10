import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:mnjood_vendor/util/app_colors.dart';

/// Coupon status enum
enum CouponStatus {
  active,
  expired,
  upcoming,
  disabled,
}

/// Extension for coupon status
extension CouponStatusExtension on CouponStatus {
  Color get color {
    switch (this) {
      case CouponStatus.active:
        return AppColors.success;
      case CouponStatus.expired:
        return AppColors.error;
      case CouponStatus.upcoming:
        return AppColors.info;
      case CouponStatus.disabled:
        return AppColors.gray400;
    }
  }

  String get label {
    switch (this) {
      case CouponStatus.active:
        return 'active'.tr;
      case CouponStatus.expired:
        return 'expired'.tr;
      case CouponStatus.upcoming:
        return 'upcoming'.tr;
      case CouponStatus.disabled:
        return 'disabled'.tr;
    }
  }
}

/// A visual coupon card widget
class CouponCard extends StatelessWidget {
  final String code;
  final String title;
  final String? description;
  final String discountValue;
  final String discountType; // 'percent' or 'amount'
  final CouponStatus status;
  final String? validUntil;
  final String? minOrder;
  final int? usageCount;
  final int? maxUsage;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final bool isEnabled;

  const CouponCard({
    super.key,
    required this.code,
    required this.title,
    this.description,
    required this.discountValue,
    this.discountType = 'percent',
    this.status = CouponStatus.active,
    this.validUntil,
    this.minOrder,
    this.usageCount,
    this.maxUsage,
    this.onTap,
    this.onToggle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.6,
            child: Stack(
              children: [
                Row(
                  children: [
                    _buildDiscountSection(context, isDark),
                    Expanded(
                      child: _buildDetailsSection(context, isDark),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildStatusBadge(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountSection(BuildContext context, bool isDark) {
    final bool isPercent = discountType == 'percent';

    return Container(
      width: 100,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusMedium),
          bottomLeft: Radius.circular(Dimensions.radiusMedium),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discountValue,
            style: robotoBold.copyWith(
              fontSize: 28,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            isPercent ? '%' : 'off'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).primaryColor,
            ),
          ),
          if (!isPercent)
            Text(
              'OFF',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _buildCodeChip(context),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.grey[500],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          _buildInfoRow(context, isDark),
          if (usageCount != null || maxUsage != null) ...[
            const SizedBox(height: 8),
            _buildUsageProgress(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeChip(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        Get.snackbar(
          'copied'.tr,
          'coupon_code_copied'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              HeroiconsOutline.clipboard,
              size: 14,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (validUntil != null) ...[
          Icon(
            HeroiconsOutline.clock,
            size: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            validUntil!,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Colors.grey[500],
            ),
          ),
        ],
        if (validUntil != null && minOrder != null)
          const SizedBox(width: 12),
        if (minOrder != null) ...[
          Icon(
            HeroiconsOutline.shoppingCart,
            size: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            '${'min'.tr}: $minOrder',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUsageProgress(BuildContext context) {
    final int used = usageCount ?? 0;
    final int max = maxUsage ?? 100;
    final double progress = max > 0 ? (used / max).clamp(0.0, 1.0) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'used'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Colors.grey[500],
              ),
            ),
            Text(
              '$used / $max',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.8 ? AppColors.warning : Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(2),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: robotoMedium.copyWith(
          fontSize: 10,
          color: status.color,
        ),
      ),
    );
  }
}

/// A compact coupon chip for inline display
class CouponChip extends StatelessWidget {
  final String code;
  final String discount;
  final VoidCallback? onTap;

  const CouponChip({
    super.key,
    required this.code,
    required this.discount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                HeroiconsOutline.ticket,
                size: 14,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                code,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  discount,
                  style: robotoMedium.copyWith(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
