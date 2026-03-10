import 'package:mnjood/common/enums/business_type_enum.dart';
import 'package:mnjood/features/wallet/domain/models/fund_bonus_model.dart';
import 'package:mnjood/util/app_constants.dart';

/// Helper to safely convert API value to bool (handles int, bool, String, null)
bool? _safeBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return null;
}

/// Helper to safely convert API value to int (handles bool, int, String, null)
int? _safeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Helper to safely convert API value to double (handles int, double, String, null)
double? _safeDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class RestaurantModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Restaurant>? restaurants;

  // V3 pagination fields
  int? currentPage;
  int? perPage;
  int? totalPages;
  bool? hasNext;
  bool? hasPrev;

  RestaurantModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.restaurants,
    this.currentPage,
    this.perPage,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  RestaurantModel.fromJson(Map<String, dynamic> json) {
    // V3 API: Check if pagination metadata exists
    if(json['meta'] != null && json['meta']['pagination'] != null) {
      var pagination = json['meta']['pagination'];
      currentPage = pagination['current_page'] is int ? pagination['current_page'] : int.tryParse(pagination['current_page']?.toString() ?? '1');
      perPage = pagination['per_page'] is int ? pagination['per_page'] : int.tryParse(pagination['per_page']?.toString() ?? '12');
      totalSize = pagination['total'] is int ? pagination['total'] : int.tryParse(pagination['total']?.toString() ?? '0');
      totalPages = pagination['total_pages'] is int ? pagination['total_pages'] : int.tryParse(pagination['total_pages']?.toString() ?? '1');
      hasNext = pagination['has_next'];
      hasPrev = pagination['has_prev'];

      // Calculate V1-style offset for backward compatibility
      offset = ((currentPage ?? 1) - 1) * (perPage ?? 12);
      limit = perPage.toString();
    } else {
      // V1 API fallback (for any remaining V1 endpoints)
      totalSize = json['total_size'];
      limit = json['limit']?.toString();
      offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    }

    // Parse restaurants array
    if (json['restaurants'] != null) {
      restaurants = [];
      json['restaurants'].forEach((v) {
        restaurants!.add(Restaurant.fromJson(v));
      });
    }
    // V3 might use 'data' or 'vendors' instead of 'restaurants'
    else if (json['data'] is List) {
      restaurants = [];
      (json['data'] as List).forEach((v) {
        restaurants!.add(Restaurant.fromJson(v));
      });
    }
    else if (json['vendors'] != null) {
      restaurants = [];
      json['vendors'].forEach((v) {
        restaurants!.add(Restaurant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
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
  int? zoneId;
  double? minimumOrder;
  String? currency;
  bool? freeDelivery;
  String? coverPhotoFullUrl;
  bool? delivery;
  bool? takeAway;
  bool? isDineInActive;
  bool? scheduleOrder;
  double? avgRating;
  double? tax;
  int? ratingCount;
  int? selfDeliverySystem;
  bool? posSystem;
  int? open;
  bool? active;
  String? deliveryTime;
  List<int>? categoryIds;
  int? veg;
  int? nonVeg;
  Discount? discount;
  List<Schedules>? schedules;
  double? minimumShippingCharge;
  double? perKmShippingCharge;
  double? maximumShippingCharge;
  int? vendorId;
  String? restaurantModel;
  int? restaurantStatus;
  RestaurantSubscription? restaurantSubscription;
  List<Cuisines>? cuisineNames;
  List<int>? cuisineIds;
  bool? orderSubscriptionActive;
  bool? cutlery;
  String? slug;
  int? foodsCount;
  List<Foods>? foods;
  bool? announcementActive;
  String? announcementMessage;
  bool? instantOrder;
  bool? customerDateOrderStatus;
  int? customerOrderDate;
  bool? freeDeliveryDistanceStatus;
  double? freeDeliveryDistanceValue;
  String? restaurantOpeningTime;
  bool? extraPackagingStatusIsMandatory;
  double? extraPackagingAmount;
  List<int>? ratings;
  int? reviewsCommentsCount;
  List<String>? characteristics;
  bool? isExtraPackagingActive;
  int? scheduleAdvanceDineInBookingDuration;
  String? scheduleAdvanceDineInBookingDurationTimeFormat;
  bool? isActiveDineIn;
  int? dineInBookingDuration;
  String? dineInBookingDurationTimeFormat;
  double? priceStartFrom;
  String? businessType; // restaurant, supermarket, pharmacy

  Restaurant({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.logoFullUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.zoneId,
    this.minimumOrder,
    this.currency,
    this.freeDelivery,
    this.coverPhotoFullUrl,
    this.delivery,
    this.takeAway,
    this.isDineInActive,
    this.scheduleOrder,
    this.avgRating,
    this.tax,
    this.ratingCount,
    this.selfDeliverySystem,
    this.posSystem,
    this.open,
    this.active,
    this.deliveryTime,
    this.categoryIds,
    this.veg,
    this.nonVeg,
    this.discount,
    this.schedules,
    this.minimumShippingCharge,
    this.perKmShippingCharge,
    this.maximumShippingCharge,
    this.vendorId,
    this.restaurantModel,
    this.restaurantStatus,
    this.restaurantSubscription,
    this.cuisineNames,
    this.cuisineIds,
    this.orderSubscriptionActive,
    this.cutlery,
    this.slug,
    this.foodsCount,
    this.foods,
    this.announcementActive,
    this.announcementMessage,
    this.instantOrder,
    this.customerDateOrderStatus,
    this.customerOrderDate,
    this.freeDeliveryDistanceStatus,
    this.freeDeliveryDistanceValue,
    this.restaurantOpeningTime,
    this.extraPackagingStatusIsMandatory,
    this.extraPackagingAmount,
    this.ratings,
    this.reviewsCommentsCount,
    this.characteristics,
    this.isExtraPackagingActive,
    this.scheduleAdvanceDineInBookingDuration,
    this.scheduleAdvanceDineInBookingDurationTimeFormat,
    this.isActiveDineIn,
    this.dineInBookingDuration,
    this.dineInBookingDurationTimeFormat,
    this.priceStartFrom,
    this.businessType,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    // V3 API uses 'logo' and 'cover_photo', V1 uses 'logo_full_url' and 'cover_photo_full_url'
    // V3 wishlist API uses 'image' for the logo
    logoFullUrl = json['logo_full_url'] ?? json['logo'] ?? json['image'] ?? '';
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    address = json['address'];
    zoneId = json['zone_id'];
    minimumOrder = _safeDouble(json['minimum_order']) ?? 0;
    currency = json['currency'];
    freeDelivery = _safeBool(json['free_delivery']);
    // V3 API uses 'cover_image', V1 uses 'cover_photo_full_url' or 'cover_photo'
    coverPhotoFullUrl = json['cover_photo_full_url'] ?? json['cover_photo'] ?? json['cover_image'] ?? '';
    // V3 API may use 'is_delivery' or 'has_delivery', default to true if not specified
    delivery = _safeBool(json['delivery'] ?? json['is_delivery'] ?? json['has_delivery']) ?? true;
    // V3 API may use 'is_take_away' or 'has_takeaway', default to true if not specified
    takeAway = _safeBool(json['take_away'] ?? json['is_take_away'] ?? json['has_takeaway']) ?? true;
    isDineInActive = _safeBool(json['is_dine_in_active']);
    scheduleOrder = _safeBool(json['schedule_order']);
    // V3 API uses 'rating', V1 uses 'avg_rating'
    // Handle case where 'rating' might be a List (ratings breakdown) instead of a number
    var ratingValue = json['avg_rating'] ?? json['rating'];
    if (ratingValue is List) {
      avgRating = 0.0; // If it's a list of ratings breakdown, default to 0
    } else if (ratingValue != null) {
      avgRating = _safeDouble(ratingValue) ?? 0.0;
    } else {
      avgRating = 0.0;
    }
    tax = _safeDouble(json['tax']);
    ratingCount = json['rating_count'];
    selfDeliverySystem = _safeInt(json['self_delivery_system']);
    posSystem = _safeBool(json['pos_system']);
    // V3 API uses 'is_open' (bool), V1 uses 'open' (int)
    if (json['is_open'] != null) {
      open = _safeBool(json['is_open']) == true ? 1 : 0;
    } else if (json['open'] != null) {
      // Handle both bool and int for 'open' field
      open = json['open'] is bool ? (json['open'] == true ? 1 : 0) : json['open'];
    }
    // V3 API uses 'available' or 'is_open' (bool), V1 uses 'active' (bool)
    active = _safeBool(json['active'] ?? json['available'] ?? json['is_open']);
    deliveryTime = json['delivery_time'];
    // V3 API returns bool, convert to int (0 or 1)
    veg = json['veg'] is bool ? (json['veg'] ? 1 : 0) : json['veg'];
    nonVeg = json['non_veg'] is bool ? (json['non_veg'] ? 1 : 0) : json['non_veg'];
    // Defensive parsing for category_ids - may be null or wrong type in V3
    if (json['category_ids'] != null && json['category_ids'] is List) {
      try {
        categoryIds = (json['category_ids'] as List).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
      } catch (e) {
        categoryIds = [];
      }
    } else {
      categoryIds = [];
    }
    // Defensive parsing for discount - may be List instead of Map in V3
    if (json['discount'] != null && json['discount'] is Map<String, dynamic>) {
      try {
        discount = Discount.fromJson(json['discount']);
      } catch (e) {
        discount = null;
      }
    }
    // Defensive parsing for schedules
    if (json['schedules'] != null && json['schedules'] is List) {
      schedules = <Schedules>[];
      try {
        (json['schedules'] as List).forEach((v) {
          if (v is Map<String, dynamic>) {
            schedules!.add(Schedules.fromJson(v));
          }
        });
      } catch (e) {
        schedules = null;
      }
    } else if (json['opening_time'] != null && json['closing_time'] != null) {
      // V3 API fallback: Create schedule from opening_time/closing_time
      String openTime = json['opening_time'].toString();
      String closeTime = json['closing_time'].toString();
      // Extract time portion (HH:mm) from ISO datetime string
      if (openTime.contains('T')) {
        openTime = openTime.split('T')[1].substring(0, 5);
      }
      if (closeTime.contains('T')) {
        closeTime = closeTime.split('T')[1].substring(0, 5);
      }
      schedules = [
        Schedules(
          day: DateTime.now().weekday,
          openingTime: openTime,
          closingTime: closeTime,
        )
      ];
    }
    minimumShippingCharge = _safeDouble(json['minimum_shipping_charge']) ?? 0.0;
    perKmShippingCharge = _safeDouble(json['per_km_shipping_charge']) ?? 0.0;
    maximumShippingCharge = _safeDouble(json['maximum_shipping_charge']);
    vendorId = json['vendor_id'];
    restaurantModel = json['restaurant_model'];
    restaurantStatus = json['restaurant_status'] ?? (json['is_open'] == true ? 1 : 0);
    restaurantSubscription = json['restaurant_sub'] != null ? RestaurantSubscription.fromJson(json['restaurant_sub']) : null;
    // Defensive parsing for cuisine - may be null or non-List in V3
    if (json['cuisine'] != null && json['cuisine'] is List) {
      cuisineNames = [];
      try {
        (json['cuisine'] as List).forEach((v) {
          if (v is Map<String, dynamic>) {
            cuisineNames!.add(Cuisines.fromJson(v));
          }
        });
      } catch (e) {
        cuisineNames = [];
      }
    }
    orderSubscriptionActive = _safeBool(json['order_subscription_active']);
    cutlery = _safeBool(json['cutlery']);
    slug = json['slug'];
    foodsCount = json['foods_count'];
    // Defensive parsing for foods
    if (json['foods'] != null && json['foods'] is List) {
      foods = <Foods>[];
      try {
        (json['foods'] as List).forEach((v) {
          if (v is Map<String, dynamic>) {
            foods!.add(Foods.fromJson(v));
          }
        });
      } catch (e) {
        foods = null;
      }
    }
    announcementActive = json['announcement'] == 1 || json['announcement'] == true;
    // V3 API might return int for announcement_message, convert to string
    announcementMessage = json['announcement_message']?.toString();
    instantOrder = _safeBool(json['instant_order']);
    customerDateOrderStatus = _safeBool(json['customer_date_order_sratus']);
    customerOrderDate = json['customer_order_date'];
    freeDeliveryDistanceStatus = _safeBool(json['free_delivery_distance_status']);
    freeDeliveryDistanceValue = _safeDouble(json['free_delivery_distance_value']);
    restaurantOpeningTime = json['current_opening_time'];
    extraPackagingStatusIsMandatory = _safeBool(json['extra_packaging_status']) ?? false;
    extraPackagingAmount = _safeDouble(json['extra_packaging_amount']) ?? 0;
    // Defensive parsing for ratings - may be wrong type in V3
    if (json['ratings'] != null && json['ratings'] is List) {
      ratings = [];
      try {
        (json['ratings'] as List).forEach((v) {
          if (v is int) ratings!.add(v);
        });
      } catch (e) {
        ratings = [];
      }
    }
    reviewsCommentsCount = json['reviews_comments_count'];
    // Defensive parsing for characteristics
    if (json['characteristics'] != null && json['characteristics'] is List) {
      characteristics = <String>[];
      try {
        (json['characteristics'] as List).forEach((v) {
          if (v is String) characteristics!.add(v);
        });
      } catch (e) {
        characteristics = null;
      }
    }
    isExtraPackagingActive = _safeBool(json['is_extra_packaging_active']);
    scheduleAdvanceDineInBookingDuration = json['schedule_advance_dine_in_booking_duration'];
    scheduleAdvanceDineInBookingDurationTimeFormat = json['schedule_advance_dine_in_booking_duration_time_format'];
    isActiveDineIn = _safeBool(json['is_dine_in_active']) ?? false;
    dineInBookingDuration = json['schedule_advance_dine_in_booking_duration'] ?? 0;
    dineInBookingDurationTimeFormat = json['schedule_advance_dine_in_booking_duration_time_format'];
    priceStartFrom = _safeDouble(json['price_starts_from']);
    businessType = json['business_type'] ?? 'restaurant'; // default to restaurant for backward compatibility
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
    data['currency'] = currency;
    data['zone_id'] = zoneId;
    data['free_delivery'] = freeDelivery;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['is_dine_in_active'] = isDineInActive;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['tax'] = tax;
    data['rating_count'] = ratingCount;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['open'] = open;
    data['active'] = active;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    data['delivery_time'] = deliveryTime;
    data['category_ids'] = categoryIds;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['vendor_id'] = vendorId;
    if (cuisineNames != null) {
      data['cuisine'] = cuisineNames!.map((v) => v.toJson()).toList();
    }
    data['order_subscription_active'] = orderSubscriptionActive;
    data['cutlery'] = cutlery;
    data['slug'] = slug;
    data['foods_count'] = foodsCount;
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    data['announcement'] = announcementActive;
    data['announcement_message'] = announcementMessage;
    data['instant_order'] = instantOrder;
    data['customer_date_order_sratus'] = customerDateOrderStatus;
    data['customer_order_date'] = customerOrderDate;
    data['free_delivery_distance_status'] = freeDeliveryDistanceStatus;
    data['free_delivery_distance_value'] = freeDeliveryDistanceValue;
    data['current_opening_time'] = restaurantOpeningTime;
    data['extra_packaging_status'] = extraPackagingStatusIsMandatory;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ratings'] = ratings;
    data['reviews_comments_count'] = reviewsCommentsCount;
    data['characteristics'] = characteristics;
    if (characteristics != null) {
      data['characteristics'] = characteristics!.map((v) => v).toList();
    }
    data['is_extra_packaging_active'] = isExtraPackagingActive;
    data['schedule_advance_dine_in_booking_duration'] = scheduleAdvanceDineInBookingDuration;
    data['schedule_advance_dine_in_booking_duration_time_format'] = scheduleAdvanceDineInBookingDurationTimeFormat;
    data['is_dine_in_active'] = isActiveDineIn;
    data['schedule_advance_dine_in_booking_duration'] = dineInBookingDuration;
    data['schedule_advance_dine_in_booking_duration_time_format'] = dineInBookingDurationTimeFormat;
    data['price_starts_from'] = priceStartFrom;
    data['business_type'] = businessType;
    return data;
  }

  // Helper method to get BusinessType enum from string
  BusinessType getBusinessTypeEnum() {
    return BusinessTypeExtension.fromString(businessType);
  }
}

class Discount {
  int? id;
  String? title;
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
    this.title,
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
    title = json['title'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time'] != null ? json['start_time'].toString().substring(0, json['start_time'].toString().length >= 5 ? 5 : json['start_time'].toString().length) : null;
    endTime = json['end_time'] != null ? json['end_time'].toString().substring(0, json['end_time'].toString().length >= 5 ? 5 : json['end_time'].toString().length) : null;
    // Handle both old and new API field names
    minPurchase = _safeDouble(json['min_purchase'] ?? json['min_purchase_amount']) ?? 0;
    maxDiscount = _safeDouble(json['max_discount'] ?? json['max_discount_amount']) ?? 0;
    discount = _safeDouble(json['discount'] ?? json['discount_amount']) ?? 0;
    discountType = json['discount_type'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
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

  Schedules({this.id, this.restaurantId, this.day, this.openingTime, this.closingTime});

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    day = json['day'];
    openingTime = json['opening_time'] != null
        ? json['opening_time'].toString().substring(0, json['opening_time'].toString().length >= 5 ? 5 : json['opening_time'].toString().length)
        : null;
    closingTime = json['closing_time'] != null
        ? json['closing_time'].toString().substring(0, json['closing_time'].toString().length >= 5 ? 5 : json['closing_time'].toString().length)
        : null;
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

class RestaurantSubscription {
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
  int? totalPackageRenewed;
  String? createdAt;
  String? updatedAt;

  RestaurantSubscription({
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
    this.totalPackageRenewed,
    this.createdAt,
    this.updatedAt,
  });

  RestaurantSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    restaurantId = json['restaurant_id'];
    expiryDate = json['expiry_date'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'];
    mobileApp = json['mobile_app'];
    chat = (json['chat'] != null && json['chat'] != 'null') ? json['chat'] : 0;
    review = json['review'] ?? 0;
    selfDelivery = json['self_delivery'];
    status = json['status'];
    totalPackageRenewed = json['total_package_renewed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    return data;
  }
}

class Refund {
  int? id;
  int? orderId;
  List<String>? imageFullUrl;
  String? customerReason;
  String? customerNote;
  String? adminNote;

  Refund({
    this.id,
    this.orderId,
    this.imageFullUrl,
    this.customerReason,
    this.customerNote,
    this.adminNote,
  });

  Refund.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    if (json['image_full_url'] != null) {
      imageFullUrl = <String>[];
      json['image_full_url'].forEach((v) {
        if(v != null) {
          imageFullUrl!.add(v);
        }
      });
    }
    customerReason = json['customer_reason'];
    customerNote = json['customer_note'];
    adminNote = json['admin_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['image_full_url'] = imageFullUrl;
    data['customer_reason'] = customerReason;
    data['customer_note'] = customerNote;
    data['admin_note'] = adminNote;
    return data;
  }
}

class Foods {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  int? categoryId;
  String? categoryIds;
  String? variations;
  String? addOns;
  String? attributes;
  String? choiceOptions;
  double? price;
  double? tax;
  String? taxType;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? veg;
  int? status;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  int? orderCount;
  double? avgRating;
  int? ratingCount;
  String? rating;
  int? recommended;
  String? slug;
  int? maximumCartQuantity;
  List<Translations>? translations;

  Foods({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.attributes,
    this.choiceOptions,
    this.price,
    this.tax,
    this.taxType,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.veg,
    this.status,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.orderCount,
    this.avgRating,
    this.ratingCount,
    this.rating,
    this.recommended,
    this.slug,
    this.maximumCartQuantity,
    this.translations,
  });

  Foods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    categoryId = json['category_id'];
    categoryIds = json['category_ids'];
    variations = json['variations'];
    addOns = json['add_ons'];
    attributes = json['attributes'];
    choiceOptions = json['choice_options'];
    price = _safeDouble(json['price']);
    tax = _safeDouble(json['tax']);
    taxType = json['tax_type'];
    discount = _safeDouble(json['discount']);
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    veg = json['veg'];
    status = json['status'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    orderCount = json['order_count'];
    avgRating = _safeDouble(json['avg_rating']);
    ratingCount = json['rating_count'];
    rating = json['rating'];
    recommended = json['recommended'];
    slug = json['slug'];
    maximumCartQuantity = json['maximum_cart_quantity'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['category_id'] = categoryId;
    data['category_ids'] = categoryIds;
    data['variations'] = variations;
    data['add_ons'] = addOns;
    data['attributes'] = attributes;
    data['choice_options'] = choiceOptions;
    data['price'] = price;
    data['tax'] = tax;
    data['tax_type'] = taxType;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['veg'] = veg;
    data['status'] = status;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['order_count'] = orderCount;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['rating'] = rating;
    data['recommended'] = recommended;
    data['slug'] = slug;
    data['maximum_cart_quantity'] = maximumCartQuantity;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CuisineModel {
  List<Cuisines>? cuisines;

  CuisineModel({this.cuisines});

  CuisineModel.fromJson(Map<String, dynamic> json) {
    if (json['Cuisines'] != null) {
      cuisines = <Cuisines>[];
      json['Cuisines'].forEach((v) {
        cuisines!.add(Cuisines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cuisines != null) {
      data['Cuisines'] = cuisines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cuisines {
  int? id;
  String? name;
  String? image;
  int? status;
  String? slug;
  String? createdAt;
  String? updatedAt;

  Cuisines({this.id, this.name, this.image, this.status, this.slug, this.createdAt, this.updatedAt});

  Cuisines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    status = json['status'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    return data;
  }
}
