import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/feature/auth/controllers/auth_controller.dart';
import 'package:mnjood_delivery/feature/disbursements/helper/disbursement_helper.dart';
import 'package:mnjood_delivery/feature/home/screens/home_screen.dart';
import 'package:mnjood_delivery/feature/order/controllers/order_controller.dart';
import 'package:mnjood_delivery/feature/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:mnjood_delivery/feature/order/screens/order_screen.dart';
import 'package:mnjood_delivery/feature/order/screens/running_order_screen.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/feature/profile/screens/profile_screen.dart';
import 'package:mnjood_delivery/feature/order/screens/order_request_screen.dart';
import 'package:mnjood_delivery/helper/custom_print_helper.dart';
import 'package:mnjood_delivery/helper/notification_helper.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/main.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/images.dart';
import 'package:mnjood_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  DisbursementHelper disbursementHelper = DisbursementHelper();

  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  late StreamSubscription _stream;

  // Polling for new orders (fallback when FCM fails)
  Timer? _orderCheckTimer;
  int _previousOrderCount = 0;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      OrderRequestScreen(onTap: () => _setPage(0)),
      RunningOrderScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ];

    showDisbursementWarningMessage();
    Get.find<OrderController>().getLatestOrders();
    Get.find<OrderController>().getCurrentOrders(status: 'all');

    // Start polling for new orders (fallback when FCM fails)
    _startOrderPolling();

    customPrint('dashboard call');
      _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        customPrint("dashboard onMessage: ${message.data}/ ${message.data['type']}");
        String? type = message.data['body_loc_key'] ?? message.data['type'];
        String? orderID = message.data['title_loc_key'] ?? message.data['order_id'];
      if(type != 'assign' && type != 'new_order' && type != 'message' && type != 'order_request'&& type != 'order_status' && type != 'maintenance') {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      }
      if(type == 'new_order' || type == 'order_request' || type == 'assign') {
        AudioPlayer().play(AssetSource('notification.mp3'));
        Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus!);
        Get.find<OrderController>().getLatestOrders();
      }else if(type == 'block') {
        Get.find<AuthController>().clearSharedData();
        Get.find<ProfileController>().stopLocationRecord();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  void _navigateRequestPage() {
    if(Get.find<ProfileController>().profileModel != null && Get.find<ProfileController>().profileModel!.active == 1
        && Get.find<OrderController>().currentOrderList != null && Get.find<OrderController>().currentOrderList!.isEmpty) {
      _setPage(1);
    }else {
      if(Get.find<ProfileController>().profileModel == null || Get.find<ProfileController>().profileModel!.active == 0) {
        Get.dialog(CustomAlertDialogWidget(description: 'you_are_offline_now'.tr, onOkPressed: () => Get.back()));
      }else {
        _setPage(1);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _stream.cancel();
    _orderCheckTimer?.cancel();
  }

  // Polling for new orders every 10 seconds (fallback when FCM fails)
  void _startOrderPolling() {
    // Initialize previous count
    _previousOrderCount = Get.find<OrderController>().latestOrderList?.length ?? 0;

    _orderCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForNewOrders();
    });
  }

  Future<void> _checkForNewOrders() async {
    customPrint('Checking for new orders...');

    await Get.find<OrderController>().getLatestOrders();
    await Get.find<OrderController>().getCurrentOrders(status: Get.find<OrderController>().selectedRunningOrderStatus ?? 'all');
    int currentCount = Get.find<OrderController>().latestOrderList?.length ?? 0;

    customPrint('Order count: previous=$_previousOrderCount, current=$currentCount');

    if (currentCount > 0 && currentCount > _previousOrderCount) {
      customPrint('New order detected via polling');
      AudioPlayer().play(AssetSource('notification.mp3'));
    }
    _previousOrderCount = currentCount;
  }

  Future<void> showDisbursementWarningMessage() async {
    disbursementHelper.enableDisbursementWarningMessage(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(_pageIndex != 0) {
          _setPage(0);
        }else {
          if (GetPlatform.isAndroid && Get.find<ProfileController>().profileModel!.active == 1) {
            _channel.invokeMethod('sendToBackground');
          } else {
            return;
          }
        }
      },
      child: Scaffold(

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(children: [

                BottomNavItemWidget(
                  imagePath: Images.homeIcon,
                  label: 'home'.tr,
                  isSelected: _pageIndex == 0,
                  onTap: () => _setPage(0),
                ),

                BottomNavItemWidget(
                  icon: HeroiconsOutline.clipboardDocumentList,
                  activeIcon: HeroiconsSolid.clipboardDocumentList,
                  label: 'requests'.tr,
                  isSelected: _pageIndex == 1,
                  showBadge: true,
                  onTap: () => _navigateRequestPage(),
                ),

                BottomNavItemWidget(
                  icon: HeroiconsOutline.truck,
                  activeIcon: HeroiconsSolid.truck,
                  label: 'delivery'.tr,
                  isSelected: _pageIndex == 2,
                  onTap: () => _setPage(2),
                ),

                BottomNavItemWidget(
                  icon: HeroiconsOutline.clipboardDocumentCheck,
                  activeIcon: HeroiconsSolid.clipboardDocumentCheck,
                  label: 'orders'.tr,
                  isSelected: _pageIndex == 3,
                  onTap: () => _setPage(3),
                ),

                BottomNavItemWidget(
                  icon: HeroiconsOutline.user,
                  activeIcon: HeroiconsSolid.user,
                  label: 'profile'.tr,
                  isSelected: _pageIndex == 4,
                  onTap: () => _setPage(4),
                ),

              ]),
            ),
          ),
        ),

        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });

    // Load running orders when switching to Delivery tab
    if (pageIndex == 2) {
      Get.find<OrderController>().getCurrentOrders(
        status: Get.find<OrderController>().selectedRunningOrderStatus ?? 'all',
      );
    }
  }
}