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

class ProductModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<Product>? products;

  ProductModel({
    int? totalSize,
    String? limit,
    String? offset,
    List<Product>? products,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
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
  double? price;
  double? tax;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? setMenu;
  int? status;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  String? restaurantName;
  double? restaurantDiscount;
  String? restaurantOpeningTime;
  String? restaurantClosingTime;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  List<Translation>? translations;
  List<Tag>? tags;
  int? recommendedStatus;
  int? maxOrderQuantity;
  int? itemStock;
  String? stockType;
  int? isHalal;
  int? halalTagStatus;
  List<String?>? nutrition;
  List<String?>? allergies;
  List<int>? taxVatIds;
  List<TaxData>? taxData;
  int? cartQuantityLimit;
  FoodSeoData? foodSeoData;

  // ========== SUPERMARKET FIELDS ==========
  String? barcode;                    // Product barcode (EAN-13, UPC, etc.)
  String? sku;                        // Stock Keeping Unit
  int? reorderPoint;                  // Threshold for low stock alert
  int? reorderQuantity;               // Suggested reorder amount
  List<ExpiryBatch>? expiryBatches;   // Batches with expiry tracking
  DateTime? nearestExpiryDate;        // Calculated: nearest expiry date
  int? expiringWithin7Days;           // Count of items expiring within 7 days
  int? expiringWithin3Days;           // Count of items expiring within 3 days
  int? expiredCount;                  // Count of expired items

  // ========== MULTI-UNIT FIELDS ==========
  List<ProductUnit>? units;
  int? maxQtyPerUser;

  // ========== PHARMACY FIELDS ==========
  int? prescriptionRequired;          // 0 = not required, 1 = required
  PharmacyInfo? pharmacyInfo;         // Nested model for dosage/medical info
  List<GenericAlternative>? genericAlternatives;  // Linked generic medicines

  Product({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.price,
    this.tax,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.setMenu,
    this.status,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.restaurantName,
    this.restaurantDiscount,
    this.restaurantOpeningTime,
    this.restaurantClosingTime,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.translations,
    this.tags,
    this.recommendedStatus,
    this.maxOrderQuantity,
    this.itemStock,
    this.stockType,
    this.isHalal,
    this.halalTagStatus,
    this.nutrition,
    this.allergies,
    this.taxVatIds,
    this.taxData,
    this.cartQuantityLimit,
    this.foodSeoData,
    // Supermarket fields
    this.barcode,
    this.sku,
    this.reorderPoint,
    this.reorderQuantity,
    this.expiryBatches,
    this.nearestExpiryDate,
    this.expiringWithin7Days,
    this.expiringWithin3Days,
    this.expiredCount,
    // Multi-unit fields
    this.units,
    this.maxQtyPerUser,
    // Pharmacy fields
    this.prescriptionRequired,
    this.pharmacyInfo,
    this.genericAlternatives,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'] ?? json['image'];
    categoryId = json['category_id'];
    if (json['category_ids'] != null && json['category_ids'] is List) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    if (json['variations'] != null && json['variations'] is List && (json['variations'] as List).isNotEmpty) {
      variations = [];
      try {
        if(json['variations'][0] is Map && json['variations'][0]['values'] != null) {
          json['variations'].forEach((v) {
            if (v is Map<String, dynamic>) {
              variations!.add(Variation.fromJson(v));
            }
          });
        }
      } catch (_) {
        // Safely ignore variation parsing errors
      }
    }
    if (json['add_ons'] != null && json['add_ons'] is List) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOns.fromJson(v));
      });
    }
    price = _toDouble(json['price']);
    tax = _toDouble(json['tax']);
    discount = _toDouble(json['discount']);
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    setMenu = _toInt(json['set_menu']);
    status = _toInt(json['status']);
    restaurantId = _toInt(json['restaurant_id']);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    restaurantName = json['restaurant_name'];
    restaurantDiscount = _toDouble(json['restaurant_discount']);
    restaurantOpeningTime = json['restaurant_opening_time'];
    restaurantClosingTime = json['restaurant_closing_time'];
    scheduleOrder = _toBool(json['schedule_order']);
    avgRating = _toDouble(json['avg_rating']);
    ratingCount = _toInt(json['rating_count']);
    veg = _toInt(json['veg']);
    if (json['translations'] != null && json['translations'] is List) {
      translations = [];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
    if (json['tags'] != null && json['tags'] is List) {
      tags = [];
      json['tags'].forEach((v) {
        tags!.add(Tag.fromJson(v));
      });
    }
    recommendedStatus = _toInt(json['recommended']);
    maxOrderQuantity = _toInt(json['maximum_cart_quantity']) ?? 0;
    itemStock = _toInt(json['item_stock']);
    stockType = json['stock_type'];
    isHalal = _toInt(json['is_halal']);
    halalTagStatus = _toInt(json['halal_tag_status']);
    if(json['nutritions_name'] != null && json['nutritions_name'] is List) {
      nutrition = [];
      for(var v in json['nutritions_name']) {
        if (v != null) nutrition!.add(v.toString());
      }
    }
    if(json['allergies_name'] != null && json['allergies_name'] is List) {
      allergies = [];
      for(var v in json['allergies_name']) {
        if (v != null) allergies!.add(v.toString());
      }
    }
    if (json['tax_ids'] != null && json['tax_ids'] is List) {
      taxVatIds = [];
      json['tax_ids'].forEach((v) {
        taxVatIds!.add(int.parse(v.toString()));
      });
    }
    if (json['tax_data'] != null && json['tax_data'] is List) {
      taxData = <TaxData>[];
      json['tax_data'].forEach((v) { taxData!.add(TaxData.fromJson(v)); });
    }
    cartQuantityLimit = _toInt(json['maximum_cart_quantity']);
    foodSeoData = json['food_seo_data'] != null ? FoodSeoData.fromJson(json['food_seo_data']) : null;

    // ========== SUPERMARKET FIELDS ==========
    barcode = json['barcode'];
    sku = json['sku'];
    reorderPoint = _toInt(json['reorder_point']);
    reorderQuantity = _toInt(json['reorder_quantity']);
    if (json['expiry_batches'] != null && json['expiry_batches'] is List) {
      expiryBatches = [];
      json['expiry_batches'].forEach((v) {
        expiryBatches!.add(ExpiryBatch.fromJson(v));
      });
    }
    nearestExpiryDate = json['nearest_expiry_date'] != null
        ? DateTime.tryParse(json['nearest_expiry_date'])
        : null;
    expiringWithin7Days = _toInt(json['expiring_within_7_days']);
    expiringWithin3Days = _toInt(json['expiring_within_3_days']);
    expiredCount = _toInt(json['expired_count']);

    // ========== MULTI-UNIT FIELDS ==========
    if (json['units'] != null && json['units'] is List) {
      units = [];
      json['units'].forEach((v) {
        units!.add(ProductUnit.fromJson(v));
      });
    }
    maxQtyPerUser = _toInt(json['max_qty_per_user']);

    // ========== PHARMACY FIELDS ==========
    prescriptionRequired = _toInt(json['prescription_required']);
    pharmacyInfo = json['pharmacy_info'] != null
        ? PharmacyInfo.fromJson(json['pharmacy_info'])
        : null;
    if (json['generic_alternatives'] != null && json['generic_alternatives'] is List) {
      genericAlternatives = [];
      json['generic_alternatives'].forEach((v) {
        genericAlternatives!.add(GenericAlternative.fromJson(v));
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
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['tax'] = tax;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['set_menu'] = setMenu;
    data['status'] = status;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['restaurant_name'] = restaurantName;
    data['restaurant_discount'] = restaurantDiscount;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['recommended'] = recommendedStatus;
    data['veg'] = veg;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    data['maximum_cart_quantity'] = maxOrderQuantity;
    data['item_stock'] = itemStock;
    data['stock_type'] = stockType;
    data['is_halal'] = isHalal;
    data['halal_tag_status'] = halalTagStatus;
    if (nutrition != null) {
      data['nutritions_name'] = nutrition;
    }
    if (allergies != null) {
      data['allergies_name'] = allergies;
    }
    if (taxVatIds != null) {
      data['tax_ids'] = taxVatIds!.map((v) => v.toString()).toList();
    }
    if (taxData != null) {
      data['tax_data'] = taxData!.map((v) => v.toJson()).toList();
    }
    data['maximum_cart_quantity'] = cartQuantityLimit;
    if (foodSeoData != null) {
      data['food_seo_data'] = foodSeoData!.toJson();
    }

    // ========== SUPERMARKET FIELDS ==========
    data['barcode'] = barcode;
    data['sku'] = sku;
    data['reorder_point'] = reorderPoint;
    data['reorder_quantity'] = reorderQuantity;
    if (expiryBatches != null) {
      data['expiry_batches'] = expiryBatches!.map((v) => v.toJson()).toList();
    }
    data['nearest_expiry_date'] = nearestExpiryDate?.toIso8601String().split('T')[0];
    data['expiring_within_7_days'] = expiringWithin7Days;
    data['expiring_within_3_days'] = expiringWithin3Days;
    data['expired_count'] = expiredCount;

    // ========== MULTI-UNIT FIELDS ==========
    if (units != null) {
      data['units'] = units!.map((v) => v.toJson()).toList();
    }
    data['max_qty_per_user'] = maxQtyPerUser;

    // ========== PHARMACY FIELDS ==========
    data['prescription_required'] = prescriptionRequired;
    if (pharmacyInfo != null) {
      data['pharmacy_info'] = pharmacyInfo!.toJson();
    }
    if (genericAlternatives != null) {
      data['generic_alternatives'] = genericAlternatives!.map((v) => v.toJson()).toList();
    }

    return data;
  }

  // ========== HELPER METHODS ==========

  /// Check if product requires prescription (pharmacy)
  bool get requiresPrescription => prescriptionRequired == 1;

  /// Check if product has low stock
  bool get hasLowStock {
    if (reorderPoint == null || itemStock == null) return false;
    return itemStock! <= reorderPoint!;
  }

  /// Check if product is out of stock
  bool get isOutOfStock {
    if (itemStock == null) return false;
    return itemStock! <= 0;
  }

  /// Check if product has expiring items
  bool get hasExpiringItems {
    return (expiringWithin7Days ?? 0) > 0 || (expiringWithin3Days ?? 0) > 0;
  }

  /// Check if product has expired items
  bool get hasExpiredItems => (expiredCount ?? 0) > 0;
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
  String? id;
  String? name;
  String? type;
  String? min;
  String? max;
  String? required;
  List<VariationOption>? variationValues;

  Variation({this.id, this.name, this.type, this.min, this.max, this.required, this.variationValues});

  Variation.fromJson(Map<String, dynamic> json) {
    id = json['variation_id']?.toString();
    name = json['name'];
    type = json['type'];
    min = json['min']?.toString();
    max = json['max']?.toString();
    required = json['required'];
    if (json['values'] != null) {
      variationValues = [];
      json['values'].forEach((v) {
        variationValues!.add(VariationOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variation_id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (variationValues != null) {
      data['values'] = variationValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationOption {
  String? level;
  String? optionPrice;
  String? totalStock;
  String? stockType;
  String? sellCount;
  String? optionId;
  String? currentStock;

  VariationOption({this.level, this.optionPrice, this.totalStock, this.stockType, this.sellCount, this.optionId, this.currentStock});

  VariationOption.fromJson(Map<String, dynamic> json) {
    level = json['label'];
    optionPrice = json['optionPrice']?.toString();
    totalStock = json['total_stock']?.toString();
    stockType = json['stock_type']?.toString();
    sellCount = json['sell_count']?.toString();
    optionId = json['option_id']?.toString();
    currentStock = json['current_stock']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    data['total_stock'] = totalStock;
    data['stock_type'] = stockType;
    data['sell_count'] = sellCount;
    data['option_id'] = optionId;
    data['current_stock'] = currentStock;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;
  int? status;
  List<Translation>? translations;
  int? addonStock;
  String? stockType;
  List<int>? taxVatIds;
  int? addonCategoryId;

  AddOns({this.id, this.name, this.price, this.status, this.translations, this.addonStock, this.stockType, this.taxVatIds, this.addonCategoryId});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = _toDouble(json['price']);
    status = _toInt(json['status']);
    if (json['translations'] != null && json['translations'] is List) {
      translations = [];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
    addonStock = json['addon_stock'];
    stockType = json['stock_type'];
    if (json['tax_ids'] != null && json['tax_ids'] is List) {
      taxVatIds = [];
      json['tax_ids'].forEach((v) {
        taxVatIds!.add(int.parse(v.toString()));
      });
    }
    addonCategoryId = json['addon_category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['status'] = status;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['addon_stock'] = addonStock;
    data['stock_type'] = stockType;
    if (taxVatIds != null) {
      data['tax_ids'] = taxVatIds!.map((v) => v.toString()).toList();
    }
    data['addon_category_id'] = addonCategoryId;
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
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    data['options'] = options;
    return data;
  }
}

class Translation {
  int? id;
  String? locale;
  String? key;
  String? value;

  Translation({this.id, this.locale, this.key, this.value});

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class Tag {
  int? id;
  String? tag;

  Tag({this.id, this.tag});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tag'] = tag;
    return data;
  }
}

class TaxData {
  int? id;
  String? name;
  double? taxRate;

  TaxData({this.id, this.name, this.taxRate});

  TaxData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    taxRate = _toDouble(json['tax_rate']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tax_rate'] = taxRate;
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

// ========== PRODUCT UNIT MODEL ==========

class ProductUnit {
  int? id;
  String? name;
  String? label;
  String? labelAr;
  String? symbol;
  double? sellingPrice;
  double? conversionRate;
  int? minOrderQty;
  bool? isDefault;
  bool? isPurchasable;

  ProductUnit({
    this.id,
    this.name,
    this.label,
    this.labelAr,
    this.symbol,
    this.sellingPrice,
    this.conversionRate,
    this.minOrderQty,
    this.isDefault,
    this.isPurchasable,
  });

  ProductUnit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    label = json['label'];
    labelAr = json['label_ar'];
    symbol = json['symbol'];
    sellingPrice = _toDouble(json['selling_price']);
    conversionRate = _toDouble(json['conversion_rate']);
    minOrderQty = _toInt(json['min_order_qty']);
    isDefault = json['is_default'] == 1 || json['is_default'] == true;
    isPurchasable = json['is_purchasable'] == 1 || json['is_purchasable'] == true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['label'] = label;
    data['label_ar'] = labelAr;
    data['symbol'] = symbol;
    data['selling_price'] = sellingPrice;
    data['conversion_rate'] = conversionRate;
    data['min_order_qty'] = minOrderQty;
    data['is_default'] = (isDefault ?? false) ? 1 : 0;
    data['is_purchasable'] = (isPurchasable ?? true) ? 1 : 0;
    return data;
  }
}

// ========== SUPERMARKET MODELS ==========

/// Expiry batch model for tracking product batches with expiry dates
class ExpiryBatch {
  int? id;
  int? productId;
  String? batchNumber;
  int? quantity;
  DateTime? expiryDate;
  DateTime? manufacturingDate;
  String? status;  // 'valid', 'expiring_soon', 'expired'
  String? createdAt;

  ExpiryBatch({
    this.id,
    this.productId,
    this.batchNumber,
    this.quantity,
    this.expiryDate,
    this.manufacturingDate,
    this.status,
    this.createdAt,
  });

  ExpiryBatch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    batchNumber = json['batch_number'];
    quantity = _toInt(json['quantity']);
    expiryDate = json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date']) : null;
    manufacturingDate = json['manufacturing_date'] != null ? DateTime.tryParse(json['manufacturing_date']) : null;
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['batch_number'] = batchNumber;
    data['quantity'] = quantity;
    data['expiry_date'] = expiryDate?.toIso8601String().split('T')[0];
    data['manufacturing_date'] = manufacturingDate?.toIso8601String().split('T')[0];
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }

  /// Check if batch is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if batch is expiring within given days
  bool isExpiringWithin(int days) {
    if (expiryDate == null) return false;
    final threshold = DateTime.now().add(Duration(days: days));
    return expiryDate!.isBefore(threshold) && !isExpired;
  }

  /// Get days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}

// ========== PHARMACY MODELS ==========

/// Pharmacy-specific information for medicines
class PharmacyInfo {
  String? dosage;                    // e.g., "500mg"
  String? frequency;                 // e.g., "Twice daily"
  String? duration;                  // e.g., "7 days"
  String? usageInstructions;         // How to take the medicine
  List<String>? sideEffects;         // Known side effects
  List<String>? contraindications;   // When not to use
  List<MedicineWarning>? warnings;   // Pregnancy, driving, alcohol warnings
  String? activeIngredient;          // Generic compound name
  String? manufacturer;              // Drug manufacturer
  String? strength;                  // e.g., "500mg", "10ml"
  String? form;                      // e.g., "tablet", "syrup", "injection"
  String? storageConditions;         // e.g., "Store below 25°C"

  PharmacyInfo({
    this.dosage,
    this.frequency,
    this.duration,
    this.usageInstructions,
    this.sideEffects,
    this.contraindications,
    this.warnings,
    this.activeIngredient,
    this.manufacturer,
    this.strength,
    this.form,
    this.storageConditions,
  });

  PharmacyInfo.fromJson(Map<String, dynamic> json) {
    dosage = json['dosage'];
    frequency = json['frequency'];
    duration = json['duration'];
    usageInstructions = json['usage_instructions'];
    if (json['side_effects'] != null) {
      sideEffects = List<String>.from(json['side_effects']);
    }
    if (json['contraindications'] != null) {
      contraindications = List<String>.from(json['contraindications']);
    }
    if (json['warnings'] != null) {
      warnings = [];
      json['warnings'].forEach((v) {
        warnings!.add(MedicineWarning.fromJson(v));
      });
    }
    activeIngredient = json['active_ingredient'];
    manufacturer = json['manufacturer'];
    strength = json['strength'];
    form = json['form'];
    storageConditions = json['storage_conditions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dosage'] = dosage;
    data['frequency'] = frequency;
    data['duration'] = duration;
    data['usage_instructions'] = usageInstructions;
    data['side_effects'] = sideEffects;
    data['contraindications'] = contraindications;
    if (warnings != null) {
      data['warnings'] = warnings!.map((v) => v.toJson()).toList();
    }
    data['active_ingredient'] = activeIngredient;
    data['manufacturer'] = manufacturer;
    data['strength'] = strength;
    data['form'] = form;
    data['storage_conditions'] = storageConditions;
    return data;
  }
}

/// Medicine warning types
class MedicineWarning {
  String? type;         // 'pregnancy', 'driving', 'alcohol', 'elderly', 'children'
  String? level;        // 'caution', 'warning', 'contraindicated'
  String? description;  // Detailed warning text

  MedicineWarning({
    this.type,
    this.level,
    this.description,
  });

  MedicineWarning.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    level = json['level'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['level'] = level;
    data['description'] = description;
    return data;
  }
}

/// Generic alternative medicine
class GenericAlternative {
  int? productId;
  String? name;
  double? price;
  String? imageUrl;
  String? manufacturer;
  String? activeIngredient;

  GenericAlternative({
    this.productId,
    this.name,
    this.price,
    this.imageUrl,
    this.manufacturer,
    this.activeIngredient,
  });

  GenericAlternative.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['name'];
    price = _toDouble(json['price']);
    imageUrl = json['image_url'];
    manufacturer = json['manufacturer'];
    activeIngredient = json['active_ingredient'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['name'] = name;
    data['price'] = price;
    data['image_url'] = imageUrl;
    data['manufacturer'] = manufacturer;
    data['active_ingredient'] = activeIngredient;
    return data;
  }
}