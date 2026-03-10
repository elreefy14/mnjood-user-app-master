// Helper function to safely convert values to int
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

// Helper function to safely convert values to double
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Helper function to safely convert int/bool values
bool? _toBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  return null;
}

class PaginatedOrderModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<OrderModel>? orders;

  PaginatedOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = json['offset'].toString();
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders!.add(OrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class OrderModel {
  int? id;
  double? orderAmount;
  double? couponDiscountAmount;
  String? couponDiscountTitle;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? orderNote;
  String? orderType;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  String? scheduleAt;
  String? otp;
  String? pending;
  String? accepted;
  String? confirmed;
  String? processing;
  String? handover;
  String? pickedUp;
  String? delivered;
  String? canceled;
  String? refundRequested;
  String? refunded;
  DeliveryAddress? deliveryAddress;
  int? scheduled;
  double? restaurantDiscountAmount;
  String? restaurantName;
  String? restaurantAddress;
  String? restaurantPhone;
  String? restaurantLat;
  String? restaurantLng;
  String? restaurantLogo;
  int? foodCampaign;
  int? detailsCount;
  Customer? customer;
  double? dmTips;
  int? processingTime;
  DeliveryMan? deliveryMan;
  bool? taxStatus;
  bool? cutlery;
  int? subscriptionId;
  String? unavailableItemNote;
  String? deliveryInstruction;
  double? additionalCharge;
  List<String>? orderProofFullUrl;
  List<Payments>? payments;
  bool? isGuest;
  double? extraPackagingAmount;
  double? referrerBonusAmount;
  OrderReference? orderReference;
  double? bringChangeAmount;
  List<OrderEditLogs>? orderEditLogs;
  int? chatCount;
  bool? hasActiveChat;

  // ========== DELIVERY FEE DISCOUNT FIELDS ==========
  double? originalDeliveryFee;
  double? deliveryFeeDiscount;

  // ========== PARTIAL PAYMENT FIELDS ==========
  double? partiallyPaidAmount;
  double? remainingAmount;

  // ========== PHARMACY/PRESCRIPTION FIELDS ==========
  PrescriptionInfo? prescription;       // Prescription details if order has prescription items
  String? prescriptionStatus;           // 'pending_verification', 'approved', 'rejected'
  bool? hasPrescriptionItems;           // Quick check if order contains prescription items
  int? prescriptionItemsCount;          // Number of prescription-required items

  OrderModel({
    this.id,
    this.orderAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.orderNote,
    this.orderType,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.scheduleAt,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.processing,
    this.handover,
    this.pickedUp,
    this.delivered,
    this.canceled,
    this.refundRequested,
    this.refunded,
    this.deliveryAddress,
    this.scheduled,
    this.restaurantDiscountAmount,
    this.restaurantName,
    this.restaurantAddress,
    this.restaurantPhone,
    this.restaurantLat,
    this.restaurantLng,
    this.restaurantLogo,
    this.foodCampaign,
    this.detailsCount,
    this.customer,
    this.dmTips,
    this.processingTime,
    this.deliveryMan,
    this.taxStatus,
    this.cutlery,
    this.subscriptionId,
    this.unavailableItemNote,
    this.deliveryInstruction,
    this.additionalCharge,
    this.orderProofFullUrl,
    this.payments,
    this.isGuest,
    this.extraPackagingAmount,
    this.referrerBonusAmount,
    this.orderReference,
    this.bringChangeAmount,
    this.orderEditLogs,
    this.chatCount,
    this.hasActiveChat,
    // Delivery fee discount
    this.originalDeliveryFee,
    this.deliveryFeeDiscount,
    // Partial payment
    this.partiallyPaidAmount,
    this.remainingAmount,
    // Pharmacy/Prescription
    this.prescription,
    this.prescriptionStatus,
    this.hasPrescriptionItems,
    this.prescriptionItemsCount,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    orderAmount = _toDouble(json['order_amount']);
    couponDiscountAmount = _toDouble(json['coupon_discount_amount']);
    couponDiscountTitle = json['coupon_discount_title'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = _toDouble(json['total_tax_amount']);
    paymentMethod = json['payment_method'];
    orderNote = json['order_note'];
    orderType = json['order_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = _toDouble(json['delivery_charge']);
    scheduleAt = json['schedule_at'];
    otp = json['otp'];
    pending = json['pending'];
    accepted = json['accepted'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    handover = json['handover'];
    pickedUp = json['picked_up'];
    delivered = json['delivered'];
    canceled = json['canceled'];
    refundRequested = json['refund_requested'];
    refunded = json['refunded'];
    deliveryAddress = json['delivery_address'] != null ? DeliveryAddress.fromJson(json['delivery_address']) : null;
    scheduled = _toInt(json['scheduled']);
    restaurantDiscountAmount = _toDouble(json['restaurant_discount_amount']);
    restaurantName = json['restaurant_name'];
    restaurantAddress = json['restaurant_address'];
    restaurantPhone = json['restaurant_phone'];
    restaurantLat = json['restaurant_lat'];
    restaurantLng = json['restaurant_lng'];
    restaurantLogo = json['restaurant_logo'];
    foodCampaign = _toInt(json['food_campaign']);
    detailsCount = _toInt(json['details_count']);
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    dmTips = _toDouble(json['dm_tips']);
    processingTime = _toInt(json['processing_time']);
    deliveryMan = json['delivery_man'] != null ? DeliveryMan.fromJson(json['delivery_man']) : null;
    taxStatus = json['tax_status'] == 'included' ? true : false;
    cutlery = _toBool(json['cutlery']);
    subscriptionId = _toInt(json['subscription_id']);
    unavailableItemNote = json['unavailable_item_note'];
    deliveryInstruction = json['delivery_instruction'];
    additionalCharge = _toDouble(json['additional_charge']) ?? 0;
    if (json['order_proof_full_url'] != null && json['order_proof_full_url'] != "null") {
      orderProofFullUrl = [];
      json['order_proof_full_url'].forEach((v) {
        if(v != null) {
          orderProofFullUrl!.add(v.toString());
        }
      });
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(Payments.fromJson(v));
      });
    }
    isGuest = json['is_guest'];
    extraPackagingAmount = _toDouble(json['extra_packaging_amount']);
    referrerBonusAmount = _toDouble(json['ref_bonus_amount']);
    orderReference = json['order_reference'] != null ? OrderReference.fromJson(json['order_reference']) : null;
    bringChangeAmount = _toDouble(json['bring_change_amount']);
    if (json['order_edit_logs'] != null) {
      orderEditLogs = <OrderEditLogs>[];
      json['order_edit_logs'].forEach((v) {
        orderEditLogs!.add(OrderEditLogs.fromJson(v));
      });
    }

    chatCount = _toInt(json['chat_count']);
    hasActiveChat = json['has_active_chat'] == true || json['has_active_chat'] == 1;

    // ========== DELIVERY FEE DISCOUNT FIELDS ==========
    originalDeliveryFee = _toDouble(json['original_delivery_fee']);
    deliveryFeeDiscount = _toDouble(json['delivery_fee_discount']);

    // ========== PARTIAL PAYMENT FIELDS ==========
    partiallyPaidAmount = _toDouble(json['partially_paid_amount']);
    remainingAmount = _toDouble(json['remaining_amount']);

    // ========== PHARMACY/PRESCRIPTION FIELDS ==========
    prescription = json['prescription'] != null
        ? PrescriptionInfo.fromJson(json['prescription'])
        : null;
    prescriptionStatus = json['prescription_status'];
    hasPrescriptionItems = _toBool(json['has_prescription_items']);
    prescriptionItemsCount = _toInt(json['prescription_items_count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['coupon_discount_title'] = couponDiscountTitle;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['otp'] = otp;
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['confirmed'] = confirmed;
    data['processing'] = processing;
    data['handover'] = handover;
    data['picked_up'] = pickedUp;
    data['delivered'] = delivered;
    data['canceled'] = canceled;
    data['refund_requested'] = refundRequested;
    data['refunded'] = refunded;
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    data['scheduled'] = scheduled;
    data['restaurant_discount_amount'] = restaurantDiscountAmount;
    data['restaurant_name'] = restaurantName;
    data['restaurant_address'] = restaurantAddress;
    data['restaurant_phone'] = restaurantPhone;
    data['restaurant_lat'] = restaurantLat;
    data['restaurant_lng'] = restaurantLng;
    data['restaurant_logo'] = restaurantLogo;
    data['food_campaign'] = foodCampaign;
    data['details_count'] = detailsCount;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['dm_tips'] = dmTips;
    data['processing_time'] = processingTime;
    data['subscription_id'] = subscriptionId;
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['additional_charge'] = additionalCharge;
    data['order_proof_full_url'] = orderProofFullUrl;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    data['is_guest'] = isGuest;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ref_bonus_amount'] = referrerBonusAmount;
    if (orderReference != null) {
      data['order_reference'] = orderReference!.toJson();
    }
    data['bring_change_amount'] = bringChangeAmount;
    if (orderEditLogs != null) {
      data['order_edit_logs'] = orderEditLogs!.map((v) => v.toJson()).toList();
    }

    // ========== DELIVERY FEE DISCOUNT FIELDS ==========
    data['original_delivery_fee'] = originalDeliveryFee;
    data['delivery_fee_discount'] = deliveryFeeDiscount;

    // ========== PARTIAL PAYMENT FIELDS ==========
    data['partially_paid_amount'] = partiallyPaidAmount;
    data['remaining_amount'] = remainingAmount;

    // ========== PHARMACY/PRESCRIPTION FIELDS ==========
    if (prescription != null) {
      data['prescription'] = prescription!.toJson();
    }
    data['prescription_status'] = prescriptionStatus;
    data['has_prescription_items'] = hasPrescriptionItems;
    data['prescription_items_count'] = prescriptionItemsCount;
    data['chat_count'] = chatCount;
    data['has_active_chat'] = hasActiveChat;

    return data;
  }

  // ========== HELPER METHODS ==========

  /// Check if prescription verification is pending
  bool get isPrescriptionPending => prescriptionStatus == 'pending_verification';

  /// Check if prescription is approved
  bool get isPrescriptionApproved => prescriptionStatus == 'approved';

  /// Check if prescription is rejected
  bool get isPrescriptionRejected => prescriptionStatus == 'rejected';

  /// Check if order needs prescription verification before processing
  bool get needsPrescriptionVerification =>
      (hasPrescriptionItems ?? false) && isPrescriptionPending;

  /// Check if order is from a supermarket (Mnjood Mart)
  /// Returns true if restaurant name contains 'mart', 'market', or 'سوبرماركت'
  bool get isSupermarketOrder {
    final name = restaurantName?.toLowerCase() ?? '';
    return name.contains('mart') ||
           name.contains('market') ||
           name.contains('سوبرماركت') ||
           name.contains('ماركت');
  }
}

class DeliveryAddress {
  String? contactPersonName;
  String? contactPersonNumber;
  String? addressType;
  String? address;
  String? longitude;
  String? latitude;
  String? streetNumber;
  String? house;
  String? floor;

  DeliveryAddress({
    this.contactPersonName,
    this.contactPersonNumber,
    this.addressType,
    this.address,
    this.longitude,
    this.latitude,
    this.streetNumber,
    this.house,
    this.floor,
  });

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    contactPersonName = json['contact_person_name'];
    contactPersonNumber = json['contact_person_number'];
    addressType = json['address_type'];
    address = json['address'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    streetNumber = json['road'];
    house = json['house'];
    floor = json['floor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contact_person_name'] = contactPersonName;
    data['contact_person_number'] = contactPersonNumber;
    data['address_type'] = addressType;
    data['address'] = address;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    return data;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  String? createdAt;
  String? updatedAt;

  Customer({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.createdAt,
    this.updatedAt,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class DeliveryMan {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  int? zoneId;
  int? active;
  String? status;

  DeliveryMan({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.zoneId,
    this.active,
    this.status,
  });

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    zoneId = _toInt(json['zone_id']);
    active = _toInt(json['active']);
    status = json['application_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['available'] = status;
    return data;
  }
}

class Payments {
  int? id;
  int? orderId;
  double? amount;
  String? paymentStatus;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;

  Payments({
    this.id,
    this.orderId,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    orderId = _toInt(json['order_id']);
    amount = _toDouble(json['amount']);
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OrderReference{
  int? id;
  int? orderId;
  String? tokenNumber;
  String? tableNumber;
  String? createdAt;
  String? updatedAt;

  OrderReference({this.id, this.orderId, this.tokenNumber, this.tableNumber, this.createdAt, this.updatedAt});

  OrderReference.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    orderId = _toInt(json['order_id']);
    tokenNumber = json['token_number'];
    tableNumber = json['table_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['token_number'] = tokenNumber;
    data['table_number'] = tableNumber;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OrderEditLogs {
  int? id;
  int? orderId;
  String? log;
  String? editedBy;
  String? createdAt;
  String? updatedAt;

  OrderEditLogs({
    this.id,
    this.orderId,
    this.log,
    this.editedBy,
    this.createdAt,
    this.updatedAt,
  });

  OrderEditLogs.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    orderId = _toInt(json['order_id']);
    log = json['log'];
    editedBy = json['edited_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['log'] = log;
    data['edited_by'] = editedBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

// ========== PHARMACY/PRESCRIPTION MODELS ==========

/// Prescription information attached to an order
class PrescriptionInfo {
  int? id;
  int? orderId;
  List<String>? prescriptionImageUrls;  // Full URLs to prescription images
  String? status;                        // 'pending_verification', 'approved', 'rejected'
  String? verifiedBy;                    // Staff ID who verified
  String? verifiedAt;                    // Timestamp of verification
  String? rejectionReason;               // Reason if rejected
  String? pharmacistNotes;               // Notes from pharmacist
  String? createdAt;
  String? updatedAt;

  PrescriptionInfo({
    this.id,
    this.orderId,
    this.prescriptionImageUrls,
    this.status,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    this.pharmacistNotes,
    this.createdAt,
    this.updatedAt,
  });

  PrescriptionInfo.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    orderId = _toInt(json['order_id']);
    if (json['prescription_image_urls'] != null) {
      prescriptionImageUrls = [];
      json['prescription_image_urls'].forEach((v) {
        if (v != null) {
          prescriptionImageUrls!.add(v.toString());
        }
      });
    }
    // Also try alternative key format
    if (prescriptionImageUrls == null && json['prescription_images'] != null) {
      prescriptionImageUrls = [];
      json['prescription_images'].forEach((v) {
        if (v != null) {
          prescriptionImageUrls!.add(v.toString());
        }
      });
    }
    status = json['status'];
    verifiedBy = json['verified_by']?.toString();
    verifiedAt = json['verified_at'];
    rejectionReason = json['rejection_reason'];
    pharmacistNotes = json['pharmacist_notes'] ?? json['notes'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['prescription_image_urls'] = prescriptionImageUrls;
    data['status'] = status;
    data['verified_by'] = verifiedBy;
    data['verified_at'] = verifiedAt;
    data['rejection_reason'] = rejectionReason;
    data['pharmacist_notes'] = pharmacistNotes;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  /// Check if prescription is pending verification
  bool get isPending => status == 'pending_verification';

  /// Check if prescription is approved
  bool get isApproved => status == 'approved';

  /// Check if prescription is rejected
  bool get isRejected => status == 'rejected';

  /// Get count of prescription images
  int get imageCount => prescriptionImageUrls?.length ?? 0;

  /// Check if prescription has images
  bool get hasImages => imageCount > 0;
}