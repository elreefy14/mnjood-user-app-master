import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class PortionWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String? suffix;
  final Function()? onTap;

  const PortionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.suffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ?? () => Get.toNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Text(
              title,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
          ),

          // Suffix badge
          if (suffix != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                suffix!,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Chevron
          Icon(
            isRtl ? HeroiconsOutline.chevronLeft : HeroiconsOutline.chevronRight,
            size: 20,
            color: Theme.of(context).hintColor,
          ),
        ]),
      ),
    );
  }
}
