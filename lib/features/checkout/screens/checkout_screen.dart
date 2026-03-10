import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/checkout/widgets/bottom_section_widget.dart';
import 'package:mnjood/features/checkout/widgets/checkout_screen_shimmer_view.dart';
import 'package:mnjood/features/checkout/widgets/guest_login_bottom_sheet.dart';
import 'package:mnjood/features/checkout/widgets/order_place_button.dart';
import 'package:mnjood/features/checkout/widgets/top_section_widget.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/location/domain/models/zone_response_model.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/address/controllers/address_controller.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/features/splash/domain/models/config_model.dart';
import 'package:mnjood/helper/address_helper.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/custom_validator.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/footer_view_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/not_logged_in_screen.dart';
import 'package:mnjood/common/widgets/web_page_title_widget.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final bool fromCart;
  final bool fromDineInPage;
  final bool isPrescriptionOnly;
  const CheckoutScreen({super.key, required this.fromCart, required this.cartList, this.fromDineInPage = false, this.isPrescriptionOnly = false});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  double? taxPercent = 0;
  bool? _isCashOnDeliveryActive;
  bool? _isDigitalPaymentActive;
  bool _isOfflinePaymentActive = false;
  bool _isWalletActive = false;
  List<CartModel>? _cartList;
  double? _payableAmount = 0;
  String _deliveryChargeForView = '';

  List<AddressModel> address = [];
  bool firstTime = true;
  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();
  final tooltipController3 = JustTheController();
  final loginTooltipController = JustTheController();
  final serviceFeeTooltipController = JustTheController();
  final deliveryFeeTooltipController = JustTheController();

  final ExpansibleController expansionTileController = ExpansibleController();

  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();

  final TextEditingController estimateArrivalDateController = TextEditingController();
  final TextEditingController estimateArrivalTimeController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  final ScrollController deliveryOptionScrollController = ScrollController();

  double badWeatherChargeForToolTip = 0;
  double extraChargeForToolTip = 0;
  bool _calledOrderTax = false;

  @override
  void initState() {
    super.initState();

    // Initialize payment values synchronously from config BEFORE first build
    final config = Get.find<SplashController>().configModel;
    _isCashOnDeliveryActive = config?.cashOnDelivery ?? true; // Default to true
    _isDigitalPaymentActive = config?.digitalPayment ?? false;
    _isOfflinePaymentActive = config?.offlinePaymentStatus ?? false;
    _isWalletActive = config?.customerWalletStatus ?? false;

    // Force enable COD for prescription-only orders
    if (widget.isPrescriptionOnly || (!(_isCashOnDeliveryActive ?? false) && !(_isDigitalPaymentActive ?? false))) {
      _isCashOnDeliveryActive = true;
    }

    print('=== CHECKOUT initState PAYMENT ===');
    print('COD: $_isCashOnDeliveryActive, Digital: $_isDigitalPaymentActive, Prescription: ${widget.isPrescriptionOnly}');

    initCall();
  }

  Future<void> initCall() async {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    CheckoutController checkoutController = Get.find<CheckoutController>();

    // Set prescription-only mode from widget parameter if passed
    if (widget.isPrescriptionOnly) {
      checkoutController.setPrescriptionOnlyMode(true);
    }

    final savedAddress = AddressHelper.getAddressFromSharedPref();
    checkoutController.streetNumberController.text = savedAddress?.road ?? '';
    checkoutController.houseController.text = savedAddress?.house ?? '';
    checkoutController.floorController.text = savedAddress?.floor ?? '';
    checkoutController.couponController.text = '';

    checkoutController.clearPrevData();
    checkoutController.getDmTipMostTapped();
    checkoutController.setPreferenceTimeForView('', false, isUpdate: false);
    checkoutController.setCustomDate(null, false, canUpdate: false);

    checkoutController.getOfflineMethodList();
    checkoutController.initDineInSetup();
    checkoutController.setExchangeAmount(0);

    if (savedAddress?.latitude != null && savedAddress?.longitude != null) {
      Get.find<LocationController>().getZone(
        savedAddress!.latitude,
        savedAddress.longitude, false, updateInAddress: true,
      );
    }

    _cartList = [];

    await Get.find<CartController>().getCartDataOnline();
    if (widget.fromCart) {
      _cartList?.addAll(Get.find<CartController>().cartList);
    } else if (widget.cartList != null) {
      _cartList?.addAll(widget.cartList!);
    }

    if(isLoggedIn){
      if(Get.find<ProfileController>().userInfoModel == null && Get.find<ProfileController>().userInfoModel?.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }

      if(Get.find<AddressController>().addressList == null) {
        Get.find<AddressController>().getAddressList(canInsertAddress: true);
      }
    }

    final firstCartItem = _cartList?.isNotEmpty == true ? _cartList![0] : null;
    final product = firstCartItem?.product;
    final businessType = product?.businessType;

    // API uses restaurant_id for all vendor types (restaurant, pharmacy, supermarket)
    // The businessType getter correctly identifies the type from vendor_type field
    final vendorId = product?.restaurantId;

    if (vendorId != null) {
      checkoutController.setRestaurantDetails(restaurantId: vendorId, businessType: businessType);
      checkoutController.initCheckoutData(vendorId, businessType: businessType);
    } else if (checkoutController.isPrescriptionOnlyOrder && checkoutController.prescriptionRestaurantId != null) {
      // Prescription-only order - use prescription restaurant ID
      checkoutController.initCheckoutData(checkoutController.prescriptionRestaurantId!, businessType: 'pharmacy');
    }


    Get.find<CouponController>().setCoupon('', isUpdate: false);

    checkoutController.stopLoader(isUpdate: false);
    checkoutController.updateTimeSlot(0, false, notify: false);

    // Set COD as default payment method if enabled
    if(_isCashOnDeliveryActive == true){
      checkoutController.setPaymentMethod(0, willUpdate: false);
    }

    checkoutController.updateTips(
      checkoutController.getDmTipIndex().isNotEmpty ? int.parse(checkoutController.getDmTipIndex()) : 0, notify: false,
    );
    checkoutController.tipController.text = checkoutController.selectedTips != -1 ? AppConstants.tips[checkoutController.selectedTips] : '';

    setSinglePaymentActive();

    Future.delayed(const Duration(milliseconds: 500), () {
      // Null-safe check for homeDelivery and takeAway config
      final configModel = Get.find<SplashController>().configModel;
      if(configModel != null && !(configModel.homeDelivery ?? true) && (configModel.takeAway ?? false)) {
        checkoutController.setOrderType('take_away', notify: true);
      }

      if(checkoutController.isPartialPay){
        checkoutController.changePartialPayment(isUpdate: false);
      }

      if(widget.fromDineInPage) {
        _selectDineIn();
      }
    });

    if(AuthHelper.isLoggedIn()) {
      String phone = await _splitPhoneNumber(Get.find<ProfileController>().userInfoModel?.userInfo?.phone ?? '');

      guestContactPersonNameController.text = '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.lName ?? ''}';
      guestContactPersonNumberController.text = phone;
      guestEmailController.text = Get.find<ProfileController>().userInfoModel?.userInfo?.email ?? '';
    }

  }

  Future<void> _selectDineIn() async {

    Future.delayed(Duration(milliseconds: 800), () {
      Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
      Future.delayed(Duration(milliseconds: 500), () {
        if(Get.find<CheckoutController>().restaurant != null && Get.find<CheckoutController>().distance != null) {
          Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
          _animateDeliverySection();
        } else {
          Future.delayed(Duration(seconds: 3), () {
            Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
            _animateDeliverySection();
          });
        }
      });
    });

  }

  void _animateDeliverySection() {
    if(deliveryOptionScrollController.hasClients) {
      deliveryOptionScrollController.animateTo(
        deliveryOptionScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode = '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }

  void setSinglePaymentActive() {
    // Null-safe access to config model and payment methods
    final configModel = Get.find<SplashController>().configModel;
    if (configModel == null) return;

    final activePaymentMethodList = configModel.activePaymentMethodList;
    if (activePaymentMethodList == null || activePaymentMethodList.isEmpty) return;

    if(_isCashOnDeliveryActive != true &&
       _isDigitalPaymentActive == true &&
       activePaymentMethodList.length == 1 &&
       !_isWalletActive) {
      Get.find<CheckoutController>().setPaymentMethod(2, willUpdate: false);
      if (activePaymentMethodList[0].getWay != null) {
        Get.find<CheckoutController>().changeDigitalPaymentName(activePaymentMethodList[0].getWay!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() && (Get.find<SplashController>().configModel?.guestCheckoutStatus ?? false);
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isGuestLogIn = AuthHelper.isGuestLoggedIn();
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF7F7F7) : null,
      appBar: CustomAppBarWidget(title: 'checkout'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: guestCheckoutPermission || AuthHelper.isLoggedIn() ? GetBuilder<CheckoutController>(builder: (checkoutController) {
        return (checkoutController.distance != null && checkoutController.restaurant != null) ? GetBuilder<LocationController>(builder: (locationController) {

          bool todayClosed = false;
          bool tomorrowClosed = false;

          if(checkoutController.restaurant != null) {
            final restaurant = checkoutController.restaurant!;
            todayClosed = checkoutController.isRestaurantClosed(DateTime.now(), restaurant.active ?? true, restaurant.schedules);
            tomorrowClosed = checkoutController.isRestaurantClosed(DateTime.now().add(const Duration(days: 1)), restaurant.active ?? true, restaurant.schedules);
            taxPercent = restaurant.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            bool showTips = checkoutController.orderType != 'take_away' && (Get.find<SplashController>().configModel?.dmTipsStatus ?? 0) == 1 && !checkoutController.subscriptionOrder;
            double deliveryCharge = -1;
            double charge = -1;
            double? maxCodOrderAmount;
            if(checkoutController.restaurant != null && checkoutController.distance != null && checkoutController.distance != -1 ) {

              deliveryCharge = _getDeliveryCharge(restaurant: checkoutController.restaurant, checkoutController: checkoutController, returnDeliveryCharge: true)!;
              charge = _getDeliveryCharge(restaurant: checkoutController.restaurant, checkoutController: checkoutController, returnDeliveryCharge: false)!;
              maxCodOrderAmount = _getDeliveryCharge(restaurant: checkoutController.restaurant, checkoutController: checkoutController, returnMaxCodOrderAmount: true);

              if(checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in') {
                // Use actual calculated delivery charge to determine if free
                _deliveryChargeForView = deliveryCharge == -1 ? 'calculating'.tr
                    : deliveryCharge == 0 ? 'free'.tr
                    : PriceConverter.convertPrice(deliveryCharge);
              }
            }

            double price = _cartList != null ? _calculatePrice(_cartList) : 0;
            double addOnsPrice = _cartList != null ? _calculateAddonsPrice(_cartList) : 0;

            double? discount = _calculateDiscountPrice(cartList: _cartList, restaurant: checkoutController.restaurant, price: price, addOns: addOnsPrice);

            double? couponDiscount = PriceConverter.toFixed(couponController.discount ?? 0);

            double subTotal = _calculateSubTotal(price, addOnsPrice);

            double referralDiscount = _calculateReferralDiscount(subTotal, discount, couponDiscount, checkoutController.subscriptionOrder);

            double orderAmount = _calculateOrderAmount(price, addOnsPrice, discount, couponDiscount, referralDiscount);

            Future.delayed(const Duration(milliseconds: 100), () {
              if(checkoutController.isFirstTime || ((couponController.discount ?? 0) > 0 && !checkoutController.isFirstTime && !_calledOrderTax)){
                if((couponController.discount ?? 0) > 0){
                  _calledOrderTax = true;
                }
                List<OnlineCart> carts = [];
                final cartList = _cartList;
                // Allow prescription-only orders to proceed with empty cart
                final isPrescriptionOnly = checkoutController.isPrescriptionOnlyOrder;
                if ((cartList == null || cartList.isEmpty) && !isPrescriptionOnly) return;
                for (int index = 0; index < (cartList?.length ?? 0); index++) {
                  CartModel cart = cartList![index];
                  List<int?> addOnIdList = [];
                  List<int?> addOnQtyList = [];
                  List<OrderVariation> variations = [];
                  List<int?> optionIds = [];
                  // Null-safe iteration over addOnIds
                  if (cart.addOnIds != null) {
                    for (var addOn in cart.addOnIds!) {
                      addOnIdList.add(addOn.id);
                      addOnQtyList.add(addOn.quantity);
                    }
                  }
                  // Null-safe iteration over variations
                  final productVariations = cart.product?.variations;
                  final cartVariations = cart.variations;
                  if(productVariations != null && productVariations.isNotEmpty && cartVariations != null){
                    for(int i=0; i<productVariations.length; i++) {
                      if(i < cartVariations.length && cartVariations[i].contains(true)) {
                        variations.add(OrderVariation(name: productVariations[i].name, values: OrderVariationValue(label: [])));
                        final variationValues = productVariations[i].variationValues;
                        if (variationValues != null) {
                          for(int j=0; j<variationValues.length; j++) {
                            if(j < cartVariations[i].length && cartVariations[i][j] == true) {
                              variations[variations.length-1].values?.label?.add(variationValues[j].level);
                              if(variationValues[j].optionId != null) {
                                optionIds.add(variationValues[j].optionId);
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  carts.add(OnlineCart(
                    cart.id, cart.product?.id, (cart.isCampaign ?? false) ? cart.product?.id : null,
                    cart.discountedPrice.toString(), variations,
                    cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Food',
                    variationOptionIds: optionIds, itemType: ! widget.fromCart ? "AppModelsItemCampaign" : null,
                    vendorId: cart.product?.restaurantId, vendorType: 'restaurant',
                  ));
                }

                final couponCtrl = Get.find<CouponController>();
                final subscriptionRange = checkoutController.subscriptionRange;
                PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                  cart: carts, couponDiscountAmount: couponCtrl.discount, distance: checkoutController.distance,
                  couponDiscountTitle: (couponCtrl.discount ?? 0) > 0 ? couponCtrl.coupon?.title : null,
                  orderAmount: subTotal, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
                  paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                      : checkoutController.paymentMethodIndex == 1 ? 'wallet'
                      : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
                  couponCode: ((couponCtrl.discount ?? 0) > 0 || (couponCtrl.coupon != null
                      && couponCtrl.freeDelivery)) ? couponCtrl.coupon?.code : null,
                  restaurantId: _cartList?[0].product?.restaurantId,
                  discountAmount: discount, cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                  dmTips: (checkoutController.orderType == 'take_away' || checkoutController.subscriptionOrder || checkoutController.selectedTips == 0) ? '' : checkoutController.tips.toString(),
                  subscriptionOrder: checkoutController.subscriptionOrder ? '1' : '0',
                  subscriptionStartAt: (checkoutController.subscriptionOrder && subscriptionRange != null) ? DateConverter.dateToDateAndTime(subscriptionRange.start) : '',
                  subscriptionEndAt: (checkoutController.subscriptionOrder && subscriptionRange != null) ? DateConverter.dateToDateAndTime(subscriptionRange.end) : '',
                  unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                  deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
                  partialPayment: checkoutController.isPartialPay ? 1 : 0,
                  guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
                  extraPackagingAmount: Get.find<CartController>().needExtraPackage ? (checkoutController.restaurant?.extraPackagingAmount ?? 0) : 0,
                  isBuyNow: widget.fromCart ? 0 : 1,
                );

                checkoutController.getOrderTax(placeOrderBody);
              }
            });

            if(isGuestLogIn && checkoutController.isFirstTime){
              Future.delayed(const Duration(milliseconds: 300), () {
                if(isDesktop){
                  Get.dialog(
                    Dialog(child: GuestLoginBottomSheet(callBack: () => initCall())),
                  );
                }else{
                  showCustomBottomSheet(child: GuestLoginBottomSheet(callBack: () => initCall()));
                }
              });
            }

            bool restaurantSubscriptionActive = false;
            int subscriptionQty = checkoutController.subscriptionOrder ? 0 : 1;
            double additionalCharge = 0;
            final selectedPaymentItem = checkoutController.selectedPaymentItem;
            if (selectedPaymentItem != null && selectedPaymentItem.chargePercentage > 0) {
              additionalCharge = orderAmount * (selectedPaymentItem.chargePercentage / 100);
            } else if (selectedPaymentItem == null && (Get.find<SplashController>().configModel?.additionalChargeStatus ?? false)) {
              if (Get.find<SplashController>().configModel?.additionalChargeType == 'percent') {
                additionalCharge = orderAmount * ((Get.find<SplashController>().configModel?.additionCharge ?? 0) / 100);
              } else {
                additionalCharge = Get.find<SplashController>().configModel?.additionCharge ?? 0;
              }
            }

            if(checkoutController.restaurant != null) {

              ConfigModel? configModel = Get.find<SplashController>().configModel;

              restaurantSubscriptionActive = (checkoutController.restaurant?.orderSubscriptionActive ?? false) && widget.fromCart;

              subscriptionQty = _getSubscriptionQty(checkoutController: checkoutController, restaurantSubscriptionActive: restaurantSubscriptionActive);

              // Only set delivery charge to 0 for take_away/dine_in, admin free delivery settings, or coupon free delivery
              // Note: restaurant.freeDelivery check removed as V3 API may return incorrect value
              // Free delivery based on restaurant settings is already handled in _getDeliveryCharge function

              // DEBUG: trace which condition zeros the delivery charge
              print('DEBUG delivery: orderType=${checkoutController.orderType}, '
                  'adminFreeDelivery.status=${configModel?.adminFreeDelivery?.status}, '
                  'adminFreeDelivery.type=${configModel?.adminFreeDelivery?.type}, '
                  'freeDeliveryOver=${configModel?.adminFreeDelivery?.freeDeliveryOver}, '
                  'freeDeliveryDistance=${configModel?.adminFreeDelivery?.freeDeliveryDistance}, '
                  'orderAmount=$orderAmount, distance=${checkoutController.distance}, '
                  'couponFreeDelivery=${couponController.freeDelivery}, '
                  'deliveryChargeBefore=$deliveryCharge');

              if (checkoutController.orderType == 'take_away' || checkoutController.orderType == 'dine_in'
                  || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null && configModel?.adminFreeDelivery?.type == 'free_delivery_to_all_store'))
                  || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null &&  configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && ((configModel?.adminFreeDelivery?.freeDeliveryOver ?? 0) > 0 && orderAmount >= (configModel?.adminFreeDelivery?.freeDeliveryOver ?? 0)))
                  || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null &&  configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && ((configModel?.adminFreeDelivery?.freeDeliveryDistance ?? 0) > 0 && (configModel?.adminFreeDelivery?.freeDeliveryDistance ?? 0) >= (checkoutController.distance ?? 0)))
                  || couponController.freeDelivery) {
                deliveryCharge = 0;
                print('DEBUG delivery: ZEROED by checkout_screen condition');
              }
            }

            deliveryCharge = PriceConverter.toFixed(deliveryCharge);

            double extraPackagingCharge = _calculateExtraPackagingCharge(checkoutController);

            double total = _calculateTotal(subTotal, deliveryCharge, discount, couponDiscount, (checkoutController.taxIncluded == 1), checkoutController.orderTax ?? 0, showTips, checkoutController.tips, additionalCharge, extraPackagingCharge);

            total = total - referralDiscount;

            checkoutController.setTotalAmount(total - (checkoutController.isPartialPay ? Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0 : 0));

            // Cashback disabled for now
            // final cashBackOfferList = Get.find<HomeController>().cashBackOfferList;
            // if(_payableAmount != checkoutController.viewTotalPrice && checkoutController.distance != null && isLoggedIn && cashBackOfferList != null && cashBackOfferList.isNotEmpty) {
            //   _payableAmount = checkoutController.viewTotalPrice;
            //   showCashBackSnackBar();
            // }

            if(isLoggedIn && firstTime && (price > 0.0)){
              final firstCartRestaurantId = _cartList?.isNotEmpty == true ? _cartList![0].product?.restaurantId : null;
              if (firstCartRestaurantId != null) {
                couponController.getCouponList(orderRestaurantId: firstCartRestaurantId, orderAmount: price);
              }
              firstTime = false;
            }

            return Column(
              children: [
                WebScreenTitleWidget(title: 'checkout'.tr),

                Expanded(child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: FooterViewWidget(
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                            Expanded(flex: 6, child: TopSectionWidget(
                              charge: charge, deliveryCharge: deliveryCharge,
                              locationController: locationController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed,
                              price: price, discount: discount, addOns: addOnsPrice, restaurantSubscriptionActive: restaurantSubscriptionActive,
                              showTips: showTips, isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
                              isWalletActive: _isWalletActive, fromCart: widget.fromCart, total: total, tooltipController3: tooltipController3, tooltipController2: tooltipController2,
                              guestNameTextEditingController: guestContactPersonNameController, guestNumberTextEditingController: guestContactPersonNumberController,
                              guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                              guestNumberNode: guestNumberNode, isOfflinePaymentActive: _isOfflinePaymentActive, loginTooltipController: loginTooltipController,
                              callBack: () => initCall(), deliveryChargeForView: _deliveryChargeForView, deliveryFeeTooltipController: deliveryFeeTooltipController,
                              badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip,
                              deliveryOptionScrollController: deliveryOptionScrollController,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeLarge),

                            Expanded(
                              flex: 4,
                              child: BottomSectionWidget(
                                isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, isDigitalPaymentActive: _isDigitalPaymentActive ?? false, isWalletActive: _isWalletActive,
                                total: total, subTotal: subTotal, discount: discount, couponController: couponController,
                                taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0, deliveryCharge: deliveryCharge, checkoutController: checkoutController, locationController: locationController,
                                todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount,
                                subscriptionQty: subscriptionQty, taxPercent: taxPercent ?? 0, fromCart: widget.fromCart, cartList: _cartList,
                                price: price, addOns: addOnsPrice, charge: charge,
                                guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                                guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                                guestNameTextEditingController: guestContactPersonNameController, isOfflinePaymentActive: _isOfflinePaymentActive,
                                expansionTileController: expansionTileController, serviceFeeTooltipController: serviceFeeTooltipController, referralDiscount: referralDiscount,
                                extraPackagingAmount: extraPackagingCharge, additionalCharge: additionalCharge,
                              ),
                            )
                          ]),
                        ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          TopSectionWidget(
                            charge: charge, deliveryCharge: deliveryCharge,
                            locationController: locationController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed,
                            price: price, discount: discount, addOns: addOnsPrice, restaurantSubscriptionActive: restaurantSubscriptionActive,
                            showTips: showTips, isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
                            isWalletActive: _isWalletActive, fromCart: widget.fromCart, total: total, tooltipController3: tooltipController3, tooltipController2: tooltipController2,
                            guestNameTextEditingController: guestContactPersonNameController, guestNumberTextEditingController: guestContactPersonNumberController,
                            guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                            guestNumberNode: guestNumberNode, isOfflinePaymentActive: _isOfflinePaymentActive, loginTooltipController: loginTooltipController,
                            callBack: () => initCall(), deliveryChargeForView: _deliveryChargeForView, deliveryFeeTooltipController: deliveryFeeTooltipController,
                            badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip,
                            deliveryOptionScrollController: deliveryOptionScrollController,
                          ),

                          BottomSectionWidget(
                            isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, isDigitalPaymentActive: _isDigitalPaymentActive ?? false, isWalletActive: _isWalletActive,
                            total: total, subTotal: subTotal, discount: discount, couponController: couponController,
                            taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0, deliveryCharge: deliveryCharge, checkoutController: checkoutController, locationController: locationController,
                            todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount,
                            subscriptionQty: subscriptionQty, taxPercent: taxPercent ?? 0, fromCart: widget.fromCart, cartList: _cartList ?? [],
                            price: price, addOns: addOnsPrice, charge: charge,
                            guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                            guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                            guestNameTextEditingController: guestContactPersonNameController, isOfflinePaymentActive: _isOfflinePaymentActive,
                            expansionTileController: expansionTileController, serviceFeeTooltipController: serviceFeeTooltipController, referralDiscount: referralDiscount,
                            extraPackagingAmount: extraPackagingCharge, additionalCharge: additionalCharge,
                          ),
                        ]),
                      ),
                    ),
                  ),
                )),

                ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                        child: Row(children: [
                          Text(
                            'total_amount'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                          ),

                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          (checkoutController.taxIncluded == 1) ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('vat_tax_inc'.tr, style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                            )),
                          ) : const SizedBox(),

                          const Expanded(child: SizedBox()),

                          PriceConverter.convertAnimationPrice(
                            total * (checkoutController.subscriptionOrder ? (subscriptionQty == 0 ? 1 : subscriptionQty) : 1),
                            textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                          ),
                        ]),
                      ),

                      OrderPlaceButton(
                        checkoutController: checkoutController, locationController: locationController,
                        todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, deliveryCharge: deliveryCharge,
                        discount: discount, total: total, maxCodOrderAmount: maxCodOrderAmount, subscriptionQty: subscriptionQty,
                        cartList: _cartList ?? [], isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
                        isWalletActive: _isWalletActive, fromCart: widget.fromCart, guestNumberTextEditingController: guestContactPersonNumberController,
                        guestNumberNode: guestNumberNode, guestNameTextEditingController: guestContactPersonNameController,
                        guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                        isOfflinePaymentActive: _isOfflinePaymentActive, subTotal: subTotal, couponController: couponController,
                        taxPercent: taxPercent ?? 0, extraPackagingAmount: extraPackagingCharge,
                        taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0,
                      ),
                    ],
                  ),
                ),

              ],
            );
          });
        }) : const CheckoutScreenShimmerView();
      }) : NotLoggedInScreen(callBack: (value) {
        initCall();
        setState(() {});
      }),
    );
  }

  double? _getDeliveryCharge({required Restaurant? restaurant, required CheckoutController checkoutController, bool returnDeliveryCharge = true, bool returnMaxCodOrderAmount = false}) {

    ConfigModel? configModel = Get.find<SplashController>().configModel;

    final savedAddress = AddressHelper.getAddressFromSharedPref();
    final zoneDataList = savedAddress?.zoneData;
    if (restaurant == null || zoneDataList == null || zoneDataList.isEmpty) {
      return returnMaxCodOrderAmount ? null : 0;
    }

    ZoneData zoneData = zoneDataList.firstWhere(
      (data) => data.id == restaurant.zoneId,
      orElse: () => zoneDataList.first,
    );
    double perKmCharge = restaurant.selfDeliverySystem == 1 ? (restaurant.perKmShippingCharge ?? 0)
        : zoneData.perKmShippingCharge ?? 0;

    double minimumCharge = restaurant.selfDeliverySystem == 1 ? (restaurant.minimumShippingCharge ?? 0)
        :  zoneData.minimumShippingCharge ?? 0;

    double? maximumCharge = restaurant.selfDeliverySystem == 1 ? restaurant.maximumShippingCharge
        : zoneData.maximumShippingCharge;

    final distance = checkoutController.distance ?? 0;
    double deliveryCharge = distance * perKmCharge;
    double charge = distance * perKmCharge;

    if(deliveryCharge < minimumCharge) {
      deliveryCharge = minimumCharge;
      charge = minimumCharge;
    }

    if(restaurant.selfDeliverySystem == 0 && checkoutController.extraCharge != null){
      extraChargeForToolTip = checkoutController.extraCharge ?? 0;
      deliveryCharge = deliveryCharge + (checkoutController.extraCharge ?? 0);
      charge = charge + (checkoutController.extraCharge ?? 0);
    }

    if(maximumCharge != null && deliveryCharge > maximumCharge){
      deliveryCharge = maximumCharge;
      charge = maximumCharge;
    }

    if(restaurant.selfDeliverySystem == 0 && zoneData.increasedDeliveryFeeStatus == 1){
      final increasedFee = zoneData.increasedDeliveryFee ?? 0;
      badWeatherChargeForToolTip = (deliveryCharge * (increasedFee/100));
      deliveryCharge = deliveryCharge + (deliveryCharge * (increasedFee/100));
      charge = charge + charge * (increasedFee/100);
    }

    if(restaurant.selfDeliverySystem == 0 && (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null &&  configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && ((configModel?.adminFreeDelivery?.freeDeliveryDistance ?? 0) > 0 && (configModel?.adminFreeDelivery?.freeDeliveryDistance ?? 0) >= (checkoutController.distance ?? 0)))){
      deliveryCharge = 0;
      charge = 0;
      print('DEBUG _getDeliveryCharge: ZEROED by adminFreeDelivery distance criteria (freeDeliveryDistance=${configModel?.adminFreeDelivery?.freeDeliveryDistance}, userDistance=${checkoutController.distance})');
    }

/*    if(restaurant.selfDeliverySystem == 0 && Get.find<SplashController>().configModel!.freeDeliveryDistance != null && Get.find<SplashController>().configModel!.freeDeliveryDistance! >= checkoutController.distance!){
      deliveryCharge = 0;
      charge = 0;
    }*/

    if(restaurant.selfDeliverySystem == 1 && (restaurant.freeDeliveryDistanceStatus ?? false) && (restaurant.freeDeliveryDistanceValue ?? 0) >= distance){
      deliveryCharge = 0;
      charge = 0;
      print('DEBUG _getDeliveryCharge: ZEROED by restaurant freeDeliveryDistance (freeDeliveryDistanceValue=${restaurant.freeDeliveryDistanceValue}, distance=$distance)');
    }
    print('DEBUG _getDeliveryCharge: selfDeliverySystem=${restaurant.selfDeliverySystem}, perKmCharge=$perKmCharge, minCharge=$minimumCharge, maxCharge=$maximumCharge, distance=$distance, extraCharge=${checkoutController.extraCharge}, finalCharge=$deliveryCharge');

    double? maxCodOrderAmount;
    if(zoneData.maxCodOrderAmount != null) {
      maxCodOrderAmount = zoneData.maxCodOrderAmount;
    }

    if(returnMaxCodOrderAmount) {
      return maxCodOrderAmount;
    } else {
      if(returnDeliveryCharge) {
        return deliveryCharge;
      }else {
        return charge;
      }
    }

  }

  double _calculatePrice(List<CartModel>? cartList) {
    double price = 0;
    double variationPrice = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        final productPrice = cartModel.product?.price ?? 0;
        final quantity = cartModel.quantity ?? 1;
        price = price + (productPrice * quantity);

        // Null-safe variation price calculation
        final variations = cartModel.product?.variations;
        final cartVariations = cartModel.variations;
        if (variations != null && cartVariations != null) {
          for(int index = 0; index < variations.length; index++) {
            final variationValues = variations[index].variationValues;
            if (variationValues != null && index < cartVariations.length) {
              for(int i=0; i < variationValues.length; i++) {
                if(i < cartVariations[index].length && cartVariations[index][i] == true) {
                  variationPrice += ((variationValues[i].optionPrice ?? 0) * quantity);
                }
              }
            }
          }
        }
      }
    }
    return PriceConverter.toFixed(price + variationPrice);
  }

  double _calculateAddonsPrice(List<CartModel>? cartList) {
    double addonPrice = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        List<AddOns> addOnList = [];
        final addOnIds = cartModel.addOnIds;
        final productAddOns = cartModel.product?.addOns;
        if (addOnIds != null && productAddOns != null) {
          for (var addOnId in addOnIds) {
            for (AddOns addOns in productAddOns) {
              if (addOns.id == addOnId.id) {
                addOnList.add(addOns);
                break;
              }
            }
          }
          for (int index = 0; index < addOnList.length; index++) {
            if (index < addOnIds.length) {
              addonPrice = addonPrice + ((addOnList[index].price ?? 0) * (addOnIds[index].quantity ?? 1));
            }
          }
        }
      }
    }
    return PriceConverter.toFixed(addonPrice);
  }

  double _calculateDiscountPrice({List<CartModel>? cartList, Restaurant? restaurant, required double price, required double addOns}) {
    double? discount = 0;
    if(restaurant != null && cartList != null) {
      final restaurantDiscount = restaurant.discount;
      final hasRestaurantDiscount = restaurantDiscount != null
          && DateConverter.isAvailable(restaurantDiscount.startTime, restaurantDiscount.endTime);

      for (var cartModel in cartList) {
        final productPrice = cartModel.product?.price ?? 0;
        final quantity = cartModel.quantity ?? 1;

        double? dis = hasRestaurantDiscount
          ? restaurantDiscount.discount : cartModel.product?.discount;

        String? disType = hasRestaurantDiscount
          ? 'percent' : cartModel.product?.discountType;

        double d = ((productPrice - (PriceConverter.convertWithDiscount(productPrice, dis, disType) ?? 0)) * quantity);
        discount = (discount ?? 0) + d;
        discount = discount + _calculateVariationPrice(restaurant: restaurant, cartModel: cartModel);
      }

      if (restaurantDiscount != null) {
        if ((restaurantDiscount.maxDiscount ?? 0) != 0 && (restaurantDiscount.maxDiscount ?? 0) < (discount ?? 0)) {
          discount = restaurantDiscount.maxDiscount;
        }
        if ((restaurantDiscount.minPurchase ?? 0) != 0 && (restaurantDiscount.minPurchase ?? 0) > (price + addOns)) {
          discount = 0;
        }
      }

    }
    return PriceConverter.toFixed(discount ?? 0);
  }

  double _calculateVariationPrice({required Restaurant? restaurant, required CartModel? cartModel}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(restaurant != null && cartModel != null) {
      final quantity = cartModel.quantity ?? 1;
      final restaurantDiscount = restaurant.discount;
      final hasRestaurantDiscount = restaurantDiscount != null
          && DateConverter.isAvailable(restaurantDiscount.startTime, restaurantDiscount.endTime);

      double? discount = hasRestaurantDiscount
         ? restaurantDiscount.discount : cartModel.product?.discount;

      String? discountType = hasRestaurantDiscount
        ? 'percent' : cartModel.product?.discountType;

      // Null-safe variation price calculation
      final variations = cartModel.product?.variations;
      final cartVariations = cartModel.variations;
      if (variations != null && cartVariations != null) {
        for(int index = 0; index < variations.length; index++) {
          final variationValues = variations[index].variationValues;
          if (variationValues != null && index < cartVariations.length) {
            for(int i=0; i < variationValues.length; i++) {
              if(i < cartVariations[index].length && cartVariations[index][i] == true) {
                final optionPrice = variationValues[i].optionPrice ?? 0;
                variationPrice += ((PriceConverter.convertWithDiscount(optionPrice, discount, discountType, isVariation: true) ?? 0) * quantity);
                variationDiscount += (optionPrice * quantity);
              }
            }
          }
        }
      }
    }

    return variationDiscount - variationPrice;
  }

  double _calculateSubTotal(double price, double addOnsPrice) {
    double subTotal = price + addOnsPrice;
    return PriceConverter.toFixed(subTotal);
  }

  double _calculateOrderAmount(double price, double addOnsPrice, double discount, double couponDiscount, double referralDiscount) {
    double orderAmount = (price - discount) + addOnsPrice - couponDiscount - referralDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  int _getSubscriptionQty({required CheckoutController checkoutController, required bool restaurantSubscriptionActive}) {
    int subscriptionQty = checkoutController.subscriptionOrder ? 0 : 1;
    if(restaurantSubscriptionActive){
      if(checkoutController.subscriptionOrder && checkoutController.subscriptionRange != null) {
        if(checkoutController.subscriptionType == 'weekly') {
          List<int> weekDays = [];
          for(int index=0; index<checkoutController.selectedDays.length; index++) {
            if(checkoutController.selectedDays[index] != null) {
              weekDays.add(index + 1);
            }
          }
          subscriptionQty = DateConverter.getWeekDaysCount(checkoutController.subscriptionRange!, weekDays);
        }else if(checkoutController.subscriptionType == 'monthly') {
          List<int> days = [];
          for(int index=0; index<checkoutController.selectedDays.length; index++) {
            if(checkoutController.selectedDays[index] != null) {
              days.add(index + 1);
            }
          }
          subscriptionQty = DateConverter.getMonthDaysCount(checkoutController.subscriptionRange!, days);
        }else {
          subscriptionQty = checkoutController.subscriptionRange!.duration.inDays + 1;
        }
      }
    }
    return subscriptionQty;
  }

  double _calculateTotal(
      double subTotal, double deliveryCharge, double discount, double couponDiscount,
      bool taxIncluded, double tax, bool showTips, double tips, double additionalCharge, double extraPackagingCharge) {

    double total = subTotal + deliveryCharge - discount - couponDiscount + (taxIncluded ? 0 : tax)
        + (showTips ? tips : 0) + additionalCharge + extraPackagingCharge;

    return PriceConverter.toFixed(total);
  }

  double _calculateExtraPackagingCharge(CheckoutController checkoutController) {
    final restaurant = checkoutController.restaurant;
    if (restaurant == null || checkoutController.orderType == 'dine_in') return 0;

    final isExtraPackagingActive = restaurant.isExtraPackagingActive ?? false;
    final isMandatory = restaurant.extraPackagingStatusIsMandatory ?? false;
    final needExtraPackage = Get.find<CartController>().needExtraPackage;

    if ((isExtraPackagingActive && !isMandatory && needExtraPackage) || (isExtraPackagingActive && isMandatory)) {
      return restaurant.extraPackagingAmount ?? 0;
    }
    return 0;
  }

  double _calculateReferralDiscount(double subTotal, double discount, double couponDiscount, bool isSubscriptionOrder) {
    double referralDiscount = 0;
    final userInfoModel = Get.find<ProfileController>().userInfoModel;
    if(userInfoModel != null && (userInfoModel.isValidForDiscount ?? false) && !isSubscriptionOrder) {
      final discountAmount = userInfoModel.discountAmount ?? 0;
      if (userInfoModel.discountAmountType == "percentage") {
        referralDiscount = (discountAmount / 100) * (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = discountAmount;
      }
    }
    return PriceConverter.toFixed(referralDiscount);
  }

  Future<void> showCashBackSnackBar() async {
    if (_payableAmount == null) return;
    await Get.find<HomeController>().getCashBackData(_payableAmount!);
    double? cashBackAmount = Get.find<HomeController>().cashBackData?.cashbackAmount ?? 0;
    String? cashBackType = Get.find<HomeController>().cashBackData?.cashbackType ?? '';
    String text = '${'you_will_get'.tr} ${cashBackType == 'amount' ? PriceConverter.convertPrice(cashBackAmount) : '${cashBackAmount.toStringAsFixed(0)}%'} ${'cash_back_after_completing_order'.tr}';
    if(cashBackAmount > 0) {
      showCustomSnackBar(text, isError: false);
    }
  }

}