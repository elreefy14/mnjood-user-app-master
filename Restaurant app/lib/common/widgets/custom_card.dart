import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isBorder;
  const CustomCard({super.key, this.child, this.width, this.height, this.borderRadius, this.margin, this.padding, this.isBorder = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
