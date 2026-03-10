import 'dart:convert';

import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRepository implements SplashRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepository({required this.apiClient, required this.sharedPreferences});

  // @override
  // Future<Response> getConfigData({required DataSourceEnum? source}) async {
  //   return await apiClient.getData(AppConstants.configUri);
  // }

  @override
  Future<Response> getConfigData({required DataSourceEnum? source}) async {
    if (source == DataSourceEnum.local) {
      String? cachedData = sharedPreferences.getString(AppConstants.configCacheKey);
      if (cachedData != null) {
        print('===== LOADING CONFIG FROM CACHE =====');
        var decoded = jsonDecode(cachedData);
        if (decoded is Map) {
          var data = decoded['data'] ?? decoded;
          print('CACHE active_payment_method_list: ${data['active_payment_method_list']}');
          print('CACHE payment_methods: ${data['payment_methods']}');
          print('CACHE digital_payment: ${data['digital_payment']}');
          print('CACHE cash_on_delivery: ${data['cash_on_delivery']}');
        }
        return Response(statusCode: 200, body: decoded);
      } else {
        print('===== NO CACHE FOUND, FETCHING FROM API =====');
        return await getConfigDataFromApi();
      }
    } else {
      return await getConfigDataFromApi();
    }
  }

  Future<Response> getConfigDataFromApi() async {
    print('===== FETCHING CONFIG FROM API =====');
    Response response = await apiClient.getData(AppConstants.configUri);
    if (response.statusCode == 200) {
      print('===== API CONFIG RESPONSE =====');
      var data = response.body['data'] ?? response.body;
      if (data is Map) {
        print('API active_payment_method_list: ${data['active_payment_method_list']}');
        print('API payment_methods: ${data['payment_methods']}');
        print('API digital_payment_method_list: ${data['digital_payment_method_list']}');
        print('API digital_payment: ${data['digital_payment']}');
        print('API cash_on_delivery: ${data['cash_on_delivery']}');
      }
      // V3 API: Cache the full response (including data wrapper)
      sharedPreferences.setString(AppConstants.configCacheKey, jsonEncode(response.body));
    } else {
      print('API CONFIG ERROR: ${response.statusCode} - ${response.statusText}');
    }
    return response;
  }

  @override
  Future<bool> initSharedData() {
    if(!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if(!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(AppConstants.countryCode, AppConstants.languages[0].countryCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(AppConstants.languageCode, AppConstants.languages[0].languageCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.cartList)) {
      sharedPreferences.setStringList(AppConstants.cartList, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.searchHistory)) {
      sharedPreferences.setStringList(AppConstants.searchHistory, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.intro)) {
      sharedPreferences.setBool(AppConstants.intro, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if(sharedPreferences.containsKey(AppConstants.referBottomSheet)) {
      sharedPreferences.setBool(AppConstants.referBottomSheet, true);
    }
    return Future.value(true);
  }

  @override
  void setThemeStatusSharedPref(bool darkTheme) {
    sharedPreferences.setBool(AppConstants.theme, darkTheme);
  }

  @override
  Future<bool> getCurrentThemeSharedPref() async {
    return sharedPreferences.getBool(AppConstants.theme) ?? false;
  }

  @override
  void disableIntro() {
    sharedPreferences.setBool(AppConstants.intro, false);
  }

  @override
  bool? showIntro() {
    return sharedPreferences.getBool(AppConstants.intro);
  }

  @override
  Future<void> saveCookiesData(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.acceptCookies, data);
    } catch (e) {
      debugPrint('Save Cookies Data Fail, $e');
      rethrow;
    }
  }

  @override
  bool getSavedCookiesData() {
    return sharedPreferences.getBool(AppConstants.acceptCookies) ?? false;
  }

  @override
  void cookiesStatusChange(String? data) {
    if(data != null){
      sharedPreferences.setString(AppConstants.cookiesManagement, data);
    }
  }

  @override
  bool getAcceptCookiesStatus(String data) => sharedPreferences.getString(AppConstants.cookiesManagement) != null
      && sharedPreferences.getString(AppConstants.cookiesManagement) == data;


  // Future<Response> getHtmlText(HtmlType htmlType) async {
  //   return await apiClient.getData(
  //     htmlType == HtmlType.termsAndCondition ? AppConstants.termsAndConditionUri
  //         : htmlType == HtmlType.privacyPolicy ? AppConstants.privacyPolicyUri : htmlType == HtmlType.aboutUs
  //         ? AppConstants.aboutUsUri : htmlType == HtmlType.shippingPolicy ? AppConstants.shippingPolicyUri
  //         : htmlType == HtmlType.cancellation ? AppConstants.cancellationUri : AppConstants.refundUri,
  //     headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Accept': 'application/json',
  //       AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode,
  //     },
  //   );
  // }

  @override
  Future<Response> subscribeEmail(String email) async {
    return await apiClient.postData(AppConstants.subscriptionUri, {'email': email});
  }

  @override
  bool getReferBottomSheetStatus() {
    return sharedPreferences.getBool(AppConstants.referBottomSheet) ?? true;
  }

  @override
  Future<void> saveReferBottomSheetStatus(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.referBottomSheet, data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}