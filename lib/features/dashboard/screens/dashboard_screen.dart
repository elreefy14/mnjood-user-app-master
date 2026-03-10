import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/features/business_category/screens/supermarket_category_screen.dart';
import 'package:mnjood/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:mnjood/features/dashboard/widgets/registration_success_bottom_sheet.dart';
import 'package:mnjood/features/home/screens/home_screen.dart';
import 'package:mnjood/features/menu/screens/menu_screen.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/screens/order_screen.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/dashboard/controllers/dashboard_controller.dart';
import 'package:mnjood/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:mnjood/features/loyalty/controllers/loyalty_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/common/widgets/custom_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen({super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    if(_isLogin){
      if(Get.find<SplashController>().configModel!.loyaltyPointStatus! && Get.find<LoyaltyController>().getEarningPint().isNotEmpty && !ResponsiveHelper.isDesktop(Get.context)){
        Future.delayed(const Duration(seconds: 1), () => showAnimatedDialog(Get.context!, const CongratulationDialogue()));
      }
      _suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, notify: false);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    // Tabs: Home, Orders, M-Mart (center), Profile
    _screens = [
      const HomeScreen(),
      const OrderScreen(),
      const SupermarketCategoryScreen(),
      const MenuScreen(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

  }

  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet = Get.find<DashboardController>().getRegistrationSuccessfulSharedPref();
    if(canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context) ? Get.dialog(const Dialog(child: RegistrationSuccessBottomSheet())).then((value) {
          Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(false);
          setState(() {});
        }) : showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const RegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  Future<void> _suggestAddressBottomSheet() async {
    active = await Get.find<DashboardController>().checkLocationActive();
    if(widget.fromSplash && Get.find<DashboardController>().showLocationSuggestion && active){
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        debugPrint('$_canExit');
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          if(!ResponsiveHelper.isDesktop(context)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
          }
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,

        // No floating action button - cart is now in the nav bar

        bottomNavigationBar: ResponsiveHelper.isDesktop(context) ? const SizedBox() : Builder(builder: (context) {
          final primaryColor = Theme.of(context).primaryColor;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home
                    _buildHomeNavItem(
                      label: 'home'.tr,
                      index: 0,
                      primaryColor: primaryColor,
                    ),
                    // Orders
                    _buildNavItem(
                      icon: HeroiconsOutline.clipboardDocumentList,
                      selectedIcon: HeroiconsSolid.clipboardDocumentList,
                      label: 'orders'.tr,
                      index: 1,
                      primaryColor: primaryColor,
                    ),
                    // Center M-Mart button
                    _buildCenterMartButton(primaryColor),
                    // Profile / Menu
                    _buildNavItem(
                      icon: HeroiconsOutline.user,
                      selectedIcon: HeroiconsSolid.user,
                      label: 'profile'.tr,
                      index: 3,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
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

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required Color primaryColor,
  }) {
    final isSelected = _pageIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setPage(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? primaryColor : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeNavItem({
    required String label,
    required int index,
    required Color primaryColor,
  }) {
    final isSelected = _pageIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setPage(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using favicon image for home icon
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  Images.favicon,
                  fit: BoxFit.contain,
                  color: isSelected ? null : Colors.grey.shade400,
                  colorBlendMode: isSelected ? null : BlendMode.saturation,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? primaryColor : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterMartButton(Color primaryColor) {
    final isSelected = _pageIndex == 2;

    return GestureDetector(
      onTap: () => _setPage(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? HeroiconsSolid.buildingStorefront : HeroiconsOutline.buildingStorefront,
            size: 26,
            color: isSelected ? primaryColor : Colors.grey.shade500,
          ),
          const SizedBox(height: 2),
          Text(
            'mnjood_mart'.tr,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
