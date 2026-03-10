import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/helper/centralize_login_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class AuthDialogWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const AuthDialogWidget({super.key, required this.exitFromApp, required this.backFromThis});

  @override
  AuthDialogWidgetState createState() => AuthDialogWidgetState();
}

class AuthDialogWidgetState extends State<AuthDialogWidget> {

  bool _isOtpViewEnable = false;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().resetOtpView(isUpdate: false);
    _isOtpViewEnable = false;
  }

  @override
  Widget build(BuildContext context) {
    final centralizeLoginSetup = Get.find<SplashController>().configModel?.centralizeLoginSetup;
    double width = _isOtpViewEnable ? 400 : (centralizeLoginSetup != null
        ? CentralizeLoginHelper.getPreferredLoginMethod(centralizeLoginSetup, false).size
        : 400);
    return SizedBox(
      width: width,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        backgroundColor: Theme.of(context).cardColor,
        insetPadding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(HeroiconsOutline.xMark)),
            ),

            // Logo - static asset image with debug background
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOverLarge),
              padding: const EdgeInsets.all(10),
              color: Colors.yellow, // Debug: should show yellow if container renders
              child: Image.asset(Images.logoName, width: 200),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Only the sign-in form is scrollable
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOverLarge),
                  child: SignInView(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis,
                    isOtpViewEnable: (bool val) {
                    setState(() {
                      _isOtpViewEnable = true;
                    });
                    },
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
