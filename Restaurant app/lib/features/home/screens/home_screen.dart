import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:mnjood_vendor/common/controllers/theme_controller.dart';
import 'package:mnjood_vendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_card.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/order_shimmer_widget.dart';
import 'package:mnjood_vendor/common/widgets/order_widget.dart';
import 'package:mnjood_vendor/features/auth/controllers/auth_controller.dart';
import 'package:mnjood_vendor/features/home/widgets/ads_section_widget.dart';
import 'package:mnjood_vendor/features/home/widgets/business_type_dashboard_widget.dart';
import 'package:mnjood_vendor/features/home/widgets/order_button_widget.dart';
import 'package:mnjood_vendor/features/home/widgets/order_summary_card.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/notification/controllers/notification_controller.dart';
import 'package:mnjood_vendor/features/order/controllers/order_controller.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/subscription/controllers/subscription_controller.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    // Initialize the AppLifecycleListener class and pass callbacks
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _checkSystemNotification() async {
    if(await Permission.notification.status.isDenied || await Permission.notification.status.isPermanentlyDenied) {
      Get.find<ProfileController>().setNotificationActive(false);
    }
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 200), () {
          checkPermission();
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void dispose() {
    _listener.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();

    // Load inventory data for Supermarket/Pharmacy business types
    if (BusinessTypeHelper.showEnhancedInventory()) {
      Get.find<InventoryController>().getStockOverview();
      Get.find<InventoryController>().getLowStockProducts();
      Get.find<InventoryController>().getExpiringProducts();
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if(notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      Get.find<ProfileController>().setNotificationActive(false);

    } else if(batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if(batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  final WidgetStateProperty<Icon?> thumbIcon = WidgetStateProperty.resolveWith<Icon?>(
     (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Icon(HeroiconsSolid.stop, color: Get.find<ThemeController>().darkTheme ? Colors.black : Colors.white);
      }
      return Icon(HeroiconsSolid.stop, color: Get.find<ThemeController>().darkTheme ? Colors.white: Colors.black);
    },
  );

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      checkPermission();
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if(status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(Images.logoName, width: 140),
        ),
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).cardColor,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const SizedBox(),
        actions: [
          // Notification button with minimalist design
          GetBuilder<NotificationController>(builder: (notificationController) {
            bool hasNewNotification = false;

            if(notificationController.notificationList != null) {
              hasNewNotification = notificationController.notificationList!.length != notificationController.getSeenNotificationCount();
            }

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
                      if(trialEnd) {
                        Get.toNamed(RouteHelper.getNotificationRoute());
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          HeroiconsOutline.bell,
                          size: 22,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        if (hasNewNotification)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(width: 1.5, color: Theme.of(context).cardColor),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: Column(
          children: [

            if(!_isNotificationPermissionGranted)
              permissionWarning(isBatteryPermission: false, onTap: requestNotificationPermission, closeOnTap: () {
                setState(() {
                  _isNotificationPermissionGranted = true;
                });
              }),

            if(!_isBatteryOptimizationGranted)
              permissionWarning(isBatteryPermission: true, onTap: requestBatteryOptimization, closeOnTap: () {
                setState(() {
                  _isBatteryOptimizationGranted = true;
                });
              }),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                physics: const AlwaysScrollableScrollPhysics(),
                child: GetBuilder<ProfileController>(builder: (profileController) {
                  return profileController.profileModel != null ? Column(children: [

                    profileController.modulePermission?.restaurantConfig ?? false ? CustomCard(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(children: [

                        Expanded(child: Text(
                          BusinessTypeHelper.getTemporarilyClosedLabel(), style: robotoMedium,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        )),

                        profileController.profileModel != null && profileController.profileModel!.restaurants != null && profileController.profileModel!.restaurants!.isNotEmpty ? CupertinoSwitch(
                          value: !(profileController.profileModel!.restaurants![0].active ?? false),
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Theme.of(context).hintColor.withValues(alpha: 0.5),
                          onChanged: (bool isActive) {
                            if(Get.find<ProfileController>().modulePermission?.restaurantConfig ?? false){
                              Get.dialog(ConfirmationDialogWidget(
                                icon: HeroiconsOutline.exclamationTriangle,
                                description: isActive ? 'are_you_sure_to_close_restaurant'.tr : 'are_you_sure_to_open_restaurant'.tr,
                                onYesPressed: () {
                                  Get.back();
                                  Get.find<AuthController>().toggleRestaurantClosedStatus();
                                },
                              ));
                            }else{
                              showCustomSnackBar('you_have_no_permission_to_access_this_feature'.tr);
                            }
                          },
                        ) : Shimmer(duration: const Duration(seconds: 2), child: Container(height: 30, width: 50, color: Colors.grey[300])),

                      ]),
                    ) : const SizedBox(),
                    SizedBox(height: profileController.modulePermission?.restaurantConfig ?? false ? Dimensions.paddingSizeDefault : 0),

                    profileController.modulePermission?.myWallet ?? false ? OrderSummaryCard(profileController: profileController) : const SizedBox(),
                    SizedBox(height: profileController.modulePermission?.myWallet ?? false ? Dimensions.paddingSizeLarge : 0),

                    profileController.modulePermission?.newAds ?? false ? const AdsSectionWidget() : const SizedBox(),
                    SizedBox(height: profileController.modulePermission?.newAds ?? false ? Dimensions.paddingSizeLarge : 0),

                    // Business type specific dashboard section (Supermarket/Pharmacy)
                    const BusinessTypeDashboardWidget(),
                    if (BusinessTypeHelper.showEnhancedInventory()) const SizedBox(height: Dimensions.paddingSizeLarge),

                   (profileController.modulePermission?.regularOrder ?? false) ||  (profileController.modulePermission?.subscriptionOrder ?? false) ? GetBuilder<OrderController>(builder: (orderController) {

                      List<OrderModel> orderList = [];

                      if(orderController.runningOrders != null) {
                        orderList = orderController.runningOrders![orderController.orderIndex].orderList;
                      }

                      return CustomCard(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(children: [

                          orderController.runningOrders != null ? SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: orderController.runningOrders!.length,
                              itemBuilder: (context, index) {
                                return OrderButtonWidget(
                                  title: BusinessTypeHelper.getOrderStatusLabel(orderController.runningOrders![index].status), index: index,
                                  orderController: orderController, fromHistory: false,
                                );
                              },
                            ),
                          ) : const SizedBox(),

                          Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                              orderController.runningOrders != null ? InkWell(
                                onTap: () => orderController.toggleCampaignOnly(),
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      color: orderController.campaignOnly ? Colors.green : Theme.of(context).cardColor,
                                      border: Border.all(color: orderController.campaignOnly ? Colors.transparent : Theme.of(context).hintColor),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(HeroiconsOutline.check, size: 14, color: orderController.campaignOnly ? Theme.of(context).cardColor :Theme.of(context).hintColor,),
                                  ),

                                  Text(
                                    'campaign_order'.tr,
                                    style: orderController.campaignOnly ? robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!)
                                        : robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                  ),
                                ]),
                              ) : const SizedBox(),

                              orderController.runningOrders != null ? InkWell(
                                onTap: () {
                                  if(profileController.modulePermission?.subscriptionOrder ?? false) {
                                    orderController.toggleSubscriptionOnly();
                                  } else {
                                    showCustomSnackBar('you_have_no_permission_to_access_this_feature'.tr);
                                  }
                                },
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      color: orderController.subscriptionOnly ? Colors.green : Theme.of(context).cardColor,
                                      border: Border.all(color: orderController.subscriptionOnly ? Colors.transparent : Theme.of(context).hintColor),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(HeroiconsOutline.check, size: 14, color: orderController.subscriptionOnly ? Theme.of(context).cardColor :Theme.of(context).hintColor,),
                                  ),

                                  Text(
                                    'subscription_order'.tr,
                                    style: orderController.subscriptionOnly ? robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!)
                                        : robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                  ),
                                ]),
                              ) : const SizedBox(),

                            ]),
                          ),

                          const Divider(height: Dimensions.paddingSizeOverLarge),

                          orderController.runningOrders != null ? orderList.isNotEmpty ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: orderList.length,
                            itemBuilder: (context, index) {
                              return OrderWidget(orderModel: orderList[index], hasDivider: index != orderList.length-1, isRunning: true);
                            },
                          ) : Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(child: Text('no_order_found'.tr)),
                          ) : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return OrderShimmerWidget(isEnabled: orderController.runningOrders == null);
                            },
                          ),

                        ]),
                      );
                    }) : const SizedBox(),

                  ]) : Column(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 50, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 200, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 150, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 70, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 70, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 70, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Shimmer(
                        child: Container(
                          height: 70, width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),

                  ]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget permissionWarning({required bool isBatteryPermission, required Function() onTap, required Function() closeOnTap}) {
    return GetPlatform.isAndroid ? Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [

                if(isBatteryPermission)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(HeroiconsOutline.exclamationTriangle, color: Colors.yellow,),
                  ),

                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        isBatteryPermission ? 'for_better_performance_allow_notification_to_run_in_background'.tr
                            : 'notification_is_disabled_please_allow_notification'.tr,
                        maxLines: 2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    const Icon(HeroiconsOutline.arrowRightCircle, color: Colors.white, size: 24,),
                  ]),
                ),

                const SizedBox(width: 20),
              ]),
            ),

            Positioned(
              top: 5, right: 5,
              child: InkWell(
                onTap: closeOnTap,
                child: const Icon(HeroiconsOutline.xMark, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    ) : const SizedBox();
  }
}