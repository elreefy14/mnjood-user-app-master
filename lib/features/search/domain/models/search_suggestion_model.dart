class SearchSuggestionModel {
  List<Foods>? foods;
  List<Vendors>? vendors;
  // Backward compatibility - kept for old API responses
  List<Vendors>? restaurants;

  SearchSuggestionModel({this.foods, this.vendors, this.restaurants});

  SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    if (json['foods'] != null) {
      foods = <Foods>[];
      json['foods'].forEach((v) {
        foods!.add(Foods.fromJson(v));
      });
    }
    // Support both 'vendors' (new) and 'restaurants' (old) keys
    if (json['vendors'] != null) {
      vendors = <Vendors>[];
      json['vendors'].forEach((v) {
        vendors!.add(Vendors.fromJson(v));
      });
    } else if (json['restaurants'] != null) {
      // Backward compatibility: parse 'restaurants' into 'vendors'
      vendors = <Vendors>[];
      json['restaurants'].forEach((v) {
        vendors!.add(Vendors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    if (vendors != null) {
      data['vendors'] = vendors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Foods {
  int? id;
  String? name;
  String? image;
  String? imageFullUrl;
  double? price;
  int? vendorId;
  String? vendorName;
  String? vendorType; // restaurant, supermarket, pharmacy
  List<Translations>? translations;

  Foods({
    this.id,
    this.name,
    this.image,
    this.imageFullUrl,
    this.price,
    this.vendorId,
    this.vendorName,
    this.vendorType,
    this.translations,
  });

  Foods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    imageFullUrl = json['image_full_url'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    // Support both new 'vendor_id' and old 'restaurant_id' keys
    vendorId = json['vendor_id'] ?? json['restaurant_id'];
    vendorName = json['vendor_name'] ?? json['restaurant_name'];
    vendorType = json['vendor_type'] ?? 'restaurant'; // Default to restaurant for backward compatibility
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
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['price'] = price;
    data['vendor_id'] = vendorId;
    data['vendor_name'] = vendorName;
    data['vendor_type'] = vendorType;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt});

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

/// Unified vendor model for search suggestions
/// Supports restaurants, supermarkets, and pharmacies
class Vendors {
  int? id;
  String? name;
  String? logo;
  String? logoFullUrl;
  String? address;
  double? rating;
  String? type; // restaurant, supermarket, pharmacy
  // Legacy fields for backward compatibility
  bool? gstStatus;
  String? gstCode;
  bool? freeDeliveryDistanceStatus;
  String? freeDeliveryDistanceValue;
  RestaurantConfig? restaurantConfig;
  List<Translations>? translations;

  Vendors({
    this.id,
    this.name,
    this.logo,
    this.logoFullUrl,
    this.address,
    this.rating,
    this.type,
    this.gstStatus,
    this.gstCode,
    this.freeDeliveryDistanceStatus,
    this.freeDeliveryDistanceValue,
    this.restaurantConfig,
    this.translations,
  });

  Vendors.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    logoFullUrl = json['logo_full_url'];
    address = json['address'];
    rating = json['rating'] != null ? double.tryParse(json['rating'].toString()) : null;
    type = json['type'] ?? 'restaurant'; // Default to restaurant for backward compatibility
    // Legacy fields
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    freeDeliveryDistanceStatus = json['free_delivery_distance_status'];
    freeDeliveryDistanceValue = json['free_delivery_distance_value'];
    restaurantConfig = json['restaurant_config'] != null
        ? RestaurantConfig.fromJson(json['restaurant_config'])
        : null;
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
    data['logo'] = logo;
    data['logo_full_url'] = logoFullUrl;
    data['address'] = address;
    data['rating'] = rating;
    data['type'] = type;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['free_delivery_distance_status'] = freeDeliveryDistanceStatus;
    data['free_delivery_distance_value'] = freeDeliveryDistanceValue;
    if (restaurantConfig != null) {
      data['restaurant_config'] = restaurantConfig!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RestaurantConfig {
  int? id;
  int? restaurantId;
  bool? instantOrder;
  bool? customerDateOrderSratus;
  int? customerOrderDate;
  String? createdAt;
  String? updatedAt;

  RestaurantConfig(
      {this.id,
        this.restaurantId,
        this.instantOrder,
        this.customerDateOrderSratus,
        this.customerOrderDate,
        this.createdAt,
        this.updatedAt});

  RestaurantConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    instantOrder = json['instant_order'];
    customerDateOrderSratus = json['customer_date_order_sratus'];
    customerOrderDate = json['customer_order_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['instant_order'] = instantOrder;
    data['customer_date_order_sratus'] = customerDateOrderSratus;
    data['customer_order_date'] = customerOrderDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
