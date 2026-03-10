import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mnjood_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:mnjood_delivery/feature/home/widgets/order_count_card_widget.dart';
import 'package:mnjood_delivery/feature/notification/controllers/notification_controller.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/home/widgets/count_card_widget.dart';
import 'package:mnjood_delivery/feature/home/widgets/shift_dialogue_widget.dart';
import 'package:mnjood_delivery/feature/order/screens/running_order_screen.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/feature/profile/widgets/permission_dialog_widget.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/images.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_delivery/common/widgets/order_shimmer_widget.dart';
import 'package:mnjood_delivery/common/widgets/order_widget.dart';
import 'package:mnjood_delivery/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

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
        checkPermission();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();
    Get.find<ProfileController>().getShiftList();
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!, isDataClear: false);
    await Get.find<OrderController>().getCompletedOrders(offset: 1, status: 'all', isUpdate: false);
    await Get.find<NotificationController>().getNotificationList();
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
  void dispose() {
    _listener.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(Images.logoName, width: 140),
        ),
        titleSpacing: 0,
        title: const SizedBox(),
        centerTitle: false,
        actions: [
          // Notification button with minimalist design
          GetBuilder<NotificationController>(builder: (notificationController) {
            bool hasNewNotification = false;
            if(notificationController.notificationList != null) {
              hasNewNotification = notificationController.notificationList!.length != notificationController.getSeenNotificationCount();
            }
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Icon(HeroiconsOutline.bell, size: 22, color: Theme.of(context).textTheme.bodyLarge!.color),
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
            );
          }),
          const SizedBox(width: 8),

          // Online/Offline Toggle - Modern pill design
          GetBuilder<ProfileController>(builder: (profileController) {
            return GetBuilder<OrderController>(builder: (orderController) {
              if (profileController.profileModel == null || orderController.currentOrderList == null) {
                return const SizedBox();
              }
              bool isOnline = profileController.profileModel!.active == 1;
              return GestureDetector(
                onTap: () async {
                  if(!isOnline) {
                    LocationPermission permission = await Geolocator.checkPermission();
                    if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever
                        || (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
                      _checkPermission(() {
                        if(profileController.shifts != null && profileController.shifts!.isNotEmpty) {
                          Get.dialog(const ShiftDialogueWidget());
                        }else{
                          profileController.updateActiveStatus();
                        }
                      });
                    }else {
                      if(profileController.shifts != null && profileController.shifts!.isNotEmpty) {
                        Get.dialog(const ShiftDialogueWidget());
                      }else{
                        profileController.updateActiveStatus();
                      }
                    }
                  } else {
                    if(orderController.currentOrderList!.isNotEmpty) {
                      showCustomSnackBar('you_can_not_go_offline_now'.tr);
                    } else {
                      showCustomBottomSheet(
                        child: CustomConfirmationBottomSheet(
                          title: 'offline'.tr,
                          description: 'are_you_sure_to_offline'.tr,
                          onConfirm: () {
                            profileController.updateActiveStatus(isUpdate: true);
                          },
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOnline ? ColorResources.green.withOpacity(0.1) : Theme.of(context).hintColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOnline ? ColorResources.green.withOpacity(0.3) : Theme.of(context).hintColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? ColorResources.green : Theme.of(context).hintColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'online'.tr : 'offline'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isOnline ? ColorResources.green : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
          const SizedBox(width: 12),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          return await _loadData();
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
                child: GetBuilder<ProfileController>(builder: (profileController) {

                  return Column(children: [

                    // Greeting Card - Minimalist Design
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              HeroiconsSolid.user,
                              size: 26,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Name and Greeting
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${'hello'.tr},',
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profileController.profileModel != null
                                    ? '${profileController.profileModel!.fName ?? ''} ${profileController.profileModel!.lName ?? ''}'
                                    : 'loading'.tr,
                                  style: robotoBold.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Online Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: profileController.profileModel?.active == 1
                                  ? ColorResources.green.withOpacity(0.1)
                                  : Theme.of(context).hintColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: profileController.profileModel?.active == 1
                                        ? ColorResources.green
                                        : Theme.of(context).hintColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  profileController.profileModel?.active == 1 ? 'online'.tr : 'offline'.tr,
                                  style: robotoMedium.copyWith(
                                    color: profileController.profileModel?.active == 1
                                        ? ColorResources.green
                                        : Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    GetBuilder<OrderController>(builder: (orderController) {
                      bool hasActiveOrder = orderController.currentOrderList == null || orderController.currentOrderList!.isNotEmpty;
                      bool hasMoreOrder = orderController.currentOrderList != null && orderController.currentOrderList!.length > 1;
                      return Column(children: [

                        hasActiveOrder ? TitleWidget(
                          title: 'active_order'.tr, onTap: hasMoreOrder ? () {
                            Get.toNamed(RouteHelper.getRunningOrderRoute(), arguments: const RunningOrderScreen());
                          } : null,
                        ) : const SizedBox(),
                        SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeSmall : 0),

                        orderController.currentOrderList != null ? orderController.currentOrderList!.isNotEmpty ? OrderWidget(
                          orderModel: orderController.currentOrderList![0], isRunningOrder: true, orderIndex: 0,
                        ) : const SizedBox() : OrderShimmerWidget(
                          isEnabled: orderController.currentOrderList == null,
                        ),
                        SizedBox(height: hasActiveOrder ? Dimensions.paddingSizeDefault : 0),

                      ]);
                    }),

                    TitleWidget(title: 'orders'.tr),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Order Statistics Cards
                    Row(children: [
                      Expanded(child: CountCardWidget(
                        title: 'todays_orders'.tr,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08),
                        height: 100,
                        value: profileController.profileModel?.todaysOrderCount.toString(),
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: CountCardWidget(
                        title: 'this_week_orders'.tr,
                        backgroundColor: ColorResources.green.withOpacity(0.08),
                        height: 100,
                        value: profileController.profileModel?.thisWeekOrderCount.toString(),
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    CountCardWidget(
                      title: 'total_orders'.tr,
                      backgroundColor: Theme.of(context).hintColor.withOpacity(0.08),
                      height: 100,
                      value: profileController.profileModel?.orderCount.toString(),
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
        color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.9),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [

                if(isBatteryPermission)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(HeroiconsOutline.exclamationTriangle, size: 20, color: Theme.of(context).primaryColor),
                  ),

                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        isBatteryPermission ? 'for_better_performance_allow_notification_to_run_in_background'.tr
                            : 'notification_is_disabled_please_allow_notification'.tr,
                        maxLines: 2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Icon(HeroiconsOutline.arrowRightCircle, size: 24, color: Theme.of(context).cardColor),
                  ]),
                ),

                const SizedBox(width: 20),
              ]),
            ),

            Positioned(
              top: 5, right: 5,
              child: InkWell(
                onTap: closeOnTap,
                child: Icon(HeroiconsOutline.xMark, size: 18, color: Theme.of(context).cardColor),
              ),
            ),
          ],
        ),
      ),
    ) : const SizedBox();
  }

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();

    while(Get.isDialogOpen == true) {
      Get.back();
    }

    if(permission == LocationPermission.denied/* || (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)*/) {
      Get.dialog(PermissionDialogWidget(description: 'you_denied'.tr, onOkPressed: () async {
        Get.back();
        final perm = await Geolocator.requestPermission();
        if(perm == LocationPermission.deniedForever) await Geolocator.openAppSettings();
        Future.delayed(const Duration(seconds: 3), () {
          if(GetPlatform.isAndroid) _checkPermission(callback);
        });
      }));
    }else if(permission == LocationPermission.deniedForever || (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
      Get.dialog(PermissionDialogWidget(description:  permission == LocationPermission.whileInUse ? 'you_denied'.tr : 'you_denied_forever'.tr, onOkPressed: () async {
        Get.back();
        await Geolocator.openAppSettings();
        Future.delayed(const Duration(seconds: 3), () {
          if(GetPlatform.isAndroid) _checkPermission(callback);
        });
      }));
    }else {
      callback();
    }
  }
}
