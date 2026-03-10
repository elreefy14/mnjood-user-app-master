import 'package:mnjood/common/models/response_model.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart' as place_order_model;
import 'package:mnjood/features/checkout/domain/models/pricing_view_model.dart';
import 'package:mnjood/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:mnjood/features/coupon/controllers/coupon_controller.dart';
import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/profile/controllers/profile_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/features/splash/controllers/splash_controller.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/address/controllers/address_controller.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/auth/controllers/auth_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/helper/address_helper.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/common/widgets/custom_button_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPlaceButton extends StatelessWidget {
  final CheckoutController checkoutController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? deliveryCharge;
  final double tax;
  final double? discount;
  final double total;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final List<CartModel>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final CouponController couponController;
  final double subTotal;
  final bool taxIncluded;
  final double taxPercent;
  final double extraPackagingAmount;

  const OrderPlaceButton({
    super.key, required this.checkoutController, required this.locationController,
    required this.todayClosed, required this.tomorrowClosed, required this.orderAmount, this.deliveryCharge,
    required this.tax, this.discount, required this.total, this.maxCodOrderAmount, required this.subscriptionQty,
    required this.cartList, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.fromCart, required this.guestNameTextEditingController, required this.guestNumberTextEditingController,
    required this.guestNumberNode, required this.isOfflinePaymentActive, required this.couponController, required this.subTotal,
    required this.taxIncluded, required this.taxPercent, required this.guestEmailController, required this.guestEmailNode, required this.extraPackagingAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButtonWidget(
            buttonText: 'place_order'.tr,
            radius: Dimensions.radiusLarge,
            height: 54,
            isLoading: checkoutController.isLoading,
            onPressed: checkoutController.isDistanceLoading ? null : () async {
          DateTime scheduleStartDate = _processScheduleStartDate();
          DateTime scheduleEndDate = _processScheduleEndDate();
          bool isAvailable = _checkAvailability(scheduleStartDate, scheduleEndDate);
          bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
          bool datePicked = _isDatePicked();

          if(checkoutController.isDmTipSave && checkoutController.selectedTips != AppConstants.tips.length - 1) {
            checkoutController.saveDmTipIndex(checkoutController.selectedTips.toString());
          }
          if(!checkoutController.isDmTipSave){
            checkoutController.saveDmTipIndex('0');
          }

          if(_showsWarningMessage(context, isGuestLogIn, datePicked, isAvailable)){
            debugPrint('Warning shows');
          } else {

            AddressModel? finalAddress = _processFinalAddress(isGuestLogIn);

            // V3 API: Auto-save address to server if it has no ID (required for delivery orders)
            if (finalAddress != null && finalAddress.id == null && checkoutController.orderType == 'delivery') {
              print('DEBUG: Address has no ID, checking for existing address with same coordinates...');

              // First check if an address with the same coordinates already exists
              List<AddressModel>? existingAddresses = Get.find<AddressController>().addressList;
              AddressModel? existingAddress;
              if (existingAddresses != null && existingAddresses.isNotEmpty) {
                for (var addr in existingAddresses) {
                  if (addr.latitude == finalAddress.latitude && addr.longitude == finalAddress.longitude && addr.id != null) {
                    existingAddress = addr;
                    break;
                  }
                }
              }

              if (existingAddress != null) {
                // Use existing address instead of creating a duplicate
                print('DEBUG: Found existing address with ID: ${existingAddress.id}, reusing it');
                finalAddress = existingAddress;
              } else {
                print('DEBUG: No existing address found, saving new address to server...');

                // Normalize address_type: 'others' -> 'other' (V3 API expects singular form)
                String normalizedAddressType = finalAddress.addressType ?? 'home';
                if (normalizedAddressType == 'others') {
                  normalizedAddressType = 'other';
                }

                // Rebuild address with correct type and fill in missing contact details
                finalAddress = AddressModel(
                  id: finalAddress.id,
                  address: finalAddress.address,
                  addressType: normalizedAddressType,
                  latitude: finalAddress.latitude,
                  longitude: finalAddress.longitude,
                  zoneId: finalAddress.zoneId,
                  zoneIds: finalAddress.zoneIds,
                  zoneData: finalAddress.zoneData,
                  contactPersonName: (finalAddress.contactPersonName == null || finalAddress.contactPersonName!.isEmpty)
                      ? '${Get.find<ProfileController>().userInfoModel?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.lName ?? ''}'.trim()
                      : finalAddress.contactPersonName,
                  contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel?.phone,
                  email: finalAddress.email ?? Get.find<ProfileController>().userInfoModel?.email,
                );

                // Save address to server
                ResponseModel response = await Get.find<AddressController>().addAddress(
                  finalAddress,
                  true,  // fromCheckout
                  checkoutController.restaurant?.zoneId,
                );

                if (!response.isSuccess) {
                  showCustomSnackBar(response.message ?? 'failed_to_save_address'.tr);
                  return;
                }

                // Refresh address list to get the new address with server ID
                await Get.find<AddressController>().getAddressList();

                // Find the newly saved address by matching coordinates
                AddressModel? savedAddress;
                final addressList = Get.find<AddressController>().addressList;
                if (addressList != null && addressList.isNotEmpty) {
                  for (var addr in addressList) {
                    if (addr.latitude == finalAddress!.latitude && addr.longitude == finalAddress.longitude) {
                      savedAddress = addr;
                      break;
                    }
                  }
                }
                savedAddress ??= finalAddress;

                if (savedAddress != null && savedAddress.id != null) {
                  finalAddress = savedAddress;
                  print('DEBUG: Address saved successfully with ID: ${finalAddress.id}');
                } else {
                  showCustomSnackBar('failed_to_get_address_id'.tr);
                  return;
                }
              }
            }

            // Single vendor checkout flow
            List<place_order_model.OnlineCart> carts = cartList != null ? _generateOnlineCartList() : [];
            List<place_order_model.SubscriptionDays> days = _generateSubscriptionDays();
            PlaceOrderBodyModel placeOrderBody = _preparePlaceOrderModel(carts, scheduleStartDate, finalAddress, isGuestLogIn, days);

            if(checkoutController.paymentMethodIndex == 3){

              Map<String, dynamic> data = {
                "restaurant_id": placeOrderBody.restaurantId,
                "order_type": placeOrderBody.orderType,
                "schedule_at": placeOrderBody.scheduleAt,
                "subscription_order": placeOrderBody.subscriptionOrder,
              };

              checkoutController.checkRestaurantValidation(data: data).then((response) {
                if(response) {
                  final zoneId = checkoutController.restaurant?.zoneId ?? 0;
                  Get.toNamed(RouteHelper.getOfflinePaymentScreen(placeOrderBody: placeOrderBody, zoneId: zoneId, total: total, maxCodOrderAmount: maxCodOrderAmount,
                    fromCart: fromCart, isCodActive: isCashOnDeliveryActive,
                    pricingView: PricingViewModel(
                      subTotal: subTotal, subscriptionQty: subscriptionQty, discount: discount ?? 0, taxIncluded: taxIncluded,
                      tax: tax, deliveryCharge: deliveryCharge ?? 0, total: total, taxPercent: taxPercent,
                    ),
                  ));
                }else{
                  showCustomSnackBar('restaurant_is_closed_now'.tr);
                }
              });
            }else{
              final zoneId = checkoutController.restaurant?.zoneId ?? 0;
              bool isDigitalPayment = checkoutController.paymentMethodIndex == 2;

              if (isDigitalPayment) {
                // PAY-FIRST: store order data, route to payment
                checkoutController.setPendingOrderData(
                  placeOrderBody: placeOrderBody,
                  total: total,
                  fromCart: fromCart,
                  contactNumber: placeOrderBody.contactPersonNumber,
                  isDeliveryOrder: placeOrderBody.orderType == 'delivery',
                );

                final selectedKey = checkoutController.selectedPaymentKey;
                bool isMoyasarNative = false;
                String? moyasarSource;
                if (selectedKey != null && selectedKey.startsWith('moyasar_')) {
                  moyasarSource = selectedKey.replaceFirst('moyasar_', '');
                  isMoyasarNative = moyasarSource == 'creditcard' || moyasarSource == 'stcpay'
                      || moyasarSource == 'samsungpay'
                      || (moyasarSource == 'applepay' && !GetPlatform.isWeb && GetPlatform.isIOS)
                      || (moyasarSource == 'googlepay' && !GetPlatform.isWeb && GetPlatform.isAndroid);
                }

                if (isMoyasarNative) {
                  // Samsung Pay routes to credit card form (no native SDK widget)
                  final effectiveSource = (moyasarSource == 'samsungpay') ? 'creditcard' : moyasarSource;
                  Get.toNamed(RouteHelper.getMoyasarPaymentRoute(
                    '', // empty orderId = pay-first mode
                    (total * 100).toInt(),
                    'SAR',
                    '',
                    effectiveSource,
                    placeOrderBody.contactPersonNumber,
                    isDeliveryOrder: placeOrderBody.orderType == 'delivery',
                  ));
                } else {
                  // Non-native payments — initialize payment session first
                  checkoutController.initializePaymentSession(
                    paymentMethod: selectedKey ?? checkoutController.digitalPaymentName ?? 'digital_payment',
                    amount: total,
                    restaurantId: placeOrderBody.restaurantId ?? 0,
                  ).then((result) {
                    if (result == null) return;

                    final paymentUrl = result['payment_url']?.toString();
                    final moyasarData = result['moyasar_payment_data'];

                    if (moyasarData != null && moyasarData is Map) {
                      // Backend returned Moyasar payment data
                      final source = moyasarData['moyasar_source']?.toString();
                      final amountHalalas = (moyasarData['payment_amount_halalas'] is int)
                          ? moyasarData['payment_amount_halalas']
                          : int.tryParse(moyasarData['payment_amount_halalas']?.toString() ?? '') ?? (total * 100).toInt();
                      final currency = moyasarData['currency']?.toString() ?? 'SAR';
                      final paymentRequestId = moyasarData['payment_request_id']?.toString() ?? '';
                      final sessionId = result['session_id']?.toString() ?? '';

                      // Check if source is natively supported by Moyasar SDK
                      final isNativeSource = source == 'creditcard' || source == 'stcpay'
                          || (source == 'applepay' && !GetPlatform.isWeb && GetPlatform.isIOS)
                          || (source == 'googlepay' && !GetPlatform.isWeb && GetPlatform.isAndroid);

                      if (isNativeSource) {
                        Get.toNamed(RouteHelper.getMoyasarPaymentRoute(
                          '', // empty orderId = pay-first mode
                          amountHalalas,
                          currency,
                          paymentRequestId,
                          source,
                          placeOrderBody.contactPersonNumber,
                          isDeliveryOrder: placeOrderBody.orderType == 'delivery',
                        ));
                      } else {
                        // samsungpay, googlepay, etc. → need server webview
                        // Construct payment URL using session_id
                        final userId = Get.find<ProfileController>().userInfoModel?.id ?? 0;
                        final webviewUrl = '${AppConstants.baseUrl}/payment-mobile'
                            '?customer_id=$userId'
                            '&session_id=$sessionId'
                            '&payment_method=${selectedKey ?? checkoutController.digitalPaymentName}'
                            '&payment_platform=app'
                            '&callback=${Uri.encodeComponent('${AppConstants.baseUrl}/payment-success')}';
                        Get.toNamed(RouteHelper.getPaymentRoute(
                          OrderModel(id: 0, userId: userId, orderAmount: total, restaurant: Get.find<RestaurantController>().restaurant),
                          selectedKey ?? checkoutController.digitalPaymentName,
                          guestId: Get.find<AuthController>().getGuestId(),
                          contactNumber: placeOrderBody.contactPersonNumber,
                          payFirstUrl: webviewUrl,
                        ));
                      }
                    } else if (paymentUrl != null && paymentUrl.isNotEmpty && paymentUrl != 'null') {
                      // Tamara/Tabby — webview with payment URL
                      Get.toNamed(RouteHelper.getPaymentRoute(
                        OrderModel(id: 0, userId: Get.find<ProfileController>().userInfoModel?.id ?? 0, orderAmount: total, restaurant: Get.find<RestaurantController>().restaurant),
                        selectedKey ?? checkoutController.digitalPaymentName,
                        guestId: Get.find<AuthController>().getGuestId(),
                        contactNumber: placeOrderBody.contactPersonNumber,
                        payFirstUrl: paymentUrl,
                      ));
                    }
                  });
                }
              } else {
                // COD / Wallet — existing order-first flow
                checkoutController.placeOrder(placeOrderBody, zoneId, total, maxCodOrderAmount, fromCart, isCashOnDeliveryActive);
              }
            }

          }
        }),
      ),
    );
  }

  bool _isDatePicked() {
    bool datePicked = false;
    for(DateTime? time in checkoutController.selectedDays) {
      if(time != null) {
        datePicked = true;
        break;
      }
    }
    return datePicked;
  }

  DateTime _processScheduleStartDate() {
    DateTime scheduleStartDate = DateTime.now();
    final timeSlots = checkoutController.timeSlots;
    final selectedTimeSlot = checkoutController.selectedTimeSlot ?? 0;

    if(timeSlots != null && timeSlots.isNotEmpty && selectedTimeSlot < timeSlots.length) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : checkoutController.selectedCustomDate?? DateTime.now();
      DateTime? startTime = timeSlots[selectedTimeSlot].startTime;

      if(checkoutController.orderType == 'dine_in') {
        scheduleStartDate = checkoutController.orderPlaceDineInDateTime ?? DateTime.now();
      } else if (startTime != null) {
        scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute + 1);
      }
    }
    return scheduleStartDate;
  }

  DateTime _processScheduleEndDate() {
    DateTime scheduleEndDate = DateTime.now();
    final timeSlots = checkoutController.timeSlots;
    final selectedTimeSlot = checkoutController.selectedTimeSlot ?? 0;

    if(timeSlots != null && timeSlots.isNotEmpty && selectedTimeSlot < timeSlots.length) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : checkoutController.selectedCustomDate?? DateTime.now();
      DateTime? endTime = timeSlots[selectedTimeSlot].endTime;
      if(checkoutController.orderType == 'dine_in') {
        scheduleEndDate = checkoutController.orderPlaceDineInDateTime?.add(const Duration(minutes: 1)) ?? DateTime.now().add(const Duration(minutes: 1));
      } else if (endTime != null) {
        scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute + 1);
      }
    }
    return scheduleEndDate;
  }

  bool _checkAvailability(DateTime scheduleStartDate, DateTime scheduleEndDate) {
    bool isAvailable = true;
    if(checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
      isAvailable = false;
    } else {
      final scheduleOrder = checkoutController.restaurant?.scheduleOrder ?? false;
      // Only check product availability times when schedule ordering is enabled.
      // When schedule_order is false, the restaurant takes orders anytime it's open.
      if(scheduleOrder && cartList != null) {
        for (CartModel cart in cartList!) {
          final product = cart.product;
          if (product != null && !DateConverter.isAvailable(
            product.availableTimeStarts, product.availableTimeEnds,
            time: scheduleStartDate,
          ) && !DateConverter.isAvailable(
            product.availableTimeStarts, product.availableTimeEnds,
            time: scheduleEndDate,
          )) {
            isAvailable = false;
            break;
          }
        }
      }
    }
    return isAvailable;
  }

  bool _showsWarningMessage(BuildContext context, bool isGuestLogIn, bool datePicked, bool isAvailable) {
    if(isGuestLogIn && checkoutController.guestAddress == null && checkoutController.orderType != 'take_away'&& checkoutController.orderType != 'dine_in'){
      showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
      return true;
    } else if(checkoutController.orderType == 'dine_in' && checkoutController.selectedDineInDate == null){
      showCustomSnackBar('please_select_your_dine_in_date'.tr);
      return true;
    } else if(checkoutController.orderType == 'dine_in' && checkoutController.estimateDineInTime == null){
      showCustomSnackBar('please_select_your_dine_in_time'.tr);
      return true;
    } else if(((isGuestLogIn && checkoutController.orderType == 'take_away') || checkoutController.orderType == 'dine_in') && guestNameTextEditingController.text.isEmpty){
      showCustomSnackBar('please_enter_contact_person_name'.tr);
      return true;
    } else if(((isGuestLogIn && checkoutController.orderType == 'take_away') || checkoutController.orderType == 'dine_in') && guestNumberTextEditingController.text.isEmpty){
      showCustomSnackBar('please_enter_contact_person_number'.tr);
      return true;
    } else if(!isCashOnDeliveryActive && !isDigitalPaymentActive && !isWalletActive) {
      showCustomSnackBar('no_payment_method_is_enabled'.tr);
      return true;
    // DISABLED: Preference time validation removed - all orders are immediate
    // }else if((Get.find<SplashController>().configModel?.instantOrder != true) && (checkoutController.restaurant?.instantOrder != true) && (checkoutController.restaurant?.scheduleOrder == true) && (checkoutController.preferableTime.isEmpty || checkoutController.preferableTime == 'Not Available')) {
    //   showCustomSnackBar('please_select_order_preference_time'.tr);
    //   return true;
    } else if(checkoutController.paymentMethodIndex == -1) {
      if(ResponsiveHelper.isDesktop(context)){
        Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
          isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
          isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
        )));
      }else{
        Get.bottomSheet(
          PaymentMethodBottomSheet(
            isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
            isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
          ),
          backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true,
        );
      }
      return true;
    }else if(orderAmount < (checkoutController.restaurant?.minimumOrder ?? 0) && !checkoutController.isPrescriptionOnlyOrder) {
      // Skip minimum order check for prescription-only orders (pharmacy will set the price)
      print('=== MINIMUM ORDER CHECK ===');
      print('orderAmount: $orderAmount');
      print('minimumOrder: ${checkoutController.restaurant?.minimumOrder}');
      print('isPrescriptionOnlyOrder: ${checkoutController.isPrescriptionOnlyOrder}');
      showCustomSnackBar('${'minimum_order_amount_is'.tr} ${checkoutController.restaurant?.minimumOrder ?? 0}');
      return true;
    }else if(checkoutController.subscriptionOrder && ((Get.find<SplashController>().configModel?.homeDelivery != true) || (checkoutController.restaurant?.delivery != true))){
      showCustomSnackBar('home_delivery_is_disable_for_subscription'.tr);
      return true;
    }else if(checkoutController.subscriptionOrder && checkoutController.subscriptionRange == null) {
      showCustomSnackBar('select_a_date_range_for_subscription'.tr);
      return true;
    }else if(checkoutController.subscriptionOrder && !datePicked && checkoutController.subscriptionType == 'daily') {
      showCustomSnackBar('choose_time'.tr);
      return true;
    }else if(checkoutController.subscriptionOrder && !datePicked) {
      showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
      return true;
    }else if(((checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed) || (checkoutController.selectedDateSlot == 2 && checkoutController.customDateRestaurantClose)) && checkoutController.orderType != 'dine_in') {
      showCustomSnackBar('restaurant_is_closed'.tr);
      return true;
    }else if(checkoutController.paymentMethodIndex == 0 && (Get.find<SplashController>().configModel?.cashOnDelivery == true) && maxCodOrderAmount != null && (total > maxCodOrderAmount!)){
      showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
      return true;
    } else if (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
      if((checkoutController.restaurant?.scheduleOrder == true) && !checkoutController.subscriptionOrder) {
        showCustomSnackBar('select_a_time'.tr);
      }else {
        showCustomSnackBar('restaurant_is_closed'.tr);
      }
      return true;
    }else if (!isAvailable && !checkoutController.subscriptionOrder) {
      showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
      return true;
    }else if (checkoutController.orderType != 'take_away' && checkoutController.distance == -1 && deliveryCharge == -1) {
      showCustomSnackBar('delivery_fee_not_set_yet'.tr);
      return true;
    } else if(checkoutController.paymentMethodIndex == 1 && Get.find<ProfileController>().userInfoModel
        != null && (Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0) < total) {
      showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
      return true;
    } else {
      return false;
    }
  }

  AddressModel? _processFinalAddress(bool isGuestLogIn) {
    AddressModel? finalAddress = isGuestLogIn ? checkoutController.guestAddress : checkoutController.address;

    if(isGuestLogIn && checkoutController.orderType == 'take_away' || checkoutController.orderType == 'dine_in') {
      String number = checkoutController.countryDialCode! + guestNumberTextEditingController.text;
      finalAddress = AddressModel(contactPersonName: guestNameTextEditingController.text, contactPersonNumber: number,
        address: AddressHelper.getAddressFromSharedPref()!.address!, latitude: AddressHelper.getAddressFromSharedPref()!.latitude,
        longitude: AddressHelper.getAddressFromSharedPref()!.longitude, zoneId: AddressHelper.getAddressFromSharedPref()!.zoneId,
        email: guestEmailController.text,
      );
    }

    if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
      finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone;
    }
    return finalAddress;
  }

  List<place_order_model.OnlineCart> _generateOnlineCartList() {
    List<place_order_model.OnlineCart> carts = [];
    if (cartList == null) return carts;
    for (int index = 0; index < cartList!.length; index++) {
      CartModel cart = cartList![index];
      List<int?> addOnIdList = [];
      List<int?> addOnQtyList = [];
      List<place_order_model.OrderVariation> variations = [];
      List<int?> optionIds = [];
      // Null-safe addOnIds iteration
      if (cart.addOnIds != null) {
        for (var addOn in cart.addOnIds!) {
          addOnIdList.add(addOn.id);
          addOnQtyList.add(addOn.quantity);
        }
      }
      // Null-safe variations iteration
      final productVariations = cart.product?.variations;
      final cartVariations = cart.variations;
      if(productVariations != null && productVariations.isNotEmpty && cartVariations != null){
        for(int i=0; i<productVariations.length; i++) {
          if(i < cartVariations.length && cartVariations[i].contains(true)) {
            variations.add(place_order_model.OrderVariation(name: productVariations[i].name, values: place_order_model.OrderVariationValue(label: [])));
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
      carts.add(place_order_model.OnlineCart(
        cart.id, cart.product?.id, (cart.isCampaign ?? false) ? cart.product?.id : null,
        cart.discountedPrice.toString(), variations,
        cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Food',
        variationOptionIds: optionIds, itemType: !fromCart ? "AppModelsItemCampaign" : null,
        vendorId: cart.product?.restaurantId, vendorType: 'restaurant',
      ));
    }
    return carts;
  }

  List<place_order_model.SubscriptionDays> _generateSubscriptionDays() {
    List<place_order_model.SubscriptionDays> days = [];
    for(int index=0; index<checkoutController.selectedDays.length; index++) {
      if(checkoutController.selectedDays[index] != null) {
        days.add(place_order_model.SubscriptionDays(
          day: checkoutController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
              : checkoutController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
          time: DateConverter.dateToTime(checkoutController.selectedDays[index]!),
        ));
      }
    }
    return days;
  }

  PlaceOrderBodyModel _preparePlaceOrderModel(List<place_order_model.OnlineCart> carts, DateTime scheduleStartDate, AddressModel? finalAddress, bool isGuestLogIn,
      List<place_order_model.SubscriptionDays> days) {
    return PlaceOrderBodyModel(
      cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: checkoutController.distance,
      couponDiscountTitle: Get.find<CouponController>().discount! > 0 ? Get.find<CouponController>().coupon!.title : null,
      scheduleAt: checkoutController.orderType == 'dine_in' ? checkoutController.orderPlaceDineInDateTime.toString()
          : null, // ALWAYS IMMEDIATE: Orders are always 'now', no scheduling
      orderAmount: total, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
      paymentMethod: checkoutController.selectedPaymentKey
          ?? (checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
          : checkoutController.paymentMethodIndex == 1 ? 'wallet'
          : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment'),
      couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
          && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
      restaurantId: cartList?.isNotEmpty == true
          ? cartList![0].product?.restaurantId
          : checkoutController.prescriptionRestaurantId,
      isPrescriptionOnly: checkoutController.isPrescriptionOnlyOrder ? 1 : 0,
      address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
      contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName} '
          '${Get.find<ProfileController>().userInfoModel!.lName}',
      contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone,
      discountAmount: discount, taxAmount: tax, cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
      road: isGuestLogIn ? finalAddress.road??'' : checkoutController.streetNumberController.text.trim(),
      house: isGuestLogIn ? finalAddress.house??'' : checkoutController.houseController.text.trim(),
      floor: isGuestLogIn ? finalAddress.floor??'' : checkoutController.floorController.text.trim(),
      dmTips: (checkoutController.orderType == 'take_away' || checkoutController.subscriptionOrder || checkoutController.selectedTips == 0) ? '0' : checkoutController.tips.toString(),
      subscriptionOrder: checkoutController.subscriptionOrder ? '1' : '0',
      subscriptionType: checkoutController.subscriptionType, subscriptionQuantity: subscriptionQty.toString(),
      subscriptionDays: days,
      subscriptionStartAt: checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(checkoutController.subscriptionRange!.start) : '',
      subscriptionEndAt: checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(checkoutController.subscriptionRange!.end) : '',
      unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
      deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
      partialPayment: checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
      isBuyNow: fromCart ? 0 : 1, guestEmail: isGuestLogIn ? finalAddress.email : null,
      extraPackagingAmount: extraPackagingAmount, bringChangeAmount: checkoutController.paymentMethodIndex == 0 && checkoutController.exchangeAmount > 0 ? checkoutController.exchangeAmount : null,
      walletAmount: checkoutController.isPartialPay
          ? Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0
          : null,
      // V3 API fields - Debug address ID
      addressId: (() {
        print('DEBUG V3 Order: finalAddress.id = ${finalAddress.id}');
        print('DEBUG V3 Order: finalAddress.address = ${finalAddress.address}');
        print('DEBUG V3 Order: finalAddress toJson = ${finalAddress.toJson()}');
        return finalAddress.id;
      })(),
      deliveryTime: checkoutController.orderType == 'dine_in'
          ? checkoutController.orderPlaceDineInDateTime.toString()
          : 'now', // ALWAYS IMMEDIATE: Orders are always 'now', no scheduling
    );
  }

}
