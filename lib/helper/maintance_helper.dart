import 'package:get/get.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';

class MaintenanceHelper{
  static bool isMaintenanceEnable() {
    try {
      final configModel = Get.find<SplashController>().configModel;

      if (configModel == null) {
        return false;
      }

      bool isMaintenanceMode = configModel.maintenanceMode ?? false;
      String platform = GetPlatform.isWeb ? 'user_web_app' : 'user_mobile_app';

      bool isInMaintenance = isMaintenanceMode &&
          configModel.maintenanceModeData != null &&
          configModel.maintenanceModeData!.maintenanceSystemSetup != null &&
          configModel.maintenanceModeData!.maintenanceSystemSetup!.contains(platform);

      return isInMaintenance;
    } catch (e) {
      // If config not loaded yet or any other error, return false
      return false;
    }
  }
}