import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/features/auth/widgets/auth_dialog_widget.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';

/// Sign-up widget now redirects to OTP login since OTP handles both
/// login and auto-registration of new users.
class SignUpWidget extends StatelessWidget {
  const SignUpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    // On desktop (dialog), close and open sign-in dialog.
    // On mobile, redirect to sign-in route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isDesktop) {
        Get.back();
        Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: false)), barrierDismissible: false);
      } else {
        Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
      }
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text('redirecting_to_login'.tr, style: robotoRegular),
        ]),
      ),
    );
  }
}
