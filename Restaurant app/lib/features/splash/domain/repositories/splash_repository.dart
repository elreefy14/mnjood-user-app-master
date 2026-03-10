import 'package:mnjood_vendor/common/models/config_model.dart';
import 'package:mnjood_vendor/api/api_client.dart';
import 'package:mnjood_vendor/features/splash/domain/repositories/splash_repository_service.dart';
import 'package:mnjood_vendor/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRepository implements SplashRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<ConfigModel?> getConfigData() async {
    ConfigModel? configModel;
    try {
      Response response = await apiClient.getData(AppConstants.configUri);
      if(response.statusCode == 200) {
        // V3 API: Extract data from response wrapper
        var data = response.body['data'] ?? response.body;
        configModel = ConfigModel.fromJson(data);
      }
    } catch (_) {
      configModel = null;
    }
    return configModel;
  }

  @override
  Future<bool> initSharedData() {
    if(!sharedPreferences.containsKey(AppConstants.theme)) {
      return sharedPreferences.setBool(AppConstants.theme, false);
    }
    if(!sharedPreferences.containsKey(AppConstants.countryCode)) {
      return sharedPreferences.setString(AppConstants.countryCode, AppConstants.languages[0].countryCode ?? 'US');
    }
    if(!sharedPreferences.containsKey(AppConstants.languageCode)) {
      return sharedPreferences.setString(AppConstants.languageCode, AppConstants.languages[0].languageCode ?? 'en');
    }
    if(!sharedPreferences.containsKey(AppConstants.notification)) {
      return sharedPreferences.setBool(AppConstants.notification, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.intro)) {
      return sharedPreferences.setBool(AppConstants.intro, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.intro)) {
      return sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    return Future.value(true);
  }

  @override
  Future<bool> removeSharedData() {
    return sharedPreferences.clear();
  }

  @override
  bool showIntro() {
    return sharedPreferences.getBool(AppConstants.intro) ?? true;
  }

  @override
  void setIntro(bool intro) {
    sharedPreferences.setBool(AppConstants.intro, intro);
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete({int? id}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList() {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    // TODO: implement update
    throw UnimplementedError();
  }

}