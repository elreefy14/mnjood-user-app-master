import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A card with gradient background
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.boxShadow,
  });

  /// Primary gradient (orange)
  factory GradientCard.primary({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      colors: const [Color(0xFFFF9E1B), Color(0xFFFF6B35)],
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Success gradient (green)
  factory GradientCard.success({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      colors: const [Color(0xFF10B981), Color(0xFF059669)],
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Info gradient (blue)
  factory GradientCard.info({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Warning gradient (amber)
  factory GradientCard.warning({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Dark gradient
  factory GradientCard.dark({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GradientCard(
      colors: const [Color(0xFF374151), Color(0xFF1F2937)],
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ??
        [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withOpacity(0.8),
        ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effectiveColors,
          begin: begin,
          end: end,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.radiusMedium),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: effectiveColors.first.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.radiusMedium),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A wallet balance card with gradient
class WalletBalanceCard extends StatelessWidget {
  final String balance;
  final String? label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? action;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    this.label,
    this.subtitle,
    this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard.primary(
      onTap: onTap,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label ?? 'current_balance'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeOverLarge + 8,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A promotional banner card
class PromoBannerCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final List<Color>? colors;
  final Widget? icon;

  const PromoBannerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
    this.colors,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      colors: colors ?? const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
                if (buttonLabel != null) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  ElevatedButton(
                    onPressed: onButtonTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colors?.first ?? const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                    ),
                    child: Text(buttonLabel!, style: robotoMedium),
                  ),
                ],
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: Dimensions.paddingSizeDefault),
            icon!,
          ],
        ],
      ),
    );
  }
}
