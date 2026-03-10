import 'dart:typed_data';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/chat/domain/models/conversation_model.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/features/profile/domain/models/update_user_model.dart';
import 'package:mnjood/features/profile/domain/models/userinfo_model.dart';
import 'package:mnjood/features/profile/domain/services/profile_service_interface.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnjood/features/verification/screens/verification_screen.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;

  ProfileController({required this.profileServiceInterface});

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  Uint8List? _pickedFileBytes;
  Uint8List? get pickedFileBytes => _pickedFileBytes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getUserInfo() async {
    _pickedFile = null;
    _pickedFileBytes = null;
    _userInfoModel = await profileServiceInterface.getUserInfo();
    update();
  }

  void setForceFullyUserEmpty() {
    _userInfoModel = null;
    update();
  }


  Future<ResponseModel> updateUserInfo(UpdateUserModel updateUserModel, String token, {bool fromVerification = false, bool fromButton = false}) async {
    if(fromButton) {
      _isLoading = true;
      update();
    }
    ResponseModel responseModel = await profileServiceInterface.updateProfile(updateUserModel, _pickedFile, token);
    if(!fromVerification) {
      _updateProfileResponseHandle(responseModel, updateUserModel, token);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> _updateProfileResponseHandle(ResponseModel responseModel, UpdateUserModel updateUserModel, String token) async {
    updateUserModel.verificationOn = responseModel.updateProfileResponseModel?.verificationOn;
    updateUserModel.verificationMedium = responseModel.updateProfileResponseModel?.verificationMedium;
    if(Get.isDialogOpen!) {
      Get.back();
    }
    if(responseModel.isSuccess && responseModel.updateProfileResponseModel != null && responseModel.updateProfileResponseModel!.verificationOn != null && responseModel.updateProfileResponseModel!.verificationOn! == 'phone'){
      if(responseModel.updateProfileResponseModel!.verificationMedium! == 'firebase') {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(updateUserModel.phone!, token, '', fromSignUp: false, updateUserModel: updateUserModel);
      } else {
        if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.dialog(VerificationScreen(
            number: updateUserModel.phone!, email: null, token: '', fromSignUp: false,
            fromForgetPassword: false, loginType: '', password: '', userModel: updateUserModel,
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(updateUserModel.phone!, null, '', '', null, '', updateUserModel: updateUserModel));
        }
      }
    } else if(responseModel.isSuccess && responseModel.updateProfileResponseModel != null && responseModel.updateProfileResponseModel!.verificationOn != null && responseModel.updateProfileResponseModel!.verificationOn! == 'email'){
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.dialog(VerificationScreen(
          number: null, email: updateUserModel.email!, token: '', fromSignUp: false,
          fromForgetPassword: false, loginType: '', password: '', userModel: updateUserModel,
        ));
      } else {
        Get.toNamed(RouteHelper.getVerificationRoute(null, updateUserModel.email!, '', '', null, '', updateUserModel: updateUserModel));
      }
    } else if(responseModel.isSuccess && responseModel.updateProfileResponseModel == null){
      Get.back();
      _pickedFile = null;
      showCustomSnackBar(responseModel.message, isError: false);
      await getUserInfo();
    }  else if(!responseModel.isSuccess && responseModel.updateProfileResponseModel != null){
      showCustomSnackBar(responseModel.updateProfileResponseModel!.message);
    }else if(!responseModel.isSuccess){
      showCustomSnackBar(responseModel.message);
    }
  }

  void updateUserWithNewData(User? user) {
    _userInfoModel!.userInfo = user;
  }

  Future<ResponseModel> changePassword(UserInfoModel updatedUserModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.changePassword(updatedUserModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void pickImage() async {
    _pickedFile = await profileServiceInterface.pickImageFromGallery();
    if (_pickedFile != null) {
      _pickedFileBytes = await _pickedFile!.readAsBytes();
    }
    update();
  }

  void initData() {
    _pickedFile = null;
    _pickedFileBytes = null;
  }

  Future removeUser({String? password}) async {
    _isLoading = true;
    update();
    Response response = await profileServiceInterface.deleteUser(password: password);
    _isLoading = false;
    if (response.statusCode == 200 || response.statusCode == 204) {
      await Get.find<AuthController>().clearSharedData(removeToken: false);
      await Get.find<AuthController>().clearUserNumberAndPassword();
      await Get.find<CartController>().clearCartList();
      if(Get.find<AuthController>().isActiveRememberMe) {
        Get.find<AuthController>().toggleRememberMe();
      }
      if(Get.find<AuthController>().isActiveRememberMeForOtp) {
        Get.find<AuthController>().toggleRememberMeForOtp();
      }
      Get.find<FavouriteController>().removeFavourites();
      setForceFullyUserEmpty();
      showCustomSnackBar('your_account_remove_successfully'.tr, isError: false);
      _isLoading = false;
      Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
    } else {
      _isLoading = false;
      Get.back();
    }
    update();
  }


}