import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/images.dart';
import 'package:mnjood_delivery/util/styles.dart';

class PermissionDialogWidget extends StatelessWidget {
  final String description;
  final Function onOkPressed;
  const PermissionDialogWidget({super.key, required this.description, required this.onOkPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.only(
          left: Dimensions.paddingSizeOverLarge,
          right: Dimensions.paddingSizeOverLarge,
          top: 50, bottom: Dimensions.paddingSizeLarge,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          CustomAssetImageWidget(
            image: Images.locationVectorImage,
            height: 80, width: 80,
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            description, textAlign: TextAlign.center,
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onOkPressed as void Function()?,
              child: Text(
                'go_to_settings'.tr,
                style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              ),
            ),
          ),

        ]),
      ),
    );
  }
}