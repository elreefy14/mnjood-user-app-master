import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/features/notification/domain/models/notification_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class NotificationDialogWidget extends StatelessWidget {
  final NotificationModel notificationModel;
  const NotificationDialogWidget({super.key, required this.notificationModel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall))),
      child:  Column(mainAxisSize: MainAxisSize.min, children: [

        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(HeroiconsOutline.xMark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        (notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty) ? Container(
          height: 150, width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).primaryColor.withValues(alpha: 0.20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(
              placeholder: Images.notificationPlaceholder,
              image: '${notificationModel.imageFullUrl}',
              height: 150, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
            ),
          ),
        ) : const SizedBox(),
        SizedBox(height: (notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Text(
            notificationModel.title ?? '',
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Text(
            notificationModel.description ?? '',
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
          ),
        ),

      ]),
    );
  }
}