import 'package:mnjood_vendor/features/payment/domain/models/bank_info_body_model.dart';
import 'package:mnjood_vendor/interface/repository_interface.dart';

abstract class PaymentRepositoryInterface implements RepositoryInterface {
  Future<dynamic> updateBankInfo(BankInfoBodyModel bankInfoBody);
  Future<dynamic> requestWithdraw(Map<String?, String> data);
  Future<dynamic> getWithdrawMethodList();
  Future<dynamic> makeCollectCashPayment(double amount, String paymentGatewayName);
  Future<dynamic> makeWalletAdjustment();
  Future<dynamic> getWalletPaymentList();
}