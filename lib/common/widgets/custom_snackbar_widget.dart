import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

void showCustomSnackBar(String? message, {bool isError = true}) {
  if (message != null && message.isNotEmpty && Get.context != null) {
    ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      dismissDirection: DismissDirection.horizontal,
      margin: ResponsiveHelper.isDesktop(Get.context)
          ? EdgeInsets.only(
              right: Get.context!.width * 0.7,
              left: Dimensions.paddingSizeLarge,
              bottom: Dimensions.paddingSizeLarge,
            )
          : const EdgeInsets.all(Dimensions.paddingSizeLarge),
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? const Color(0xFFFF6B6B) : const Color(0xFF039D55),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? HeroiconsOutline.exclamationCircle : HeroiconsOutline.checkCircle,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ));
  }
}
