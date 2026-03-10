import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mnjood_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_delivery/feature/auth/controllers/auth_controller.dart';
import 'package:mnjood_delivery/feature/splash/controllers/splash_controller.dart';
import 'package:mnjood_delivery/feature/profile/controllers/profile_controller.dart';
import 'package:mnjood_delivery/helper/route_helper.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/images.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:mnjood_delivery/common/widgets/custom_button_widget.dart';
import 'package:mnjood_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInViewScreen extends StatefulWidget {
  const SignInViewScreen({super.key});

  @override
  State<SignInViewScreen> createState() => _SignInViewScreenState();
}

class _SignInViewScreenState extends State<SignInViewScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();

    getNotificationPermission();
  }

  Future<void> getNotificationPermission() async {
    var notifStatus = await Permission.notification.status;
    if (notifStatus.isDenied || notifStatus.isPermanentlyDenied) {
      notifStatus = await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Center(
            child: SizedBox(
              width: 1170,
              child: GetBuilder<AuthController>(builder: (authController) {
                return Column(children: [

                  Image.asset(Images.logoName, width: 150),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text('sign_in'.tr.toUpperCase(), style: robotoBlack.copyWith(fontSize: 30)),
                  const SizedBox(height: 50),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(children: [

                      CustomTextFieldWidget(
                        hintText: 'email'.tr,
                        showLabelText: false,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: HeroiconsOutline.envelope,
                        showBorder: false,
                        divider: true,
                      ),

                      CustomTextFieldWidget(
                        showBorder: false,
                        hintText: 'eight_characters'.tr,
                        showLabelText: false,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        inputAction: TextInputAction.done,
                        inputType: TextInputType.visiblePassword,
                        prefixIcon: HeroiconsOutline.lockClosed,
                        isPassword: true,
                        onSubmit: (text) => GetPlatform.isWeb ? _login(authController, _emailController, _passwordController, context) : null,
                      ),

                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [

                    Expanded(
                      child: ListTile(
                        onTap: () => authController.toggleRememberMe(),
                        leading: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: authController.isActiveRememberMe,
                          onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                        ),
                        title: Text('remember_me'.tr),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        horizontalTitleGap: 0,
                      ),
                    ),

                    TextButton(
                      onPressed: () => Get.toNamed(RouteHelper.getForgotPassRoute()),
                      child: Text('${'forgot_password'.tr}?'),
                    ),

                  ]),
                  const SizedBox(height: 50),

                  CustomButtonWidget(
                    buttonText: 'sign_in'.tr,
                    isLoading: authController.isLoading,
                    onPressed: () => _login(authController, _emailController, _passwordController, context),
                  ),
                  SizedBox(height: Get.find<SplashController>().configModel!.toggleDmRegistration! ? Dimensions.paddingSizeSmall : 0),

                  Get.find<SplashController>().configModel!.toggleDmRegistration! ? TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(1, 40),
                    ),
                    onPressed: () async {
                      Get.toNamed(RouteHelper.getDeliverymanRegistrationRoute());
                    },
                    child: RichText(text: TextSpan(children: [

                      TextSpan(text: '${'join_as_a'.tr} ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                      TextSpan(text: 'delivery_man'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),

                    ])),
                  ) : const SizedBox(),

                ]);
              }),
            ),
          ),
        ),
      )),
    );
  }

  void _login(AuthController authController, TextEditingController emailCtlr, TextEditingController passCtlr, BuildContext context) async {
    String email = emailCtlr.text.trim();
    String password = passCtlr.text.trim();

    if (email.isEmpty) {
      showCustomSnackBar('enter_email'.tr);
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('invalid_email'.tr);
    } else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else {
      authController.login(email, password).then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(email, password, '');
          } else {
            authController.clearUserNumberAndPassword();
          }
          await Get.find<ProfileController>().getProfile();
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}