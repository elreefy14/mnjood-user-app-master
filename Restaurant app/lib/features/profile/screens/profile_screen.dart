import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mnjood_vendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/details_custom_card.dart';
import 'package:mnjood_vendor/common/widgets/switch_button_widget.dart';
import 'package:mnjood_vendor/common/controllers/theme_controller.dart';
import 'package:mnjood_vendor/features/auth/controllers/auth_controller.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/profile/widgets/account_delete_bottom_sheet.dart';
import 'package:mnjood_vendor/features/profile/widgets/profile_bg_widget.dart';
import 'package:mnjood_vendor/features/profile/widgets/profile_card_widget.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/app_constants.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isOwner;

  @override
  void initState() {
    super.initState();

    Get.find<ProfileController>().getProfile();
    _isOwner = Get.find<AuthController>().getUserType() == 'owner';
  }

  void checkBatteryPermission() async {
    Future.delayed(const Duration(milliseconds: 400), () async {
      if(await Permission.ignoreBatteryOptimizations.status.isDenied) {
        Get.find<ProfileController>().setBackgroundNotificationActive(false);
      } else {
        Get.find<ProfileController>().setBackgroundNotificationActive(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return profileController.profileModel == null ? const Center(child: CircularProgressIndicator()) : ProfileBgWidget(
          backButton: true,
          circularImage: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 4, color: Theme.of(context).cardColor),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ClipOval(child: CustomImageWidget(
              image: _isOwner ? profileController.profileModel?.imageFullUrl ?? '' : profileController.profileModel?.employeeInfo?.imageFullUrl ?? '',
              height: 100, width: 100, fit: BoxFit.cover,
            )),
          ),
          mainWidget: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Center(child: Container(
            width: 1170,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [

              _isOwner ? Text(
                '${profileController.profileModel!.fName} ${profileController.profileModel!.lName}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ) : Text(
                '${profileController.profileModel!.employeeInfo!.fName} ${profileController.profileModel!.employeeInfo!.lName}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),

              Row(children: [
                _isOwner ? ProfileCardWidget(title: 'since_joining'.tr, data: '${profileController.profileModel?.memberSinceDays ?? 0} ${'days'.tr}') : const SizedBox(),
                SizedBox(width: (Get.find<ProfileController>().modulePermission?.regularOrder ?? false) && _isOwner ? Dimensions.paddingSizeDefault : 0),
                (Get.find<ProfileController>().modulePermission?.regularOrder ?? false) ? ProfileCardWidget(title: 'total_order'.tr, data: (profileController.profileModel?.orderCount ?? 0).toString()) : const SizedBox(),
              ]),
              const SizedBox(height: 24),

              SwitchButtonWidget(icon: HeroiconsOutline.moon, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.find<ThemeController>().toggleTheme();
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SwitchButtonWidget(
                icon: HeroiconsOutline.bell, title: 'system_notification'.tr,
                isButtonActive: profileController.notification, onTap: () {
                  profileController.setNotificationActive(!profileController.notification);
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if (GetPlatform.isAndroid) ...[
                InkWell(
                  onTap: () {
                    showBgNotificationBottomSheet(profileController.backgroundNotification);
                  },
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: DetailsCustomCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(HeroiconsSolid.bell, size: 20, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Text(
                          'background_notification'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Theme.of(context).hintColor.withOpacity(0.3),
                          value: profileController.backgroundNotification,
                          onChanged: (bool isActive) {
                            showBgNotificationBottomSheet(profileController.backgroundNotification);
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],

              _isOwner ? SwitchButtonWidget(icon: HeroiconsOutline.lockClosed, title: 'change_password'.tr, onTap: () {
                Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change'));
              }) : const SizedBox(),
              SizedBox(height: _isOwner ? Dimensions.paddingSizeSmall : 0),

              _isOwner ? SwitchButtonWidget(icon: HeroiconsOutline.pencilSquare, title: 'edit_profile'.tr, onTap: () {
                Get.toNamed(RouteHelper.getUpdateProfileRoute());
              }) : const SizedBox(),
              SizedBox(height: _isOwner ? Dimensions.paddingSizeSmall : 0),

              _isOwner ? SwitchButtonWidget(
                icon: HeroiconsOutline.trash, title: 'delete_account'.tr,
                onTap: () {
                  showCustomBottomSheet(
                    child: const AccountDeleteBottomSheet(),
                  );
                },
              ) : const SizedBox(),
              SizedBox(height: _isOwner ? Dimensions.paddingSizeLarge : 0),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(AppConstants.appVersion.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),

              ]),

            ]),
          ))),
        );
      }),
    );
  }

  void showBgNotificationBottomSheet(bool allow) {
    Get.bottomSheet(Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // Handle bar
        Container(
          height: 4, width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).hintColor.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 24),

        // Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            HeroiconsSolid.bell,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          '${!allow ? 'allow'.tr : 'disable'.tr} ${AppConstants.appName} ${'to_run_notification_in_background'.tr}',
          textAlign: TextAlign.center,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),

        if (allow) ...[
          const SizedBox(height: 8),
          Text(
            '(${AppConstants.appName} -> Battery -> Select Optimized)',
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
        const SizedBox(height: 20),

        _buildInfoText("you_will_be_able_to_get_order_notification_even_if_you_are_not_in_the_app".tr),
        _buildInfoText("${AppConstants.appName} ${!allow ? 'will_run_notification_service_in_the_background_always'.tr : 'will_not_run_notification_service_in_the_background_always'.tr}"),
        _buildInfoText(!allow ? "notification_will_always_send_alert_from_the_background".tr : 'notification_will_not_always_send_alert_from_the_background'.tr),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  side: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.3)),
                ),
              ),
              child: Text(
                "cancel".tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if(await Permission.ignoreBatteryOptimizations.status.isGranted) {
                  openAppSettings();
                } else {
                  await Permission.ignoreBatteryOptimizations.request();
                }
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              child: Text(
                "okay".tr,
                style: robotoMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ]),
      ]),
    ), isScrollControlled: true).then((value) {
      checkBatteryPermission();
    });
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        text,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}