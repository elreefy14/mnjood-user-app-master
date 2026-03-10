import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';

class OrderTypeWidget extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final Function onTap;
  const OrderTypeWidget({super.key, required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Row(children: [
          Image.asset(
            icon, width: 28, height: 28,
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(
            title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
            ),
          ),
        ]),
      ),
    );
  }
}
