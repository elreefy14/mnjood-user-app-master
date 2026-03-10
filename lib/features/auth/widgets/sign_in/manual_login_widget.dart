import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_ink_well_widget.dart';
import 'package:mnjood/common/widgets/custom_text_field_widget.dart';
import 'package:mnjood/common/widgets/validate_check.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/auth/widgets/social_login_widget.dart';
import 'package:mnjood/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/verification/screens/forget_pass_screen.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ManualLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final Function() onClickLoginButton;
  final Function()? onWebSubmit;
  final bool socialEnable;
  final Function()? onOtpViewClick;
  const ManualLoginWidget({
    super.key, required this.phoneController, required this.phoneFocus, required this.onClickLoginButton, required this.passwordController,
    required this.passwordFocus, this.onWebSubmit, this.socialEnable = false, this.onOtpViewClick,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      if(isDesktop) {
        return webView(isDesktop, context, authController);
      }
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('login'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CustomTextFieldWidget(
          textAlign: TextAlign.left,
          onCountryChanged: (countryCode) => authController.countryDialCode = countryCode.dialCode ?? '+966',
          countryDialCode: () {
            final country = Get.find<SplashController>().configModel?.country;
            if (authController.isNumberLogin && country != null && country.isNotEmpty) {
              return CountryCode.fromCountryCode(country).code;
            }
            return null;
          }(),
          labelText: 'email_or_phone'.tr,
          hintText: 'enter_email_or_phone'.tr,
          controller: phoneController,
          focusNode: phoneFocus,
          nextFocus: passwordFocus,
          inputType: TextInputType.emailAddress,
          prefixIcon: authController.isNumberLogin ? null : HeroiconsOutline.envelope,
          onChanged: (String text){
            final numberRegExp = RegExp(r'^[+]?[0-9]+$');

            if(text.isEmpty && authController.isNumberLogin){
              authController.toggleIsNumberLogin();
            }
            if(text.startsWith(numberRegExp) && !authController.isNumberLogin ){
              authController.toggleIsNumberLogin();
              phoneController.text = text.replaceAll("+", "");
            }
            final emailRegExp = RegExp(r'@');
            if(text.contains(emailRegExp) && authController.isNumberLogin){
              authController.toggleIsNumberLogin();
            }

          },
          validator: (String? value){
            final val = value ?? '';
            if(authController.isNumberLogin && ValidateCheck.getValidPhone(authController.countryDialCode+val) == ""){
              return "enter_valid_phone_number".tr;
            }
            return (GetUtils.isPhoneNumber(authController.countryDialCode+val) || GetUtils.isEmail(val)) ? null : 'enter_email_address_or_phone_number'.tr;
          },
        ),

        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        CustomTextFieldWidget(
          textAlign: TextAlign.left,
          hintText: '8_character'.tr,
          controller: passwordController,
          focusNode: passwordFocus,
          inputAction: TextInputAction.done,
          inputType: TextInputType.visiblePassword,
          prefixIcon: HeroiconsOutline.lockClosed,
          isPassword: true,
          onSubmit: (text) => (GetPlatform.isWeb) ? onWebSubmit : null,
          labelText: 'password'.tr,
          required: true,
          validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall),


        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: () => authController.toggleRememberMe(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24, width: 24,
                  child: Checkbox(
                    side: BorderSide(color: Theme.of(context).hintColor),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Theme.of(context).primaryColor,
                    value: authController.isActiveRememberMe,
                    onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text('remember_me'.tr, style: robotoRegular),
              ],
            ),
          ),

          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
              }

              Future.delayed(const Duration(milliseconds: 250), () {
                Get.toNamed(RouteHelper.getForgotPassRoute());
              });
            },
            child: Text('${'forgot_password'.tr}?', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
          ),
        ]),

        const SizedBox(height: Dimensions.paddingSizeLarge),

        TramsConditionsCheckBoxWidget(authController: authController),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        CustomButtonWidget(
          height: isDesktop ? 50 : null,
          width:  isDesktop ? 250 : null,
          buttonText: 'login'.tr,
          radius: isDesktop ? Dimensions.radiusSmall : Dimensions.radiusDefault,
          isBold: isDesktop ? false : true,
          isLoading: authController.isLoading,
          onPressed: onClickLoginButton,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Center(child: Text('new_users_auto_registered'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor))),

        SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),

        onOtpViewClick != null ? Column(children: [
          Center(child: Text('or'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('sign_in_with'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            InkWell(
              onTap: onOtpViewClick,
              child: Text('otp'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline)),
            ),
          ])),
        ]) : const SizedBox(),

        socialEnable ? const SocialLoginWidget(onlySocialLogin: false) : const SizedBox(),

      ]);
    });
  }

  Widget webView(bool isDesktop, BuildContext context, AuthController authController) {
    bool onlyManualLoginEnable = onOtpViewClick == null && !socialEnable;
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        Expanded(
          flex: 5,
          child: Column(children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Text('login'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomTextFieldWidget(
              onCountryChanged: (countryCode) => authController.countryDialCode = countryCode.dialCode ?? '+966',
              countryDialCode: () {
                final country = Get.find<SplashController>().configModel?.country;
                if (authController.isNumberLogin && country != null && country.isNotEmpty) {
                  return CountryCode.fromCountryCode(country).code;
                }
                return null;
              }(),
              labelText: 'email_or_phone'.tr,
              hintText: 'enter_email_or_phone'.tr,
              controller: phoneController,
              focusNode: phoneFocus,
              nextFocus: passwordFocus,
              inputType: TextInputType.emailAddress,
              onChanged: (String text){
                final numberRegExp = RegExp(r'^[+]?[0-9]+$');

                // Toggle isNumberLogin flag based on input
                if (text.isEmpty && authController.isNumberLogin) {
                  authController.toggleIsNumberLogin();
                } else if (text.startsWith(numberRegExp) && !authController.isNumberLogin) {
                  authController.toggleIsNumberLogin();
                  // Store the cleaned number temporarily
                  final cleanedText = text.replaceAll("+", "");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    phoneController.text = cleanedText;
                    phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: phoneController.text.length),
                    );
                  });
                } else if (text.contains('@') && authController.isNumberLogin) {
                  authController.toggleIsNumberLogin();
                }

              },
              validator: (String? value){
                final val = value ?? '';
                if(authController.isNumberLogin && ValidateCheck.getValidPhone(authController.countryDialCode+val) == ""){
                  return "enter_valid_phone_number".tr;
                }
                return (GetUtils.isPhoneNumber(authController.countryDialCode+val) || GetUtils.isEmail(val)) ? null : 'enter_email_address_or_phone_number'.tr;
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            CustomTextFieldWidget(
              hintText: '8_character'.tr,
              controller: passwordController,
              focusNode: passwordFocus,
              inputAction: TextInputAction.done,
              inputType: TextInputType.visiblePassword,
              prefixIcon: HeroiconsOutline.lockClosed,
              isPassword: true,
              onSubmit: (text) => (GetPlatform.isWeb) ? onWebSubmit : null,
              labelText: 'password'.tr,
              required: true,
              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
            ),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall),


            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: () => authController.toggleRememberMe(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24, width: 24,
                      child: Checkbox(
                        side: BorderSide(color: Theme.of(context).hintColor),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: Theme.of(context).primaryColor,
                        value: authController.isActiveRememberMe,
                        onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text('remember_me'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  ],
                ),
              ),

              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  if(isDesktop) {
                    Get.back();
                    Get.dialog(const Center(child: ForgetPassScreen(fromDialog: true)));
                  } else {
                    Get.toNamed(RouteHelper.getForgotPassRoute());
                  }
                },
                child: Text('${'forgot_password'.tr}?', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
              ),
            ]),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            TramsConditionsCheckBoxWidget(authController: authController, fromDialog: true),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            CustomButtonWidget(
              buttonText: 'login'.tr,
              radius: Dimensions.radiusDefault,
              isBold: isDesktop ? false : true,
              isLoading: authController.isLoading,
              onPressed: onClickLoginButton,
              fontSize: Dimensions.fontSizeSmall,
            ),

            onlyManualLoginEnable ? Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: Text('new_users_auto_registered'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
            ) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ),

        !onlyManualLoginEnable ? Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraOverLarge, vertical: Dimensions.paddingSizeLarge),
            child: RotatedBox(
              quarterTurns: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 1,
                    child: Container(
                      color: Theme.of(context).disabledColor,
                      width: 100,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'or_login_with'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ),
                  SizedBox(
                    height: 1,
                    child: Container(
                      color: Theme.of(context).disabledColor,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) : const SizedBox(),

        !onlyManualLoginEnable ? Expanded(flex: 4, child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

          socialEnable ? const SocialLoginWidget(onlySocialLogin: true, showWelcomeText: false) : const SizedBox(),

          onOtpViewClick != null ? Container(
            height: 50,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300] ?? Colors.grey, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
            ),
            child: CustomInkWellWidget(
              onTap: onOtpViewClick!,
              radius: Dimensions.radiusDefault,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(Images.otp, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text('otp_sign_in'.tr, style: robotoMedium.copyWith()),
                ]),
              ),
            ),
          ) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text('new_users_auto_registered'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        ])) : const SizedBox(),

      ]),
    );
  }
}
