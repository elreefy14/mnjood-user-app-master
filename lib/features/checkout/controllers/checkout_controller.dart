import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnjood/api/api_checker.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/home/screens/home_screen.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/checkout/domain/models/offline_method_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/checkout/domain/models/timeslote_model.dart';
import 'package:mnjood/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:mnjood/features/checkout/widgets/order_successfull_dialog_widget.dart';
import 'package:mnjood/features/checkout/widgets/partial_pay_dialog.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/loyalty/controllers/loyalty_controller.dart';
import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/splash/domain/models/config_model.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;

class CheckoutController extends GetxController implements GetxService {
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  AddressModel? _address;
  AddressModel? get address => _address;

  Restaurant? _restaurant;
  Restaurant? get restaurant => _restaurant;

  String _preferableTime = '';
  String get preferableTime => _preferableTime;

  List<OfflineMethodModel>? _offlineMethodList;
  List<OfflineMethodModel>? get offlineMethodList => _offlineMethodList;

  int _selectedOfflineBankIndex = 0;
  int get selectedOfflineBankIndex => _selectedOfflineBankIndex;

  bool _isPartialPay = false;
  bool get isPartialPay => _isPartialPay;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDistanceLoading = false;
  bool get isDistanceLoading => _isDistanceLoading;

  int _selectedTips = 0;
  int get selectedTips => _selectedTips;

  double _tips = 0.0;
  double get tips => _tips;

  final TextEditingController couponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController tipController = TextEditingController(text: '0');
  String addressType = '';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();

  bool _customDateRestaurantClose = false;
  bool get customDateRestaurantClose => _customDateRestaurantClose;

  DateTime? _selectedCustomDate;
  DateTime? get selectedCustomDate => _selectedCustomDate;

  int? _mostDmTipAmount;
  int? get mostDmTipAmount => _mostDmTipAmount;

  String _orderType = 'delivery';
  String get orderType => _orderType;

  bool _subscriptionOrder = false;
  bool get subscriptionOrder => _subscriptionOrder;

  DateTimeRange? _subscriptionRange;
  DateTimeRange? get subscriptionRange => _subscriptionRange;

  String? _subscriptionType = 'daily';
  String? get subscriptionType => _subscriptionType;

  int _subscriptionTypeIndex = 0;
  int get subscriptionTypeIndex => _subscriptionTypeIndex;

  List<DateTime?> _selectedDays = [null];
  List<DateTime?> get selectedDays => _selectedDays;

  double? _distance;
  double? get distance => _distance;

  double? _extraCharge;
  double? get extraCharge => _extraCharge;

  double _viewTotalPrice = 0;
  double? get viewTotalPrice => _viewTotalPrice;

  int _paymentMethodIndex = -1;
  int get paymentMethodIndex => _paymentMethodIndex;

  List<TextEditingController> informationControllerList = [];

  List<FocusNode> informationFocusList = [];

  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? get timeSlots => _timeSlots;

  List<TimeSlotModel>? _allTimeSlots;
  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;

  List<int>? _slotIndexList;
  List<int>? get slotIndexList => _slotIndexList;

  int _selectedDateSlot = 0;
  int get selectedDateSlot => _selectedDateSlot;

  int? _selectedTimeSlot = 0;
  int? get selectedTimeSlot => _selectedTimeSlot;

  AddressModel? _guestAddress;
  AddressModel? get guestAddress => _guestAddress;

  bool _isDmTipSave = false;
  bool get isDmTipSave => _isDmTipSave;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  String? _selectedPaymentKey;
  String? get selectedPaymentKey => _selectedPaymentKey;

  CheckoutPaymentItem? _selectedPaymentItem;
  CheckoutPaymentItem? get selectedPaymentItem => _selectedPaymentItem;

  String? countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
      : (() {
          final country = Get.find<SplashController>().configModel?.country;
          if (country != null && country.isNotEmpty) {
            try {
              return CountryCode.fromCountryCode(country).dialCode;
            } catch (_) {
              return null;
            }
          }
          return null;
        })() ?? Get.find<LocalizationController>().locale.countryCode;

  int _selectedInstruction = -1;
  int get selectedInstruction => _selectedInstruction;

  bool _canShowTimeSlot = false;
  bool get canShowTimeSlot => _canShowTimeSlot;

  bool _canShowTipsField = false;
  bool get canShowTipsField => _canShowTipsField;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  bool _isLoadingUpdate = false;
  bool get isLoadingUpdate => _isLoadingUpdate;

  String? _estimateDineInTime;
  String? get estimateDineInTime => _estimateDineInTime;

  DateTime? _selectedDineInDate;
  DateTime? get selectedDineInDate => _selectedDineInDate;

  DateTime? _orderPlaceDineInDateTime;
  DateTime? get orderPlaceDineInDateTime => _orderPlaceDineInDateTime;

  double _exchangeAmount = 0;
  double get exchangeAmount => _exchangeAmount;

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;

  double? _orderTax = 0.0;
  double? get orderTax => _orderTax;

  int? _taxIncluded;
  int? get taxIncluded => _taxIncluded;

  bool _showMoreDetails = false;
  bool get showMoreDetails => _showMoreDetails;

  bool _showChangeAmount = true;
  bool get showChangeAmount => _showChangeAmount;

  // Prescription image for pharmacy orders
  XFile? _prescriptionImage;
  XFile? get prescriptionImage => _prescriptionImage;

  String? _businessType;
  String? get businessType => _businessType;

  bool _isPrescriptionOnlyOrder = false;
  bool get isPrescriptionOnlyOrder => _isPrescriptionOnlyOrder;

  // Pay-first pending order data
  PlaceOrderBodyModel? _pendingPlaceOrderBody;
  PlaceOrderBodyModel? get pendingPlaceOrderBody => _pendingPlaceOrderBody;
  double _pendingTotal = 0;
  bool _pendingFromCart = false;
  String? _pendingContactNumber;
  bool _pendingIsDeliveryOrder = false;

  int? _prescriptionRestaurantId;
  int? get prescriptionRestaurantId => _prescriptionRestaurantId;

  void setPrescriptionOnlyMode(bool value) {
    _isPrescriptionOnlyOrder = value;
    update();
  }

  void setPrescriptionRestaurantId(int? id) {
    _prescriptionRestaurantId = id;
  }

  void setShowChangeAmount(bool value){
    _showChangeAmount = value;
    update();
  }

  void setBusinessType(String? type) {
    _businessType = type;
  }

  Future<void> pickPrescriptionImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image != null) {
      _prescriptionImage = image;
      update();
    }
  }

  void removePrescriptionImage() {
    _prescriptionImage = null;
    update();
  }

  void clearPrescriptionImage() {
    _prescriptionImage = null;
    _isPrescriptionOnlyOrder = false;
    _prescriptionRestaurantId = null;
  }

  void setShowMoreDetails(bool value, {bool willUpdate = true}) {
    _showMoreDetails = value;
    if(willUpdate) {
      update();
    }
  }

  void updateFirstTime() {
    _isFirstTime = true;
    update();
  }

  void setExchangeAmount(double value) {
    _exchangeAmount = value;
  }

  void setSelectedDineInDate(DateTime? date, {bool willUpdate = true}) {
    _estimateDineInTime = null;
    _selectedDineInDate = date;
    if(willUpdate) {
      update();
    }
  }

  void setOrderPlaceDineInDateTime(DateTime? value) {
    _orderPlaceDineInDateTime = value;
  }

  void setEstimateDineInTime(String? value) {
    _estimateDineInTime = value;
    update();
  }

  void initDineInSetup() {
    _estimateDineInTime = null;
    _selectedDineInDate = null;
    _orderPlaceDineInDateTime = null;
  }

  void showTipsField(){
    _canShowTipsField = !_canShowTipsField;
    update();
  }

  void showHideTimeSlot(){
    _canShowTimeSlot = !_canShowTimeSlot;
    update();
  }

  void setInstruction(int index, {bool willUpdate = true}){
    _selectedInstruction = checkoutServiceInterface.selectInstruction(index, _selectedInstruction);
    if(willUpdate) {
      update();
    }
  }

  void setDateCloseRestaurant(bool status) {
    _customDateRestaurantClose = status;
    update();
  }

  void changeDigitalPaymentName(String name){
    _digitalPaymentName = name;
    update();
  }

  void selectPaymentFromList(CheckoutPaymentItem item) {
    _selectedPaymentKey = item.key;
    _selectedPaymentItem = item;
    _paymentMethodIndex = item.legacyIndex;
    if (item.legacyIndex == 2) _digitalPaymentName = item.gateway;
    update();
  }

  void _setGuestAddress(AddressModel? address) {
    _guestAddress = address;
    update();
  }

  Future<bool> saveOfflineInfo(String data) async {
    _isLoading = true;
    update();
    bool success = await checkoutServiceInterface.saveOfflineInfo(data, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if (success) {
      _isLoading = false;
      _guestAddress = null;
    }
    update();
    return success;
  }

  void setGuestAddress(AddressModel? address) {
    _guestAddress = address;
    update();
  }

  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  void setPaymentMethod(int index, {bool willUpdate = true}) {
    _paymentMethodIndex = index;
    index == 0 ? _showChangeAmount = true : _showChangeAmount = false;

    if(willUpdate) update();
  }

  void selectOfflineBank(int index){
    _selectedOfflineBankIndex = index;
    update();
  }

  void changesMethod() {
    List<MethodInformations>? methodInformation = offlineMethodList![selectedOfflineBankIndex].methodInformations!;

    informationControllerList = checkoutServiceInterface.generateTextControllerList(methodInformation);
    informationFocusList = checkoutServiceInterface.generateFocusList(methodInformation);

    update();
  }

  Future<double?> getExtraCharge(double? distance) async {
    _extraCharge = await checkoutServiceInterface.getExtraCharge(distance);
    return _extraCharge;
  }

  void setTotalAmount(double amount){
    _viewTotalPrice = amount;
  }

  Future<void> setRestaurantDetails({int? restaurantId, String? businessType}) async {
    setBusinessType(businessType); // Set business type for prescription image visibility
    if(Get.find<RestaurantController>().restaurant == null) {
      await Get.find<RestaurantController>().getRestaurantDetails(
        Restaurant(id: restaurantId, businessType: businessType),
        businessType: businessType,
      );
    }
    _restaurant = Get.find<RestaurantController>().restaurant;
    Future.delayed(const Duration(milliseconds: 600), () => update());
  }

  Future<void> initCheckoutData(int? restaurantID, {String? businessType}) async {
    Get.find<CouponController>().removeCouponData(false);
    await Get.find<RestaurantController>().getRestaurantDetails(
      Restaurant(id: restaurantID, businessType: businessType),
      businessType: businessType,
    );
    final restaurant = Get.find<RestaurantController>().restaurant;
    if (restaurant != null) {
      initializeTimeSlot(restaurant);
    }
    insertAddresses(null);
  }

  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules, {int? customDateDuration}) {
    return Get.find<RestaurantController>().isRestaurantClosed(dateTime, active, schedules);
  }

  Future<void> getDmTipMostTapped() async {
    _mostDmTipAmount = await checkoutServiceInterface.getDmTipMostTapped();
    update();
  }

  void setPreferenceTimeForView(String time, bool instanceOrder, {bool isUpdate = true}){
    _preferableTime = checkoutServiceInterface.setPreferenceTimeForView(time, instanceOrder);
    if(isUpdate) {
      update();
    }
  }

  void setCustomDate(DateTime? date, bool instanceOrder, {bool canUpdate = true}) {
    _selectedCustomDate = date;
    // _selectedTimeSlot = checkoutServiceInterface.selectTimeSlot(instanceOrder);

    if(canUpdate) {
      update();
    }
  }

  Future<void> getOfflineMethodList() async {
    _offlineMethodList = await checkoutServiceInterface.getOfflineMethodList();
    update();
  }

  void changePartialPayment({bool isUpdate = true}){
    _isPartialPay = !_isPartialPay;
    if(isUpdate) {
      update();
    }
  }

  void stopLoader({bool isUpdate = true}) {
    _isLoading = false;
    if(isUpdate) {
      update();
    }
  }

  void updateTimeSlot(int? index, bool instanceOrder, {bool notify = true}) {
    if(!instanceOrder) {
      if(index == 0) {
        if(notify) {
          showCustomSnackBar('instance_order_is_not_active'.tr);
        }
      } else {
        _selectedTimeSlot = index;
      }
    } else {
      _selectedTimeSlot = index;
    }
    if(notify) {
      update();
    }
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    _tips = checkoutServiceInterface.updateTips(index, _selectedTips);

    if(notify) {
      update();
    }
  }

  Future<void> addTips(double tips, {bool notify = true}) async {
    _tips = tips;
    if(notify) {
      update();
    }
  }

  void setOrderType(String type, {bool notify = true}) {
    _orderType = type;
    if(notify) {
      update();
    }
  }

  void setSubscription(bool isSubscribed) {
    _subscriptionOrder = isSubscribed;
    _orderType = 'delivery';
    update();
  }

  void setSubscriptionRange(DateTimeRange range) {
    _subscriptionRange = range;
    update();
  }

  void setSubscriptionType(String? type, int index) {
    _subscriptionType = type;
    _selectedDays = [];
    for(int index=0; index < (type == 'weekly' ? 7 : type == 'monthly' ? 31 : 1); index++) {
      _selectedDays.add(null);
    }
    _subscriptionTypeIndex = index;
    update();
  }

  void addDay(int index, TimeOfDay? time) {
    if(time != null) {
      _selectedDays[index] = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    }else {
      _selectedDays[index] = null;
    }
    update();
  }

  Future<bool> checkBalanceStatus(double totalPrice, {double discount = 0, double extraCharge = 0}) async {
    totalPrice = (totalPrice - discount) + extraCharge;
    if(isPartialPay){
      changePartialPayment();
    }
    setPaymentMethod(-1);

    // Null-safe wallet balance access
    final walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
    if((walletBalance < totalPrice) && (walletBalance != 0.0)){
      Get.dialog(PartialPayDialog(isPartialPay: true, totalPrice: totalPrice), useSafeArea: false,);
    }else{
      Get.dialog(PartialPayDialog(isPartialPay: false, totalPrice: totalPrice), useSafeArea: false,);
    }

    update();
    return true;
  }

  void insertAddresses(AddressModel? addressModel, {bool notify = false}){
    _address = addressModel;

    addressType = _address?.addressType ?? '';
    addressController.text = _address?.address ?? '';
    streetNumberController.text = _address?.road ?? '';
    houseController.text = _address?.house ?? '';
    floorController.text = _address?.floor ?? '';
    if(notify) update();
  }

  Future<void> initializeTimeSlot(Restaurant restaurant) async {
    // Null-safe configModel access
    final slotDuration = Get.find<SplashController>().configModel?.scheduleOrderSlotDuration;
    _timeSlots = await checkoutServiceInterface.initializeTimeSlot(restaurant, slotDuration);
    _allTimeSlots = await checkoutServiceInterface.initializeTimeSlot(restaurant, slotDuration);

    if (_allTimeSlots != null) {
      _validateSlot(_allTimeSlots!, DateTime.now(), notify: false);
    }
  }

  void updateDateSlot(DateTime date, bool instanceOrder) {
    if(!instanceOrder && _selectedTimeSlot == 0) {
      _selectedTimeSlot = 1;
    }
    if(_allTimeSlots != null) {
      _validateSlot(_allTimeSlots!, date);
    }
    update();
  }

  void updateDateSlotIndex(int index) {
    _selectedDateSlot = index;
    update();
  }

  void _validateSlot(List<TimeSlotModel> slots, DateTime date, {bool notify = true}) {
    _timeSlots = checkoutServiceInterface.validateTimeSlot(slots, date);
    _slotIndexList = checkoutServiceInterface.validateSlotIndexes(slots, date);

    if(notify) {
      update();
    }
  }

  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng, {bool isDuration = false, bool isRiding = false, bool fromDashboard = false}) async {
    _isDistanceLoading = true;
    update();
    _distance = await checkoutServiceInterface.getDistanceInKM(originLatLng, destinationLatLng, isDuration: isDuration);

    if(!fromDashboard) {
      await getExtraCharge(_distance);
    }
    _isDistanceLoading = false;
    update();
    return _distance;
  }

  Future<String> placeOrder(PlaceOrderBodyModel placeOrderBody, int? zoneID, double amount, double? maximumCodOrderAmount, bool fromCart,
      bool isCashOnDeliveryActive, {bool isOfflinePay = false}) async {
    _isLoading = true;
    update();
    String orderID = '';
    Response response = await checkoutServiceInterface.placeOrder(placeOrderBody, prescriptionImage: _prescriptionImage);
    _isLoading = false;
    if (response.statusCode == 200 || response.statusCode == 201) {
      String? message = response.body['message'];
      // V3 API: Extract order ID from data.id or fallback to order_id
      var data = response.body['data'];
      if (data != null && data['id'] != null) {
        orderID = data['id'].toString();
      } else {
        orderID = response.body['order_id']?.toString() ?? '';
      }
      noteController.clear();
      clearPrescriptionImage(); // Clear prescription image after successful order

      // Extract response-driven routing fields
      Map<String, dynamic> responseBody = response.body is Map<String, dynamic>
          ? response.body as Map<String, dynamic>
          : {};

      // V3 API: Skip notification if no valid orderID, and handle response safely.
      // For digital payments (index 2), notification is sent AFTER payment succeeds
      // (in payment_screen.dart) to avoid notifying restaurant before payment.
      if (orderID.isNotEmpty && orderID != 'null' && _paymentMethodIndex != 2) {
        Response notificationResponse = await checkoutServiceInterface.sendNotificationRequest(orderID, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
        bool reloadHome = notificationResponse.body?['reload_home'] ?? notificationResponse.body?['data']?['reload_home'] ?? false;

        if(reloadHome) {
          await HomeScreen.loadData(true);
        }
      }

      if(!isOfflinePay) {
        _callback(true, message, orderID, zoneID, amount, maximumCodOrderAmount, fromCart, isCashOnDeliveryActive, placeOrderBody.contactPersonNumber, placeOrderBody.orderType == 'dine_in', placeOrderBody.orderType == 'delivery', responseBody: responseBody);
      } else {
        Get.find<CartController>().getCartDataOnline();
      }
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
        print('DEBUG placeOrder response body: ${response.body}');
      }
    } else {
      if(response.statusCode == 400 && response.body is Map && response.body['error_code'] == 'PURCHASE_LIMIT_EXCEEDED') {
        String message = response.body['message'] ?? 'purchase_limit_exceeded'.tr;
        showCustomSnackBar(message);
      } else if(!isOfflinePay){
        _callback(false, response.statusText, '-1', zoneID, amount, maximumCodOrderAmount, fromCart, isCashOnDeliveryActive, placeOrderBody.contactPersonNumber, placeOrderBody.orderType == 'dine_in' , placeOrderBody.orderType == 'delivery');
      }else{
        showCustomSnackBar(response.statusText);
      }
    }
    update();
    return orderID;
  }

  /// Send restaurant notification for a placed order.
  /// Called from PaymentScreen after digital payment succeeds.
  Future<void> sendOrderNotification(String orderID) async {
    if (orderID.isEmpty || orderID == 'null') return;
    Response notificationResponse = await checkoutServiceInterface.sendNotificationRequest(
      orderID,
      Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId(),
    );
    bool reloadHome = notificationResponse.body?['reload_home'] ?? notificationResponse.body?['data']?['reload_home'] ?? false;
    if (reloadHome) {
      await HomeScreen.loadData(true);
    }
  }

  /// Verify a Moyasar payment with the backend after SDK success.
  /// Returns true if status == 'paid'.
  Future<bool> verifyMoyasarPayment(String orderId, String paymentId) async {
    Response response = await checkoutServiceInterface.verifyMoyasarPayment(orderId, paymentId);
    if (response.statusCode == 200) {
      final status = response.body['status'] ?? response.body['data']?['status'];
      return status == 'paid';
    }
    return false;
  }

  void _callback(bool isSuccess, String? message, String orderID, int? zoneID, double amount, double? maximumCodOrderAmount, bool fromCart, bool isCashOnDeliveryActive,
      String? contactNumber, bool isDineInOrder, bool isDeliveryOrder, {Map<String, dynamic>? responseBody}) async {
    if(isSuccess) {
      // Show success toast
      showCustomSnackBar('your_order_has_been_placed_successfully'.tr, isError: false);

      // Refresh orders list so it shows on Orders page
      Get.find<OrderController>().getRunningOrders(1, notify: false);

      if(fromCart) {
        Get.find<CartController>().clearCartList();
      }

      // Auto-cancel old order if this was an edit-order flow
      final editingId = Get.find<CartController>().editingOrderId;
      if (editingId != null) {
        Get.find<OrderController>().cancelOrderSilently(editingId);
        Get.find<CartController>().clearEditingOrderId();
      }

      _setGuestAddress(null);
      stopLoader();

      // Response-driven routing: check for payment_url or moyasar_payment_data
      final paymentUrl = responseBody?['payment_url'] ?? responseBody?['data']?['payment_url'];
      final moyasarData = responseBody?['moyasar_payment_data'] ?? responseBody?['data']?['moyasar_payment_data'];
      print('DEBUG _callback: paymentMethodIndex=$_paymentMethodIndex, digitalPaymentName=$_digitalPaymentName, '
          'selectedPaymentKey=$_selectedPaymentKey, paymentUrl=$paymentUrl, moyasarData=$moyasarData, '
          'responseBody keys=${responseBody?.keys}');

      if (paymentUrl != null && paymentUrl.toString().isNotEmpty) {
        // Webview payment (tamara, tabby, etc.)
        if(GetPlatform.isWeb) {
          html.window.open(paymentUrl.toString(), "_self");
        } else {
          Get.offNamed(RouteHelper.getPaymentRoute(
            OrderModel(id: int.parse(orderID), userId: Get.find<ProfileController>().userInfoModel?.id ?? 0, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant),
            digitalPaymentName, guestId: Get.find<AuthController>().getGuestId(), contactNumber: contactNumber,
          ));
        }
      } else if (moyasarData != null && moyasarData is Map) {
        // Moyasar payment — route native SDK for supported sources, webview for rest
        final moyasarSource = moyasarData['moyasar_source']?.toString();
        final useNativeMoyasar = moyasarSource == 'creditcard' || moyasarSource == 'stcpay'
            || (moyasarSource == 'applepay' && !GetPlatform.isWeb && GetPlatform.isIOS)
            || (moyasarSource == 'googlepay' && !GetPlatform.isWeb && GetPlatform.isAndroid);
        if (useNativeMoyasar) {
          Get.offNamed(RouteHelper.getMoyasarPaymentRoute(
            orderID,
            (moyasarData['amount_halalas'] is int) ? moyasarData['amount_halalas'] : int.tryParse(moyasarData['amount_halalas']?.toString() ?? '') ?? (amount * 100).toInt(),
            moyasarData['currency']?.toString() ?? 'SAR',
            moyasarData['payment_request_id']?.toString() ?? '',
            moyasarSource,
            contactNumber,
            isDeliveryOrder: isDeliveryOrder,
          ));
        } else {
          // applepay on Android, googlepay, samsungpay → webview
          debugPrint('[Moyasar] Webview fallback: moyasarSource=$moyasarSource, selectedPaymentKey=$_selectedPaymentKey');
          Get.offNamed(RouteHelper.getPaymentRoute(
            OrderModel(id: int.parse(orderID), userId: Get.find<ProfileController>().userInfoModel?.id ?? 0, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant),
            _selectedPaymentKey ?? _digitalPaymentName, guestId: Get.find<AuthController>().getGuestId(), contactNumber: contactNumber,
          ));
        }
      } else if (_selectedPaymentKey != null && _selectedPaymentKey!.startsWith('moyasar_') &&
          Get.find<SplashController>().configModel?.moyasarPublishableKey != null) {
        // Moyasar payment selected via checkout_payment_list but server didn't return payment data
        final source = _selectedPaymentKey!.replaceFirst('moyasar_', '');
        // Native SDK: creditcard, stcpay, applepay (iOS only)
        // Webview: googlepay, samsungpay, applepay (Android)
        final useNativeSDK = source == 'creditcard' || source == 'stcpay'
            || (source == 'applepay' && !GetPlatform.isWeb && GetPlatform.isIOS)
            || (source == 'googlepay' && !GetPlatform.isWeb && GetPlatform.isAndroid);
        if (useNativeSDK) {
          Get.offNamed(RouteHelper.getMoyasarPaymentRoute(
            orderID, (amount * 100).toInt(), 'SAR', '', source, contactNumber, isDeliveryOrder: isDeliveryOrder,
          ));
        } else {
          // Google Pay, Samsung Pay, Apple Pay on Android → webview
          debugPrint('[Moyasar] Webview fallback (no server data): source=$source, selectedPaymentKey=$_selectedPaymentKey');
          Get.offNamed(RouteHelper.getPaymentRoute(
            OrderModel(id: int.parse(orderID), userId: Get.find<ProfileController>().userInfoModel?.id ?? 0, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant),
            _selectedPaymentKey, guestId: Get.find<AuthController>().getGuestId(), contactNumber: contactNumber,
          ));
        }
      } else if(paymentMethodIndex == 0 || paymentMethodIndex == 1) {
        // COD / Wallet — go straight to success
        final loyaltyPoint = Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0;
        double total = ((amount / 100) * loyaltyPoint);
        Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
        if(isDineInOrder) {
          Get.offNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderID), fromDineIn: true, contactNumber: contactNumber));
        } else if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.offNamed(RouteHelper.getInitialRoute());
          Future.delayed(const Duration(seconds: 2) , () => Get.dialog(Center(child: SizedBox(height: 350, width : 500, child: OrderSuccessfulDialogWidget(orderID: orderID, contactNumber: contactNumber, isDeliveryOrder: isDeliveryOrder)))));
        } else {
          Get.offAllNamed(RouteHelper.getOrderRoute());
        }
      } else {
        // Legacy digital payment fallback
        if(GetPlatform.isWeb) {
          await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&customer_id=${Get.find<ProfileController>().userInfoModel?.id ?? Get.find<AuthController>().getGuestId()}'
              '&payment_method=$digitalPaymentName&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&amount=$amount&status=';
          html.window.open(selectedUrl,"_self");
        } else{
          try {
            // Route Moyasar payments to native SDK screen
            if (digitalPaymentName == 'moyasar' &&
                Get.find<SplashController>().configModel?.moyasarPublishableKey != null) {
              Get.offNamed(RouteHelper.getMoyasarPaymentRoute(
                orderID, (amount * 100).toInt(), 'SAR', '', null, contactNumber, isDeliveryOrder: isDeliveryOrder,
              ));
            } else {
              Get.offNamed(RouteHelper.getPaymentRoute(
                OrderModel(id: int.parse(orderID), userId: Get.find<ProfileController>().userInfoModel?.id ?? 0, orderAmount: amount, restaurant: Get.find<RestaurantController>().restaurant),
                digitalPaymentName, guestId: Get.find<AuthController>().getGuestId(), contactNumber: contactNumber,
              ));
            }
          } catch(e) {
            debugPrint('Payment navigation error: $e');
          }
        }
      }
      clearPrevData();
      updateTips(0);
      Get.find<CouponController>().removeCouponData(false);
    }else {
      showCustomSnackBar(message);
    }
  }

  /// Store order body + metadata before navigating to payment screen (pay-first flow)
  void setPendingOrderData({
    required PlaceOrderBodyModel placeOrderBody,
    required double total,
    required bool fromCart,
    String? contactNumber,
    bool isDeliveryOrder = false,
  }) {
    _pendingPlaceOrderBody = placeOrderBody;
    _pendingTotal = total;
    _pendingFromCart = fromCart;
    _pendingContactNumber = contactNumber;
    _pendingIsDeliveryOrder = isDeliveryOrder;
  }

  /// Clean up pending order data after success or cancel
  void clearPendingOrderData() {
    _pendingPlaceOrderBody = null;
    _pendingTotal = 0;
    _pendingFromCart = false;
    _pendingContactNumber = null;
    _pendingIsDeliveryOrder = false;
  }

  /// Place order after payment succeeds (pay-first flow).
  /// Attaches payment proof to stored body, calls placeOrder API.
  /// Returns the order ID on success, empty string on failure.
  Future<String> placeOrderAfterPayment({String? moyasarPaymentId, String? webviewSessionId}) async {
    if (_pendingPlaceOrderBody == null) return '';

    // Attach payment proof
    if (moyasarPaymentId != null) {
      _pendingPlaceOrderBody!.moyasarPaymentId = moyasarPaymentId;
    }
    if (webviewSessionId != null) {
      _pendingPlaceOrderBody!.paymentSessionId = webviewSessionId;
    }

    _isLoading = true;
    update();

    Response response = await checkoutServiceInterface.placeOrder(_pendingPlaceOrderBody!, prescriptionImage: _prescriptionImage);
    _isLoading = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      String orderID = '';
      var data = response.body['data'];
      if (data != null && data['id'] != null) {
        orderID = data['id'].toString();
      } else {
        orderID = response.body['order_id']?.toString() ?? '';
      }

      noteController.clear();
      clearPrescriptionImage();

      // Send notification
      if (orderID.isNotEmpty && orderID != 'null') {
        sendOrderNotification(orderID);
      }

      // Save loyalty points
      final loyaltyPoint = Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0;
      double loyaltyTotal = ((_pendingTotal / 100) * loyaltyPoint);
      Get.find<LoyaltyController>().saveEarningPoint(loyaltyTotal.toStringAsFixed(0));

      // Refresh orders + clear cart
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      if (_pendingFromCart) {
        Get.find<CartController>().clearCartList();
      }

      // Auto-cancel old order if edit-order flow
      final editingId = Get.find<CartController>().editingOrderId;
      if (editingId != null) {
        Get.find<OrderController>().cancelOrderSilently(editingId);
        Get.find<CartController>().clearEditingOrderId();
      }

      clearPrevData();
      updateTips(0);
      Get.find<CouponController>().removeCouponData(false);

      // Navigate to success
      Get.offAllNamed(RouteHelper.getOrderSuccessRoute(
        orderID, 'success', _pendingTotal, _pendingContactNumber,
        isDeliveryOrder: _pendingIsDeliveryOrder,
      ));

      clearPendingOrderData();
      update();
      return orderID;
    } else {
      // Order creation failed — payment already captured
      String errorMsg = response.body?['message'] ?? response.statusText ?? 'order_creation_failed_after_payment'.tr;
      showCustomSnackBar(errorMsg);
      update();
      return '';
    }
  }

  /// Initialize a payment session for non-native digital payments.
  /// Returns the full response data map on success, null on failure.
  Future<Map<String, dynamic>?> initializePaymentSession({
    required String paymentMethod,
    required double amount,
    required int restaurantId,
  }) async {
    _isLoading = true;
    update();

    Response response = await checkoutServiceInterface.initializePaymentSession({
      'payment_method': paymentMethod,
      'amount': amount,
      'restaurant_id': restaurantId,
    });

    _isLoading = false;
    update();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.body['data'] ?? response.body;
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    showCustomSnackBar('payment_initialization_failed'.tr);
    return null;
  }

  void clearPrevData() {
    _distance = null;
    //_addressIndex = 0;
    _paymentMethodIndex = -1;
    _selectedDateSlot = 0;
    _selectedTimeSlot = 0;
    _subscriptionOrder = false;
    _selectedDays = [null];
    _subscriptionType = 'daily';
    _subscriptionRange = null;
    _isDmTipSave = false;
    _selectedPaymentKey = null;
    _selectedPaymentItem = null;
    clearPendingOrderData();
  }

  void toggleDmTipSave() {
    _isDmTipSave = !_isDmTipSave;
    update();
  }

  Future<bool> updateOfflineInfo(String data) async {
    _isLoadingUpdate = true;
    update();
    bool success = await checkoutServiceInterface.updateOfflineInfo(data, Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    if (success) {
      _isLoadingUpdate = false;
    }
    update();
    return success;
  }

  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data}) async {
    _isLoading = true;
    update();
    bool success = await checkoutServiceInterface.checkRestaurantValidation(data: data, guestId: Get.find<AuthController>().isLoggedIn() ? null : Get.find<AuthController>().getGuestId());
    _isLoading = false;
    update();
    return success;
  }

  void saveDmTipIndex(String i){
    checkoutServiceInterface.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return checkoutServiceInterface.getDmTipIndex();
  }

  Future<void> getOrderTax(PlaceOrderBodyModel placeOrderBody) async {
    Response response = await checkoutServiceInterface.getOrderTax(placeOrderBody);
    if(response.statusCode == 200) {
      _isFirstTime = false;
      _orderTax = double.tryParse(response.body['tax_amount'].toString()) ?? 0.0;
      _taxIncluded = response.body['tax_included'];
    } else {
      _isFirstTime = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

}