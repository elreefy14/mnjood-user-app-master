import 'package:mnjood_delivery/common/models/response_model.dart';
import 'package:mnjood_delivery/feature/cash_in_hand/domain/models/wallet_payment_model.dart';
import 'package:mnjood_delivery/feature/cash_in_hand/domain/repositories/cash_in_hand_repository_interface.dart';
import 'package:mnjood_delivery/feature/cash_in_hand/domain/services/cash_in_hand_service_interface.dart';

class CashInHandService implements CashInHandServiceInterface {
  final CashInHandRepositoryInterface cashInHandRepositoryInterface;
  CashInHandService({required this.cashInHandRepositoryInterface});

  @override
  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    return await cashInHandRepositoryInterface.makeCollectCashPayment(amount, paymentGatewayName);
  }

  @override
  Future<ResponseModel> makeWalletAdjustment() async {
    return await cashInHandRepositoryInterface.makeWalletAdjustment();
  }

  @override
  Future<List<Transactions>?> getWalletPaymentList() async {
    return await cashInHandRepositoryInterface.getList();
  }

}