import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mnjood_vendor/features/auth/controllers/auth_controller.dart';
import 'package:mnjood_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/features/chat/domain/models/notification_body_model.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/app_constants.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  bool _hasNavigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    // Global fallback timer - navigate to sign-in after 15 seconds if nothing happens
    _fallbackTimer = Timer(const Duration(seconds: 15), () {
      if (!_hasNavigated) {
        _hasNavigated = true;
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    });

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime && mounted) {
        try {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: isConnected ? Colors.green : Colors.red,
            duration: Duration(seconds: isConnected ? 3 : 6000),
            content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
          ));
        } catch (e) {
          // Context not available, ignore
        }
        if(isConnected) {
          _route();
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
    _fallbackTimer?.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) async {
      if (_hasNavigated) return;

      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          if (_hasNavigated) return;

          try {
            double minimumVersion = _getMinimumVersion() ?? 0;
            bool isMaintenanceMode = Get.find<SplashController>().configModel?.maintenanceMode ?? false;
            bool needsUpdate = AppConstants.appVersion < minimumVersion;
            bool inMaintenanceForApp = isMaintenanceMode &&
                (Get.find<SplashController>().configModel?.maintenanceModeData?.maintenanceSystemSetup?.contains('restaurant_app') ?? false);

            if (needsUpdate || inMaintenanceForApp) {
              _hasNavigated = true;
              _fallbackTimer?.cancel();
              Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
              return;
            }

            if (widget.body != null) {
              _hasNavigated = true;
              _fallbackTimer?.cancel();
              await _handleNotificationRouting(widget.body);
            } else {
              _hasNavigated = true;
              _fallbackTimer?.cancel();
              await _handleDefaultRouting();
            }
          } catch (e) {
            if (!_hasNavigated) {
              _hasNavigated = true;
              _fallbackTimer?.cancel();
              Get.offNamed(RouteHelper.getSignInRoute());
            }
          }
        });
      } else {
        // Config failed, navigate to sign-in as fallback
        Timer(const Duration(seconds: 2), () {
          if (!_hasNavigated) {
            _hasNavigated = true;
            _fallbackTimer?.cancel();
            Get.offNamed(RouteHelper.getSignInRoute());
          }
        });
      }
    }).catchError((e) {
      if (!_hasNavigated) {
        _hasNavigated = true;
        _fallbackTimer?.cancel();
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel?.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel?.appMinimumVersionIos;
    }
    return 0;
  }

  Future<void> _handleNotificationRouting(NotificationBodyModel? body) async {
    if (body == null) {
      Get.offNamed(RouteHelper.getSignInRoute());
      return;
    }
    if(body.notificationType == NotificationType.order){
      await Get.find<ProfileController>().getProfile();
      Get.toNamed(RouteHelper.getOrderDetailsRoute(body.orderId, fromNotification: true));
    }else if(body.notificationType == NotificationType.message){
      Get.toNamed(RouteHelper.getChatRoute(notificationBody: body, conversationId: body.conversationId, fromNotification: true));
    }else if(body.notificationType == NotificationType.block || body.notificationType == NotificationType.unblock) {
      Get.toNamed(RouteHelper.getSignInRoute());
    }else if(body.notificationType == NotificationType.withdraw){
      Get.to(const DashboardScreen(pageIndex: 3));
    }else if(body.notificationType == NotificationType.advertisement){
      Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: body.advertisementId, fromNotification: true));
    }else if(body.notificationType == NotificationType.campaign){
      Get.toNamed(RouteHelper.getCampaignDetailsRoute(id: body.campaignId, fromNotification: true));
    }else{
      Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
    }
  }

  Future<void> _handleDefaultRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      try {
        await Get.find<AuthController>().updateToken();
      } catch (e) {
        print('Token update error (non-fatal): $e');
      }
      try {
        await Get.find<ProfileController>().getProfile();
      } catch (e) {
        print('Profile load error: $e');
      }
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      // Always go to sign-in for now (bypass language screen for debugging)
      Get.offNamed(RouteHelper.getSignInRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Image.asset(Images.favicon, width: 150),

          ]),
        ),
      ),
    );
  }
}