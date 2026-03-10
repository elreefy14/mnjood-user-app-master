import 'package:mnjood_vendor/features/profile/controllers/profile_controller.dart';
import 'package:mnjood_vendor/features/profile/domain/models/employed_permission_model.dart';
import 'package:mnjood_vendor/features/profile/domain/models/profile_model.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/features/menu/domain/models/menu_model.dart';
import 'package:mnjood_vendor/features/menu/widgets/menu_button_widget.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/helper/route_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Restaurant? restaurant = Get.find<ProfileController>().profileModel != null ? Get.find<ProfileController>().profileModel!.restaurants![0] : null;

    ModulePermissionModel? modulePermission = Get.find<ProfileController>().modulePermission;

    final List<MenuModel> menuList = [];

    menuList.add(MenuModel(iconData: HeroiconsSolid.user, title: 'profile'.tr, route: RouteHelper.getProfileRoute()));

    if(modulePermission?.food ?? false){
      bool foodSectionBlocked = false;
      if(Get.find<ProfileController>().profileModel?.restaurants != null && Get.find<ProfileController>().profileModel!.restaurants!.isNotEmpty) {
        foodSectionBlocked = !(Get.find<ProfileController>().profileModel!.restaurants![0].foodSection ?? true);
      }
      menuList.add(MenuModel(
        iconData: HeroiconsOutline.squares2x2, title: BusinessTypeHelper.getAllItemsLabel(), route: RouteHelper.getAllProductsRoute(),
        isBlocked: foodSectionBlocked,
      ));
    }

    if(modulePermission?.campaign ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.megaphone, title: 'campaign'.tr, route: RouteHelper.getCampaignRoute()));
    }

    if(modulePermission?.restaurantConfig ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.cog6Tooth, title: BusinessTypeHelper.getSettingsLabel(), route: RouteHelper.getRestaurantSettingRoute(restaurant)));
    }

    if(restaurant?.selfDeliverySystem == 1) {
      menuList.add(MenuModel(
        iconData: HeroiconsOutline.truck, title: 'delivery_man'.tr, route: RouteHelper.getDeliveryManRoute(),
      ));
    }

    if(modulePermission?.adsList ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.speakerWave, title: 'advertisements'.tr, route: RouteHelper.getAdvertisementListRoute()));
    }

    if(modulePermission?.addon ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.plusCircle, title: 'addons'.tr, route: RouteHelper.getAddonsRoute()));
    }

    if(modulePermission?.category ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.squares2x2, title: 'categories'.tr, route: RouteHelper.getCategoriesRoute()));
    }

    if(modulePermission?.coupon ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.ticket, title: 'coupon'.tr, route: RouteHelper.getCouponRoute()));
    }

    if(modulePermission?.businessPlan ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.briefcase, title: 'my_business_plan'.tr, route: RouteHelper.getMySubscriptionRoute()));
    }

    if(modulePermission?.reviews ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.star, title: 'reviews'.tr, route: RouteHelper.getCustomerReviewRoute()));
    }

    if((modulePermission?.expenseReport ?? false) || (modulePermission?.transaction ?? false) || (modulePermission?.orderReport ?? false) || (modulePermission?.foodReport ?? false) || (modulePermission?.taxReport ?? false)){
      menuList.add(MenuModel(iconData: HeroiconsOutline.chartPie, title: 'reports'.tr, route: RouteHelper.getReportsRoute()));
    }

    // Inventory Management for Supermarket and Pharmacy
    if(BusinessTypeHelper.showEnhancedInventory()) {
      menuList.add(MenuModel(
        iconData: HeroiconsOutline.cube,
        title: 'inventory_management'.tr,
        route: RouteHelper.getInventoryRoute(),
      ));
    }

    // Finance Management for Supermarket
    if(BusinessTypeHelper.showFinanceManagement()) {
      menuList.add(MenuModel(
        iconData: HeroiconsOutline.banknotes,
        title: 'finance_management'.tr,
        route: RouteHelper.getFinanceDashboardRoute(),
      ));
    }

    // POS (Point of Sale) for Supermarket
    if(BusinessTypeHelper.showEnhancedInventory()) {
      menuList.add(MenuModel(
        iconData: HeroiconsOutline.creditCard,
        title: 'pos'.tr,
        route: RouteHelper.getPosRoute(),
      ));
    }

    if(modulePermission?.disbursement ?? false){
      if(Get.find<SplashController>().configModel?.disbursementType == 'automated'){
        menuList.add(MenuModel(iconData: HeroiconsOutline.arrowsRightLeft, title: 'disbursement'.tr, route: RouteHelper.getDisbursementRoute()));
      }
    }

    if(modulePermission?.walletMethod ?? false){
      menuList.add(MenuModel(iconData: HeroiconsOutline.wallet, title: 'wallet_method'.tr, route: RouteHelper.getWithdrawMethodRoute()));
    }

    menuList.add(MenuModel(iconData: HeroiconsOutline.language, title: 'language'.tr, route: '', isLanguage: true));

    if(modulePermission?.chat ?? false){
      bool isNotSubscribe = false;
      if(Get.find<ProfileController>().profileModel?.restaurants != null && Get.find<ProfileController>().profileModel!.restaurants!.isNotEmpty) {
        isNotSubscribe = (Get.find<ProfileController>().profileModel!.restaurants![0].restaurantModel == 'subscription'
          && Get.find<ProfileController>().profileModel!.subscription != null && (Get.find<ProfileController>().profileModel!.subscription!.chat ?? 0) == 0);
      }
      menuList.add(
        MenuModel(
        iconData: HeroiconsOutline.chatBubbleLeftRight, title: 'conversation'.tr, route: RouteHelper.getConversationListRoute(),
        isNotSubscribe: isNotSubscribe,
        ),
      );
    }

    menuList.add(MenuModel(iconData: HeroiconsOutline.shieldCheck, title: 'privacy_policy'.tr, route: RouteHelper.getPrivacyRoute()));

    menuList.add(MenuModel(iconData: HeroiconsOutline.documentText, title: 'terms_condition'.tr, route: RouteHelper.getTermsRoute()));

    menuList.add(MenuModel(iconData: HeroiconsOutline.arrowRightOnRectangle, title: 'logout'.tr, route: ''));


    return Container(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 50,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: (1/1.27),
            crossAxisSpacing: Dimensions.paddingSizeExtraSmall, mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
          ),
          itemCount: menuList.length,
          itemBuilder: (context, index) {
            return MenuButtonWidget(menu: menuList[index], isProfile: index == 0, isLogout: index == menuList.length-1);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

      ]),
    );
  }
}