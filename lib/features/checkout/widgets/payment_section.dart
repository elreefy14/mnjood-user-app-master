import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/widgets/offline_payment_button.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood/util/images.dart';

class PaymentSection extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final bool isOfflinePaymentActive;
  final double total;
  final CheckoutController checkoutController;
  const PaymentSection({
    super.key,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  late bool _isCashOnDeliveryActive;
  late bool _isDigitalPaymentActive;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    // Respect the values passed from parent - these come from API config
    // Do NOT override with fallback logic - let API control payment methods
    _isCashOnDeliveryActive = widget.isCashOnDeliveryActive;
    _isDigitalPaymentActive = widget.isDigitalPaymentActive;

    // Only show COD in UI if it's enabled by API
    notHideCod = _isCashOnDeliveryActive;

    _configurePartialPayment();
  }

  void _configurePartialPayment() {
    if (!Get.find<AuthController>().isGuestLoggedIn()) {
      double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
      if (walletBalance < widget.total) {
        canSelectWallet = false;
      }
      if (widget.checkoutController.isPartialPay) {
        notHideWallet = false;
        final partialPaymentMethod = Get.find<SplashController>().configModel?.partialPaymentMethod;
        if (partialPaymentMethod == 'cod') {
          // Only show COD if API has it enabled
          notHideCod = _isCashOnDeliveryActive;
          notHideDigital = false;
        } else if (partialPaymentMethod == 'digital_payment') {
          notHideCod = false;
          notHideDigital = true;
        } else if (partialPaymentMethod == 'both') {
          // Respect API settings for COD
          notHideCod = _isCashOnDeliveryActive;
          notHideDigital = true;
        }
      } else {
        notHideWallet = false;
        // Respect API settings - only show COD if enabled
        notHideCod = _isCashOnDeliveryActive;
        notHideDigital = true;
      }
    }
    // Removed: Force-enable COD for prescription orders
    // COD visibility is now fully controlled by API config
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.fontSizeDefault),
      child: GetBuilder<CheckoutController>(builder: (checkoutController) {
        bool disablePayments = checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(
              color: checkoutController.paymentMethodIndex == -1
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Header
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(HeroiconsOutline.creditCard, size: 18, color: Theme.of(context).primaryColor)),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('payment_method'.tr, style: robotoSemiBold),
            ]),
            const Divider(),

            // Wallet section
            _walletView(checkoutController),

            // Use new checkout_payment_list if available, else old rendering
            if (Get.find<SplashController>().configModel?.checkoutPaymentList != null)
              _buildFromCheckoutPaymentList(checkoutController, disablePayments)
            else ...[
              // COD
              if (!checkoutController.subscriptionOrder && _isCashOnDeliveryActive && notHideCod)
                _paymentOptionTile(
                  title: 'cash_on_delivery'.tr,
                  assetImage: Images.cashOnDelivery,
                  isSelected: checkoutController.paymentMethodIndex == 0,
                  disabled: disablePayments,
                  onTap: disablePayments ? null : () => checkoutController.setPaymentMethod(0),
                ),

              // Digital payment gateways
              if (_isDigitalPaymentActive && notHideDigital && !checkoutController.subscriptionOrder)
                Builder(builder: (context) {
                  final paymentMethodList = Get.find<SplashController>().configModel?.activePaymentMethodList ?? [];
                  if (paymentMethodList.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeExtraSmall),
                        child: Text(
                          'pay_via_online'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      ...paymentMethodList.map((paymentMethod) {
                        bool isSelected = checkoutController.paymentMethodIndex == 2 &&
                            (paymentMethod.getWay ?? '') == checkoutController.digitalPaymentName;
                        return _paymentOptionTile(
                          title: paymentMethod.getWayTitle ?? '',
                          image: paymentMethod.getWayImageFullUrl,
                          isSelected: isSelected,
                          disabled: disablePayments,
                          onTap: disablePayments ? null : () {
                            checkoutController.setPaymentMethod(2);
                            checkoutController.changeDigitalPaymentName(paymentMethod.getWay ?? '');
                          },
                        );
                      }),
                    ],
                  );
                }),

              // Offline payment
              if (widget.isOfflinePaymentActive && !checkoutController.subscriptionOrder)
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: OfflinePaymentButton(
                    isSelected: checkoutController.paymentMethodIndex == 3,
                    offlineMethodList: checkoutController.offlineMethodList,
                    isOfflinePaymentActive: widget.isOfflinePaymentActive,
                    onTap: disablePayments ? null : () => checkoutController.setPaymentMethod(3),
                    checkoutController: checkoutController,
                    tooltipController: tooltipController,
                    disablePayment: disablePayments,
                  ),
                ),
            ],

          ]),
        );
      }),
    );
  }

  Widget _buildFromCheckoutPaymentList(CheckoutController checkoutController, bool disablePayments) {
    final list = Get.find<SplashController>().configModel!.checkoutPaymentList!;
    final isArabic = Get.find<LocalizationController>().locale.languageCode == 'ar';
    final activePaymentMethods = Get.find<SplashController>().configModel?.activePaymentMethodList ?? [];

    // Filter out wallet (handled separately by _walletView) and skip subscription-incompatible items
    final filteredList = list.where((item) {
      if (item.key == 'wallet') return false;
      // Respect COD enabled/disabled from API config
      if (item.key == 'cod' && !_isCashOnDeliveryActive) return false;
      if (checkoutController.subscriptionOrder && item.key != 'cod') return false;
      // Platform-based filtering for Moyasar sub-methods
      if (item.key == 'moyasar_applepay' && (GetPlatform.isWeb || !GetPlatform.isIOS)) return false;
      if (item.key == 'moyasar_googlepay' && (GetPlatform.isWeb || !GetPlatform.isAndroid)) return false;
      if (item.key == 'moyasar_samsungpay' && (GetPlatform.isWeb || !GetPlatform.isAndroid)) return false;
      // Respect partial payment visibility rules
      if (checkoutController.isPartialPay) {
        final partialPaymentMethod = Get.find<SplashController>().configModel?.partialPaymentMethod;
        if (partialPaymentMethod == 'cod' && item.legacyIndex == 2) return false;
        if (partialPaymentMethod == 'digital_payment' && item.key == 'cod') return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredList.map((item) {
        final isSelected = checkoutController.selectedPaymentKey == item.key;
        String title = isArabic && item.labelAr != null ? item.labelAr! : item.label;

        // 1. Network URL from active_payment_method_list (tamara, tabby)
        String? resolvedLogo = item.logo;
        if (resolvedLogo == null && item.gateway != null) {
          for (final m in activePaymentMethods) {
            if (m.getWay == item.gateway) {
              final url = m.getWayImageFullUrl;
              if (url != null && url.isNotEmpty && !url.contains('blank')) {
                resolvedLogo = url;
              }
              break;
            }
          }
        }

        // 2. Local asset by payment key
        String? assetImage;
        if (resolvedLogo == null) {
          assetImage = _getLocalAssetForKey(item.key);
        }

        // 3. Heroicon fallback (last resort)
        IconData? fallbackIcon;
        if (resolvedLogo == null && assetImage == null) {
          fallbackIcon = HeroiconsOutline.creditCard;
        }

        return _paymentOptionTile(
          title: title,
          image: resolvedLogo,
          assetImage: assetImage,
          icon: fallbackIcon,
          isSelected: isSelected,
          disabled: disablePayments,
          onTap: disablePayments ? null : () => checkoutController.selectPaymentFromList(item),
        );
      }).toList(),
    );
  }

  String? _getLocalAssetForKey(String key) {
    switch (key) {
      case 'cod':
      case 'cash_on_delivery':
        return Images.cashOnDelivery;
      case 'moyasar_creditcard':
        return Images.payCreditCard;
      case 'moyasar_applepay':
        return Images.appleLogo;
      case 'moyasar_stcpay':
        return Images.payStcPay;
      case 'moyasar_googlepay':
        return Images.google;
      case 'moyasar_samsungpay':
        return Images.paySamsungPay;
      default:
        return null;
    }
  }

  Widget _paymentOptionTile({
    required String title,
    String? image,
    String? assetImage,
    IconData? icon,
    required bool isSelected,
    required Function? onTap,
    bool disabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.06) : null,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                  : Theme.of(context).disabledColor.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [
            if (assetImage != null) ...[
              CustomAssetImageWidget(assetImage, height: 20, fit: BoxFit.contain, color: disabled ? Theme.of(context).disabledColor : null),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ] else if (image != null) ...[
              CustomImageWidget(height: 20, fit: BoxFit.contain, image: image, color: disabled ? Theme.of(context).disabledColor : null),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ] else if (icon != null) ...[
              Icon(icon, size: 20, color: disabled ? Theme.of(context).disabledColor : Theme.of(context).primaryColor),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
            Expanded(
              child: Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: disabled ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            Icon(
              isSelected ? HeroiconsOutline.checkCircle : HeroiconsOutline.minusCircle,
              size: 22,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _walletView(CheckoutController checkoutController) {
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;

    final configModel = Get.find<SplashController>().configModel;
    final userInfoModel = Get.find<ProfileController>().userInfoModel;
    if (checkoutController.subscriptionOrder ||
        !(configModel?.customerWalletStatus ?? false) ||
        userInfoModel == null ||
        checkoutController.distance == -1) {
      return const SizedBox();
    }

    bool isWalletSelected = checkoutController.paymentMethodIndex == 1 || checkoutController.isPartialPay;
    double balance = 0;
    if (walletBalance > widget.total && checkoutController.paymentMethodIndex == 1) {
      balance = walletBalance - widget.total;
    }

    return Column(children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: isWalletSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : Theme.of(context).disabledColor.withValues(alpha: 0.3)),
          color: isWalletSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.06) : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isWalletSelected ? 'wallet_remaining_balance'.tr : 'wallet_balance'.tr,
                style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey.shade700)),
            Row(children: [
              PriceConverter.convertPriceWithSvg(isWalletSelected ? balance : walletBalance,
                  textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
              Text(isWalletSelected ? ' (${'applied'.tr})' : '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
            ]),
          ]),
          CustomInkWellWidget(
            onTap: () {
              if (isWalletSelected) {
                checkoutController.setPaymentMethod(-1);
                if (checkoutController.isPartialPay) {
                  checkoutController.changePartialPayment();
                }
              } else {
                if (checkoutController.isPartialPay) {
                  checkoutController.changePartialPayment();
                }
                checkoutController.setPaymentMethod(1);
                if (walletBalance < widget.total) {
                  checkoutController.changePartialPayment();
                }
              }
              setState(() => _configurePartialPayment());
            },
            radius: 5,
            child: isWalletSelected
                ? const Icon(HeroiconsOutline.xMark, color: Colors.red)
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                    child: Text('apply'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
                  ),
          ),
        ]),
      ),

      if (isWalletSelected && !checkoutController.isPartialPay)
        Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('paid_by_wallet'.tr, style: robotoBold.copyWith(fontSize: 14)),
            PriceConverter.convertPriceWithSvg(widget.total, textStyle: robotoMedium.copyWith(fontSize: 18)),
          ]),
        ),

      if (isWalletSelected && checkoutController.isPartialPay) ...[
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
              PriceConverter.convertPriceWithSvg(walletBalance, textStyle: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
            ]),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('remaining_bill'.tr, style: robotoMedium.copyWith(fontSize: 14)),
              PriceConverter.convertPriceWithSvg(widget.total - walletBalance, textStyle: robotoBold.copyWith(fontSize: 18)),
            ]),
          ]),
        ),
        if (checkoutController.paymentMethodIndex == 1)
          Text('* ${'please_select_a_option_to_pay_remain_billing_amount'.tr}',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFFE74B4B))),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    ]);
  }
}
