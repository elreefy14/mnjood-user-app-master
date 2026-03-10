import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CustomStepper extends StatelessWidget {
  final bool isActive;
  final bool haveLeftBar;
  final bool haveRightBar;
  final String title;
  final bool rightActive;
  const CustomStepper({super.key, required this.title, required this.isActive, required this.haveLeftBar, required this.haveRightBar,
    required this.rightActive});

  @override
  Widget build(BuildContext context) {
    Color color = isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor;
    Color right = rightActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor;

    return Expanded(
      child: Column(children: [

        Row(children: [
          Expanded(child: haveLeftBar ? Divider(color: color, thickness: 2) : const SizedBox()),
          Padding(
            padding: EdgeInsets.symmetric(vertical: isActive ? 0 : 5),
            child: Icon(isActive ? HeroiconsOutline.checkCircle : HeroiconsOutline.minusCircle, color: color, size: isActive ? 25 : 15),
          ),
          Expanded(child: haveRightBar ? Divider(color: right, thickness: 2) : const SizedBox()),
        ]),

        Text(
          '$title\n', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          style: robotoMedium.copyWith(color: color, fontSize: Dimensions.fontSizeExtraSmall),
        ),

      ]),
    );
  }
}
