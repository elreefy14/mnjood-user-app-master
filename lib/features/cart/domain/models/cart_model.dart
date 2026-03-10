import 'package:mnjood/common/models/product_model.dart';

class CartModel {
  int? _id;
  double? _price;
  double? _discountedPrice;
  List<List<bool?>>? _variations;
  double? _discountAmount;
  int? _quantity;
  List<AddOn>? _addOnIds;
  List<AddOns>? _addOns;
  bool? _isCampaign;
  Product? _product;
  int? _quantityLimit;
  List<List<int?>>? _variationsStock;
  int? _unitId;
  CartUnitInfo? _unitInfo;

  CartModel(
      int? id,
      double price,
      double? discountedPrice,
      double discountAmount,
      int? quantity,
      List<AddOn> addOnIds,
      List<AddOns> addOns,
      bool isCampaign,
      Product? product,
      List<List<bool?>> variations,
      int? quantityLimit,
      List<List<int?>> variationsStock,
      {int? unitId,
      CartUnitInfo? unitInfo}) {
    _id = id;
    _price = price;
    _discountedPrice = discountedPrice;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _addOnIds = addOnIds;
    _addOns = addOns;
    _isCampaign = isCampaign;
    _product = product;
    _variations = variations;
    _quantityLimit = quantityLimit;
    _variationsStock = variationsStock;
    _unitId = unitId;
    _unitInfo = unitInfo;
  }

  int? get id => _id;
  double? get price => _price;
  double? get discountedPrice => _discountedPrice;
  double? get discountAmount => _discountAmount;
  // ignore: unnecessary_getters_setters
  int? get quantity => _quantity;
  // ignore: unnecessary_getters_setters
  set quantity(int? qty) => _quantity = qty;
  List<AddOn>? get addOnIds => _addOnIds;
  List<AddOns>? get addOns => _addOns;
  bool? get isCampaign => _isCampaign;
  Product? get product => _product;
  List<List<bool?>>? get variations => _variations;
  int? get quantityLimit => _quantityLimit;
  List<List<int?>>? get variationsStock => _variationsStock;
  int? get unitId => _unitId;
  CartUnitInfo? get unitInfo => _unitInfo;

  CartModel.fromJson(Map<String, dynamic> json) {
    _id = json['cart_id'];
    _price = json['price']?.toDouble() ?? 0.0;
    _discountedPrice = json['discounted_price']?.toDouble();
    _discountAmount = json['discount_amount']?.toDouble();
    _quantity = json['quantity'];
    if (json['add_on_ids'] != null) {
      _addOnIds = [];
      json['add_on_ids'].forEach((v) {
        _addOnIds!.add(AddOn.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      _addOns = [];
      json['add_ons'].forEach((v) {
        _addOns!.add(AddOns.fromJson(v));
      });
    }
    _isCampaign = json['is_campaign'];
    if (json['product'] != null) {
      // Create a mutable copy of the product JSON
      var productJson = Map<String, dynamic>.from(json['product']);
      // Inject vendor IDs from cart item level into product if not present
      // This ensures Product.fromJson can correctly determine businessType
      if (productJson['supermarket_id'] == null && json['supermarket_id'] != null) {
        productJson['supermarket_id'] = json['supermarket_id'];
      }
      if (productJson['pharmacy_id'] == null && json['pharmacy_id'] != null) {
        productJson['pharmacy_id'] = json['pharmacy_id'];
      }
      if (productJson['restaurant_id'] == null && json['restaurant_id'] != null) {
        productJson['restaurant_id'] = json['restaurant_id'];
      }
      _product = Product.fromJson(productJson);
    }
    if (json['variations'] != null) {
      _variations = [];
      for(int index=0; index<json['variations'].length; index++) {
        _variations!.add([]);
        for(int i=0; i<json['variations'][index].length; i++) {
          _variations![index].add(json['variations'][index][i]);
        }
      }
    }
    if(json['quantity_limit'] != null) {
      _quantityLimit = int.parse(json['quantity_limit']);
    }
    _unitId = json['unit_id'];
    if (json['unit_info'] != null && json['unit_info'] is Map<String, dynamic>) {
      _unitInfo = CartUnitInfo.fromJson(json['unit_info']);
    }
    if (json['variations_stock'] != null) {
      _variationsStock = [];
      for(int index=0; index<json['variations_stock'].length; index++) {
        _variationsStock!.add([]);
        for(int i=0; i<json['variations_stock'][index].length; i++) {
          _variationsStock![index].add(json['variations_stock'][index][i]);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = _price;
    data['discounted_price'] = _discountedPrice;
    data['discount_amount'] = _discountAmount;
    data['quantity'] = _quantity;
    if (_addOnIds != null) {
      data['add_on_ids'] = _addOnIds!.map((v) => v.toJson()).toList();
    }
    if (_addOns != null) {
      data['add_ons'] = _addOns!.map((v) => v.toJson()).toList();
    }
    data['is_campaign'] = _isCampaign;
    data['product'] = _product?.toJson();
    data['variations'] = _variations;
    data['quantity_limit'] = _quantityLimit?.toString();
    if (_unitId != null) data['unit_id'] = _unitId;
    if (_unitInfo != null) data['unit_info'] = _unitInfo!.toJson();
    return data;
  }
}

class AddOn {
  int? _id;
  int? _quantity;

  AddOn({int? id, int? quantity}) {
    _id = id;
    _quantity = quantity;
  }

  int? get id => _id;
  int? get quantity => _quantity;

  AddOn.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['quantity'] = _quantity;
    return data;
  }
}
