import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_loader_widget.dart';
import 'package:mnjood/features/address/controllers/address_controller.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/features/location/domain/models/zone_response_model.dart';
import 'package:mnjood/features/location/widgets/permission_dialog.dart';
import 'package:mnjood/features/location/widgets/pick_map_dialog.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood/util/images.dart';

class BottomButton extends StatelessWidget {
  final AddressController addressController;
  final bool fromSignUp;
  final String? route;
  const BottomButton({super.key, required this.addressController, required this.fromSignUp, required this.route});

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(width: 700, child: Padding(
      padding: context.width > 700 ? const EdgeInsets.all(0) :  const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      child: Column(children: [

        CustomButtonWidget(
          radius: Dimensions.radiusDefault,
          buttonText: 'user_current_location'.tr,
          onPressed: () async {
            _checkPermission(() async {
              Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
              AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
              ZoneResponseModel response = await Get.find<LocationController>().getZone(address.latitude, address.longitude, false);
              if(response.isSuccess) {
                if(!Get.find<AuthController>().isGuestLoggedIn() || !Get.find<AuthController>().isLoggedIn()) {
                  Get.find<AuthController>().guestLogin().then((response) {
                    if(response.isSuccess) {
                      Get.find<ProfileController>().setForceFullyUserEmpty();
                      Get.find<LocationController>().saveAddressAndNavigate(address, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(Get.context));
                    }
                  });
                } else {
                  Get.find<LocationController>().saveAddressAndNavigate(address, fromSignUp, route, route != null, ResponsiveHelper.isDesktop(Get.context));
                }
              }else {
                Get.back();
                Get.toNamed(RouteHelper.getPickMapRoute(route ?? RouteHelper.accessLocation, route != null));
                showCustomSnackBar('service_not_available_in_current_location'.tr);
              }
            });
          },
          icon: HeroiconsOutline.mapPin,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            minimumSize: const Size(Dimensions.webMaxWidth, 50),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            if(ResponsiveHelper.isDesktop(Get.context)) {
              showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                return SizedBox(
                  height: 300, width: 300,
                  child: PickMapDialog(
                    fromSignUp: fromSignUp, canRoute: route != null, fromAddAddress: false, route: route
                      ?? (fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation),
                    // canTakeCurrentLocation: false /*(!AuthHelper.isLoggedIn() || route == '/?from-splash=false')*/,
                  ),
                );
              });
            }else {
              Get.toNamed(RouteHelper.getPickMapRoute(
                route ?? (fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation), route != null,
              ));
            }
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
              child: Icon(HeroiconsOutline.map, color: Theme.of(context).primaryColor),
            ),
            Text('set_from_map'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeLarge,
            )),
          ]),
        ),

        // Skip button for guests (Apple App Review 5.1.1 compliance)
        if (Get.find<AuthController>().isGuestLoggedIn()) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          TextButton(
            onPressed: () {
              Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
            },
            child: Text(
              'skip_for_now'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],

      ]),
    )));
  }

  void _checkPermission(Function onTap) async {
    await Geolocator.requestPermission();
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }
}