import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';

class PasswordCheckWidget extends StatelessWidget {
  final String title;
  final bool done;
  const PasswordCheckWidget({super.key, required this.title, required this.done});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
      child: Row(mainAxisSize: MainAxisSize.min, children: [

        Icon(done ? HeroiconsOutline.check : HeroiconsOutline.xMark, color: done ? Colors.green : Theme.of(context).colorScheme.error, size: 12),

        Text(title, style: robotoRegular.copyWith(color: done ? Colors.green : Theme.of(context).colorScheme.error, fontSize: 12)),

      ]),
    );
  }
}