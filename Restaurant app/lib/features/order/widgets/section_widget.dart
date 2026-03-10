import 'package:flutter/material.dart';
import 'package:mnjood_vendor/common/widgets/details_custom_card.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget child;
  final bool? titleSpace;
  const SectionWidget({super.key, required this.title, required this.child, this.titleWidget, this.titleSpace = false});

  @override
  Widget build(BuildContext context) {
    return DetailsCustomCard(
      width: double.infinity,
      isBorder: false,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: (titleSpace ?? false) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (titleWidget != null) titleWidget!,
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        child,
      ]),
    );
  }
}
