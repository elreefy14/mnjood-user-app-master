import 'package:mnjood_delivery/feature/auth/controllers/auth_controller.dart';
import 'package:mnjood_delivery/feature/forgot_password/widgets/password_check_widget.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassViewWidget extends StatelessWidget {
  const PassViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        child: Wrap(children: [

          PasswordCheckWidget(title: '8_or_more_character'.tr, done: authController.lengthCheck),

          PasswordCheckWidget(title: '1_number'.tr, done: authController.numberCheck),

          PasswordCheckWidget(title: '1_upper_case'.tr, done: authController.uppercaseCheck),

          PasswordCheckWidget(title: '1_lower_case'.tr, done: authController.lowercaseCheck),

          PasswordCheckWidget(title: '1_special_character'.tr, done: authController.spatialCheck),

        ]),
      );
    });
  }
}