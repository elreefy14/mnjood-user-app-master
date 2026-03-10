import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mnjood/util/app_constants.dart';

/// Helper function to parse values that can be bool, int, or String to int
/// Used for fields like 'veg' where API may return true/false or 0/1
int _parseBoolOrInt(dynamic value) {
  if (value == null) return 0;
  if (value is bool) return value ? 1 : 0;
  if (value is int) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return 1;
    if (value.toLowerCase() == 'false') return 0;
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

/// Helper function to parse values that can be bool, int, or String to bool
/// Used for fields like 'is_halal', 'halal_tag_status' where API may return various types
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    if (value.toLowerCase() == 'true' || value == '1') return true;
    return false;
  }
  return false;
}

class ProductModel {
  int? totalSize;
  double? minPrice;
  double? maxPrice;
  String? limit;
  int? offset;
  List<Product>? products;

  ProductModel({this.totalSize, this.minPrice, this.maxPrice, this.limit, this.offset, this.products});

  ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle both legacy format and V3 API format
    // Legacy: {total_size, offset, products: [...]}
    // V3 API: {success, data: [...], meta: {pagination: {total, current_page}}}

    // Handle pagination - try legacy first, then V3 API meta format
    totalSize = json['total_size'] ?? json['meta']?['pagination']?['total'];
    minPrice = json['min_price'] != null ? double.tryParse(json['min_price'].toString()) : null;
    maxPrice = json['max_price'] != null ? double.tryParse(json['max_price'].toString()) : null;
    limit = json['limit']?.toString();

    // Handle offset - try legacy first, then V3 API meta format
    if (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) {
      offset = int.tryParse(json['offset'].toString());
    } else if (json['meta']?['pagination']?['current_page'] != null) {
      offset = json['meta']['pagination']['current_page'];
    }

    // Handle products - try 'products' key first, then 'data' key (V3 API)
    var productsData = json['products'] ?? json['data'];
    products = []; // Always initialize to empty list to prevent null
    if (productsData != null && productsData is List) {
      productsData.forEach((v) {
        // Parse all products - let individual Product handle variations safely
        try {
          products!.add(Product.fromJson(v));
        } catch (e) {
          debugPrint('Error parsing product: $e');
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['min_price'] = minPrice;
    data['max_price'] = maxPrice;
    data['limit'] = limit;
    data['offset'] = offset;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<Variation>? variations;
  List<AddOns>? addOns;
  List<ChoiceOptions>? choiceOptions;
  double? price;
  double? tax;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? restaurantId;
  int? supermarketId;
  int? pharmacyId;
  String? vendorType;
  String? restaurantName;
  String? restaurantLogoUrl;
  double? restaurantDiscount;
  int? restaurantStatus;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  int? cartQuantityLimit;
  int? maxQtyPerUser;
  bool? isRestaurantHalalActive;
  bool? isHalalFood;
  String? stockType;
  int? itemStock;
  bool? available;
  List<String>? nutritionsName;
  List<String>? allergiesName;
  FoodSeoData? foodSeoData;
  int? reviewCount;
  List<Reviews>? reviews;
  List<int>? ratings;

  // Product units (multi-unit selling)
  List<ProductUnit>? units;

  // Pharmacy-specific fields
  bool? prescriptionRequired;
  String? manufacturer;
  String? brand;
  String? unit;
  String? packageSize;
  String? genericName;
  String? activeIngredient;
  String? dosageForm;
  String? strength;
  String? therapeuticCategory;
  String? routeOfAdministration;
  String? storageConditions;
  String? drugInteractions;
  String? sideEffects;
  String? contraindications;
  String? maxDailyDose;
  String? drugSchedule;
  String? ageRestriction;
  String? pregnancyCategory;
  String? lactationSafety;

  Product({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.choiceOptions,
    this.price,
    this.tax,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.restaurantId,
    this.supermarketId,
    this.pharmacyId,
    this.restaurantName,
    this.restaurantLogoUrl,
    this.restaurantDiscount,
    this.restaurantStatus,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.cartQuantityLimit,
    this.maxQtyPerUser,
    this.isRestaurantHalalActive,
    this.isHalalFood,
    this.stockType,
    this.itemStock,
    this.available,
    this.nutritionsName,
    this.allergiesName,
    this.foodSeoData,
    this.reviewCount,
    this.reviews,
    this.ratings,
    this.units,
    // Pharmacy-specific fields
    this.prescriptionRequired,
    this.manufacturer,
    this.brand,
    this.unit,
    this.packageSize,
    this.genericName,
    this.activeIngredient,
    this.dosageForm,
    this.strength,
    this.therapeuticCategory,
    this.routeOfAdministration,
    this.storageConditions,
    this.drugInteractions,
    this.sideEffects,
    this.contraindications,
    this.maxDailyDose,
    this.drugSchedule,
    this.ageRestriction,
    this.pregnancyCategory,
    this.lactationSafety,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    // V3 API uses 'image', V1 uses 'image_full_url'
    // Handle relative paths by constructing full URL with product subdirectory
    String? rawImage = json['image_full_url'] ?? json['image'];
    if (rawImage != null && rawImage.isNotEmpty) {
      if (!rawImage.startsWith('http')) {
        // Relative path - construct full URL with product subdirectory
        // Check if path already includes directory
        if (rawImage.contains('/')) {
          imageFullUrl = '${AppConstants.baseUrl}/storage/$rawImage';
        } else {
          // Just filename - add product directory
          imageFullUrl = '${AppConstants.baseUrl}/storage/product/$rawImage';
        }
      } else {
        // Full URL - use as-is
        imageFullUrl = rawImage;
      }
    }
    categoryId = json['category_id'];
    if (json['category_ids'] != null) {
      categoryIds = [];
      var catIds = json['category_ids'];
      // Handle string format "[66,67]" from order details API
      if (catIds is String) {
        try {
          catIds = jsonDecode(catIds);
        } catch (e) {
          catIds = []; // Fallback to empty if parsing fails
        }
      }
      if (catIds is List) {
        catIds.forEach((v) {
          if (v is int) {
            categoryIds!.add(CategoryIds(id: v.toString()));
          } else if (v is Map<String, dynamic>) {
            categoryIds!.add(CategoryIds.fromJson(v));
          }
        });
      }
    }
    if (json['variations'] != null) {
      variations = [];
      var variationData = json['variations'];
      // Handle string format "[]" from order details API
      if (variationData is String) {
        try {
          variationData = jsonDecode(variationData);
        } catch (e) {
          variationData = [];
        }
      }
      if (variationData is List) {
        variationData.forEach((v) {
          if (v is Map<String, dynamic>) {
            variations!.add(Variation.fromJson(v));
          }
        });
      }
    }
    if (json['add_ons'] != null && json['add_ons'] is List && json['add_ons'].length > 0) {
      addOns = [];
      json['add_ons'].forEach((v) {
        if (v is Map<String, dynamic>) {
          addOns!.add(AddOns.fromJson(v));
        }
      });
    } else if (json['addons'] != null && json['addons'] is List) {
      addOns = [];
      json['addons'].forEach((v) {
        if (v is Map<String, dynamic>) {
          addOns!.add(AddOns.fromJson(v));
        }
      });
    }
    if (json['choice_options'] != null && json['choice_options'] is! String) {
      choiceOptions = [];
      json['choice_options'].forEach((v) {
        choiceOptions!.add(ChoiceOptions.fromJson(v));
      });
    }
    price = double.tryParse(json['price']?.toString() ?? '') ?? 0;
    tax = json['tax'] != null ? double.tryParse(json['tax'].toString()) : null;
    discount = double.tryParse(json['discount']?.toString() ?? '') ?? 0;
    discountType = json['discount_type'] ?? 'percent';
    // V3 API: compute discount from discount_price if discount is 0
    if (discount == 0 && json['discount_price'] != null) {
      double? discountedPrice = double.tryParse(json['discount_price'].toString());
      if (discountedPrice != null && discountedPrice > 0 && discountedPrice < (price ?? 0)) {
        discount = double.parse(((price ?? 0) - discountedPrice).toStringAsFixed(2));
        discountType = 'amount';
      }
    }
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    restaurantId = json['restaurant_id'];
    supermarketId = json['supermarket_id'];
    pharmacyId = json['pharmacy_id'];
    vendorType = json['vendor_type'];
    // V3 API: Get vendor name and ID from correct vendor type (pharmacy/supermarket/restaurant)
    if (json['supermarket'] != null && json['supermarket'] is Map<String, dynamic>) {
      restaurantName = json['supermarket']['name'];
      supermarketId ??= json['supermarket']['id'];
    } else if (json['pharmacy'] != null && json['pharmacy'] is Map<String, dynamic>) {
      restaurantName = json['pharmacy']['name'];
      pharmacyId ??= json['pharmacy']['id'];
    } else {
      restaurantName = json['restaurant_name'];
    }
    // Populate restaurantId from vendor ID if null OR 0 (for supermarket/pharmacy products)
    if (restaurantId == null || restaurantId == 0) {
      restaurantId = supermarketId ?? pharmacyId;
    }
    // Fallback to vendor object if still null
    if (json['vendor'] != null && json['vendor'] is Map<String, dynamic>) {
      var vendor = json['vendor'];
      if (restaurantId == null || restaurantId == 0) {
        restaurantId = vendor['id'];
      }
      restaurantName ??= vendor['name'];
      restaurantLogoUrl ??= vendor['logo'];
    }
    // Also check for direct restaurant_logo field (used in campaign items)
    restaurantLogoUrl ??= json['restaurant_logo'];
    restaurantDiscount = double.tryParse(json['restaurant_discount']?.toString() ?? '') ?? 0;
    restaurantStatus = json['restaurant_status'];
    scheduleOrder = json['schedule_order'];
    // V3 API uses 'rating', V1 uses 'avg_rating'
    avgRating = double.tryParse((json['avg_rating'] ?? json['rating'])?.toString() ?? '') ?? 0;
    ratingCount = json['rating_count'];
    veg = _parseBoolOrInt(json['veg']);
    cartQuantityLimit = json['maximum_cart_quantity'];
    maxQtyPerUser = json['max_qty_per_user'] != null ? int.tryParse(json['max_qty_per_user'].toString()) : null;
    isRestaurantHalalActive = _parseBool(json['halal_tag_status']);
    isHalalFood = _parseBool(json['is_halal']);
    // Parse stock fields - handle both V1 (item_stock) and V3 API (stock_quantity) field names
    stockType = json['stock_type'] ?? 'unlimited';
    itemStock = json['item_stock'] != null
        ? int.tryParse(json['item_stock'].toString())
        : (json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : null);

    // If track_inventory is false, treat as unlimited stock
    if (json['track_inventory'] == false) {
      stockType = 'unlimited';
    }
    // Default to true if 'available' field is missing (V3 API doesn't always include it)
    available = json.containsKey('available') ? _parseBool(json['available']) : true;
    nutritionsName = json['nutritions_name']?.cast<String>();
    allergiesName = json['allergies_name']?.cast<String>();
    foodSeoData = json['food_seo_data'] != null ? FoodSeoData.fromJson(json['food_seo_data']) : null;
    reviewCount = json['review_count'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }

    if (json['ratings'] != null) {
      ratings = List<int>.filled(5, 0);
      if (json['ratings'] is Map) {
        (json['ratings'] as Map).forEach((key, value) {
          try {
            int ratingIndex = int.parse(key.toString()) - 1;
            if (ratingIndex >= 0 && ratingIndex < 5) {
              ratings![ratingIndex] = value is int ? value : 0;
            }
          } catch (e) {
            debugPrint('Error parsing rating key: $e');
          }
        });
      } else if (json['ratings'] is List) {
        ratings = List<int>.filled(5, 0);

      }
    }

    // Parse product units
    if (json['units'] != null && json['units'] is List) {
      units = [];
      json['units'].forEach((v) {
        if (v is Map<String, dynamic>) {
          units!.add(ProductUnit.fromJson(v));
        }
      });
    }

    // Parse pharmacy-specific fields
    prescriptionRequired = _parseBool(json['prescription_required']);
    manufacturer = json['manufacturer'];
    brand = json['brand'];
    unit = json['unit'];
    packageSize = json['package_size'];
    genericName = json['generic_name'];
    activeIngredient = json['active_ingredient'];
    dosageForm = json['dosage_form'];
    strength = json['strength'];
    therapeuticCategory = json['therapeutic_category'];
    routeOfAdministration = json['route_of_administration'];
    storageConditions = json['storage_conditions'];
    drugInteractions = json['drug_interactions'];
    sideEffects = json['side_effects'];
    contraindications = json['contraindications'];
    maxDailyDose = json['max_daily_dose'];
    drugSchedule = json['drug_schedule'];
    ageRestriction = json['age_restriction'];
    pregnancyCategory = json['pregnancy_category'];
    lactationSafety = json['lactation_safety'];
  }

  /// Get the default unit (first where isDefault == true, or first unit)
  ProductUnit? get defaultUnit {
    if (units == null || units!.isEmpty) return null;
    return units!.firstWhere((u) => u.isDefault == true, orElse: () => units!.first);
  }

  /// Whether this product has multiple purchasable units
  bool get hasMultipleUnits => units != null && units!.where((u) => u.isPurchasable == true).length > 1;

  /// Detect business type based on vendor_type field or ID
  String get businessType {
    // Use vendor_type field if available (from cart API: "App\Models\Pharmacy" or "coffee")
    if (vendorType != null && vendorType!.isNotEmpty) {
      final type = vendorType!.toLowerCase();
      if (type.contains('pharmacy')) return 'pharmacy';
      if (type.contains('supermarket')) return 'supermarket';
      if (type.contains('coffee')) return 'coffee_shop';
      if (type.contains('restaurant')) return 'restaurant';
    }
    // Fallback to ID-based detection
    if (supermarketId != null) return 'supermarket';
    if (pharmacyId != null) return 'pharmacy';
    return 'restaurant';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['category_id'] = categoryId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (choiceOptions != null) {
      data['choice_options'] = choiceOptions!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['tax'] = tax;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['restaurant_id'] = restaurantId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_discount'] = restaurantDiscount;
    data['restaurant_status'] = restaurantStatus;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['veg'] = veg;
    data['maximum_cart_quantity'] = cartQuantityLimit;
    data['max_qty_per_user'] = maxQtyPerUser;
    data['halal_tag_status'] = isRestaurantHalalActive;
    data['is_halal'] = isHalalFood;
    data['stock_type'] = stockType;
    data['item_stock'] = itemStock;
    data['available'] = available;
    data['nutritions_name'] = nutritionsName;
    data['allergies_name'] = allergiesName;
    if (foodSeoData != null) {
      data['food_seo_data'] = foodSeoData!.toJson();
    }
    data['review_count'] = reviewCount;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['ratings'] = ratings;
    if (units != null) {
      data['units'] = units!.map((v) => v.toJson()).toList();
    }
    // Pharmacy-specific fields
    data['prescription_required'] = prescriptionRequired;
    data['manufacturer'] = manufacturer;
    data['brand'] = brand;
    data['unit'] = unit;
    data['package_size'] = packageSize;
    data['generic_name'] = genericName;
    data['active_ingredient'] = activeIngredient;
    data['dosage_form'] = dosageForm;
    data['strength'] = strength;
    data['therapeutic_category'] = therapeuticCategory;
    data['route_of_administration'] = routeOfAdministration;
    data['storage_conditions'] = storageConditions;
    data['drug_interactions'] = drugInteractions;
    data['side_effects'] = sideEffects;
    data['contraindications'] = contraindications;
    data['max_daily_dose'] = maxDailyDose;
    data['drug_schedule'] = drugSchedule;
    data['age_restriction'] = ageRestriction;
    data['pregnancy_category'] = pregnancyCategory;
    data['lactation_safety'] = lactationSafety;
    return data;
  }
}

class CategoryIds {
  String? id;

  CategoryIds({this.id});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}

class Variation {
  String? name;
  bool? multiSelect;
  int? min;
  int? max;
  bool? required;
  List<VariationValue>? variationValues;

  Variation({this.name, this.multiSelect, this.min, this.max, this.required, this.variationValues});

  Variation.fromJson(Map<String, dynamic> json) {
    if (json['max'] != null || json['name'] != null) {
      name = json['name'];
      multiSelect = json['type'] == 'multi';
      min = (multiSelect ?? false) ? int.tryParse(json['min'].toString()) ?? 0 : 0;
      max = (multiSelect ?? false) ? int.tryParse(json['max'].toString()) ?? 0 : 0;
      // V1 sends required='on', V3 sends required=true/false
      required = json['required'] == 'on' || json['required'] == true;
      // V1 uses 'values', V3 uses 'options'
      variationValues = [];
      var valuesData = json['values'] ?? json['options'];
      if (valuesData != null && valuesData is List) {
        for (var v in valuesData) {
          if (v is Map<String, dynamic>) {
            variationValues!.add(VariationValue.fromJson(v));
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = multiSelect;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (variationValues != null) {
      data['values'] = variationValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationValue {
  String? level;
  double? optionPrice;
  bool? isSelected;
  String? stockType;
  int? currentStock;
  int? optionId;

  VariationValue({this.level, this.optionPrice, this.isSelected, this.stockType, this.currentStock, this.optionId});

  VariationValue.fromJson(Map<String, dynamic> json) {
    // V1 uses 'label', V3 uses 'name'
    level = json['label'] ?? json['name'];
    // V1 uses 'optionPrice', V3 uses 'price'
    optionPrice = double.tryParse((json['optionPrice'] ?? json['price'])?.toString() ?? '0') ?? 0;
    isSelected = json['isSelected'];
    stockType = json['stock_type'];
    currentStock = json['current_stock'] != null ? int.tryParse(json['current_stock'].toString()) : null;
    optionId = json['option_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    data['isSelected'] = isSelected;
    data['stock_type'] = stockType;
    data['current_stock'] = currentStock;
    data['option_id'] = optionId;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;
  String? stockType;
  int? addonStock;

  AddOns({
    this.id,
    this.name,
    this.price,
    this.stockType,
    this.addonStock,
  });

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = double.tryParse(json['price']?.toString() ?? '0') ?? 0;
    stockType = json['stock_type'];
    addonStock = json['addon_stock'] != null ? int.parse(json['addon_stock'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['stock_type'] = stockType;
    data['addon_stock'] = addonStock;
    return data;
  }
}

class ChoiceOptions {
  String? name;
  String? title;
  List<String>? options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    options = json['options'] != null ? json['options'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    data['options'] = options;
    return data;
  }
}

class FoodSeoData {
  int? id;
  int? foodId;
  int? itemCampaignId;
  String? title;
  String? description;
  String? index;
  String? noFollow;
  String? noImageIndex;
  String? noArchive;
  String? noSnippet;
  String? maxSnippet;
  String? maxSnippetValue;
  String? maxVideoPreview;
  String? maxVideoPreviewValue;
  String? maxImagePreview;
  String? maxImagePreviewValue;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;

  FoodSeoData({
    this.id,
    this.foodId,
    this.itemCampaignId,
    this.title,
    this.description,
    this.index,
    this.noFollow,
    this.noImageIndex,
    this.noArchive,
    this.noSnippet,
    this.maxSnippet,
    this.maxSnippetValue,
    this.maxVideoPreview,
    this.maxVideoPreviewValue,
    this.maxImagePreview,
    this.maxImagePreviewValue,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
  });

  FoodSeoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    itemCampaignId = json['item_campaign_id'];
    title = json['title'];
    description = json['description'];
    index = json['index'];
    noFollow = json['no_follow'];
    noImageIndex = json['no_image_index'];
    noArchive = json['no_archive'];
    noSnippet = json['no_snippet'];
    maxSnippet = json['max_snippet'];
    maxSnippetValue = json['max_snippet_value'];
    maxVideoPreview = json['max_video_preview'];
    maxVideoPreviewValue = json['max_video_preview_value'];
    maxImagePreview = json['max_image_preview'];
    maxImagePreviewValue = json['max_image_preview_value'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['item_campaign_id'] = itemCampaignId;
    data['title'] = title;
    data['description'] = description;
    data['index'] = index;
    data['no_follow'] = noFollow;
    data['no_image_index'] = noImageIndex;
    data['no_archive'] = noArchive;
    data['no_snippet'] = noSnippet;
    data['max_snippet'] = maxSnippet;
    data['max_snippet_value'] = maxSnippetValue;
    data['max_video_preview'] = maxVideoPreview;
    data['max_video_preview_value'] = maxVideoPreviewValue;
    data['max_image_preview'] = maxImagePreview;
    data['max_image_preview_value'] = maxImagePreviewValue;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}

class Reviews {
  int? id;
  int? foodId;
  int? rating;
  String? comment;
  int? userId;
  String? createdAt;
  String? userName;

  Reviews({
    this.id,
    this.foodId,
    this.rating,
    this.comment,
    this.userId,
    this.createdAt,
    this.userName,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    rating = json['rating'];
    comment = json['comment'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['rating'] = rating;
    data['comment'] = comment;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['user_name'] = userName;
    return data;
  }
}

class ProductUnit {
  int? unitId;
  String? name;
  String? label;
  String? labelAr;
  String? symbol;
  double? sellingPrice;
  double? discountedPrice;
  double? conversionRate;
  int? minOrderQty;
  bool? isDefault;
  bool? isPurchasable;

  ProductUnit({
    this.unitId,
    this.name,
    this.label,
    this.labelAr,
    this.symbol,
    this.sellingPrice,
    this.discountedPrice,
    this.conversionRate,
    this.minOrderQty,
    this.isDefault,
    this.isPurchasable,
  });

  ProductUnit.fromJson(Map<String, dynamic> json) {
    unitId = json['unit_id'];
    name = json['name'];
    label = json['label'];
    labelAr = json['label_ar'];
    symbol = json['symbol'];
    sellingPrice = double.tryParse(json['selling_price']?.toString() ?? '');
    discountedPrice = double.tryParse(json['discounted_price']?.toString() ?? '');
    conversionRate = double.tryParse(json['conversion_rate']?.toString() ?? '');
    minOrderQty = json['min_order_qty'] != null ? int.tryParse(json['min_order_qty'].toString()) : null;
    isDefault = json['is_default'] == true || json['is_default'] == 1;
    isPurchasable = json['is_purchasable'] == true || json['is_purchasable'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unit_id'] = unitId;
    data['name'] = name;
    data['label'] = label;
    data['label_ar'] = labelAr;
    data['symbol'] = symbol;
    data['selling_price'] = sellingPrice;
    data['discounted_price'] = discountedPrice;
    data['conversion_rate'] = conversionRate;
    data['min_order_qty'] = minOrderQty;
    data['is_default'] = isDefault;
    data['is_purchasable'] = isPurchasable;
    return data;
  }

  /// Get the effective price (discounted if available, otherwise selling)
  double? get effectivePrice => (discountedPrice != null && discountedPrice! > 0) ? discountedPrice : sellingPrice;
}

class CartUnitInfo {
  int? unitId;
  String? name;
  String? label;
  String? labelAr;
  String? symbol;

  CartUnitInfo({this.unitId, this.name, this.label, this.labelAr, this.symbol});

  CartUnitInfo.fromJson(Map<String, dynamic> json) {
    unitId = json['unit_id'];
    name = json['name'];
    label = json['label'];
    labelAr = json['label_ar'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unit_id'] = unitId;
    data['name'] = name;
    data['label'] = label;
    data['label_ar'] = labelAr;
    data['symbol'] = symbol;
    return data;
  }
}