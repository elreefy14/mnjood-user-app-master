import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_text_field_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_tool_tip_widget.dart';
import 'package:mnjood_vendor/common/widgets/validate_check.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/profile/domain/models/profile_model.dart';
import 'package:mnjood_vendor/helper/custom_validator.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/styles.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _countryDialCode;
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() async{
    if(Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _countryCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code;
    _splitPhone(Get.find<ProfileController>().profileModel!.phone!);
    Get.find<ProfileController>().initData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _splitPhone(String? phone) async {
    try {
      if (phone != null && phone.isNotEmpty) {
        PhoneNumber phoneNumber = PhoneNumber.parse(phone);
        _countryDialCode = '+${phoneNumber.countryCode}';
        _countryCode = phoneNumber.isoCode.name;
        _phoneController.text = phoneNumber.international.substring(_countryDialCode!.length);
      }
    } catch (e) {
      debugPrint('Phone Number Parse Error: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'update_profile'.tr),
      body: GetBuilder<ProfileController>(builder: (profileController) {

        if(profileController.profileModel != null && _emailController.text.isEmpty) {
          _firstNameController.text = profileController.profileModel!.fName ?? '';
          _lastNameController.text = profileController.profileModel!.lName ?? '';
          _emailController.text = profileController.profileModel!.email ?? '';
        }

        return Column(children: [
          Expanded(
            child: profileController.profileModel != null ? Container(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Column(children: [
                const SizedBox(height: 70),

                Expanded(
                  child: Stack(clipBehavior: Clip.none, children: [

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                        boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                      ),
                      child: Column(children: [

                        Expanded(child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 70),

                            CustomTextFieldWidget(
                              hintText: 'enter_first_name'.tr,
                              controller: _firstNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _firstNameFocus,
                              nextFocus: _lastNameFocus,
                              prefixIcon: HeroiconsSolid.user,
                              labelText: 'first_name'.tr,
                              required: true,
                              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_first_name".tr),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeOverExtraLarge),

                            CustomTextFieldWidget(
                              hintText: 'enter_last_name'.tr,
                              controller: _lastNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _lastNameFocus,
                              nextFocus: _emailFocus,
                              prefixIcon: HeroiconsSolid.user,
                              labelText: 'last_name'.tr,
                              required: true,
                              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_last_name".tr),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeOverExtraLarge),

                            CustomTextFieldWidget(
                              hintText: 'xxx-xxx-xxxxx'.tr,
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              inputType: TextInputType.phone,
                              isPhone: true,
                              onCountryChanged: (CountryCode countryCode) {
                                _countryDialCode = countryCode.dialCode;
                              },
                              countryDialCode: _countryCode,
                              labelText: 'phone'.tr,
                              required: true,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeOverExtraLarge),

                            Stack(clipBehavior: Clip.none, children: [
                              CustomToolTip(
                                message: 'email_can_not_be_edited'.tr,
                                preferredDirection: AxisDirection.up,
                                child: Container(
                                  height: 50, width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(
                                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(HeroiconsSolid.envelope, color: Theme.of(context).hintColor.withValues(alpha: 0.5), size: 17),
                                    const SizedBox(width: 15),
                                    Flexible(
                                      fit: FlexFit.loose, // Use Flexible with FlexFit.loose
                                      child: Text(
                                        _emailController.text,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).hintColor,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),

                              Positioned(
                                left: 10, top: -15,
                                child: Container(
                                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                                  padding: const EdgeInsets.all(5),
                                  child: Text('email'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ),
                              ),
                            ]),

                          ]))),
                        )),

                        SafeArea(
                          child: !profileController.isLoading ? CustomButtonWidget(
                            onPressed: () => _updateProfile(profileController),
                            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            buttonText: 'update'.tr,
                          ) : const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                        ),

                      ]),
                    ),

                    Positioned(
                      top: -50, left: 0, right: 0,
                      child: Center(child: Stack(children: [

                        ClipOval(child: profileController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
                            profileController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(
                            File(profileController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover) : CustomImageWidget(
                          image: '${profileController.profileModel!.imageFullUrl}',
                          height: 100, width: 100, fit: BoxFit.cover,
                        ),
                        ),

                        Positioned(
                          bottom: 0, right: 0, top: 0, left: 0,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: () => profileController.pickImage(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: Colors.white),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(HeroiconsOutline.camera, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ])),
                    ),

                  ]),
                ),
              ]),
            ) : const Center(child: CircularProgressIndicator()),
          ),
        ]);

      }),
    );
  }

  void _updateProfile(ProfileController profileController) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();

    String phoneNumber = _phoneController.text.trim();

    String phoneNumberWithCode = _countryDialCode! + phoneNumber;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(phoneNumberWithCode);
    phoneNumberWithCode = phoneValid.phone;

    if (profileController.profileModel!.fName == firstName &&
        profileController.profileModel!.lName == lastName && profileController.profileModel!.phone == phoneNumberWithCode &&
        profileController.profileModel!.email == _emailController.text && profileController.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    }else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else {
      ProfileModel updatedUser = ProfileModel(fName: firstName, lName: lastName, email: email, phone: phoneNumberWithCode);
      await profileController.updateUserInfo(updatedUser, profileController.getUserToken());
    }
  }
}