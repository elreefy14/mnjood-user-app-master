import 'package:flutter/material.dart';
import 'package:mnjood_delivery/util/dimensions.dart';

class DividerWidget extends StatelessWidget {
  final double? height;
  const DividerWidget({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? Dimensions.paddingSizeSmall, width: double.infinity,
      color: Theme.of(context).disabledColor.withOpacity(0.1),
    );
  }
}
