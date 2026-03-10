import 'package:moyasar/src/models/payment_type.dart';
import 'package:moyasar/src/models/sources/payment_request_source.dart';

/// Custom [PaymentRequestSource] for Google Pay tokens.
/// Mirrors [ApplePayPaymentRequestSource] but sends type='googlepay' to Moyasar API.
class GooglePayPaymentRequestSource implements PaymentRequestSource {
  @override
  PaymentType type = PaymentType.applepay; // placeholder — overridden in toJson

  late String token;
  late String manual;
  late String saveCard;

  GooglePayPaymentRequestSource(
      this.token, bool manualPayment, bool shouldSaveCard) {
    manual = manualPayment ? 'true' : 'false';
    saveCard = shouldSaveCard ? 'true' : 'false';
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'googlepay',
        'token': token,
        'manual': manual,
        'save_card': saveCard,
      };
}
