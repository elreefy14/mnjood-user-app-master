import 'package:flutter/foundation.dart';
import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/features/auth/domain/models/auth_response_model.dart';
import 'package:mnjood/features/auth/domain/models/signup_body_model.dart';
import 'package:mnjood/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:mnjood/features/auth/domain/reposotories/auth_repo_interface.dart';
import 'package:mnjood/features/auth/domain/services/auth_service_interface.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService implements AuthServiceInterface{
  final AuthRepoInterface authRepoInterface;
  AuthService({required this.authRepoInterface});

  @override
  Future<ResponseModel> registration(SignUpBodyModel signUpModel) async {
    Response response = await authRepoInterface.registration(signUpModel);
    if(response.statusCode == 200 || response.statusCode == 201){
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      AuthResponseModel authResponse = AuthResponseModel.fromJson(data);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: false);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: _extractErrorCode(response.body));
    }
  }

  /// Safely extract error code from response body
  String? _extractErrorCode(dynamic body) {
    if (body == null || body is! Map) return null;
    final errors = body['errors'];
    if (errors != null && errors is List && errors.isNotEmpty) {
      return errors[0]['code']?.toString();
    }
    return null;
  }

  @override
  Future<ResponseModel> login({required String emailOrPhone, required String password, required String loginType, required String fieldType, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.login(emailOrPhone: emailOrPhone, password: password, loginType: loginType, fieldType: fieldType);
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      AuthResponseModel authResponse = AuthResponseModel.fromJson(data);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: alreadyInApp);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: _extractErrorCode(response.body));
    }
  }

  @override
  Future<ResponseModel> otpLogin({required String phone, required String otp, required String loginType, required String verified, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.otpLogin(phone: phone, otp: otp, loginType: loginType, verified: verified);
    if (response.statusCode == 200) {
      return ResponseModel(true, 'otp_sent');
    } else {
      return ResponseModel(false, response.statusText, code: _extractErrorCode(response.body));
    }
  }

  @override
  Future<ResponseModel> verifyOtp({required String phone, required String otp, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.verifyOtp(phone: phone, otp: otp);
    if (response.statusCode == 200) {
      var data = response.body['data'] ?? response.body;
      AuthResponseModel authResponse = AuthResponseModel.fromJson(data);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: alreadyInApp);
      return ResponseModel(true, authResponse.token ?? '', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: _extractErrorCode(response.body));
    }
  }

  @override
  Future<ResponseModel> updatePersonalInfo({required String name, required String? phone, required String loginType, required String? email, required String? referCode, bool alreadyInApp = false}) async {
    Response response = await authRepoInterface.updatePersonalInfo(name: name, phone: phone, email: email, loginType: loginType, referCode: referCode);
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      AuthResponseModel authResponse = AuthResponseModel.fromJson(data);
      await _updateHeaderFunctionality(authResponse, alreadyInApp: alreadyInApp);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: _extractErrorCode(response.body));
    }
  }

  Future<void> _updateHeaderFunctionality(AuthResponseModel authResponse, {bool alreadyInApp = false}) async {
    // Debug logging to diagnose login issues
    debugPrint('=== AUTH DEBUG ===');
    debugPrint('isEmailVerified: ${authResponse.isEmailVerified}');
    debugPrint('isPhoneVerified: ${authResponse.isPhoneVerified}');
    debugPrint('isPersonalInfo: ${authResponse.isPersonalInfo}');
    debugPrint('isExistUser: ${authResponse.isExistUser}');
    debugPrint('token exists: ${authResponse.token != null}');
    debugPrint('token length: ${authResponse.token?.length ?? 0}');

    if(authResponse.isEmailVerified! && authResponse.isPhoneVerified! && authResponse.isPersonalInfo! && authResponse.token != null && authResponse.isExistUser == null) {
      debugPrint('AUTH: All conditions met - saving token');
      authRepoInterface.saveUserToken(authResponse.token??'', alreadyInApp: alreadyInApp);
      await authRepoInterface.updateToken();
      await authRepoInterface.clearGuestId();
    } else {
      debugPrint('AUTH: Token NOT saved - conditions not met');
    }
    debugPrint('=== END AUTH DEBUG ===');
  }

  @override
  Future<ResponseModel> guestLogin() async {
    return await authRepoInterface.guestLogin();
  }

  @override
  void saveUserNumberAndPassword({required String number, required String password, required String countryCode, required String otpPoneNumber}) {
    authRepoInterface.saveUserNumberAndPassword(number: number, password: password, countryCode: countryCode, otpPoneNumber: otpPoneNumber);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    return authRepoInterface.clearUserNumberAndPassword();
  }

  @override
  String getUserCountryCode() {
    return authRepoInterface.getUserCountryCode();
  }

  @override
  String getUserNumber() {
    return authRepoInterface.getUserNumber();
  }

  @override
  String getUserPassword() {
    return authRepoInterface.getUserPassword();
  }

  @override
  Future<ResponseModel> loginWithSocialMedia(SocialLogInBodyModel socialLogInModel, {bool isCustomerVerificationOn = false}) async {
    Response response = await authRepoInterface.loginWithSocialMedia(socialLogInModel);
    if (response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      AuthResponseModel authResponse = AuthResponseModel.fromJson(data);
      await _updateHeaderFunctionality(authResponse);
      return ResponseModel(true, authResponse.token??'', authResponseModel: authResponse);
    } else {
      return ResponseModel(false, response.statusText, code: _extractErrorCode(response.body));
    }
  }

  @override
  Future<void> updateToken() async {
    await authRepoInterface.updateToken();
  }

  @override
  bool isLoggedIn() {
    return authRepoInterface.isLoggedIn();
  }

  @override
  String getGuestId() {
    return authRepoInterface.getGuestId();
  }

  @override
  bool isGuestLoggedIn() {
    return authRepoInterface.isGuestLoggedIn();
  }

  @override
  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<bool> clearSharedData({bool removeToken = true}) async {
    return await authRepoInterface.clearSharedData(removeToken: removeToken);
  }

  @override
  Future<bool> setNotificationActive(bool isActive) async {
    await authRepoInterface.setNotificationActive(isActive);
    return isActive;
  }

  @override
  bool isNotificationActive() {
    return authRepoInterface.isNotificationActive();
  }

  @override
  String getUserToken() {
    return authRepoInterface.getUserToken();
  }

  @override
  Future<void> saveGuestNumber(String number) async {
     authRepoInterface.saveGuestContactNumber(number);
  }

  @override
  String getGuestNumber() {
    return authRepoInterface.getGuestContactNumber();
  }

  @override
  String getUserOtpPhoneNumber() {
    return authRepoInterface.getUserOtpPhoneNumber();
  }

}