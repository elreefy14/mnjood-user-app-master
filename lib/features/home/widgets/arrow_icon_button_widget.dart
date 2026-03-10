import 'package:mnjood/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ArrowIconButtonWidget extends StatelessWidget {
  const ArrowIconButtonWidget({super.key, this.onTap, this.isLeft});

  final void Function()? onTap;
  final bool? isLeft;


  @override
  Widget build(BuildContext context) {
    // Auto-detect RTL direction
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // If isLeft is explicitly set, use it; otherwise use RTL detection
    final showLeftArrow = isLeft ?? isRtl;

    return InkWell(
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: ResponsiveHelper.isMobile(context) ? 30 : 40, width: ResponsiveHelper.isMobile(context) ? 30 : 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Icon(
          showLeftArrow ? HeroiconsOutline.arrowLeft : HeroiconsOutline.arrowRight,  size: 20,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
