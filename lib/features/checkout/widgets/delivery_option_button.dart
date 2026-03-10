import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mnjood/common/widgets/custom_tool_tip.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/custom_validator.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class DeliveryOptionButton extends StatelessWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final double total;
  final String? chargeForView;
  final JustTheController? deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final TextEditingController? guestNameTextEditingController;
  final TextEditingController? guestNumberTextEditingController;
  final TextEditingController? guestEmailController;
  const DeliveryOptionButton({super.key, required this.value, required this.title, required this.charge, required this.isFree, required this.total,
    this.chargeForView, this.deliveryFeeTooltipController, required this.badWeatherCharge, required this.extraChargeForToolTip,
    this.guestNameTextEditingController, this.guestNumberTextEditingController, this.guestEmailController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = checkoutController.orderType == value;
        return InkWell(
          onTap: () async {
            checkoutController.setOrderType(value);
            checkoutController.setInstruction(-1);

            if(checkoutController.orderType == 'take_away') {
              checkoutController.addTips(0);
              if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try{
                  tips = double.parse(checkoutController.tipController.text);
                } catch(_) {}
                checkoutController.checkBalanceStatus(total, discount: charge! + tips);
              }
            }else if(checkoutController.orderType == 'dine_in') {
              checkoutController.addTips(0);
              if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try{
                  tips = double.parse(checkoutController.tipController.text);
                } catch(_) {}
                checkoutController.checkBalanceStatus(total, discount: charge! + tips);
              }

              if(AuthHelper.isLoggedIn()) {
                String phone = await _splitPhoneNumber(Get.find<ProfileController>().userInfoModel?.userInfo?.phone ?? '');

                guestNameTextEditingController?.text = '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''}';
                guestNumberTextEditingController?.text = phone;
                guestEmailController?.text = Get.find<ProfileController>().userInfoModel?.userInfo?.email ?? '';
              }

            }else{
              checkoutController.updateTips(
                checkoutController.getDmTipIndex().isNotEmpty ? int.parse(checkoutController.getDmTipIndex()) : 0, notify: false,
              );

              if(checkoutController.isPartialPay){
                checkoutController.changePartialPayment();
              } else {
                checkoutController.setPaymentMethod(-1);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: select ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3), width: select ? 0 : 1),
              boxShadow: select ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Icon(
                  value == 'delivery' ? HeroiconsOutline.truck
                    : value == 'take_away' ? HeroiconsOutline.shoppingBag
                    : HeroiconsOutline.buildingStorefront,
                  size: 18,
                  color: select ? Colors.white : Theme.of(context).disabledColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(title, style: robotoMedium.copyWith(
                  color: select ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode = '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }
}
