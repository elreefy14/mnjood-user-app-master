import 'package:flutter/cupertino.dart';
import 'package:mnjood_delivery/common/widgets/details_custom_card.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';

class ProfileButtonWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  const ProfileButtonWidget({super.key, required this.icon, required this.title, required this.onTap, this.isButtonActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: DetailsCustomCard(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: isButtonActive != null ? 8 : Dimensions.paddingSizeDefault,
        ),
        child: Row(children: [

          icon,
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(title, style: robotoRegular)),

          isButtonActive != null ? CupertinoSwitch(
            value: isButtonActive!,
            onChanged: (bool isActive) => onTap(),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).disabledColor.withOpacity(0.5),
          ) : const SizedBox(),

        ]),
      ),
    );
  }
}