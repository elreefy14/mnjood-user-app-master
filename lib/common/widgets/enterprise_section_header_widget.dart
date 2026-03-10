import 'package:flutter/material.dart';
import 'package:mnjood/util/styles.dart';

/// Enterprise-level section header with icon and title
/// Used across all home screen sections for consistent styling
class EnterpriseSectionHeaderWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const EnterpriseSectionHeaderWidget({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? const Color(0xFFDA281C);  // Brand red
    final bgColor = iconBackgroundColor ?? color.withOpacity(0.1);

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: robotoBold.copyWith(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
