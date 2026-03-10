import 'package:intl/intl.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/menu/widgets/portion_widget.dart';
import 'package:mnjood/features/menu/widgets/menu_stat_card_widget.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/profile/widgets/account_deletion_bottom_sheet.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/features/auth/screens/sign_in_screen.dart';
import 'package:mnjood/features/favourite/controllers/favourite_controller.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final configModel = Get.find<SplashController>().configModel;
    bool isRightSide = configModel?.currencySymbolDirection == 'right';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (configModel == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(children: [
                // Profile Header Section
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(children: [
                      Row(children: [
                        // Profile Image with shadow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child: CustomImageWidget(
                                placeholder: isLoggedIn
                                    ? Images.profilePlaceholder
                                    : Images.guestIcon,
                                image:
                                    '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                imageColor: isLoggedIn
                                    ? Theme.of(context).hintColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isLoggedIn && profileController.userInfoModel == null
                                  ? Shimmer(
                                      duration: const Duration(seconds: 2),
                                      enabled: true,
                                      child: Container(
                                        height: 20,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[
                                              Get.find<ThemeController>().darkTheme
                                                  ? 700
                                                  : 200],
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      isLoggedIn
                                          ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName}'
                                          : 'guest_user'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeOverLarge,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                              const SizedBox(height: 4),

                              if (isLoggedIn &&
                                  profileController.userInfoModel != null)
                                Row(
                                  children: [
                                    Icon(
                                      HeroiconsOutline.calendar,
                                      size: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${'member_since'.tr} ${DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!)}',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ]),

                      // Guest Login Prompt
                      if (!isLoggedIn) ...[
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: Row(children: [
                            Icon(
                              HeroiconsOutline.userCircle,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(
                              child: Text(
                                'for_more_personalised_and_smooth_experience'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            CustomButtonWidget(
                              buttonText: 'login'.tr,
                              height: 40,
                              width: 100,
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: () async {
                                if (!isDesktop) {
                                  Get.toNamed(RouteHelper.getSignInRoute(
                                          Get.currentRoute))
                                      ?.then((value) {
                                    if (AuthHelper.isLoggedIn()) {
                                      profileController.getUserInfo();
                                    }
                                  });
                                } else {
                                  Get.dialog(const SignInScreen(
                                          exitFromApp: true, backFromThis: true))
                                      .then((value) {
                                    if (AuthHelper.isLoggedIn()) {
                                      profileController.getUserInfo();
                                    }
                                  });
                                }
                              },
                            ),
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      if (isLoggedIn) ...[
                        Row(children: [
                          MenuStatCardWidget(
                            icon: HeroiconsOutline.shoppingBag,
                            value: NumberFormat.compact()
                                .format(profileController.userInfoModel?.orderCount ?? 0),
                            label: 'total_order'.tr,
                            onTap: () => Get.toNamed(RouteHelper.getOrderRoute()),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          MenuStatCardWidget(
                            icon: HeroiconsOutline.wallet,
                            value:
                                '${isRightSide ? '' : '${configModel.currencySymbol ?? ''} '}'
                                '${NumberFormat.compact().format(profileController.userInfoModel?.walletBalance ?? 0)}'
                                '${isRightSide ? ' ${configModel.currencySymbol ?? ''}' : ''}',
                            label: 'wallet'.tr,
                            onTap: () => Get.toNamed(RouteHelper.getWalletRoute(fromMenuPage: true)),
                          ),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      ],

                      // General Section
                      _buildSectionHeader(context, 'general'.tr),
                      _buildMenuCard(context, [
                        if (isLoggedIn)
                          PortionWidget(
                            icon: HeroiconsOutline.userCircle,
                            title: 'edit_profile'.tr,
                            route: RouteHelper.getUpdateProfileRoute(),
                          ),
                        if (isLoggedIn)
                          PortionWidget(
                            icon: HeroiconsOutline.clipboardDocumentList,
                            title: 'order_history'.tr,
                            route: RouteHelper.getOrderRoute(),
                          ),
                        PortionWidget(
                          icon: HeroiconsOutline.mapPin,
                          title: 'my_address'.tr,
                          route: RouteHelper.getAddressRoute(),
                        ),
                        PortionWidget(
                          icon: HeroiconsOutline.cog6Tooth,
                          title: 'settings'.tr,
                          route: RouteHelper.getSettingsRoute(),
                        ),
                      ]),

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // Promotional Activity Section
                      _buildSectionHeader(context, 'promotional_activity'.tr),
                      _buildMenuCard(context, [
                        PortionWidget(
                          icon: HeroiconsOutline.ticket,
                          title: 'coupon'.tr,
                          route: RouteHelper.getCouponRoute(fromCheckout: false),
                        ),
                        if (configModel.loyaltyPointStatus ?? false)
                          PortionWidget(
                            icon: HeroiconsOutline.gift,
                            title: 'loyalty_points'.tr,
                            route: RouteHelper.getLoyaltyRoute(),
                            suffix: !isLoggedIn
                                ? null
                                : '${profileController.userInfoModel?.loyaltyPoint ?? 0} ${'points'.tr}',
                          ),
                        if (configModel.customerWalletStatus ?? false)
                          PortionWidget(
                            icon: HeroiconsOutline.wallet,
                            title: 'my_wallet'.tr,
                            route: RouteHelper.getWalletRoute(fromMenuPage: true),
                            suffix: !isLoggedIn
                                ? null
                                : PriceConverter.convertPrice(
                                    profileController.userInfoModel?.walletBalance ?? 0),
                          ),
                      ]),

                      // Earnings Section
                      if (configModel.refEarningStatus ?? false) ...[
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                        _buildSectionHeader(context, 'earnings'.tr),
                        _buildMenuCard(context, [
                          PortionWidget(
                            icon: HeroiconsOutline.userPlus,
                            title: 'refer_and_earn'.tr,
                            route: RouteHelper.getReferAndEarnRoute(),
                          ),
                        ]),
                      ],

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // Help & Support Section
                      _buildSectionHeader(context, 'help_and_support'.tr),
                      _buildMenuCard(context, [
                        PortionWidget(
                          icon: HeroiconsOutline.chatBubbleLeftRight,
                          title: 'live_chat'.tr,
                          route: RouteHelper.getConversationRoute(),
                        ),
                        PortionWidget(
                          icon: HeroiconsOutline.questionMarkCircle,
                          title: 'help_and_support'.tr,
                          route: RouteHelper.getSupportRoute(),
                        ),
                        PortionWidget(
                          icon: HeroiconsOutline.informationCircle,
                          title: 'about_us'.tr,
                          route: RouteHelper.getHtmlRoute('about-us'),
                        ),
                        PortionWidget(
                          icon: HeroiconsOutline.documentText,
                          title: 'terms_conditions'.tr,
                          route: RouteHelper.getHtmlRoute('terms-and-condition'),
                        ),
                        PortionWidget(
                          icon: HeroiconsOutline.shieldCheck,
                          title: 'privacy_policy'.tr,
                          route: RouteHelper.getHtmlRoute('privacy-policy'),
                        ),
                        if (configModel.refundPolicyStatus ?? false)
                          PortionWidget(
                            icon: HeroiconsOutline.arrowUturnLeft,
                            title: 'refund_policy'.tr,
                            route: RouteHelper.getHtmlRoute('refund-policy'),
                          ),
                        if (configModel.cancellationPolicyStatus ?? false)
                          PortionWidget(
                            icon: HeroiconsOutline.xCircle,
                            title: 'cancellation_policy'.tr,
                            route: RouteHelper.getHtmlRoute('cancellation-policy'),
                          ),
                        if (configModel.shippingPolicyStatus ?? false)
                          PortionWidget(
                            icon: HeroiconsOutline.truck,
                            title: 'shipping_policy'.tr,
                            route: RouteHelper.getHtmlRoute('shipping-policy'),
                          ),
                      ]),

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // Logout Button
                      if (isLoggedIn)
                        InkWell(
                          onTap: () async {
                            Get.dialog(
                              ConfirmationDialogWidget(
                                icon: Images.support,
                                description: 'are_you_sure_to_logout'.tr,
                                isLogOut: true,
                                onYesPressed: () async {
                                  Get.find<ProfileController>()
                                      .setForceFullyUserEmpty();
                                  Get.find<AuthController>().socialLogout();
                                  Get.find<AuthController>().resetOtpView();
                                  Get.find<CartController>().clearCartList();
                                  Get.find<FavouriteController>().removeFavourites();
                                  await Get.find<AuthController>().clearSharedData();
                                  Get.offAllNamed(RouteHelper.getInitialRoute());
                                },
                              ),
                              useSafeArea: false,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  HeroiconsOutline.arrowRightOnRectangle,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'logout'.tr,
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Delete Account Button
                      if (isLoggedIn) ...[
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        InkWell(
                          onTap: () async {
                            Get.find<OrderController>().getRunningOrders(1, notify: false);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return GetBuilder<OrderController>(
                                  builder: (orderController) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                      child: AccountDeletionBottomSheet(
                                        profileController: profileController,
                                        isRunningOrderAvailable: orderController.runningOrderList != null && orderController.runningOrderList!.isNotEmpty,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).hintColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  HeroiconsOutline.trash,
                                  size: 22,
                                  color: Theme.of(context).hintColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'delete_account'.tr,
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    ],
                  ),
                ),
              ]),
            ),
          );
        });
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Text(
        title.toUpperCase(),
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).hintColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Column(children: children),
    );
  }
}
