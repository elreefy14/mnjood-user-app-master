import 'package:mnjood_vendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/auth/controllers/auth_controller.dart';
import 'package:mnjood_vendor/features/language/controllers/localization_controller.dart';
import 'package:mnjood_vendor/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:mnjood_vendor/features/menu/domain/models/menu_model.dart';
import 'package:mnjood_vendor/features/menu/widgets/profile_image_widget.dart';
import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/subscription/controllers/subscription_controller.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuButtonWidget extends StatelessWidget {
  final MenuModel menu;
  final bool isProfile;
  final bool isLogout;
  const MenuButtonWidget({super.key, required this.menu, required this.isProfile, required this.isLogout});

  @override
  Widget build(BuildContext context) {

    double size = (context.width/4)-Dimensions.paddingSizeDefault;

    return InkWell(
      onTap: () async {
        if(menu.isBlocked) {
          showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
        }else if(menu.isNotSubscribe){
          showCustomSnackBar('you_have_no_available_subscription'.tr);
        } else if(menu.isLanguage){
          Get.back();
          _manageLanguageFunctionality();
        }else {
          if (isLogout) {
            Get.back();
            if (Get.find<AuthController>().isLoggedIn()) {
              Get.dialog(ConfirmationDialogWidget(icon: HeroiconsOutline.arrowRightOnRectangle, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                Get.find<AuthController>().clearSharedData();
                await Get.find<ProfileController>().trialWidgetShow(route: RouteHelper.payment);
                Get.offAllNamed(RouteHelper.getSignInRoute());
              }), useSafeArea: false);
            } else {
              await Get.find<ProfileController>().trialWidgetShow(route: RouteHelper.payment);
              Get.find<AuthController>().clearSharedData();
              Get.toNamed(RouteHelper.getSignInRoute());
            }
          } else {
            if(menu.route.contains(RouteHelper.mySubscription)) {
              Get.offNamed(menu.route);
            } else {
              if (!Get.find<SubscriptionController>().isTrialEndModalShown) {
                Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
                  if(trialEnd) {
                    Get.offNamed(menu.route);
                  }else {
                    Get.find<SubscriptionController>().setTrialEndModalShown(true);
                  }
                });
              }
            }
          }
        }
      },
      child: Column(children: [

        Container(
          height: size - (size * 0.15),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            color: isLogout
                ? (Get.find<AuthController>().isLoggedIn()
                    ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1))
                : Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          alignment: Alignment.center,
          child: isProfile
              ? ProfileImageWidget(size: size)
              : Icon(
                  menu.iconData,
                  size: size * 0.45,
                  color: isLogout
                      ? (Get.find<AuthController>().isLoggedIn()
                          ? Theme.of(context).colorScheme.error
                          : Colors.green)
                      : menu.iconColor ?? Theme.of(context).primaryColor,
                ),
        ),
        const SizedBox(height: 6),

        Text(
          menu.title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

      ]),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }

}