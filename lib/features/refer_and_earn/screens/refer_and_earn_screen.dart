import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mnjood/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:mnjood/features/refer_and_earn/widgets/bottom_sheet_view_widget.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/splash/controllers/theme_controller.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/not_logged_in_screen.dart';
import 'package:mnjood/common/widgets/web_page_title_widget.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final ScrollController scrollController = ScrollController();
  final JustTheController tooltipController = JustTheController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    Get.find<ReferAndEarnController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'refer_and_earn'.tr,
        actions: [
          isLoggedIn ? IconButton(
            onPressed: () {
              showCustomBottomSheet(child: BottomSheetViewWidget());
            },
            icon: const Icon(HeroiconsOutline.informationCircle),
          ) : const SizedBox(),
        ],
      ),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn ? SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
        child: Column(children: [

          WebScreenTitleWidget(title: 'refer_and_earn'.tr),

          FooterViewWidget(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: GetBuilder<ReferAndEarnController>(builder: (referAndEarnController) {
                  return Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                    SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraOverLarge : Dimensions.paddingSizeOverLarge),

                    Image.asset(
                      Images.referImage, width: 500,
                      height: isDesktop ? 250 : 200, fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    Text(isDesktop ? 'invite_friends_and_earn_money_on_Every_Referral'.tr : 'earn_more_by_referring_friends'.tr ,
                        style: robotoBold.copyWith(fontSize: isDesktop ? Dimensions.fontSizeLarge : Dimensions.fontSizeOverLarge), textAlign: TextAlign.center),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    isDesktop ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        '${'one_referral'.tr}= ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                            ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble() : 0.0),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                      ),
                    ]) : const SizedBox(),
                    isDesktop ?  const SizedBox(height: 40) : const SizedBox(),

                    isDesktop ? const SizedBox() : Text('copy_your_code_share_it_with_your_friends'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                    isDesktop ? const SizedBox() : const SizedBox(height: 45),

                    isDesktop ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 250),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('your_personal_code'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.start),
                      ),
                    ) : const SizedBox(),

                    isDesktop ? const SizedBox() : Text('your_personal_code'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 250 : Dimensions.paddingSizeDefault),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: Theme.of(context).primaryColor.withValues(alpha: isDesktop ? 0.7 : 0.3),
                          strokeWidth: 1,
                          strokeCap: StrokeCap.butt,
                          dashPattern: const [5, 5],
                          padding: const EdgeInsets.all(0),
                          radius: Radius.circular( isDesktop ? Dimensions.radiusDefault : 50),
                        ),
                        child: SizedBox(
                          height: 50,
                          child: (referAndEarnController.userInfoModel != null) ? Row(children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
                                child: Text(
                                  referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode ?? '' : '',
                                  style: robotoRegular,
                                ),
                              ),
                            ),

                            JustTheTooltip(
                              backgroundColor: Get.find<ThemeController>().darkTheme ? Colors.white : Colors.black87,
                              controller: tooltipController,
                              preferredDirection: AxisDirection.up,
                              tailLength: 14,
                              tailBaseWidth: 20,
                              triggerMode: TooltipTriggerMode.manual,
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('copied'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                              ),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  if(referAndEarnController.userInfoModel!.refCode!.isNotEmpty){
                                    tooltipController.showTooltip();
                                    Clipboard.setData(ClipboardData(text: '${referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode : ''}'));
                                  }

                                  Future.delayed(const Duration(seconds: 2), () {
                                    tooltipController.hideTooltip();
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular( isDesktop ? Dimensions.radiusDefault : 50)),
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                                  margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  child: Text('copy'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                                ),
                              ),
                            ),

                          ]) : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeLarge),

                    Text('or_share'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Wrap(children: [
                      InkWell(
                        onTap: () => SharePlus.instance.share(
                          ShareParams(text: Get.find<SplashController>().configModel?.appUrlAndroid != null ? '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                            : '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode}'),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                            boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 5)],
                          ),
                          padding: const EdgeInsets.all(7),
                          child: Icon(HeroiconsOutline.share, color: Theme.of(context).primaryColor),
                        ),
                      )
                    ]),

                    isDesktop ? const Padding(
                      padding: EdgeInsets.only(
                        top: Dimensions.paddingSizeOverLarge, bottom: Dimensions.paddingSizeExtraLarge,
                        left: 100, right: 100,
                      ),
                      child: BottomSheetViewWidget(),
                    ) : const SizedBox(),

                  ]);
                }),
              ),
            ),
          ),
        ]),
      ) : NotLoggedInScreen(callBack: (value){
        _initCall();
        setState(() {});
      }),
    );
  }
}