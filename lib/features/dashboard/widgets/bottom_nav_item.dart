import 'package:flutter/material.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final IconData? selectedIconData;
  final Function? onTap;
  final bool isSelected;
  final String title;

  const BottomNavItem({
    super.key,
    required this.iconData,
    this.selectedIconData,
    this.onTap,
    this.isSelected = false,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap as void Function()?,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? (selectedIconData ?? iconData) : iconData,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDark
                            ? Colors.white60
                            : Colors.grey.shade500,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: robotoMedium.copyWith(
                  fontSize: isSelected ? Dimensions.fontSizeSmall : Dimensions.fontSizeExtraSmall,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isDark
                          ? Colors.white60
                          : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
