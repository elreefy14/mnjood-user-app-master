import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class AccountDeletionBottomSheet extends StatefulWidget {
  final ProfileController profileController;
  final bool isRunningOrderAvailable;
  const AccountDeletionBottomSheet({super.key, required this.profileController, this.isRunningOrderAvailable = false});

  @override
  State<AccountDeletionBottomSheet> createState() => _AccountDeletionBottomSheetState();
}

class _AccountDeletionBottomSheetState extends State<AccountDeletionBottomSheet> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
          height: 5, width: 35,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),

        Stack(clipBehavior: Clip.none, children: [
          ClipOval(child: CustomImageWidget(
            placeholder: Images.guestIconLight,
            imageColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
            image: '${(widget.profileController.userInfoModel != null && isLoggedIn) ? widget.profileController.userInfoModel!.imageFullUrl : ''}',
            height: 70, width: 70, fit: BoxFit.cover,
          )),

          Positioned(
            right: -5, top: 0,
            child: Icon(widget.isRunningOrderAvailable ? HeroiconsOutline.exclamationTriangle : HeroiconsSolid.xCircle, color: Theme.of(context).colorScheme.error, size: 25),
          ),

        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text(widget.isRunningOrderAvailable ? 'sorry_you_cannot_delete_your_account'.tr : 'delete_your_account'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            widget.isRunningOrderAvailable ? 'please_complete_your_ongoing_and_accepted_orders'.tr : 'you_will_not_be_able_to_recover_your_data_again'.tr,
            style: robotoRegular, textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // Password field (only show when not running orders)
        if (!widget.isRunningOrderAvailable) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'enter_password'.tr,
                hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                prefixIcon: Icon(HeroiconsOutline.lockClosed, color: Theme.of(context).hintColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? HeroiconsOutline.eye : HeroiconsOutline.eyeSlash,
                    color: Theme.of(context).hintColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  borderSide: BorderSide(color: Theme.of(context).disabledColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],

        Padding(
          padding: EdgeInsets.only(left: widget.isRunningOrderAvailable ? 70 : 50, right: widget.isRunningOrderAvailable ? 70 : 50, bottom: 20),
          child: widget.isRunningOrderAvailable ? CustomButtonWidget(
            buttonText: 'view_orders'.tr,
            height: 40,
            color: Theme.of(context).primaryColor,
            fontSize: Dimensions.fontSizeDefault,
            onPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.getOrderRoute());
            },
          ) : GetBuilder<ProfileController>(
              builder: (pController) {
              return pController.isLoading ? const Center(child: CircularProgressIndicator()) : Row(children: [

                Expanded(child: CustomButtonWidget(
                  buttonText: 'cancel'.tr,
                  height: 40,
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                  fontSize: Dimensions.fontSizeDefault,
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () => Get.back(),
                )),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(child: CustomButtonWidget(
                  buttonText: 'remove'.tr,
                  height: 40,
                  color: Theme.of(context).colorScheme.error,
                  fontSize: Dimensions.fontSizeDefault,
                  isLoading: pController.isLoading,
                  onPressed: () {
                    if (_passwordController.text.isEmpty) {
                      Get.snackbar(
                        'error'.tr,
                        'enter_password'.tr,
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    pController.removeUser(password: _passwordController.text);
                  },
                )),

              ]);
            }
          ),
        ),

      ]),

    );
  }
}
