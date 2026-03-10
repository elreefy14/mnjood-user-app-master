import 'dart:convert';

import 'package:mnjood/common/models/product_model.dart';

class PlaceOrderBodyModel {
  List<OnlineCart>? _cart;
  double? _couponDiscountAmount;
  String? _couponDiscountTitle;
  double? _orderAmount;
  String? _orderType;
  String? _paymentMethod;
  String? _orderNote;
  String? _couponCode;
  int? _restaurantId;
  double? _distance;
  String? _scheduleAt;
  double? _discountAmount;
  double? _taxAmount;
  String? _address;
  String? _latitude;
  String? _longitude;
  String? _contactPersonName;
  String? _contactPersonNumber;
  String? _addressType;
  String? _road;
  String? _house;
  String? _floor;
  String? _dmTips;
  String? _subscriptionOrder;
  String? _subscriptionType;
  List<SubscriptionDays>? _subscriptionDays;
  String? _subscriptionQuantity;
  String? _subscriptionStartAt;
  String? _subscriptionEndAt;
  int? _cutlery;
  String? _unavailableItemNote;
  String? _deliveryInstruction;
  int? _partialPayment;
  int? _guestId;
  int? _isBuyNow;
  String? _guestEmail;
  double? _extraPackagingAmount;
  double? _bringChangeAmount;
  double? _walletAmount;
  // V3 API fields
  int? _addressId;
  String? _deliveryTime;
  int? _isPrescriptionOnly;
  // Pay-first payment proof fields
  String? _moyasarPaymentId;
  String? _paymentSessionId;

  PlaceOrderBodyModel({
    List<OnlineCart>? cart,
    double? couponDiscountAmount,
    String? couponDiscountTitle,
    String? couponCode,
    required double orderAmount,
    required String orderType,
    required String paymentMethod,
    int? restaurantId,
    double? distance,
    String? scheduleAt,
    double? discountAmount,
    double? taxAmount,
    String? orderNote,
    String? address,
    String? latitude,
    String? longitude,
    String? contactPersonName,
    String? contactPersonNumber,
    String? addressType,
    String? road,
    String? house,
    String? floor,
    String? dmTips,
    String? subscriptionOrder,
    String? subscriptionType,
    List<SubscriptionDays>? subscriptionDays,
    String? subscriptionQuantity,
    String? subscriptionStartAt,
    String? subscriptionEndAt,
    int? cutlery,
    String? unavailableItemNote,
    String? deliveryInstruction,
    int? partialPayment,
    int? guestId,
    int?isBuyNow,
    String? guestEmail,
    double? extraPackagingAmount,
    double? bringChangeAmount,
    double? walletAmount,
    // V3 API fields
    int? addressId,
    String? deliveryTime,
    int? isPrescriptionOnly,
  }) {
    _cart = cart;
    _isPrescriptionOnly = isPrescriptionOnly;
    _couponDiscountAmount = couponDiscountAmount;
    _couponDiscountTitle = couponDiscountTitle;
    _orderAmount = orderAmount;
    _orderType = orderType;
    _paymentMethod = paymentMethod;
    _orderNote = orderNote;
    _couponCode = couponCode;
    _restaurantId = restaurantId;
    _distance = distance;
    _scheduleAt = scheduleAt;
    _discountAmount = discountAmount;
    _taxAmount = taxAmount;
    _address = address;
    _latitude = latitude;
    _longitude = longitude;
    _contactPersonName = contactPersonName;
    _contactPersonNumber = contactPersonNumber;
    _addressType = addressType;
    _road = road;
    _house = house;
    _floor = floor;
    _dmTips = dmTips;
    _subscriptionOrder = subscriptionOrder;
    _subscriptionType = subscriptionType;
    _subscriptionDays = subscriptionDays;
    _subscriptionQuantity = subscriptionQuantity;
    _subscriptionStartAt = subscriptionStartAt;
    _subscriptionEndAt = subscriptionEndAt;
    _cutlery = cutlery;
    _unavailableItemNote = unavailableItemNote;
    _deliveryInstruction = deliveryInstruction;
    _partialPayment = partialPayment;
    _guestId = guestId;
    _isBuyNow = isBuyNow;
    _guestEmail = guestEmail;
    _extraPackagingAmount = extraPackagingAmount;
    _bringChangeAmount = bringChangeAmount;
    _walletAmount = walletAmount;
    // V3 API fields
    _addressId = addressId;
    _deliveryTime = deliveryTime;
  }

  List<OnlineCart>? get cart => _cart;
  double? get couponDiscountAmount => _couponDiscountAmount;
  String? get couponDiscountTitle => _couponDiscountTitle;
  double? get orderAmount => _orderAmount;
  String? get orderType => _orderType;
  String? get paymentMethod => _paymentMethod;
  String? get orderNote => _orderNote;
  String? get couponCode => _couponCode;
  int? get restaurantId => _restaurantId;
  double? get distance => _distance;
  String? get scheduleAt => _scheduleAt;
  double? get discountAmount => _discountAmount;
  double? get taxAmount => _taxAmount;
  String? get address => _address;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get contactPersonName => _contactPersonName;
  String? get contactPersonNumber => _contactPersonNumber;
  String? get road => _road;
  String? get house => _house;
  String? get floor => _floor;
  String? get dmTips => _dmTips;
  String? get subscriptionOrder => _subscriptionOrder;
  String? get subscriptionType => _subscriptionType;
  List<SubscriptionDays>? get subscriptionDays => _subscriptionDays;
  String? get subscriptionQuantity => _subscriptionQuantity;
  String? get subscriptionStartAt => _subscriptionStartAt;
  String? get subscriptionEndAt => _subscriptionEndAt;
  int? get cutlery => _cutlery;
  String? get unavailableItemNote => _unavailableItemNote;
  String? get deliveryInstruction => _deliveryInstruction;
  int? get partialPayment => _partialPayment;
  int? get guestId => _guestId;
  int? get isBuyNow => _isBuyNow;
  String? get guestEmail => _guestEmail;
  double? get extraPackagingAmount => _extraPackagingAmount;
  double? get bringChangeAmount => _bringChangeAmount;
  double? get walletAmount => _walletAmount;
  // V3 API getters
  int? get addressId => _addressId;
  String? get deliveryTime => _deliveryTime;
  int? get isPrescriptionOnly => _isPrescriptionOnly;
  // Pay-first payment proof getters/setters
  String? get moyasarPaymentId => _moyasarPaymentId;
  set moyasarPaymentId(String? value) => _moyasarPaymentId = value;
  String? get paymentSessionId => _paymentSessionId;
  set paymentSessionId(String? value) => _paymentSessionId = value;

  PlaceOrderBodyModel.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      _cart = [];
      json['cart'].forEach((v) {
        _cart!.add(OnlineCart.fromJson(v));
      });
    }
    _couponDiscountAmount = json['coupon_discount_amount'];
    _couponDiscountTitle = json['coupon_discount_title'];
    _orderAmount = json['order_amount'];
    _orderType = json['order_type'];
    _paymentMethod = json['payment_method'];
    _orderNote = json['order_note'];
    _couponCode = json['coupon_code'];
    _restaurantId = json['restaurant_id'];
    _distance = json['distance'];
    _scheduleAt = json['schedule_at'];
    _discountAmount = json['discount_amount']?.toDouble() ?? 0.0;
    _taxAmount = json['tax_amount']?.toDouble() ?? 0.0;
    _address = json['address'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _contactPersonName = json['contact_person_name'];
    _contactPersonNumber = json['contact_person_number'];
    _addressType = json['address_type'];
    _road = json['road'];
    _house = json['house'];
    _floor = json['floor'];
    _dmTips = json['dm_tips'];
    _subscriptionOrder = json['subscription_order'];
    _subscriptionType = json['subscription_type'];
    if (json['subscription_days'] != null) {
      _subscriptionDays = [];
        if(json['subscription_days'] is String){
          jsonDecode(json['subscription_days']).forEach((v) {
            _subscriptionDays!.add(SubscriptionDays.fromJson(v));
          });
      } else {
      json['subscription_days'].forEach((v) {
        _subscriptionDays!.add(SubscriptionDays.fromJson(v));
      });
    }
      }
    _subscriptionQuantity = json['subscription_quantity'];
    _subscriptionStartAt = json['subscription_start_at'];
    _subscriptionEndAt = json['subscription_end_at'];
    _cutlery = int.parse(json['cutlery'].toString());
    _unavailableItemNote = json['unavailable_item_note'];
    _deliveryInstruction = json['delivery_instruction'];
    _partialPayment = int.parse(json['partial_payment'].toString());
    _guestId = json['guest_id'] != null ? int.parse(json['guest_id'].toString()) : null;
    _isBuyNow = int.parse(json['is_buy_now'].toString());
    _guestEmail = json['contact_person_email'];
    _extraPackagingAmount = json['extra_packaging_amount'] != null ? double.parse(json['extra_packaging_amount'].toString()) : null;
    _bringChangeAmount = json['bring_change_amount'] != null ? double.parse(json['bring_change_amount'].toString()) : null;
    _walletAmount = json['wallet_amount'] != null ? double.parse(json['wallet_amount'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // V3 API: Handle cart items based on checkout mode
    if (_cart != null && _cart!.isNotEmpty) {
      if (_isBuyNow == 1) {
        // Buy Now mode: send single cart_id
        data['cart_id'] = _cart!.first.cartId?.toString();
      } else if (_cart!.length == 1) {
        // Single item in cart: send cart_id
        data['cart_id'] = _cart!.first.cartId?.toString();
      } else {
        // Multiple items: send cart_ids array
        data['cart_ids'] = _cart!.map((c) => c.cartId).where((id) => id != null).toList();
      }

    }
    // Note: If no cart_id/cart_ids sent, backend will checkout ALL items in user's cart

    // V3 API: Send address_id (required for delivery orders)
    if (_addressId != null) {
      data['address_id'] = _addressId;
    }

    // V3 API: delivery_time expects literal strings "now" or "schedule"
    // For scheduled orders, use "schedule" + schedule_at field with ISO datetime
    if (_scheduleAt != null && _scheduleAt!.isNotEmpty && _scheduleAt != 'now') {
      data['delivery_time'] = 'schedule';
    } else {
      data['delivery_time'] = 'now';
    }

    data['coupon_discount_amount'] = _couponDiscountAmount;
    data['coupon_discount_title'] = _couponDiscountTitle;
    data['order_amount'] = _orderAmount;
    data['order_type'] = _orderType;
    data['payment_method'] = _paymentMethod;
    data['order_note'] = _orderNote;
    data['coupon_code'] = _couponCode;
    data['restaurant_id'] = _restaurantId;
    data['distance'] = _distance;
    // Only include schedule_at if it has a valid value (not null, not empty, not 'now')
    if (_scheduleAt != null && _scheduleAt!.isNotEmpty && _scheduleAt != 'now') {
      data['schedule_at'] = _scheduleAt;
    }
    data['discount_amount'] = _discountAmount;
    data['tax_amount'] = _taxAmount;
    data['address'] = _address;
    data['latitude'] = _latitude;
    data['longitude'] = _longitude;
    data['contact_person_name'] = _contactPersonName;
    data['contact_person_number'] = _contactPersonNumber;
    data['address_type'] = _addressType;
    data['road'] = _road;
    data['house'] = _house;
    data['floor'] = _floor;
    data['dm_tips'] = _dmTips;
    data['subscription_order'] = _subscriptionOrder;
    data['subscription_type'] = _subscriptionType;
    if (_subscriptionDays != null) {
      data['subscription_days'] = jsonEncode(_subscriptionDays!.map((v) => v.toJson()).toList());
    }
    data['subscription_quantity'] = _subscriptionQuantity;
    data['subscription_start_at'] = _subscriptionStartAt;
    data['subscription_end_at'] = _subscriptionEndAt;
    if(_unavailableItemNote != null && _unavailableItemNote!.isNotEmpty) {
      data['unavailable_item_note'] = _unavailableItemNote;
    }
    if(_deliveryInstruction != null && _deliveryInstruction!.isNotEmpty) {
      data['delivery_instruction'] = _deliveryInstruction;
    }
    if(_cutlery != null){
      data['cutlery'] = _cutlery.toString();
    }
    data['partial_payment'] = _partialPayment.toString();
    if(_guestId != 0) {
      data['guest_id'] = _guestId.toString();
    }
    data['is_buy_now'] = _isBuyNow.toString();
    if(_guestEmail != null) {
      data['contact_person_email'] = _guestEmail!;
    }
    if(_extraPackagingAmount != null) {
      data['extra_packaging_amount'] = _extraPackagingAmount.toString();
    }
    if(_bringChangeAmount != null) {
      data['bring_change_amount'] = _bringChangeAmount.toString();
    }
    if(_isPrescriptionOnly != null && _isPrescriptionOnly == 1) {
      data['is_prescription_only'] = '1';
    }
    if(_walletAmount != null && _walletAmount! > 0) {
      data['wallet_amount'] = _walletAmount;
    }
    if(_moyasarPaymentId != null) {
      data['moyasar_payment_id'] = _moyasarPaymentId;
    }
    if(_paymentSessionId != null) {
      data['payment_session_id'] = _paymentSessionId;
    }
    return data;
  }
}

class Cart {
  int? _foodId;
  int? _itemCampaignId;
  String? _price;
  String? _variant;
  List<OrderVariation>? _variation;
  int? _quantity;
  List<int?>? _addOnIds;
  List<AddOns>? _addOns;
  List<int?>? _addOnQtys;

  Cart(
      int? foodId,
      int? itemCampaignId,
        String price,
        String variant,
        List<OrderVariation> variation,
        int? quantity,
        List<int?> addOnIds,
        List<AddOns>? addOns,
        List<int?> addOnQtys) {
    _foodId = foodId;
    _itemCampaignId = itemCampaignId;
    _price = price;
    _variant = variant;
    _variation = variation;
    _quantity = quantity;
    _addOnIds = addOnIds;
    _addOns = addOns;
    _addOnQtys = addOnQtys;
  }

  int? get foodId => _foodId;
  int? get itemCampaignId => _itemCampaignId;
  String? get price => _price;
  String? get variant => _variant;
  List<OrderVariation>? get variation => _variation;
  int? get quantity => _quantity;
  List<int?>? get addOnIds => _addOnIds;
  List<AddOns>? get addOns => _addOns;
  List<int?>? get addOnQtys => _addOnQtys;

  Cart.fromJson(Map<String, dynamic> json) {
    _foodId = json['food_id'];
    _itemCampaignId = json['item_campaign_id'];
    _price = json['price'];
    _variant = json['variant'];
    if (json['variation'] != null) {
      _variation = [];
      json['variations'].forEach((v) {
        _variation!.add(OrderVariation.fromJson(v));
      });
    }
    _quantity = json['quantity'];
    _addOnIds = json['add_on_ids'] != null ? List<int>.from(json['add_on_ids']) : [];
    if (json['add_ons'] != null) {
      _addOns = [];
      json['add_ons'].forEach((v) {
        _addOns!.add(AddOns.fromJson(v));
      });
    }
    _addOnQtys = json['add_on_qtys'] != null ? List<int>.from(json['add_on_qtys']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['food_id'] = _foodId;
    data['item_campaign_id'] = _itemCampaignId;
    data['price'] = _price;
    data['variant'] = _variant;
    if (_variation != null) {
      data['variations'] = _variation!.map((v) => v.toJson()).toList();
    }
    data['quantity'] = _quantity;
    data['add_on_ids'] = _addOnIds;
    if (_addOns != null) {
      data['add_ons'] = _addOns!.map((v) => v.toJson()).toList();
    }
    data['add_on_qtys'] = _addOnQtys;
    return data;
  }
}

class OrderVariation {
  String? name;
  OrderVariationValue? values;

  OrderVariation({this.name, this.values});

  OrderVariation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    values = json['values'] != null ? OrderVariationValue.fromJson(json['values']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.toJson();
    }
    return data;
  }
}

class OrderVariationValue {
  List<String?>? label;

  OrderVariationValue({this.label});

  OrderVariationValue.fromJson(Map<String, dynamic> json) {
    label = json['label'] != null ? List<String>.from(json['label']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}

class SubscriptionDays {
  String? _day;
  String? _time;

  SubscriptionDays({String? day, String? time}) {
    if (day != null) {
      _day = day;
    }
    if (time != null) {
      _time = time;
    }
  }

  String? get day => _day;
  String? get time => _time;

  SubscriptionDays.fromJson(Map<String, dynamic> json) {
    _day = json['day'];
    _time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = _day;
    data['time'] = _time;
    return data;
  }
}

class OnlineCart {
  int? _cartId;
  int? _itemId;
  int? _itemCampaignId;
  String? _price;
  List<OrderVariation>? _variations;
  int? _quantity;
  List<int?>? _addOnIds;
  List<AddOns>? _addOns;
  List<int?>? _addOnQtys;
  String? _model;
  String? _itemType;
  List<int?>? _variationOptionIds;
  int? _vendorId;
  String? _vendorType;
  int? _unitId;

  OnlineCart(
      int? cartId,
      int? itemId,
      int? itemCampaignId,
      String price,
      List<OrderVariation>? variations,
      int? quantity,
      List<int?> addOnIds,
      List<AddOns>? addOns,
      List<int?> addOnQtys,
      String model,
      {
        String? itemType,
        List<int?>? variationOptionIds,
        int? vendorId,
        String? vendorType,
        int? unitId,
      }
      ) {
    _cartId = cartId;
    _itemId = itemId;
    _itemCampaignId = itemCampaignId;
    _price = price;
    _variations = variations;
    _quantity = quantity;
    _addOnIds = addOnIds;
    _addOns = addOns;
    _addOnQtys = addOnQtys;
    _model = model;
    _itemType = itemType;
    _variationOptionIds = variationOptionIds;
    _vendorId = vendorId;
    _vendorType = vendorType;
    _unitId = unitId;
  }

  int? get cartId => _cartId;
  int? get itemId => _itemId;
  int? get itemCampaignId => _itemCampaignId;
  String? get price => _price;
  List<OrderVariation>? get variation => _variations;
  int? get quantity => _quantity;
  List<int?>? get addOnIds => _addOnIds;
  List<AddOns>? get addOns => _addOns;
  List<int?>? get addOnQtys => _addOnQtys;
  String? get model => _model;
  String? get itemType => _itemType;
  List<int?>? get variationOptionIds => _variationOptionIds;
  int? get vendorId => _vendorId;
  String? get vendorType => _vendorType;
  int? get unitId => _unitId;

  OnlineCart.fromJson(Map<String, dynamic> json) {
    _cartId = json['cart_id'];
    _itemId = json['item_id'];
    _itemCampaignId = json['item_campaign_id'];
    _price = json['price'];
    if (json['variations'] != null) {
      _variations = [];
      json['variations'].forEach((v) {
        _variations!.add(OrderVariation.fromJson(v));
      });
    }
    _quantity = json['quantity'];
    _addOnIds = json['add_on_ids'] != null ? List<int>.from(json['add_on_ids']) : [];
    if (json['add_ons'] != null) {
      _addOns = [];
      json['add_ons'].forEach((v) {
        _addOns!.add(AddOns.fromJson(v));
      });
    }
    _addOnQtys = json['add_on_qtys'] != null ? List<int>.from(json['add_on_qtys']) : [];
    _model = json['model'];
    if(json['item_type'] != null && json['item_type'] != 'null') {
      _itemType = json['item_type'];
    }
    _variationOptionIds = json['variation_options'] != null ? List<int>.from(json['variation_options']) : [];
    _vendorId = json['vendor_id'];
    _vendorType = json['vendor_type'];
    _unitId = json['unit_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = _itemId;
    data['cart_id'] = _cartId;
    data['item_campaign_id'] = _itemCampaignId;
    data['price'] = _price;
    if(_variations != null) {
      data['variations'] = _variations!.map((v) => v.toJson()).toList();
    }
    data['quantity'] = _quantity;
    data['add_on_ids'] = _addOnIds;
    if (_addOns != null) {
      data['add_ons'] = _addOns!.map((v) => v.toJson()).toList();
    }
    data['add_on_qtys'] = _addOnQtys;
    data['model'] = _model;
    if(_itemType != null) {
      data['item_type'] = _itemType;
    }
    data['variation_options'] = _variationOptionIds;
    if(_vendorId != null) {
      data['vendor_id'] = _vendorId;
    }
    if(_vendorType != null) {
      data['vendor_type'] = _vendorType;
    }
    if(_unitId != null) {
      data['unit_id'] = _unitId;
    }
    return data;
  }
}