import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/splash/domain/models/config_model.dart';
import 'package:mnjood/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:mnjood/features/splash/domain/services/splash_service_interface.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';

class SplashService implements SplashServiceInterface {
  final SplashRepositoryInterface splashRepositoryInterface;
  SplashService({required this.splashRepositoryInterface});

  /*@override
  Future<Response> getConfigData({required DataSourceEnum? source}) async {
    return await splashRepositoryInterface.getConfigData(source: source);
  }*/

  @override
  Future<Response> getConfigData({required DataSourceEnum? source}) async {
    return await splashRepositoryInterface.getConfigData(source: source);
  }

  @override
  ConfigModel? prepareConfigData(Response response){
    ConfigModel? configModel;
    if(response.statusCode == 200) {
      try {
        // Extract data from V3 API response wrapper
        var responseData = response.body['data'] ?? response.body;

        // DEBUG: Log payment method data
        print('===== CONFIG API DEBUG =====');
        print('Response body type: ${response.body.runtimeType}');
        if (response.body is Map) {
          print('Response body keys: ${response.body.keys}');
        }
        if (responseData is Map) {
          print('digital_payment: ${responseData['digital_payment']}');
          print('cash_on_delivery: ${responseData['cash_on_delivery']}');
          print('customer_wallet_status: ${responseData['customer_wallet_status']}');
          print('offline_payment_status: ${responseData['offline_payment_status']}');
          print('active_payment_method_list: ${responseData['active_payment_method_list']}');
          print('payment_methods: ${responseData['payment_methods']}');
        }

        configModel = ConfigModel.fromJson(responseData);

        // DEBUG: Log parsed results
        print('===== PARSED CONFIG =====');
        print('Parsed digitalPayment: ${configModel.digitalPayment}');
        print('Parsed cashOnDelivery: ${configModel.cashOnDelivery}');
        print('Parsed customerWalletStatus: ${configModel.customerWalletStatus}');
        print('Parsed offlinePaymentStatus: ${configModel.offlinePaymentStatus}');
        print('Parsed activePaymentMethodList count: ${configModel.activePaymentMethodList?.length ?? 0}');
        if (configModel.activePaymentMethodList != null) {
          for (var method in configModel.activePaymentMethodList!) {
            print('  - Gateway: ${method.getWay}, Title: ${method.getWayTitle}');
          }
        }

      } catch (e, stackTrace) {
        print('ERROR parsing ConfigModel: $e');
        print('Stack trace: $stackTrace');
        print('Response body keys: ${response.body?.keys}');
        // Don't rethrow - return null to trigger retry
      }
    }
    return configModel;
  }

  @override
  Future<bool> initSharedData() {
    return splashRepositoryInterface.initSharedData();
  }

  @override
  bool? showIntro() {
    return splashRepositoryInterface.showIntro();
  }

  @override
  void disableIntro() {
    return splashRepositoryInterface.disableIntro();
  }

  @override
  Future<void> saveCookiesData(bool data) async {
    return await splashRepositoryInterface.saveCookiesData(data);
  }

  @override
  bool getCookiesData() {
    return splashRepositoryInterface.getSavedCookiesData();
  }

  @override
  void cookiesStatusChange(String? data) {
    return splashRepositoryInterface.cookiesStatusChange(data);
  }

  @override
  bool getAcceptCookiesStatus(String data) {
    return splashRepositoryInterface.getAcceptCookiesStatus(data);
  }

  @override
  Future<bool> subscribeMail(String email) async{
    bool isSuccess = false;
    Response response = await splashRepositoryInterface.subscribeEmail(email);
    if (response.statusCode == 200) {
      showCustomSnackBar('subscribed_successfully'.tr, isError: false);
      isSuccess = true;
    }
    return isSuccess;
  }

  @override
  void toggleTheme(bool darkTheme) {
    splashRepositoryInterface.setThemeStatusSharedPref(darkTheme);
  }

  @override
  Future<bool> loadCurrentTheme() async {
    return await splashRepositoryInterface.getCurrentThemeSharedPref();
  }

  @override
  bool getReferBottomSheetStatus() {
    return splashRepositoryInterface.getReferBottomSheetStatus();
  }

  @override
  Future<void> saveReferBottomSheetStatus(bool data) async {
    return await splashRepositoryInterface.saveReferBottomSheetStatus(data);
  }

}