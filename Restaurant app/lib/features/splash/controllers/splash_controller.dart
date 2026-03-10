import 'package:mnjood_vendor/common/models/config_model.dart';
import 'package:mnjood_vendor/features/auth/controllers/auth_controller.dart';
import 'package:mnjood_vendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood_vendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  final DateTime _currentTime = DateTime.now();
  DateTime get currentTime => _currentTime;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  Future<bool> getConfigData() async {
    try {
      ConfigModel? configModel = await splashServiceInterface.getConfigData();
      bool isSuccess = false;
      if(configModel != null) {
        _configModel = configModel;

        bool isMaintenanceMode = _configModel?.maintenanceMode ?? false;
        String platform = 'restaurant_app';
        bool isInMaintenance = isMaintenanceMode &&
            (_configModel?.maintenanceModeData?.maintenanceSystemSetup?.contains(platform) ?? false);

        if(isInMaintenance) {
          Get.offNamed(RouteHelper.getUpdateRoute(false));
        }

        isSuccess = true;

        // Safely set order status with null checks
        bool instantOrder = _configModel?.instantOrder ?? false;
        bool scheduleOrder = _configModel?.scheduleOrder ?? true;
        Get.find<RestaurantController>().setOrderStatus(instantOrder, scheduleOrder);
      }
      update();
      return isSuccess;
    } catch (e) {
      print('SplashController getConfigData error: $e');
      update();
      return false;
    }
  }

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashServiceInterface.removeSharedData();
  }

  bool showIntro() {
    return splashServiceInterface.showIntro();
  }

  void setIntro(bool intro) {
    splashServiceInterface.setIntro(intro);
  }

  void initialConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  bool isRestaurantClosed() {
    DateTime open = DateFormat('hh:mm').parse('');
    DateTime close = DateFormat('hh:mm').parse('');
    DateTime openTime = DateTime(_currentTime.year, _currentTime.month, _currentTime.day, open.hour, open.minute);
    DateTime closeTime = DateTime(_currentTime.year, _currentTime.month, _currentTime.day, close.hour, close.minute);
    if(closeTime.isBefore(openTime)) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    if(_currentTime.isAfter(openTime) && _currentTime.isBefore(closeTime)) {
      return false;
    }else {
      return true;
    }
  }

}