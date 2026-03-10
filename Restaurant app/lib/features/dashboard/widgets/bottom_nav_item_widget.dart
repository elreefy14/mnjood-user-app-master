import 'package:flutter/material.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData? iconData;
  final IconData? selectedIconData;
  final String? imagePath;
  final String? label;
  final Function? onTap;
  final bool isSelected;
  final int? badgeCount;

  const BottomNavItemWidget({
    super.key,
    this.iconData,
    this.selectedIconData,
    this.imagePath,
    this.label,
    this.onTap,
    this.isSelected = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final hintColor = Theme.of(context).hintColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap as void Function()?,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with pill-shaped active indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    imagePath != null
                        ? Opacity(
                            opacity: isSelected ? 1.0 : 0.5,
                            child: Image.asset(
                              imagePath!,
                              width: 26,
                              height: 26,
                            ),
                          )
                        : Icon(
                            isSelected
                                ? (selectedIconData ?? iconData)
                                : iconData,
                            color: isSelected ? primaryColor : hintColor,
                            size: 24,
                          ),
                    // Badge
                    if (badgeCount != null && badgeCount! > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badgeCount! > 99 ? '99+' : '$badgeCount',
                            style: robotoMedium.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Label
              if (label != null) ...[
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: isSelected ? primaryColor : hintColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
