import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subTitle;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? menuWidget;
  const CustomAppBarWidget({super.key, required this.title, this.onBackPressed, this.isBackButtonExist = true, this.menuWidget, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? '',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          if (subTitle != null)
            Text(
              subTitle!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
      centerTitle: true,
      leading: isBackButtonExist
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(HeroiconsOutline.chevronLeft, size: 20),
                color: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: menuWidget != null
          ? [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: menuWidget,
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}