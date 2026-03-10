import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
class DeliveryDetails extends StatelessWidget {
  final bool from;
  final String? address;
  const DeliveryDetails({super.key, this.from = true, this.address});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(from ? HeroiconsOutline.buildingStorefront : HeroiconsOutline.mapPin, size: 28, color: Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(from ? 'from_restaurant'.tr : 'To'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(
          address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
        )
      ])),
    ]);
  }
}
