import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CountCardWidget extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String? value;
  final double height;
  const CountCardWidget({super.key, required this.backgroundColor, required this.title, required this.value, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        // Value on left
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              value != null ? Text(
                value!,
                style: robotoBold.copyWith(
                  fontSize: 28,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ) : Shimmer(
                duration: const Duration(seconds: 2),
                enabled: value == null,
                color: Theme.of(context).hintColor.withOpacity(0.3),
                child: Container(
                  height: 32,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Icon on right
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ]),
    );
  }
}
