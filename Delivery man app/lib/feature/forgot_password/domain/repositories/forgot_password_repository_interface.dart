import 'package:mnjood_delivery/common/models/response_model.dart';
import 'package:mnjood_delivery/feature/profile/domain/models/profile_model.dart';
import 'package:mnjood_delivery/interface/repository_interface.dart';

abstract class ForgotPasswordRepositoryInterface implements RepositoryInterface {
  Future<dynamic> changePassword(ProfileModel userInfoModel, String password);
  Future<dynamic> forgotPassword(String? phone);
  Future<dynamic> resetPassword(String? resetToken, String phone, String password, String confirmPassword);
  Future<dynamic> verifyToken(String? phone, String token);
  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp});
}