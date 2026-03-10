import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mnjood_vendor/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:mnjood_vendor/features/disbursement/helper/disbursement_helper.dart';
import 'package:mnjood_vendor/features/home/screens/home_screen.dart';
import 'package:mnjood_vendor/features/menu/screens/menu_screen.dart';
import 'package:mnjood_vendor/features/order/screens/order_history_screen.dart';
import 'package:mnjood_vendor/features/payment/screens/wallet_screen.dart';
import 'package:mnjood_vendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:mnjood_vendor/features/subscription/controllers/subscription_controller.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const OrderHistoryScreen(),
      const RestaurantScreen(),
      const WalletScreen(),
      Container(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    showDisbursementWarningMessage();

    if(Get.find<SubscriptionController>().isTrialEndModalShown){
      Get.find<SubscriptionController>().trialEndBottomSheet();
    }
  }

  Future<void> showDisbursementWarningMessage() async {
    disbursementHelper.enableDisbursementWarningMessage(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if(_pageIndex != 0) {
          _setPage(0);
        }else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          ));
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        bottomNavigationBar: !GetPlatform.isMobile ? const SizedBox() : Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(children: [
                BottomNavItemWidget(
                  imagePath: Images.favicon,
                  label: 'home'.tr,
                  isSelected: _pageIndex == 0,
                  onTap: () => _setPage(0),
                ),
                BottomNavItemWidget(
                  iconData: HeroiconsOutline.shoppingBag,
                  selectedIconData: HeroiconsSolid.shoppingBag,
                  label: 'orders'.tr,
                  isSelected: _pageIndex == 1,
                  onTap: () => _setPage(1),
                ),
                BottomNavItemWidget(
                  iconData: HeroiconsOutline.buildingStorefront,
                  selectedIconData: HeroiconsSolid.buildingStorefront,
                  label: 'store'.tr,
                  isSelected: _pageIndex == 2,
                  onTap: () => _setPage(2),
                ),
                BottomNavItemWidget(
                  iconData: HeroiconsOutline.wallet,
                  selectedIconData: HeroiconsSolid.wallet,
                  label: 'wallet'.tr,
                  isSelected: _pageIndex == 3,
                  onTap: () => _setPage(3),
                ),
                BottomNavItemWidget(
                  iconData: HeroiconsOutline.bars3,
                  selectedIconData: HeroiconsSolid.bars3,
                  label: 'menu'.tr,
                  isSelected: _pageIndex == 4,
                  onTap: () {
                    Get.bottomSheet(const MenuScreen(), backgroundColor: Colors.transparent, isScrollControlled: true);
                  },
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
    if (!Get.find<SubscriptionController>().isTrialEndModalShown) {
      Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
        if (trialEnd) {
          setState(() {
            _pageController!.jumpToPage(pageIndex);
            _pageIndex = pageIndex;
          });
        } else {
          Get.find<SubscriptionController>().setTrialEndModalShown(true);
        }
      });
    }
  }
}