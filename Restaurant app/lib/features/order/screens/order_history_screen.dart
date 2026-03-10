import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_asset_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_card.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/order/controllers/order_controller.dart';
import 'package:mnjood_vendor/features/home/widgets/order_button_widget.dart';
import 'package:mnjood_vendor/features/order/widgets/count_widget.dart';
import 'package:mnjood_vendor/features/order/widgets/order_view_widget.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().changeOrderTypeIndex((Get.find<ProfileController>().modulePermission?.regularOrder ?? true) ? 0 : 1, isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'order_history'.tr, isBackButtonExist: false),

      body: (Get.find<ProfileController>().modulePermission?.regularOrder ?? true) || (Get.find<ProfileController>().modulePermission?.subscriptionOrder ?? false) ? GetBuilder<OrderController>(builder: (orderController) {
        return Column(children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Pill-style order type selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            ),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if(Get.find<ProfileController>().modulePermission?.regularOrder ?? true){
                      orderController.changeOrderTypeIndex(0);
                    }else {
                      showCustomSnackBar('you_have_no_permission_to_access_this_feature'.tr);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: orderController.orderTypeIndex == 0
                          ? Theme.of(context).cardColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: orderController.orderTypeIndex == 0
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
                      'regular_order'.tr,
                      style: robotoMedium.copyWith(
                        color: orderController.orderTypeIndex == 0
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
                    if(Get.find<ProfileController>().modulePermission?.subscriptionOrder ?? false){
                      orderController.changeOrderTypeIndex(1);
                    }else {
                      showCustomSnackBar('you_have_no_permission_to_access_this_feature'.tr);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: orderController.orderTypeIndex == 1
                          ? Theme.of(context).cardColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: orderController.orderTypeIndex == 1
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
                      'subscription_order'.tr,
                      style: robotoMedium.copyWith(
                        color: orderController.orderTypeIndex == 1
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(children: [
            
                GetBuilder<ProfileController>(builder: (profileController) {
                  return profileController.profileModel != null ? Row(children: [
            
                    CountWidget(title: 'today'.tr, count: profileController.profileModel!.todaysOrderCount),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
            
                    CountWidget(title: 'this_week'.tr, count: profileController.profileModel!.thisWeekOrderCount),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
            
                    CountWidget(title: 'this_month'.tr, count: profileController.profileModel!.thisMonthOrderCount),
            
                  ]) : const SizedBox();
                }),
                const SizedBox(height: Dimensions.paddingSizeLarge),
            
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(children: [
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: orderController.statusList.length,
                          itemBuilder: (context, index) {
                            return OrderButtonWidget(
                              title: orderController.statusList[index].tr, index: index, orderController: orderController, fromHistory: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
            
                      Expanded(
                        child: orderController.historyOrderList != null ? orderController.historyOrderList!.isNotEmpty ? const OrderViewWidget() : Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const CustomAssetImageWidget(image: Images.noOrderIcon, height: 50, width: 50),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
            
                            Text('${'no_order_yet'.tr}!', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)),
                          ]),
                        ) : const Center(child: CircularProgressIndicator()),
                      ),
            
                    ]),
                  ),
                ),
            
              ]),
            ),
          ),
        ]);
      }) : Center(child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium)),
    );
  }
}