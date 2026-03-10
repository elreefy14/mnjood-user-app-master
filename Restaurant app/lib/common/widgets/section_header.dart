import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A section header with title and optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.actionIcon,
    this.leading,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionLabel != null || onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionLabel != null)
                    Text(
                      actionLabel!,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  if (actionIcon != null || (actionLabel != null && onActionTap != null)) ...[
                    const SizedBox(width: 4),
                    Icon(
                      actionIcon ?? HeroiconsOutline.chevronRight,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A divider with optional label
class LabeledDivider extends StatelessWidget {
  final String? label;
  final Color? color;
  final double? thickness;

  const LabeledDivider({
    super.key,
    this.label,
    this.color,
    this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Colors.grey[300];

    if (label == null) {
      return Divider(
        color: dividerColor,
        thickness: thickness ?? 1,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: thickness ?? 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: Text(
            label!,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey[500],
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: thickness ?? 1,
          ),
        ),
      ],
    );
  }
}

/// A collapsible section with header
class CollapsibleSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final Widget? leading;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? childPadding;

  const CollapsibleSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.initiallyExpanded = true,
    this.leading,
    this.headerPadding,
    this.childPadding,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  late Animation<double> _heightFactor;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _heightFactor = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: widget.headerPadding ??
                const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                RotationTransition(
                  turns: _iconRotation,
                  child: Icon(
                    HeroiconsOutline.chevronDown,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedBuilder(
            animation: _heightFactor,
            builder: (context, child) {
              return Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightFactor.value,
                child: child,
              );
            },
            child: Padding(
              padding: widget.childPadding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
