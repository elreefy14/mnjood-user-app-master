import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/custom_text_field_widget.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/widgets/offline_payment_button.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/splash/domain/models/config_model.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/business/controllers/business_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/util/images.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final double totalPrice;
  final bool isSubscriptionPackage;
  const PaymentMethodBottomSheet({super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.totalPrice, this.isSubscriptionPackage = false, required this.isOfflinePaymentActive});

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  late bool _isCashOnDeliveryActive;
  late bool _isDigitalPaymentActive;
  final JustTheController tooltipController = JustTheController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    CheckoutController checkoutController = Get.find<CheckoutController>();

    // Check if this is a prescription-only order (no cart items)
    final isPrescriptionOrder = checkoutController.isPrescriptionOnlyOrder;

    // Force enable COD if widget says false but config has it enabled
    _isCashOnDeliveryActive = widget.isCashOnDeliveryActive ||
        (Get.find<SplashController>().configModel?.cashOnDelivery == true);
    _isDigitalPaymentActive = widget.isDigitalPaymentActive ||
        (Get.find<SplashController>().configModel?.digitalPayment == true);

    // Always enable COD for prescription orders or as fallback
    if (isPrescriptionOrder || (!_isCashOnDeliveryActive && !_isDigitalPaymentActive)) {
      _isCashOnDeliveryActive = true;
      // Force show COD for prescription orders
      notHideCod = true;
    }

    if(checkoutController.exchangeAmount > 0) {
      _amountController.text = checkoutController.exchangeAmount.toString();
    }

    configurePartialPayment();
  }

  void configurePartialPayment() {
    final isPrescriptionOrder = Get.find<CheckoutController>().isPrescriptionOnlyOrder;

    if(!widget.isSubscriptionPackage && !Get.find<AuthController>().isGuestLoggedIn()){
      // Null-safe wallet balance access
      double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
      if(Get.find<CheckoutController>().isPartialPay){
        notHideWallet = false;
        // Null-safe configModel access
        final partialPaymentMethod = Get.find<SplashController>().configModel?.partialPaymentMethod;
        if(partialPaymentMethod == 'cod'){
          notHideCod = true;
          notHideDigital = false;
        } else if(partialPaymentMethod == 'digital_payment'){
          // For prescription orders, always show COD even if partial payment is digital only
          notHideCod = isPrescriptionOrder ? true : false;
          notHideDigital = true;
        } else if(partialPaymentMethod == 'both'){
          notHideCod = true;
          notHideDigital = true;
        }
      } else {
        notHideWallet = false;
        notHideCod = true;
        notHideDigital = true;
      }
    }

    // For prescription orders, always ensure COD is visible
    if (isPrescriptionOrder) {
      notHideCod = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 550,
      child: GetBuilder<CheckoutController>(builder: (checkoutController) {
        return GetBuilder<BusinessController>(builder: (businessController) {
          bool disablePayments = checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay;

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: const Radius.circular(Dimensions.radiusLarge), bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              ResponsiveHelper.isDesktop(context) ? Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 30, width: 30,
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                    child: const Icon(HeroiconsOutline.xMark),
                  ),
                ),
              ) : Align(
                alignment: Alignment.center,
                child: Container(
                  height: 5, width: 40,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text('choose_payment_method'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [

                      Text('total_bill'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      PriceConverter.convertPriceWithSvg(widget.totalPrice, textStyle: robotoMedium.copyWith(fontSize: 20, color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      !widget.isSubscriptionPackage && _isCashOnDeliveryActive && notHideCod ? paymentButtonView(
                        padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                        title: _appendChargePercent('cash_on_delivery'.tr, 'cash_on_delivery'),
                        assetImage: Images.cashOnDelivery,
                        isSelected: checkoutController.paymentMethodIndex == 0,
                        disablePayments: disablePayments,
                        onTap: disablePayments ? null : (){
                          checkoutController.setPaymentMethod(0);
                        },
                      ) : const SizedBox(),

                      checkoutController.subscriptionOrder ? SizedBox() : changeAmountView(checkoutController),

                      _isDigitalPaymentActive && notHideDigital && !checkoutController.subscriptionOrder ? Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('pay_via_online'.tr, style: robotoSemiBold.copyWith(color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color)),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Builder(
                              builder: (context) {
                                final paymentMethodList = Get.find<SplashController>().configModel?.activePaymentMethodList ?? [];
                                return ListView.builder(
                                  itemCount: paymentMethodList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index){
                                    if (index >= paymentMethodList.length) return const SizedBox();
                                    final paymentMethod = paymentMethodList[index];

                                    bool isSelected;
                                    if(widget.isSubscriptionPackage) {
                                      isSelected = businessController.paymentIndex == 1 && (paymentMethod.getWay ?? '') == businessController.digitalPaymentName;
                                    } else {
                                      isSelected = checkoutController.paymentMethodIndex == 2 && (paymentMethod.getWay ?? '') == checkoutController.digitalPaymentName;
                                    }
                                    return paymentButtonView(
                                      padding: EdgeInsets.only(bottom: index == paymentMethodList.length - 1 ? 0 : Dimensions.paddingSizeSmall),
                                      disablePayments: disablePayments,
                                      isDigitalPayment: true,
                                      onTap: disablePayments ? null : (){
                                        if(widget.isSubscriptionPackage) {
                                          businessController.setPaymentIndex(1);
                                          businessController.changeDigitalPaymentName(paymentMethod.getWay ?? '');
                                        } else {
                                          checkoutController.setPaymentMethod(2);
                                          checkoutController.changeDigitalPaymentName(paymentMethod.getWay ?? '');
                                        }
                                      },
                                      title: _appendChargePercent(paymentMethod.getWayTitle ?? '', paymentMethod.getWay ?? ''),
                                      isSelected: isSelected,
                                      image: paymentMethod.getWayImageFullUrl,
                                    );
                                  });
                              },
                            ),
                          ],
                        ),
                      ) : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      widget.isOfflinePaymentActive && !checkoutController.subscriptionOrder ? OfflinePaymentButton(
                        isSelected: checkoutController.paymentMethodIndex == 3,
                        offlineMethodList: checkoutController.offlineMethodList,
                        isOfflinePaymentActive: widget.isOfflinePaymentActive,
                        onTap: disablePayments ? null : () {
                          checkoutController.setPaymentMethod(3);
                        },
                        checkoutController: checkoutController, tooltipController: tooltipController,
                        disablePayment: disablePayments,
                      ) : const SizedBox(),

                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: ResponsiveHelper.isDesktop(context) ? null : BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: CustomButtonWidget(
                    buttonText: 'select'.tr,
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

            ]),
          );
        });
      }),
    );
  }

  String _appendChargePercent(String title, String gatewayKey) {
    return title;
  }

  Widget paymentButtonView({required String title, String? image, String? assetImage, IconData? icon, required bool isSelected, required Function? onTap, bool disablePayments = false, bool isDigitalPayment = false, required EdgeInsetsGeometry padding}) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: (image != null && assetImage == null) ? null : BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: isSelected && isDigitalPayment ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [

            assetImage != null ? CustomAssetImageWidget(
              assetImage, height: 20, fit: BoxFit.contain,
              color: disablePayments ? Theme.of(context).disabledColor : null,
            ) : image != null ? CustomImageWidget(
              height: 20, fit: BoxFit.contain,
              image: image, color: disablePayments ? Theme.of(context).disabledColor : null,
            ) : icon != null ? Icon(icon, size: 20, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).primaryColor) : const SizedBox(),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Text(
                title,
                style: isDigitalPayment ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color) :
                robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),

            Icon(
              isSelected ? HeroiconsOutline.checkCircle : HeroiconsOutline.minusCircle,
              size: 24,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            ),

          ]),
        ),
      ),
    );
  }

  Widget changeAmountView(CheckoutController checkoutController) {
    return Column(
      children: [
        checkoutController.showChangeAmount ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          ),
          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
          margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeExtraSmall, children: [

            Text('${'change_amount'.tr} (${Get.find<SplashController>().configModel?.currencySymbol ?? '\$'})', style: robotoBold),

            Text('add_cash_amount_for_charge'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            CustomTextFieldWidget(
              hintText: 'amount'.tr,
              showLabelText: false,
              inputType: TextInputType.number,
              isAmount: true,
              inputAction: TextInputAction.done,
              controller: _amountController,
              isEnabled: checkoutController.paymentMethodIndex == 0 ? true : false,
              onChanged: (String value){
                checkoutController.setExchangeAmount(double.tryParse(value)??0);
              },
            ),
          ]),
        ) : const SizedBox(),

        CustomInkWellWidget(
          onTap: (){
            checkoutController.setShowChangeAmount(!checkoutController.showChangeAmount);
          },
          radius: Dimensions.radiusSmall,
          padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Text(checkoutController.showChangeAmount ? 'see_less'.tr : 'see_more'.tr , style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }

  Widget walletView(CheckoutController checkoutController) {
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance??0;
    double balance = 0;
    if(walletBalance <= 0) {
      return const SizedBox();
    }
    if(walletBalance > widget.totalPrice && checkoutController.paymentMethodIndex == 1) {
      balance = walletBalance - widget.totalPrice;
    }
    bool isWalletSelected = checkoutController.paymentMethodIndex == 1 || checkoutController.isPartialPay;

    // Null-safe configModel and userInfoModel access
    final configModel = Get.find<SplashController>().configModel;
    final userInfoModel = Get.find<ProfileController>().userInfoModel;
    return !checkoutController.subscriptionOrder
      && (configModel?.customerWalletStatus ?? false)
      && userInfoModel != null && (checkoutController.distance != -1)
      ? Column(children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(isWalletSelected ? 'wallet_remaining_balance'.tr : 'wallet_balance'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey.shade700)),

            Row(children: [
              PriceConverter.convertPriceWithSvg(isWalletSelected ? balance : walletBalance, textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),

              Text(
                isWalletSelected ? ' (${'applied'.tr})' : '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
              ),
            ])
          ]),

          CustomInkWellWidget(
            onTap: () {
              if(isWalletSelected) {
                checkoutController.setPaymentMethod(-1);
                if(checkoutController.isPartialPay) {
                  checkoutController.changePartialPayment();
                }
              } else {
                if(checkoutController.isPartialPay) {
                  checkoutController.changePartialPayment();
                }
                checkoutController.setPaymentMethod(1);
                if(walletBalance < widget.totalPrice) {
                  checkoutController.changePartialPayment();
                }
              }
              configurePartialPayment();
            },
            radius: 5,
            child: isWalletSelected ? const Icon(HeroiconsOutline.xMark, color: Colors.red) : Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Text('apply'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
            ),
          ),
        ]),
      ),

      if(isWalletSelected && !checkoutController.isPartialPay)
        Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('paid_by_wallet'.tr, style: robotoBold.copyWith(fontSize: 14)),
            PriceConverter.convertPriceWithSvg(widget.totalPrice, textStyle: robotoMedium.copyWith(fontSize: 18))

          ]),
        ),


      if(isWalletSelected && checkoutController.isPartialPay)
        Column(children: [
          Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('paid_by_wallet'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                PriceConverter.convertPriceWithSvg(walletBalance, textStyle: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700))

              ]),
              const SizedBox(height: 5),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('remaining_bill'.tr, style: robotoMedium.copyWith(fontSize: 14)),
                PriceConverter.convertPriceWithSvg(widget.totalPrice - walletBalance, textStyle: robotoBold.copyWith(fontSize: 18)),

              ])
            ]),
          ),

          if(checkoutController.paymentMethodIndex == 1)
            Text('* ${'please_select_a_option_to_pay_remain_billing_amount'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFFE74B4B))),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),

    ]) : const SizedBox();
  }
}

