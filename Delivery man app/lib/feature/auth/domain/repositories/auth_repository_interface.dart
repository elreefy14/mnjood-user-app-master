import 'package:mnjood_delivery/api/api_client.dart';
import 'package:mnjood_delivery/interface/repository_interface.dart';

abstract class AuthRepositoryInterface implements RepositoryInterface {
  Future<dynamic> login(String email, String password);
  Future<dynamic> registerDeliveryMan(Map<String, String> data, List<MultipartBody> multiParts, List<MultipartDocument> additionalDocument);
  Future<bool> saveUserToken(String token, String topic);
  Future<dynamic> updateToken({String notificationDeviceToken = ''});
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<void> saveUserNumberAndPassword(String number, String password, String countryCode);
  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  Future<bool> clearUserNumberAndPassword();
  String getUserToken();
}
