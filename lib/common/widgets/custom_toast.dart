import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final bool isError;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;

  const CustomToast({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.borderRadius = 30,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10), required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF334257),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            margin: EdgeInsets.only(
              right: ResponsiveHelper.isDesktop(Get.context) ? Get.context!.width * 0.7 : Dimensions.paddingSizeLarge,
              left: Dimensions.paddingSizeLarge,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isError ? HeroiconsSolid.xCircle : HeroiconsOutline.checkCircle, color: isError ? const Color(0xffFF9090).withValues(alpha: 0.5) : const Color(0xff039D55), size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Flexible(child: Text(text, style: robotoRegular.copyWith(color: textColor), maxLines: 3, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
      ),
    );
  }
}