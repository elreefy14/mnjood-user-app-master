import 'package:mnjood_delivery/common/models/config_model.dart';
import 'package:mnjood_delivery/feature/splash/domain/repositories/splash_repository_interface.dart';
import 'package:mnjood_delivery/feature/splash/domain/services/splash_service_interface.dart';

class SplashService implements SplashServiceInterface {
  final SplashRepositoryInterface splashRepositoryInterface;
  SplashService({required this.splashRepositoryInterface});

  @override
  Future<ConfigModel?> getConfigData() async {
    return await splashRepositoryInterface.getConfigData();
  }

  @override
  Future<bool> initSharedData() async {
    return await splashRepositoryInterface.initSharedData();
  }

  @override
  Future<bool> removeSharedData() async {
    return await splashRepositoryInterface.removeSharedData();
  }

  @override
  void setLanguageIntro(bool intro) {
    splashRepositoryInterface.setLanguageIntro(intro);
  }

  @override
  bool showLanguageIntro() {
    return splashRepositoryInterface.showLanguageIntro();
  }

}