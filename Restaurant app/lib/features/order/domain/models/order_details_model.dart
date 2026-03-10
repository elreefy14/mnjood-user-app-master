import 'dart:convert';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

class OrderDetailsModel {
  int? id;
  int? foodId;
  int? orderId;
  double? price;
  Product? foodDetails;
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
  List<OrderEditLogs>? orderEditLogs;
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
    this.orderEditLogs,
    this.unitId,
    this.unitLabel,
    this.unitSellingPrice,
  });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    price = json['price']?.toDouble();
    if (json['food_details'] != null) {
      dynamic foodData = json['food_details'];
      if (foodData is String) {
        try {
          foodData = jsonDecode(foodData);
        } catch (_) {}
      }
      if (foodData is Map<String, dynamic>) {
        try {
          foodDetails = Product.fromJson(foodData);
        } catch (_) {
          foodDetails = Product(
            id: foodData['id'],
            name: foodData['name'],
            description: foodData['description'],
            imageFullUrl: foodData['image_full_url'] ?? foodData['image'],
            price: double.tryParse(foodData['price']?.toString() ?? ''),
            discount: double.tryParse(foodData['discount']?.toString() ?? ''),
            discountType: foodData['discount_type'],
            restaurantId: foodData['restaurant_id'],
          );
        }
      }
    }
    variation = [];
    oldVariation = [];
    try {
      if (json['variation'] != null && json['variation'] is List && (json['variation'] as List).isNotEmpty) {
        final firstVariation = json['variation'][0];
        if (firstVariation is Map && firstVariation['values'] != null) {
          json['variation'].forEach((v) {
            if (v is Map<String, dynamic>) {
              variation!.add(Variation.fromJson(v));
            }
          });
        } else {
          json['variation'].forEach((v) {
            if (v is Map<String, dynamic>) {
              oldVariation!.add(OldVariation.fromJson(v));
            }
          });
        }
      }
    } catch (e) {
      // Safely ignore parsing errors for variations
    }
    if (json['add_ons'] != null && json['add_ons'] is List) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOn.fromJson(v));
      });
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
    unitSellingPrice = json['unit_selling_price']?.toDouble();
    if (json['order_edit_logs'] != null && json['order_edit_logs'] is List) {
      orderEditLogs = <OrderEditLogs>[];
      json['order_edit_logs'].forEach((v) {
        orderEditLogs!.add(OrderEditLogs.fromJson(v));
      });
    }
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
    data['unit_id'] = unitId;
    data['unit_label'] = unitLabel;
    data['unit_selling_price'] = unitSellingPrice;
    if (orderEditLogs != null) {
      data['order_edit_logs'] = orderEditLogs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddOn {
  int? id;
  String? name;
  double? price;
  int? quantity;

  AddOn({this.id, this.name, this.price, this.quantity});

  AddOn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price']?.toDouble();
    quantity = json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class OldVariation {
  String? type;
  double? price;

  OldVariation({this.type, this.price});

  OldVariation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
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
    id = json['id'];
    orderId = json['order_id'];
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