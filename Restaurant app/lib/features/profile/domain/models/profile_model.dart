import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

// Helper function to safely convert int/bool values
bool? _toBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
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

class ProfileModel {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? bankName;
  String? branch;
  String? holderName;
  String? accountNo;
  String? imageFullUrl;
  int? orderCount;
  int? todaysOrderCount;
  int? thisWeekOrderCount;
  int? thisMonthOrderCount;
  int? memberSinceDays;
  double? cashInHands;
  double? balance;
  double? totalEarning;
  double? todaysEarning;
  double? thisWeekEarning;
  double? thisMonthEarning;
  List<Restaurant>? restaurants;
  List<Translation>? translations;
  double? withdrawAbleBalance;
  double? payableBalance;
  bool? adjustable;
  bool? overFlowWarning;
  bool? overFlowBlockWarning;
  double? pendingWithdraw;
  double? alreadyWithdrawn;
  String? dynamicBalanceType;
  double? dynamicBalance;
  bool? showPayNowButton;
  Subscription? subscription;
  SubscriptionOtherData? subscriptionOtherData;
  bool? subscriptionTransactions;
  List<String>? roles;
  EmployeeInfo? employeeInfo;

  ProfileModel({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.bankName,
    this.branch,
    this.holderName,
    this.accountNo,
    this.imageFullUrl,
    this.orderCount,
    this.todaysOrderCount,
    this.thisWeekOrderCount,
    this.thisMonthOrderCount,
    this.memberSinceDays,
    this.cashInHands,
    this.balance,
    this.totalEarning,
    this.todaysEarning,
    this.thisWeekEarning,
    this.thisMonthEarning,
    this.restaurants,
    this.subscription,
    this.subscriptionOtherData,
    this.translations,
    this.withdrawAbleBalance,
    this.payableBalance,
    this.adjustable,
    this.overFlowWarning,
    this.overFlowBlockWarning,
    this.pendingWithdraw,
    this.alreadyWithdrawn,
    this.dynamicBalanceType,
    this.dynamicBalance,
    this.showPayNowButton,
    this.subscriptionTransactions,
    this.roles,
    this.employeeInfo,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bankName = json['bank_name'];
    branch = json['branch'];
    holderName = json['holder_name'];
    accountNo = json['account_no'];
    imageFullUrl = json['image_full_url'];
    orderCount = json['order_count'];
    todaysOrderCount = json['todays_order_count'];
    thisWeekOrderCount = json['this_week_order_count'];
    thisMonthOrderCount = json['this_month_order_count'];
    memberSinceDays = json['member_since_days'];
    cashInHands = _toDouble(json['cash_in_hands']);
    balance = _toDouble(json['balance']);
    totalEarning = _toDouble(json['total_earning']);
    todaysEarning = _toDouble(json['todays_earning']);
    thisWeekEarning = _toDouble(json['this_week_earning']);
    thisMonthEarning = _toDouble(json['this_month_earning']);
    if (json['restaurants'] != null) {
      restaurants = [];
      if (json['restaurants'] is List) {
        json['restaurants'].forEach((v) {
          restaurants!.add(Restaurant.fromJson(v));
        });
      } else if (json['restaurants'] is Map) {
        restaurants!.add(Restaurant.fromJson(json['restaurants']));
      }
    }
    if (json['subscription'] != null) {
      subscription = Subscription.fromJson(json['subscription']);
    }
    subscriptionOtherData = json['subscription_other_data'] != null ? SubscriptionOtherData.fromJson(json['subscription_other_data']) : null;
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
    withdrawAbleBalance = _toDouble(json['withdraw_able_balance']);
    payableBalance = _toDouble(json['payable_balance']);
    adjustable = _toBool(json['adjust_able']);
    overFlowWarning = _toBool(json['over_flow_warning']);
    overFlowBlockWarning = _toBool(json['over_flow_block_warning']);
    pendingWithdraw = _toDouble(json['pending_withdraw']);
    alreadyWithdrawn = _toDouble(json['total_withdrawn']);
    dynamicBalanceType = json['dynamic_balance_type'];
    dynamicBalance = _toDouble(json['dynamic_balance']);
    showPayNowButton = _toBool(json['show_pay_now_button']);
    subscriptionTransactions = _toBool(json['subscription_transactions']) ?? false;
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) => roles!.add(v));
    }
    if (json['employee_info'] != null) {
      employeeInfo = EmployeeInfo.fromJson(json['employee_info']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['bank_name'] = bankName;
    data['branch'] = branch;
    data['holder_name'] = holderName;
    data['account_no'] = accountNo;
    data['image_full_url'] = imageFullUrl;
    data['order_count'] = orderCount;
    data['todays_order_count'] = todaysOrderCount;
    data['this_week_order_count'] = thisWeekOrderCount;
    data['this_month_order_count'] = thisMonthOrderCount;
    data['member_since_days'] = memberSinceDays;
    data['cash_in_hands'] = cashInHands;
    data['balance'] = balance;
    data['total_earning'] = totalEarning;
    data['todays_earning'] = todaysEarning;
    data['this_week_earning'] = thisWeekEarning;
    data['this_month_earning'] = thisMonthEarning;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    data['withdraw_able_balance'] = withdrawAbleBalance;
    data['payable_balance'] = payableBalance;
    data['adjust_able'] = adjustable;
    data['over_flow_warning'] = overFlowWarning;
    data['over_flow_block_warning'] = overFlowBlockWarning;
    data['pending_withdraw'] = pendingWithdraw;
    data['total_withdrawn'] = alreadyWithdrawn;
    data['dynamic_balance_type'] = dynamicBalanceType;
    data['dynamic_balance'] = dynamicBalance;
    data['show_pay_now_button'] = showPayNowButton;
    data['subscription_transactions'] = subscriptionTransactions;
    if (roles != null) {
      data['roles'] = roles;
    }
    if (employeeInfo != null) {
      data['employee_info'] = employeeInfo!.toJson();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logoFullUrl;
  String? latitude;
  String? longitude;
  String? address;
  double? minimumOrder;
  bool? scheduleOrder;
  String? currency;
  String? createdAt;
  String? updatedAt;
  bool? freeDelivery;
  String? coverPhotoFullUrl;
  bool? delivery;
  bool? takeAway;
  bool? orderSubscriptionActive;
  double? tax;
  bool? reviewsSection;
  bool? foodSection;
  String? availableTimeStarts;
  String? availableTimeEnds;
  double? avgRating;
  int? ratingCount;
  bool? active;
  bool? gstStatus;
  String? gstCode;
  int? selfDeliverySystem;
  bool? posSystem;
  double? minimumShippingCharge;
  double? maximumShippingCharge;
  double? perKmShippingCharge;
  String? restaurantModel;
  int? veg;
  int? nonVeg;
  Discount? discount;
  List<Schedules>? schedules;
  String? deliveryTime;
  List<Cuisine>? cuisines;
  bool? cutlery;
  List<Translation>? translations;
  String? metaTitle;
  String? metaDescription;
  String? metaKeyWord;
  String? metaImageFullUrl;
  String? announcementMessage;
  int? isAnnouncementActive;
  bool? instanceOrder;
  int? extraPackagingStatus;
  double? extraPackagingAmount;
  bool? isHalalActive;
  List<String>? characteristics;
  bool? isExtraPackagingActive;
  String? restaurantBusinessModel;
  double? comission;
  int? scheduleAdvanceDineInBookingDuration;
  String? scheduleAdvanceDineInBookingDurationTimeFormat;
  bool? isDineInActive;
  bool? customDateOrderStatus;
  int? customOrderDate;
  bool? freeDeliveryDistanceStatus;
  String? freeDeliveryDistance;
  List<String?>? tags;
  bool? canEditOrder;
  String? businessType;

  Restaurant({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.logoFullUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.minimumOrder,
    this.scheduleOrder,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.freeDelivery,
    this.coverPhotoFullUrl,
    this.delivery,
    this.takeAway,
    this.orderSubscriptionActive,
    this.tax,
    this.reviewsSection,
    this.foodSection,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.avgRating,
    this.ratingCount,
    this.active,
    this.gstStatus,
    this.gstCode,
    this.selfDeliverySystem,
    this.posSystem,
    this.minimumShippingCharge,
    this.maximumShippingCharge,
    this.perKmShippingCharge,
    this.restaurantModel,
    this.veg,
    this.nonVeg,
    this.discount,
    this.schedules,
    this.deliveryTime,
    this.cuisines,
    this.cutlery,
    this.translations,
    this.metaTitle,
    this.metaDescription,
    this.metaKeyWord,
    this.metaImageFullUrl,
    this.announcementMessage,
    this.isAnnouncementActive,
    this.instanceOrder,
    this.extraPackagingStatus,
    this.extraPackagingAmount,
    this.isHalalActive,
    this.characteristics,
    this.isExtraPackagingActive,
    this.restaurantBusinessModel,
    this.comission,
    this.scheduleAdvanceDineInBookingDuration,
    this.scheduleAdvanceDineInBookingDurationTimeFormat,
    this.isDineInActive,
    this.customDateOrderStatus,
    this.customOrderDate,
    this.freeDeliveryDistanceStatus,
    this.freeDeliveryDistance,
    this.tags,
    this.canEditOrder,
    this.businessType,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logoFullUrl = json['logo_full_url'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    minimumOrder = _toDouble(json['minimum_order']);
    scheduleOrder = _toBool(json['schedule_order']);
    currency = json['currency'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    freeDelivery = _toBool(json['free_delivery']);
    coverPhotoFullUrl = json['cover_photo_full_url'];
    delivery = _toBool(json['delivery']);
    takeAway = _toBool(json['take_away']);
    orderSubscriptionActive = _toBool(json['order_subscription_active']);
    tax = _toDouble(json['tax']);
    reviewsSection = _toBool(json['reviews_section']);
    foodSection = _toBool(json['food_section']);
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    avgRating = _toDouble(json['avg_rating']);
    ratingCount = json['rating_count'];
    active = _toBool(json['active']);
    gstStatus = _toBool(json['gst_status']);
    gstCode = json['gst_code'];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = _toBool(json['pos_system']);
    minimumShippingCharge = _toDouble(json['minimum_shipping_charge']);
    maximumShippingCharge = _toDouble(json['maximum_shipping_charge']);
    perKmShippingCharge = _toDouble(json['per_km_shipping_charge']);
    restaurantModel = json['restaurant_model'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    discount = json['discount'] != null ? Discount.fromJson(json['discount']) : null;
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(v));
      });
    }
    deliveryTime = json['delivery_time'];
    if (json['cuisine'] != null) {
      cuisines = <Cuisine>[];
      json['cuisine'].forEach((v) {
        cuisines!.add(Cuisine.fromJson(v));
      });
    }
    cutlery = _toBool(json['cutlery']);
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
    metaTitle = json['meta_title'];
    metaDescription = json['meta_description'];
    metaKeyWord = json['meta_key_word'];
    metaImageFullUrl = json['meta_image_full_url'];
    announcementMessage = json['announcement_message']?.toString();
    isAnnouncementActive = json['announcement'];
    instanceOrder = _toBool(json['instant_order']);
    extraPackagingStatus = json['extra_packaging_status'] is bool ? (json['extra_packaging_status'] ? 1 : 0) : (json['extra_packaging_status'] ?? 0);
    extraPackagingAmount = _toDouble(json['extra_packaging_amount']);
    isHalalActive = _toBool(json['halal_tag_status']) ?? false;
    if (json['characteristics'] != null) {
      characteristics = (json['characteristics'] as List).map((e) => e.toString()).toList();
    } else {
      characteristics = [];
    }
    isExtraPackagingActive = _toBool(json['is_extra_packaging_active']);
    restaurantBusinessModel = json['restaurant_model'];
    comission = _toDouble(json['comission']);
    scheduleAdvanceDineInBookingDuration = json['schedule_advance_dine_in_booking_duration'];
    scheduleAdvanceDineInBookingDurationTimeFormat = json['schedule_advance_dine_in_booking_duration_time_format'];
    isDineInActive = _toBool(json['is_dine_in_active']);
    customDateOrderStatus = _toBool(json['customer_date_order_status']);
    customOrderDate = json['customer_order_date'];
    freeDeliveryDistanceStatus = _toBool(json['free_delivery_distance_status']);
    freeDeliveryDistance = json['free_delivery_distance_value'];
    if(json['tags'] != null && json['tags'] is List) {
      tags = [];
      for(var v in json['tags']) {
        tags!.add(v?.toString());
      }
    }
    canEditOrder = _toBool(json['can_edit_order']) ?? false;
    businessType = json['business_type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo_full_url'] = logoFullUrl;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['minimum_order'] = minimumOrder;
    data['schedule_order'] = scheduleOrder;
    data['currency'] = currency;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['free_delivery'] = freeDelivery;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['order_subscription_active'] = orderSubscriptionActive;
    data['tax'] = tax;
    data['reviews_section'] = reviewsSection;
    data['food_section'] = foodSection;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['active'] = active;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['restaurant_model'] = restaurantModel;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    data['delivery_time'] = deliveryTime;
    if (cuisines != null) {
      data['cuisine'] = cuisines!.map((v) => v.toJson()).toList();
    }
    data['cutlery'] = cutlery;
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_key_word'] = metaKeyWord;
    data['meta_image_full_url'] = metaImageFullUrl;
    data['announcement_message'] = announcementMessage;
    data['announcement'] = isAnnouncementActive;
    data['instant_order'] = instanceOrder;
    data['extra_packaging_status'] = extraPackagingStatus;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['halal_tag_status'] = isHalalActive;
    data['characteristics'] = characteristics;
    data['is_extra_packaging_active'] = isExtraPackagingActive;
    data['restaurant_model'] = restaurantBusinessModel;
    data['comission'] = comission;
    data['schedule_advance_dine_in_booking_duration'] = scheduleAdvanceDineInBookingDuration;
    data['schedule_advance_dine_in_booking_duration_time_format'] = scheduleAdvanceDineInBookingDurationTimeFormat;
    data['is_dine_in_active'] = isDineInActive;
    data['customer_date_order_status'] = customDateOrderStatus;
    data['customer_order_date'] = customOrderDate;
    data['free_delivery_distance_status'] = freeDeliveryDistanceStatus;
    data['free_delivery_distance_value'] = freeDeliveryDistance;
    if(tags != null) {
      data['tags'] = tags;
    }
    data['can_edit_order'] = canEditOrder;
    data['business_type'] = businessType;
    return data;
  }
}

class Cuisine {
  int? id;
  String? name;
  String? image;
  int? status;
  String? slug;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Cuisine({
    this.id,
    this.name,
    this.image,
    this.status,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  Cuisine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    status = json['status'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['status'] = status;
    data['slug'] = slug;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? restaurantId;
  int? cuisineId;

  Pivot({this.restaurantId, this.cuisineId});

  Pivot.fromJson(Map<String, dynamic> json) {
    restaurantId = int.parse(json['restaurant_id'].toString());
    cuisineId = int.parse(json['cuisine_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_id'] = restaurantId;
    data['cuisine_id'] = cuisineId;
    return data;
  }
}

class Discount {
  int? id;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;

  Discount({
    this.id,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
  });

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    minPurchase = _toDouble(json['min_purchase']);
    maxDiscount = _toDouble(json['max_discount']);
    discount = _toDouble(json['discount']);
    discountType = json['discount_type'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Schedules {
  int? id;
  int? restaurantId;
  int? day;
  String? openingTime;
  String? closingTime;

  Schedules({
    this.id,
    this.restaurantId,
    this.day,
    this.openingTime,
    this.closingTime,
  });

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    day = json['day'];
    String? opening = json['opening_time']?.toString();
    String? closing = json['closing_time']?.toString();
    openingTime = opening != null && opening.length >= 5 ? opening.substring(0, 5) : opening;
    closingTime = closing != null && closing.length >= 5 ? closing.substring(0, 5) : closing;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
    return data;
  }
}

class Subscription {
  int? id;
  int? packageId;
  int? restaurantId;
  String? expiryDate;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? isTrial;
  int? totalPackageRenewed;
  String? createdAt;
  String? updatedAt;
  String? renewedAt;
  int? isCanceled;
  String? canceledBy;
  int? validity;
  Package? package;

  Subscription({
    this.id,
    this.packageId,
    this.restaurantId,
    this.expiryDate,
    this.maxOrder,
    this.maxProduct,
    this.pos,
    this.mobileApp,
    this.chat,
    this.review,
    this.selfDelivery,
    this.status,
    this.isTrial,
    this.totalPackageRenewed,
    this.createdAt,
    this.updatedAt,
    this.renewedAt,
    this.isCanceled,
    this.canceledBy,
    this.validity,
    this.package,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    restaurantId = json['restaurant_id'];
    expiryDate = json['expiry_date'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'] ?? 0;
    mobileApp = json['mobile_app'] ?? 0;
    chat = json['chat'] ?? 0;
    review = json['review'] ?? 0;
    selfDelivery = json['self_delivery'];
    status = json['status'];
    isTrial = json['is_trial'];
    totalPackageRenewed = json['total_package_renewed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    renewedAt = json['renewed_at'];
    isCanceled = json['is_canceled'];
    canceledBy = json['canceled_by'];
    validity = json['validity'];
    package = json['package'] != null ? Package.fromJson(json['package']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['restaurant_id'] = restaurantId;
    data['expiry_date'] = expiryDate;
    data['max_order'] = maxOrder;
    data['max_product'] = maxProduct;
    data['pos'] = pos;
    data['mobile_app'] = mobileApp;
    data['chat'] = chat;
    data['review'] = review;
    data['self_delivery'] = selfDelivery;
    data['status'] = status;
    data['total_package_renewed'] = totalPackageRenewed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['renewed_at'] = renewedAt;
    data['is_canceled'] = isCanceled;
    data['canceled_by'] = canceledBy;
    data['validity'] = validity;
    if (package != null) {
      data['package'] = package!.toJson();
    }
    return data;
  }
}

class Package {
  int? id;
  String? packageName;
  double? price;
  int? validity;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? def;
  String? colour;
  String? text;
  String? createdAt;
  String? updatedAt;

  Package({
    this.id,
    this.packageName,
    this.price,
    this.validity,
    this.maxOrder,
    this.maxProduct,
    this.pos,
    this.mobileApp,
    this.chat,
    this.review,
    this.selfDelivery,
    this.status,
    this.def,
    this.colour,
    this.text,
    this.createdAt,
    this.updatedAt,
  });

  Package.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageName = json['package_name'];
    price = _toDouble(json['price']);
    validity = json['validity'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'];
    mobileApp = json['mobile_app'];
    chat = json['chat'];
    review = json['review'];
    selfDelivery = json['self_delivery'];
    status = json['status'];
    def = json['default'];
    colour = json['colour'];
    text = json['text'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_name'] = packageName;
    data['price'] = price;
    data['validity'] = validity;
    data['max_order'] = maxOrder;
    data['max_product'] = maxProduct;
    data['pos'] = pos;
    data['mobile_app'] = mobileApp;
    data['chat'] = chat;
    data['review'] = review;
    data['self_delivery'] = selfDelivery;
    data['status'] = status;
    data['default'] = def;
    data['colour'] = colour;
    data['text'] = text;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SubscriptionOtherData {
  double? totalBill;
  int? maxProductUpload;
  double? pendingBill;

  SubscriptionOtherData({
    this.totalBill,
    this.maxProductUpload,
    this.pendingBill,
  });

  SubscriptionOtherData.fromJson(Map<String, dynamic> json) {
    totalBill = _toDouble(json['total_bill']);
    maxProductUpload = json['max_product_uploads'];
    pendingBill = _toDouble(json['pending_bill']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_bill'] = totalBill;
    data['max_product_uploads'] = maxProductUpload;
    data['pending_bill'] = pendingBill;
    return data;
  }
}

class EmployeeInfo {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  int? employeeRoleId;
  int? restaurantId;

  EmployeeInfo({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.employeeRoleId,
    this.restaurantId,
  });

  EmployeeInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    employeeRoleId = json['employee_role_id'];
    restaurantId = json['restaurant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['employee_role_id'] = employeeRoleId;
    data['restaurant_id'] = restaurantId;
    return data;
  }
}