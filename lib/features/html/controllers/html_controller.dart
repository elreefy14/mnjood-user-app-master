import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/html/domain/services/html_service_interface.dart';
import 'package:mnjood/features/html/enums/html_type.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';

class HtmlController extends GetxController implements GetxService {
  final HtmlServiceInterface htmlServiceInterface;

  HtmlController({required this.htmlServiceInterface});

  String? _htmlText;
  String? get htmlText => _htmlText;

  Future<void> getHtmlText(HtmlType htmlType) async {
    _htmlText = null;
    final config = Get.find<SplashController>().configModel;

    // Use config values for main pages to avoid CORS issues
    if (htmlType == HtmlType.termsAndCondition) {
      _htmlText = config?.termsAndConditions;
    } else if (htmlType == HtmlType.privacyPolicy) {
      _htmlText = config?.privacyPolicy;
    } else if (htmlType == HtmlType.aboutUs) {
      _htmlText = config?.aboutUs;
    } else {
      // For other types (shipping, cancellation, refund), keep API call
      _htmlText = await htmlServiceInterface.getHtmlText(htmlType, Get.find<LocalizationController>().locale.languageCode);
    }
    update();
  }

}