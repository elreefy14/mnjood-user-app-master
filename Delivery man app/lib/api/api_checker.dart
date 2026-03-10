import 'package:mnjood_delivery/feature/auth/controllers/auth_controller.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<ProfileController>().stopLocationRecord();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }else {
      showCustomSnackBar(response.statusText);
    }
  }
}