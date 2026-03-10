import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/common/widgets/web_menu_bar.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/cart_widget.dart';
import 'package:mnjood/common/widgets/veg_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool showCart;
  final Color? bgColor;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final List<Widget>? actions;
  const CustomAppBarWidget({super.key, required this.title, this.isBackButtonExist = true, this.onBackPressed,
    this.showCart = false, this.bgColor, this.onVegFilterTap, this.type, this.actions});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
      title: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: bgColor == null ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).cardColor)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(HeroiconsOutline.arrowLeft, size: 24),
        color: bgColor == null ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).cardColor,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : const SizedBox(),
      backgroundColor: bgColor ?? Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
      elevation: 2,
      actions: showCart || onVegFilterTap != null ? [
        showCart ? IconButton(
          onPressed: () => AuthHelper.isLoggedIn()
              ? Get.toNamed(RouteHelper.getCartRoute())
              : Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.cart)),
          icon: CartWidget(color: Theme.of(context).primaryColor, size: 25),
        ) : const SizedBox(),

        onVegFilterTap != null ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
          iconColor: Theme.of(context).primaryColor,

        ) : const SizedBox(),

        const SizedBox(width: Dimensions.paddingSizeSmall),
      ] : actions ?? [const SizedBox()],
    );
  }

  @override
  Size get preferredSize => Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 100 : 50);
}
