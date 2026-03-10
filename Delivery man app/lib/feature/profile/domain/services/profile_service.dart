import 'package:mnjood_delivery/common/models/response_model.dart';
import 'package:mnjood_delivery/feature/profile/domain/models/profile_model.dart';
import 'package:mnjood_delivery/feature/profile/domain/models/record_location_body.dart';
import 'package:mnjood_delivery/feature/profile/domain/models/shift_model.dart';
import 'package:mnjood_delivery/feature/profile/domain/repositories/profile_repository_interface.dart';
import 'package:mnjood_delivery/feature/profile/domain/services/profile_service_interface.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo_coding;
import 'package:location/location.dart' as loc;
import 'package:mnjood_delivery/feature/profile/widgets/permission_dialog_widget.dart';

class ProfileService implements ProfileServiceInterface {
  final ProfileRepositoryInterface profileRepositoryInterface;
  ProfileService({required this.profileRepositoryInterface});

  @override
  Future<ProfileModel?> getProfileInfo() async {
    return await profileRepositoryInterface.getProfileInfo();
  }

  @override
  Future<bool> recordLocation(RecordLocationBody recordLocationBody) async {
    return await profileRepositoryInterface.recordLocation(recordLocationBody);
  }

  @override
  Future<ResponseModel?> updateProfile(ProfileModel userInfoModel, XFile? data, String token) async {
    return await profileRepositoryInterface.updateProfile(userInfoModel, data, token);
  }

  @override
  Future<ResponseModel?> updateActiveStatus({int? shiftId}) async {
    return await profileRepositoryInterface.updateActiveStatus(shiftId: shiftId);
  }

  @override
  bool isNotificationActive() {
    return profileRepositoryInterface.isNotificationActive();
  }

  @override
  void setNotificationActive(bool isActive) {
    profileRepositoryInterface.setNotificationActive(isActive);
  }

  @override
  Future<ResponseModel> deleteDriver() async {
    return await profileRepositoryInterface.deleteDriver();
  }

  @override
  Future<List<ShiftModel>?> getShiftList() async {
    return await profileRepositoryInterface.getShiftList();
  }

  @override
  Future<String> addressPlaceMark(Position locationResult) async {
    String address;
    try{
      List<geo_coding.Placemark> addresses = await geo_coding.placemarkFromCoordinates(locationResult.latitude, locationResult.longitude);
      geo_coding.Placemark placeMark = addresses.first;
      address = '${placeMark.name}, ${placeMark.subAdministrativeArea}, ${placeMark.isoCountryCode}';
    }catch(e) {
      address = 'Unknown Location Found';
    }
    return address;
  }

  @override
  Future<void> checkPermission(Function callback) async {
    final locationService = loc.Location();
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();

    //Check if GPS is enabled
    bool serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        Get.dialog(PermissionDialogWidget(
          description: 'location_service_disabled'.tr,
          onOkPressed: () async {
            Get.back();
            await Geolocator.openLocationSettings();
            Future.delayed(Duration(seconds: 3), () {
              if(GetPlatform.isAndroid) checkPermission(callback);
            });
          },
        ));
      }
    }

    //Check if location permission is granted
    while(Get.isDialogOpen == true) {
      Get.back();
    }

    if(permission == LocationPermission.denied /*|| (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)*/) {
      Get.dialog(PermissionDialogWidget(description: 'you_denied'.tr, onOkPressed: () async {
        Get.back();
        final perm = await Geolocator.requestPermission();
        if(perm == LocationPermission.deniedForever) await Geolocator.openAppSettings();
        Future.delayed(Duration(seconds: 3), () {
          if(GetPlatform.isAndroid) checkPermission(callback);
        });
      }));
    }else if(permission == LocationPermission.deniedForever || (GetPlatform.isIOS ? false : permission == LocationPermission.whileInUse)) {
      Get.dialog(PermissionDialogWidget(description: permission == LocationPermission.whileInUse ? 'you_denied'.tr : 'you_denied_forever'.tr, onOkPressed: () async {
        Get.back();
        await Geolocator.openAppSettings();
        Future.delayed(Duration(seconds: 3), () {
          if(GetPlatform.isAndroid) checkPermission(callback);
        });
      }));
    }else {
      callback();
    }
  }
}