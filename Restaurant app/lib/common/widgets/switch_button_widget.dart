import 'package:flutter/cupertino.dart';
import 'package:mnjood_vendor/common/widgets/details_custom_card.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class SwitchButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  const SwitchButtonWidget({super.key, this.icon, required this.title, required this.onTap, this.isButtonActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: DetailsCustomCard(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: isButtonActive != null ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault,
        ),
        child: Row(children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          ],

          Expanded(
            child: Text(
              title,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),

          if (isButtonActive != null)
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Theme.of(context).hintColor.withOpacity(0.3),
                value: isButtonActive!,
                onChanged: (bool? value) => onTap(),
              ),
            )
          else
            Icon(
              HeroiconsOutline.chevronRight,
              size: 20,
              color: Theme.of(context).hintColor,
            ),
        ]),
      ),
    );
  }
}