import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mnjood/common/widgets/custom_tool_tip.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class GuestLoginWidget extends StatefulWidget {
  final JustTheController loginTooltipController;
  final Function()? onTap;
  const GuestLoginWidget({super.key, required this.loginTooltipController, this.onTap});

  @override
  State<GuestLoginWidget> createState() => _GuestLoginWidgetState();
}

class _GuestLoginWidgetState extends State<GuestLoginWidget> {

  final loginController = JustTheController();

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: context.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        Row(children: [
          Icon(HeroiconsOutline.userCircle, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text('wants_to_unlock_more_features'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          SizedBox(
            height: isDesktop ? 30 : 20,
            child: TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: widget.onTap,
              child: Text('click_here_to_login'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
            ),
          ),

        ]),
        ]),

        CustomToolTip(
          message: 'login_to_manage_your_orders_and_enjoy_additional_benefits'.tr,
          preferredDirection: AxisDirection.down,
        ),

      ]),
    );
  }
}
