import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moyasar/moyasar.dart';
import 'package:pay/pay.dart' as google_pay;
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/domain/models/google_pay_request_source.dart';
import 'package:mnjood/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:mnjood/features/loyalty/controllers/loyalty_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class MoyasarPaymentScreen extends StatefulWidget {
  final String orderId;
  final int amountHalalas;
  final String currency;
  final String paymentRequestId;
  final String? moyasarSource;
  final String? contactNumber;
  final bool isDeliveryOrder;
  const MoyasarPaymentScreen({
    super.key,
    required this.orderId,
    required this.amountHalalas,
    this.currency = 'SAR',
    this.paymentRequestId = '',
    this.moyasarSource,
    this.contactNumber,
    this.isDeliveryOrder = false,
  });

  @override
  State<MoyasarPaymentScreen> createState() => _MoyasarPaymentScreenState();
}

class _MoyasarPaymentScreenState extends State<MoyasarPaymentScreen> {
  late PaymentConfig _paymentConfig;
  bool _paymentProcessed = false;
  bool _isProcessingGooglePay = false;

  double get _amountForDisplay => widget.amountHalalas / 100.0;

  @override
  void initState() {
    super.initState();
    final config = Get.find<SplashController>().configModel;
    final apiKey = config?.moyasarPublishableKey ?? '';

    _paymentConfig = PaymentConfig(
      publishableApiKey: apiKey,
      amount: widget.amountHalalas,
      description: widget.orderId.isNotEmpty ? 'Order #${widget.orderId}' : 'Mnjood Payment',
      metadata: {
        if (widget.orderId.isNotEmpty) 'order_id': widget.orderId,
        if (widget.paymentRequestId.isNotEmpty) 'payment_request_id': widget.paymentRequestId,
      },
      creditCard: CreditCardConfig(saveCard: false, manual: false),
      applePay: ApplePayConfig(
        merchantId: config?.moyasarApplePayMerchantId ?? 'merchant.com.mnjood',
        label: config?.businessName ?? 'Mnjood',
        manual: false,
        saveCard: false,
      ),
    );
  }

  void _onPaymentResult(result) {
    if (_paymentProcessed) return;

    if (result is PaymentResponse) {
      switch (result.status) {
        case PaymentStatus.paid:
          _paymentProcessed = true;
          _handleSuccess(result.id);
          break;
        case PaymentStatus.failed:
          _handleFailure();
          break;
        default:
          if (kDebugMode) print('Moyasar payment status: ${result.status}');
          break;
      }
    } else if (result is PaymentCanceledError) {
      if (kDebugMode) print('Payment canceled by user');
    } else {
      if (kDebugMode) print('Moyasar error: $result');
      _handleFailure();
    }
  }

  void _handleSuccess(String moyasarPaymentId) async {
    if (widget.orderId.isEmpty) {
      // PAY-FIRST: create order now with payment proof
      final orderID = await Get.find<CheckoutController>()
          .placeOrderAfterPayment(moyasarPaymentId: moyasarPaymentId);
      if (orderID.isEmpty) {
        // Payment OK but order creation failed — show retry dialog
        _showRetryDialog(moyasarPaymentId);
      }
      // placeOrderAfterPayment handles navigation on success
    } else {
      // LEGACY: existing verify + notify flow
      final verified = await Get.find<CheckoutController>().verifyMoyasarPayment(
        widget.orderId, moyasarPaymentId,
      );

      if (!verified) {
        if (kDebugMode) print('Moyasar verify returned non-paid status, proceeding anyway');
      }

      Get.find<CheckoutController>().sendOrderNotification(widget.orderId);

      final loyaltyPoint = Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0;
      double total = ((_amountForDisplay / 100) * loyaltyPoint);
      Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));

      Get.offNamed(RouteHelper.getOrderSuccessRoute(
        widget.orderId, 'success', _amountForDisplay, widget.contactNumber,
        isDeliveryOrder: widget.isDeliveryOrder,
      ));
    }
  }

  void _handleFailure() {
    if (widget.orderId.isEmpty) {
      // PAY-FIRST: no order created, just go back
      Get.find<CheckoutController>().clearPendingOrderData();
      Get.back();
      showCustomSnackBar('payment_cancelled'.tr);
    } else {
      // LEGACY: show payment failed dialog
      Get.dialog(PaymentFailedDialog(
        orderID: widget.orderId,
        orderAmount: _amountForDisplay,
        maxCodOrderAmount: null,
        contactPersonNumber: widget.contactNumber,
      ));
    }
  }

  void _showRetryDialog(String moyasarPaymentId) {
    Get.dialog(
      AlertDialog(
        title: Text('order_creation_failed_after_payment'.tr),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back(); // close dialog
              final orderID = await Get.find<CheckoutController>()
                  .placeOrderAfterPayment(moyasarPaymentId: moyasarPaymentId);
              if (orderID.isEmpty) {
                _showRetryDialog(moyasarPaymentId);
              }
            },
            child: Text('retry'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // --- Google Pay helpers ---

  String _buildGooglePayConfigString() {
    final publishableKey = _paymentConfig.publishableApiKey;
    return jsonEncode({
      "provider": "google_pay",
      "data": {
        "environment": "PRODUCTION",
        "apiVersion": 2,
        "apiVersionMinor": 0,
        "allowedPaymentMethods": [
          {
            "type": "CARD",
            "tokenizationSpecification": {
              "type": "PAYMENT_GATEWAY",
              "parameters": {
                "gateway": "moyasar",
                "gatewayMerchantId": publishableKey,
              }
            },
            "parameters": {
              "allowedCardNetworks": ["VISA", "MASTERCARD", "MADA"],
              "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
              "billingAddressRequired": false,
            }
          }
        ],
        "merchantInfo": {
          "merchantName": Get.find<SplashController>().configModel?.businessName ?? "Mnjood",
        },
        "transactionInfo": {
          "countryCode": "SA",
          "currencyCode": widget.currency,
          "totalPriceStatus": "FINAL",
          "totalPrice": _amountForDisplay.toStringAsFixed(2),
        }
      }
    });
  }

  void _onGooglePayResult(Map<String, dynamic> paymentResult) async {
    if (_isProcessingGooglePay || _paymentProcessed) return;
    setState(() => _isProcessingGooglePay = true);

    try {
      // Extract the token — same structure as Apple Pay result
      final tokenData = paymentResult['paymentMethodData']?['tokenizationData']?['token'];
      if (tokenData == null || tokenData.toString().isEmpty) {
        _onPaymentResult(UnprocessableTokenError());
        return;
      }

      final token = tokenData.toString();
      final source = GooglePayPaymentRequestSource(token, false, false);
      final paymentRequest = PaymentRequest(_paymentConfig, source);

      final result = await Moyasar.pay(
        apiKey: _paymentConfig.publishableApiKey,
        paymentRequest: paymentRequest,
      );

      _onPaymentResult(result);
    } catch (e) {
      if (kDebugMode) print('Google Pay processing error: $e');
      _onPaymentResult(PaymentCanceledError());
    } finally {
      if (mounted) setState(() => _isProcessingGooglePay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showApplePay = !kIsWeb && Platform.isIOS;
    final bool showCreditCard = widget.moyasarSource == null || widget.moyasarSource == 'creditcard';
    final bool showApplePayWidget = showApplePay && (widget.moyasarSource == null || widget.moyasarSource == 'applepay');
    final bool showSTCPay = widget.moyasarSource == 'stcpay';
    final bool showGooglePay = !kIsWeb && Platform.isAndroid && widget.moyasarSource == 'googlepay';
    final isArabic = Get.locale?.languageCode == 'ar';

    // STC Pay has its own Scaffold — return it directly to avoid nested Scaffold issues
    if (showSTCPay) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && !_paymentProcessed) _handleFailure();
        },
        child: STCPaymentComponent(
          config: _paymentConfig,
          onPaymentResult: _onPaymentResult,
          locale: isArabic ? const Localization.ar() : const Localization.en(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_paymentProcessed) {
          _handleFailure();
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'payment'.tr,
          onBackPressed: () {
            if (!_paymentProcessed) _handleFailure();
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(children: [

                // Order info
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(children: [
                    Icon(HeroiconsOutline.shoppingBag, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(widget.orderId.isNotEmpty ? '${'order'.tr} #${widget.orderId}' : 'complete_payment'.tr, style: robotoMedium),
                    const Spacer(),
                    Text(
                      '${_amountForDisplay.toStringAsFixed(2)} ${widget.currency}',
                      style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                    ),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Google Pay (Android only)
                if (showGooglePay) ...[
                  if (_isProcessingGooglePay)
                    const Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: CircularProgressIndicator(),
                    )
                  else
                    google_pay.GooglePayButton(
                      paymentConfiguration: google_pay.PaymentConfiguration.fromJsonString(
                        _buildGooglePayConfigString(),
                      ),
                      paymentItems: [
                        google_pay.PaymentItem(
                          label: Get.find<SplashController>().configModel?.businessName ?? 'Mnjood',
                          amount: _amountForDisplay.toStringAsFixed(2),
                          status: google_pay.PaymentItemStatus.final_price,
                        ),
                      ],
                      type: google_pay.GooglePayButtonType.pay,
                      onPaymentResult: _onGooglePayResult,
                      width: MediaQuery.of(context).size.width,
                      height: 48,
                      onError: (error) {
                        if (kDebugMode) print('Google Pay error: $error');
                        showCustomSnackBar('google_pay_not_available'.tr);
                      },
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],

                // Apple Pay (iOS only, if source allows)
                if (showApplePayWidget) ...[
                  ApplePay(
                    config: _paymentConfig,
                    onPaymentResult: _onPaymentResult,
                  ),
                  if (showCreditCard) ...[
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Text('or'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ],

                // Credit Card form (if source allows)
                if (showCreditCard)
                  CreditCard(
                    config: _paymentConfig,
                    onPaymentResult: _onPaymentResult,
                  ),

              ]),
            ),
          ),
        ),
      ),
    );
  }
}
