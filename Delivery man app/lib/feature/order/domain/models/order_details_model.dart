import 'dart:convert';

class OrderDetailsModel {
  int? id;
  int? foodId;
  int? orderId;
  double? price;
  FoodDetails? foodDetails;
  List<Variation>? variation;
  List<OldVariation>? oldVariation;
  List<AddOn>? addOns;
  double? discountOnFood;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;
  int? unitId;
  String? unitLabel;
  double? unitSellingPrice;

  OrderDetailsModel({
    this.id,
    this.foodId,
    this.orderId,
    this.price,
    this.foodDetails,
    this.variation,
    this.oldVariation,
    this.addOns,
    this.discountOnFood,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
    this.unitId,
    this.unitLabel,
    this.unitSellingPrice,
  });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    price = json['price']?.toDouble() ?? 0.0;
    // Safely parse food_details - handle both Map and String formats
    if (json['food_details'] != null) {
      try {
        var foodDetailsData = json['food_details'];
        if (foodDetailsData is String) {
          // If food_details is a JSON string, decode it
          foodDetailsData = jsonDecode(foodDetailsData);
        }
        if (foodDetailsData is Map<String, dynamic>) {
          foodDetails = FoodDetails.fromJson(foodDetailsData);
        }
      } catch (e) {
        // If parsing fails, create a basic FoodDetails with minimal data
        foodDetails = FoodDetails(
          name: json['food_details']?['name']?.toString() ?? 'Unknown Item',
          description: json['food_details']?['description']?.toString(),
          imageFullUrl: json['food_details']?['image_full_url']?.toString() ?? json['food_details']?['image']?.toString(),
        );
      }
    }
    variation = [];
    oldVariation = [];
    if (json['variation'] != null && json['variation'].isNotEmpty) {
      if(json['variation'][0]['values'] != null || json['variation'][0]['options'] != null) {
        json['variation'].forEach((v) {
          variation!.add(Variation.fromJson(v));
        });
      }else {
        json['variation'].forEach((v) {
          oldVariation!.add(OldVariation.fromJson(v));
        });
      }
    }
    addOns = [];
    if (json['add_ons'] != null && json['add_ons'] is List) {
      for (var v in json['add_ons']) {
        if (v is Map<String, dynamic>) {
          addOns!.add(AddOn.fromJson(v));
        }
      }
    }
    discountOnFood = json['discount_on_food']?.toDouble();
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = json['tax_amount']?.toDouble();
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = json['total_add_on_price']?.toDouble();
    unitId = json['unit_id'];
    unitLabel = json['unit_label'];
    unitSellingPrice = json['unit_selling_price'] != null ? double.tryParse(json['unit_selling_price'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (foodDetails != null) {
      data['food_details'] = foodDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_on_food'] = discountOnFood;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    if (unitId != null) data['unit_id'] = unitId;
    if (unitLabel != null) data['unit_label'] = unitLabel;
    if (unitSellingPrice != null) data['unit_selling_price'] = unitSellingPrice;
    return data;
  }
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

class AddOn {
  String? name;
  double? price;
  int? quantity;
  String? stockType;
  int? addonStock;

  AddOn({this.name, this.price, this.quantity, this.stockType, this.addonStock});

  AddOn.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    quantity = json['quantity'];
    stockType = json['stock_type'];
    addonStock = json['addon_stock'] != null ? int.tryParse(json['addon_stock'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['stock_type'] = stockType;
    data['addon_stock'] = addonStock;
    return data;
  }
}


class FoodDetails {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  List<CategoryIds>? categoryIds;
  List<Variation>? variations;
  List<AddOns>? addOns;
  double? price;
  double? tax;
  String? taxType;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  String? restaurantName;
  double? restaurantDiscount;
  double? avgRating;
  int? veg;
  int? ratingCount;

  FoodDetails({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.price,
    this.tax,
    this.taxType,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.restaurantName,
    this.restaurantDiscount,
    this.avgRating,
    this.veg,
    this.ratingCount,
  });

  FoodDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'] ?? json['image'];
    if (json['category_ids'] != null) {
      categoryIds = [];
      var catIds = json['category_ids'];
      // Handle case where category_ids is a string like "[61]"
      if (catIds is String) {
        try {
          catIds = catIds.replaceAll('[', '').replaceAll(']', '').split(',');
          for (var id in catIds) {
            if (id.toString().trim().isNotEmpty) {
              categoryIds!.add(CategoryIds(id: id.toString().trim()));
            }
          }
        } catch (e) {
          // Ignore parsing errors
        }
      } else if (catIds is List) {
        for (var v in catIds) {
          if (v is Map<String, dynamic>) {
            categoryIds!.add(CategoryIds.fromJson(v));
          } else {
            // Handle simple integer/string IDs
            categoryIds!.add(CategoryIds(id: v.toString()));
          }
        }
      }
    }
    variations = [];
    if (json['variations'] != null && json['variations'] is List) {
      for (var v in json['variations']) {
        if (v is Map<String, dynamic>) {
          variations!.add(Variation.fromJson(v));
        }
      }
    }
    addOns = [];
    if (json['add_ons'] != null && json['add_ons'] is List) {
      for (var v in json['add_ons']) {
        if (v is Map<String, dynamic>) {
          addOns!.add(AddOns.fromJson(v));
        }
      }
    }
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    tax = json['tax'] != null ? double.tryParse(json['tax'].toString()) : null;
    taxType = json['tax_type'];
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    restaurantName = json['restaurant_name'];
    restaurantDiscount = json['restaurant_discount'] != null ? double.tryParse(json['restaurant_discount'].toString()) : null;
    avgRating = json['avg_rating'] != null ? double.tryParse(json['avg_rating'].toString()) ?? 0.0 : 0.0;
    veg = json['veg'] != null ? int.tryParse(json['veg'].toString()) ?? 0 : 0;
    ratingCount = json['rating_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
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
    data['tax_type'] = taxType;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['restaurant_name'] = restaurantName;
    data['restaurant_discount'] = restaurantDiscount;
    data['avg_rating'] = avgRating;
    data['veg'] = veg;
    data['rating_count'] = ratingCount;
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
    if(json['max'] != null) {
      name = json['name'];
      multiSelect = json['type'] == 'multi';
      min =  multiSelect! ? int.parse(json['min'].toString()) : 0;
      max = multiSelect! ? int.parse(json['max'].toString()) : 0;
      required = json['required'] == 'on' || json['required'] == true;
      var valuesData = json['values'] ?? json['options'];
      if (valuesData != null) {
        variationValues = [];
        valuesData.forEach((v) {
          variationValues!.add(VariationValue.fromJson(v));
        });
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

  VariationValue({this.level, this.optionPrice});

  VariationValue.fromJson(Map<String, dynamic> json) {
    level = json['label'] ?? json['name'];
    optionPrice = double.tryParse((json['optionPrice'] ?? json['price'])?.toString() ?? '0') ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    return data;
  }
}

class OldVariation {
  String? type;
  double? price;

  OldVariation({this.type, this.price});

  OldVariation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;

  AddOns({this.id, this.name, this.price});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
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