import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_vendor/features/disbursement/controllers/disbursement_controller.dart';
import 'package:mnjood_vendor/features/payment/controllers/payment_controller.dart';
import 'package:mnjood_vendor/features/payment/widgets/wallet_card_widget.dart';
import 'package:mnjood_vendor/features/payment/widgets/wallet_attention_alert_widget.dart';
import 'package:mnjood_vendor/features/payment/widgets/wallet_widget.dart';
import 'package:mnjood_vendor/features/payment/widgets/withdraw_widget.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  @override
  void initState() {
    Get.find<PaymentController>().getWithdrawList();
    Get.find<PaymentController>().getWithdrawMethodList();
    Get.find<PaymentController>().getWalletPaymentList();
    Get.find<DisbursementController>().getDisbursementMethodList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'wallet'.tr, isBackButtonExist: false),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return GetBuilder<PaymentController>(builder: (paymentController) {
          return (profileController.profileModel != null && paymentController.withdrawList != null) ? profileController.modulePermission!.myWallet! ? RefreshIndicator(
            onRefresh: () async {
              await Get.find<ProfileController>().getProfile();
              await Get.find<PaymentController>().getWithdrawList();
            },
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    WalletCardWidget(
                      paymentController: paymentController,
                      profileController: profileController,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      Expanded(child: WalletWidget(title: 'cash_in_hand'.tr, value: profileController.profileModel!.cashInHands, image: Images.cashInHandBgIcon)),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: WalletWidget(title: 'withdraw_able_balance'.tr, value: profileController.profileModel!.balance, image: Images.withdrawAbleBalanceBgIcon)),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [
                      Expanded(child: WalletWidget(title: 'pending_withdraw'.tr, value: profileController.profileModel!.pendingWithdraw, image: Images.pendingWithdrawBgIcon),),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: WalletWidget(title: 'already_withdrawn'.tr, value: profileController.profileModel!.alreadyWithdrawn, image: Images.alreadyWithdrawBgIcon)),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    WalletWidget(title: 'total_earning'.tr, value: profileController.profileModel!.totalEarning, image: Images.totalWithdrawBgIcon),

                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    // Pill-style tab selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (paymentController.selectedIndex != 0) {
                                paymentController.setIndex(0);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentController.selectedIndex == 0
                                    ? Theme.of(context).cardColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                boxShadow: paymentController.selectedIndex == 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'withdraw_request'.tr,
                                style: robotoMedium.copyWith(
                                  color: paymentController.selectedIndex == 0
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (paymentController.selectedIndex != 1) {
                                paymentController.setIndex(1);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentController.selectedIndex == 1
                                    ? Theme.of(context).cardColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                boxShadow: paymentController.selectedIndex == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'payment_history'.tr,
                                style: robotoMedium.copyWith(
                                  color: paymentController.selectedIndex == 1
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Transaction history header
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        "transaction_history".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (paymentController.selectedIndex == 0) {
                            Get.toNamed(RouteHelper.getWithdrawHistoryRoute());
                          }
                          if (paymentController.selectedIndex == 1) {
                            Get.toNamed(RouteHelper.getPaymentHistoryRoute());
                          }
                        },
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'see_all'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeDefault),


                    if(paymentController.selectedIndex == 0)
                      paymentController.withdrawList != null ? paymentController.withdrawList!.isNotEmpty ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: paymentController.withdrawList!.length > 10 ? 10 : paymentController.withdrawList!.length,
                        itemBuilder: (context, index) {
                          return WithdrawWidget(
                            withdrawModel: paymentController.withdrawList![index],
                            showDivider: index != (paymentController.withdrawList!.length > 25 ? 25 : paymentController.withdrawList!.length-1),
                          );
                        },
                      ) : Center(child: Padding(padding: const EdgeInsets.only(top: 40, bottom: 50), child: Column(children: [
                        const CustomAssetImageWidget(image: Images.noTransactionIcon, height: 50, width: 50),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text('${'no_transaction_found'.tr}!' , style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),

                      ]))) : const Center(child: Padding(padding: EdgeInsets.only(top: 100, bottom: 50), child: CircularProgressIndicator())),

                    if (paymentController.selectedIndex == 1)
                      paymentController.transactions != null ? paymentController.transactions!.isNotEmpty ? ListView.builder(
                        itemCount: paymentController.transactions!.length > 25 ? 25 : paymentController.transactions!.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                              child: Row(children: [
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    PriceConverter.convertPriceWithSvg(paymentController.transactions![index].amount, textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Text('${'paid_via'.tr} ${paymentController.transactions![index].method?.replaceAll('_', ' ').capitalize??''}', style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor,
                                    )),
                                  ]),
                                ),
                                Text(paymentController.transactions![index].paymentTime.toString(),
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                ),
                              ]),
                            ),

                            const Divider(height: 1),
                          ]);
                        },
                      ) : Center(child: Padding(padding: const EdgeInsets.only(top: 40, bottom: 50), child: Column(children: [
                        const CustomAssetImageWidget(image: Images.noTransactionIcon, height: 50, width: 50),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text('${'no_transaction_yet'.tr}!' , style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),

                      ]))) : const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator())),

                  ]),
                ),
              ),

              (profileController.profileModel!.overFlowWarning! || profileController.profileModel!.overFlowBlockWarning!)
                  ? WalletAttentionAlertWidget(isOverFlowBlockWarning: profileController.profileModel!.overFlowBlockWarning!) : const SizedBox(),

            ]),
          ) : Center(child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium)) : const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }
}