import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreClosedDialogWidget extends StatelessWidget {
  final Restaurant restaurant;
  const StoreClosedDialogWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    String? nextOpenTime = _getNextOpenTime();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImageWidget(
              image: restaurant.logoFullUrl ?? '',
              height: 70, width: 70, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            restaurant.name ?? '',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Text(
              'store_closed_title'.tr,
              style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          if (nextOpenTime != null) ...[
            Text(
              '${'opens_at'.tr} $nextOpenTime',
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],

          SizedBox(
            width: double.infinity,
            child: CustomButtonWidget(
              buttonText: 'got_it'.tr,
              onPressed: () => Get.back(),
            ),
          ),
        ]),
      ),
    );
  }

  String? _getNextOpenTime() {
    if (restaurant.schedules == null || restaurant.schedules!.isEmpty) return null;

    final now = DateTime.now();
    int today = now.weekday; // 1=Monday .. 7=Sunday

    for (int offset = 0; offset < 7; offset++) {
      int checkDay = ((today - 1 + offset) % 7) + 1;
      for (var schedule in restaurant.schedules!) {
        if (schedule.day == checkDay) {
          if (offset == 0 && schedule.openingTime != null) {
            try {
              final parts = schedule.openingTime!.split(':');
              final openTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
              if (openTime.isAfter(now)) {
                return schedule.openingTime!.substring(0, 5);
              }
            } catch (_) {}
          } else if (offset > 0 && schedule.openingTime != null) {
            return schedule.openingTime!.substring(0, 5);
          }
        }
      }
    }
    return null;
  }
}
