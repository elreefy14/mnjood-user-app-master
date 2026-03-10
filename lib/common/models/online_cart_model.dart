import 'package:mnjood/common/models/product_model.dart';

class OnlineCartModel {
  int? id;
  int? userId;
  int? itemId;
  bool? isGuest;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  String? itemType;
  double? price;
  int? quantity;
  List<Variation>? variation;
  String? createdAt;
  String? updatedAt;
  Product? product;
  int? unitId;
  CartUnitInfo? unitInfo;

  OnlineCartModel(
      {this.id,
        this.userId,
        this.itemId,
        this.isGuest,
        this.addOnIds,
        this.addOnQtys,
        this.itemType,
        this.price,
        this.quantity,
        this.variation,
        this.createdAt,
        this.updatedAt,
        this.product,
        this.unitId,
        this.unitInfo});

  OnlineCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    itemId = json['item_id'];
    isGuest = json['is_guest'];
    addOnIds = json['add_on_ids'] != null ? List<int>.from(json['add_on_ids']) : [];
    addOnQtys = json['add_on_qtys'] != null ? List<int>.from(json['add_on_qtys']) : [];
    itemType = json['item_type'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    quantity = json['quantity'];
    if (json['variations'] != null) {
      variation = [];
      json['variations'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // Inject vendor_type from cart item into product data so businessType getter works
    if (json['item'] != null) {
      Map<String, dynamic> itemData = Map<String, dynamic>.from(json['item']);
      // Pass vendor_type from cart item level to product if not already present
      if (json['vendor_type'] != null && itemData['vendor_type'] == null) {
        itemData['vendor_type'] = json['vendor_type'];
      }
      product = Product.fromJson(itemData);
    }
    unitId = json['unit_id'];
    if (json['unit'] != null && json['unit'] is Map<String, dynamic>) {
      unitInfo = CartUnitInfo.fromJson(json['unit']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['item_id'] = itemId;
    data['is_guest'] = isGuest;
    data['add_on_ids'] = addOnIds;
    data['add_on_qtys'] = addOnQtys;
    data['item_type'] = itemType;
    data['price'] = price;
    data['quantity'] = quantity;
    if (variation != null) {
      data['variations'] = variation!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (product != null) {
      data['item'] = product!.toJson();
    }
    if (unitId != null) data['unit_id'] = unitId;
    if (unitInfo != null) data['unit'] = unitInfo!.toJson();
    return data;
  }
}

class Variation {
  String? name;
  Value? values;

  Variation({this.name, this.values});

  Variation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    values = json['values'] != null ? Value.fromJson(json['values']) : null;
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

class Value {
  List<String>? label;

  Value({this.label});

  Value.fromJson(Map<String, dynamic> json) {
    label = json['label'] != null ? List<String>.from(json['label']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}
