import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class PrescriptionSection extends StatelessWidget {
  const PrescriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      // Only show for pharmacy orders
      if (checkoutController.businessType != 'pharmacy') {
        return const SizedBox();
      }

      return Container(
        width: context.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        child: Row(
          children: [
            // Icon
            Icon(HeroiconsOutline.beaker, color: Theme.of(context).primaryColor, size: 18),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Title
            Text('prescription'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(width: 4),
            Text('(${'optional'.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

            const Spacer(),

            // Thumbnail if image uploaded
            if (checkoutController.prescriptionImage != null) ...[
              _buildThumbnail(context, checkoutController),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],

            // Camera button
            _buildIconButton(
              context: context,
              icon: HeroiconsOutline.camera,
              onTap: () => checkoutController.pickPrescriptionImage(ImageSource.camera),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Gallery button
            _buildIconButton(
              context: context,
              icon: HeroiconsOutline.photo,
              onTap: () => checkoutController.pickPrescriptionImage(ImageSource.gallery),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildThumbnail(BuildContext context, CheckoutController checkoutController) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.file(
              File(checkoutController.prescriptionImage!.path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => checkoutController.removePrescriptionImage(),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(HeroiconsOutline.xMark, color: Colors.white, size: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
      ),
    );
  }
}
