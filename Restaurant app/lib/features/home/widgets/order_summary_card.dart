import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';

class OrderSummaryCard extends StatelessWidget {
  final ProfileController profileController;
  const OrderSummaryCard({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: Column(children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [

            Image.asset(Images.wallet, width: 60, height: 60),
            const SizedBox(width: Dimensions.paddingSizeLarge),

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(
                'today'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              profileController.profileModel != null
                ? PriceConverter.convertPriceWithSvg(profileController.profileModel!.todaysEarning, textStyle: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor), symbolColor: Theme.of(context).cardColor, symbolSize: 20)
                : Text('0', style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor)),

            ]),

          ]),
        ),
        const SizedBox(height: 30),

        Row(children: [

          Expanded(child: Column(children: [

            Text(
              'this_week'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            profileController.profileModel != null
              ? PriceConverter.convertPriceWithSvg(profileController.profileModel!.thisWeekEarning, textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor), symbolColor: Theme.of(context).cardColor, symbolSize: 16)
              : Text('0', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor)),

          ])),

          Container(height: 30, width: 1, color: Theme.of(context).cardColor),

          Expanded(child: Column(children: [

            Text(
              'this_month'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            profileController.profileModel != null
              ? PriceConverter.convertPriceWithSvg(profileController.profileModel!.thisMonthEarning, textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor), symbolColor: Theme.of(context).cardColor, symbolSize: 16)
              : Text('0', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor)),

          ])),

        ]),

      ]),
    );
  }
}
