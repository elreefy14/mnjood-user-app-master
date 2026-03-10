import 'package:mnjood/features/auth/domain/centralize_login_enum.dart';
import 'package:mnjood/features/splash/domain/models/config_model.dart';

class CentralizeLoginHelper {
  static ({CentralizeLoginType type, double size}) getPreferredLoginMethod(CentralizeLoginSetup data, bool isOtpViewEnable, {bool calculateWidth = false}) {
    final otp = data.otpLoginStatus ?? false;
    final manual = data.manualLoginStatus ?? false;
    final social = data.socialLoginStatus ?? false;

    // When OTP is enabled, always show phone field directly
    if (otp || isOtpViewEnable) {
      return (type: CentralizeLoginType.otp, size: 400);
    } else if(manual && !social && !otp) {
      return (type: CentralizeLoginType.manual, size: 500);
    } else if(social && !otp && !manual) {
      return (type: CentralizeLoginType.social, size: 500);
    } else if(manual && social && !otp) {
      return (type: CentralizeLoginType.manualAndSocial, size: 700);
    } else if(manual && social && otp) {
      return (type: CentralizeLoginType.manualAndSocialAndOtp, size: 700);
    } else if(!manual && social && otp) {
      return (type: CentralizeLoginType.otpAndSocial, size: 500);
    } else if(manual && !social && otp) {
      return (type: CentralizeLoginType.manualAndOtp, size: 700);
    } else {
      return (type: CentralizeLoginType.manual, size: 500);
    }
  }
}