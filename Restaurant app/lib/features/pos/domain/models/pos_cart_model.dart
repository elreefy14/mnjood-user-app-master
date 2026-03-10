import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

/// Model for a single item in the POS cart
class PosCartItem {
  final int foodId;
  final Product product;
  int quantity;
  final double unitPrice;
  final double discount;
  final Map<String, dynamic> variation;
  final List<String> variant;
  final List<int> addOnIds;
  final List<int> addOnQtys;
  final String? barcode;

  PosCartItem({
    required this.foodId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.variation = const {},
    this.variant = const [],
    this.addOnIds = const [],
    this.addOnQtys = const [],
    this.barcode,
  });

  /// Calculate the total price for this item (unit price * quantity)
  double get totalPrice => unitPrice * quantity;

  /// Calculate the discounted price
  double get discountedPrice {
    if (product.discountType == 'percent') {
      return unitPrice - (unitPrice * (product.discount ?? 0) / 100);
    } else {
      return unitPrice - (product.discount ?? 0);
    }
  }

  /// Calculate total with discount
  double get totalWithDiscount => discountedPrice * quantity;

  /// Convert to API request format
  Map<String, dynamic> toApiJson() {
    return {
      'food_id': foodId,
      'quantity': quantity,
      'variation': variation,
      'variant': variant,
      'add_on_ids': addOnIds,
      'add_on_qtys': addOnQtys,
    };
  }

  /// Create a copy with updated quantity
  PosCartItem copyWith({int? quantity}) {
    return PosCartItem(
      foodId: foodId,
      product: product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      discount: discount,
      variation: variation,
      variant: variant,
      addOnIds: addOnIds,
      addOnQtys: addOnQtys,
      barcode: barcode,
    );
  }

  /// Create from JSON (for held orders)
  factory PosCartItem.fromJson(Map<String, dynamic> json) {
    return PosCartItem(
      foodId: json['food_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      discount: double.parse((json['discount'] ?? 0).toString()),
      variation: json['variation'] ?? {},
      variant: List<String>.from(json['variant'] ?? []),
      addOnIds: List<int>.from(json['add_on_ids'] ?? []),
      addOnQtys: List<int>.from(json['add_on_qtys'] ?? []),
      barcode: json['barcode'],
    );
  }

  /// Convert to JSON (for holding orders)
  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'product': product.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'variation': variation,
      'variant': variant,
      'add_on_ids': addOnIds,
      'add_on_qtys': addOnQtys,
      'barcode': barcode,
    };
  }
}

/// Model for the entire POS cart
class PosCart {
  final List<PosCartItem> items;
  final int? customerId;
  final String? customerPhone;
  final String? customerName;
  final double discountPercent;
  final double discountAmount;
  final String discountType; // 'percent' or 'amount'
  final String? note;

  PosCart({
    this.items = const [],
    this.customerId,
    this.customerPhone,
    this.customerName,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.discountType = 'percent',
    this.note,
  });

  /// Calculate subtotal (before tax and discount)
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalWithDiscount);
  }

  /// Calculate discount value
  double get discountValue {
    if (discountType == 'percent') {
      return subtotal * discountPercent / 100;
    }
    return discountAmount;
  }

  /// Calculate subtotal after discount
  double get subtotalAfterDiscount => subtotal - discountValue;

  /// Calculate tax (15% VAT)
  double get tax => subtotalAfterDiscount * 0.15;

  /// Calculate total (subtotal after discount + tax)
  double get total => subtotalAfterDiscount + tax;

  /// Get total item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Create a copy with modifications
  PosCart copyWith({
    List<PosCartItem>? items,
    int? customerId,
    String? customerPhone,
    String? customerName,
    double? discountPercent,
    double? discountAmount,
    String? discountType,
    String? note,
  }) {
    return PosCart(
      items: items ?? this.items,
      customerId: customerId ?? this.customerId,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      note: note ?? this.note,
    );
  }

  /// Create from JSON (for held orders)
  factory PosCart.fromJson(Map<String, dynamic> json) {
    return PosCart(
      items: (json['items'] as List?)
              ?.map((e) => PosCartItem.fromJson(e))
              .toList() ??
          [],
      customerId: json['customer_id'],
      customerPhone: json['customer_phone'],
      customerName: json['customer_name'],
      discountPercent: double.parse((json['discount_percent'] ?? 0).toString()),
      discountAmount: double.parse((json['discount_amount'] ?? 0).toString()),
      discountType: json['discount_type'] ?? 'percent',
      note: json['note'],
    );
  }

  /// Convert to JSON (for holding orders)
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'customer_id': customerId,
      'customer_phone': customerPhone,
      'customer_name': customerName,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'discount_type': discountType,
      'note': note,
    };
  }
}
