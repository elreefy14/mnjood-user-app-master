import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/wallet/domain/models/fund_bonus_model.dart';
import 'package:mnjood/features/wallet/domain/models/wallet_model.dart';
import 'package:mnjood/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class WalletRepository implements WalletRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  WalletRepository( {required this.apiClient, required this.sharedPreferences});

  @override
  Future<WalletModel?> getList({int? offset, String? sortingType}) async {
    return await _getWalletTransactionList(offset!, sortingType!);
  }

  Future<WalletModel?> _getWalletTransactionList(int offset, String sortingType) async {
    WalletModel? walletModel;
    Response response = await apiClient.getData('${AppConstants.walletTransactionUri}?offset=$offset&limit=10&type=$sortingType');
    if (response.statusCode == 200) {
      var body = response.body;
      // V3 API returns {success, data: [...], meta: {pagination: {total:...}}}
      // V1 API returns {total_size:..., limit:..., offset:..., data: [...]}
      if (body is Map && body.containsKey('success') && body['data'] is List) {
        // V3 format — adapt to WalletModel structure
        int totalSize = body['meta']?['pagination']?['total'] ?? (body['data'] as List).length;
        walletModel = WalletModel.fromJson({
          'total_size': totalSize,
          'limit': '10',
          'offset': '$offset',
          'data': body['data'],
        });
      } else if (body is Map) {
        walletModel = WalletModel.fromJson(Map<String, dynamic>.from(body));
      }
    }
    return walletModel;
  }

  @override
  Future<Response> addFundToWallet(double amount, String paymentMethod) async {
    Map<String, dynamic> body = {
      "amount": amount,
      "payment_method": paymentMethod,
      "payment_platform": GetPlatform.isWeb ? 'web' : 'app',
    };

    if (GetPlatform.isWeb) {
      String? hostname = html.window.location.hostname;
      String protocol = html.window.location.protocol;
      body["callback"] = '$protocol//$hostname${RouteHelper.wallet}';
    }

    return await apiClient.postData(AppConstants.addFundUri, body);
  }

  @override
  Future<List<FundBonusModel>?> getWalletBonusList() async {
    List<FundBonusModel>? fundBonusList;
    Response response = await apiClient.getData(AppConstants.walletBonusUri);
    if (response.statusCode == 200) {
      fundBonusList = [];
      // V3 API: Extract data array from response wrapper
      var dataArray = response.body['data'] ?? response.body;
      if (dataArray is List) {
        dataArray.forEach((value){
          fundBonusList!.add(FundBonusModel.fromJson(value));
        });
      }
    }
    return fundBonusList;
  }

  @override
  Future<void> setWalletAccessToken(String token) {
    return sharedPreferences.setString(AppConstants.walletAccessToken, token);
  }

  @override
  String getWalletAccessToken(){
    return sharedPreferences.getString(AppConstants.walletAccessToken) ?? "";
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
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}