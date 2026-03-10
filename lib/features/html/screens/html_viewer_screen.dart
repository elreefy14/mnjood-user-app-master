import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mnjood/features/html/controllers/html_controller.dart';
import 'package:mnjood/features/html/enums/html_type.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<HtmlController>().getHtmlText(widget.htmlType);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  // Get icon for page type
  IconData _getPageIcon() {
    switch (widget.htmlType) {
      case HtmlType.aboutUs:
        return HeroiconsOutline.informationCircle;
      case HtmlType.termsAndCondition:
        return HeroiconsOutline.documentText;
      case HtmlType.privacyPolicy:
        return HeroiconsOutline.shieldCheck;
      case HtmlType.shippingPolicy:
        return HeroiconsOutline.truck;
      case HtmlType.refund:
        return HeroiconsOutline.arrowPath;
      case HtmlType.cancellation:
        return HeroiconsOutline.xCircle;
      default:
        return HeroiconsOutline.documentText;
    }
  }

  // Get page title
  String _getPageTitle() {
    switch (widget.htmlType) {
      case HtmlType.termsAndCondition:
        return 'terms_conditions'.tr;
      case HtmlType.aboutUs:
        return 'about_us'.tr;
      case HtmlType.privacyPolicy:
        return 'privacy_policy'.tr;
      case HtmlType.shippingPolicy:
        return 'shipping_policy'.tr;
      case HtmlType.refund:
        return 'refund_policy'.tr;
      case HtmlType.cancellation:
        return 'cancellation_policy'.tr;
      default:
        return 'no_data_found'.tr;
    }
  }

  // Get page description
  String _getPageDescription() {
    switch (widget.htmlType) {
      case HtmlType.aboutUs:
        return 'learn_more_about_us'.tr;
      case HtmlType.termsAndCondition:
        return 'our_terms_and_conditions'.tr;
      case HtmlType.privacyPolicy:
        return 'how_we_protect_your_data'.tr;
      case HtmlType.shippingPolicy:
        return 'shipping_and_delivery_info'.tr;
      case HtmlType.refund:
        return 'our_refund_guidelines'.tr;
      case HtmlType.cancellation:
        return 'cancellation_guidelines'.tr;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(title: _getPageTitle()),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        return htmlController.htmlText != null
            ? Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: isDesktop ? Theme.of(context).cardColor : Theme.of(context).colorScheme.surface,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    child: FooterViewWidget(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section with Icon
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor.withOpacity(0.1),
                                    Theme.of(context).primaryColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              child: Row(
                                children: [
                                  // Icon Circle
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getPageIcon(),
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  // Title and Description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getPageTitle(),
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeExtraLarge,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getPageDescription(),
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            // Content Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: HtmlWidget(
                                htmlController.htmlText ?? '',
                                key: Key(widget.htmlType.toString()),
                                textStyle: robotoRegular.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: Dimensions.fontSizeDefault,
                                  height: 1.6,
                                ),
                                onTapUrl: (String url) {
                                  return launchUrlString(url);
                                },
                              ),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
