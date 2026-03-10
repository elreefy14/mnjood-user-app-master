import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ProfileBgWidget extends StatelessWidget {
  final Widget circularImage;
  final Widget mainWidget;
  final bool backButton;
  const ProfileBgWidget({super.key, required this.mainWidget, required this.circularImage, required this.backButton});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Stack(clipBehavior: Clip.none, children: [

        // Gradient background instead of image
        Container(
          width: context.width,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),

        // Curved bottom overlay
        Positioned(
          top: 160, left: 0, right: 0, bottom: 0,
          child: Center(
            child: Container(
              width: 1170,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ),

        // Title
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0, right: 0,
          child: Text(
            'profile'.tr,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Back button with modern style
        if (backButton)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(HeroiconsOutline.chevronLeft, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),

        // Profile image
        Positioned(
          top: 120, left: 0, right: 0,
          child: circularImage,
        ),

      ]),

      Expanded(child: mainWidget),

    ]);
  }
}