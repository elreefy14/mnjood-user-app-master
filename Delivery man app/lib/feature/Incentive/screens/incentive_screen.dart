import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncentiveScreen extends StatefulWidget {
  const IncentiveScreen({super.key});

  @override
  State<IncentiveScreen> createState() => _IncentiveScreenState();
}

class _IncentiveScreenState extends State<IncentiveScreen> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(title: 'incentive'.tr),

      body: GetBuilder<ProfileController>(builder: (profileController) {

        for (var incentive in profileController.profileModel!.incentiveList!) {
          if(incentive.earning! < profileController.profileModel!.todaysEarning!){
            selectedIndex = profileController.profileModel!.incentiveList!.indexOf(incentive);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Center(child: Text(
                '${'you_have_total_incentive'.tr}\n${PriceConverter.convertPrice(profileController.profileModel!.totalIncentiveEarning)}',
                textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
              )),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Text('current_incentive_offers'.tr, style: robotoMedium),
            ),

            profileController.profileModel!.incentiveList!.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              itemCount: profileController.profileModel!.incentiveList!.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: selectedIndex == index ? Theme.of(context).primaryColor : Theme.of(context).cardColor, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    child: Column(children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Text('earning'.tr, style: robotoMedium),

                        Text('incentive'.tr, style: robotoMedium),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        PriceConverter.convertPriceWithSvg(profileController.profileModel!.incentiveList![index].earning, textStyle: robotoMedium),

                        PriceConverter.convertPriceWithSvg(profileController.profileModel!.incentiveList![index].incentive, textStyle: robotoMedium),

                      ]),

                    ]),
                  ),
                );
              },
            ) : Text('no_offer_available'.tr, style: robotoBold),

          ]),
        );
      }),
    );
  }
}