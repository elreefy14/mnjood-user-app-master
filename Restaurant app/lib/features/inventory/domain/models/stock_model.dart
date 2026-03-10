/// Stock overview model for inventory dashboard
class StockOverviewModel {
  int? totalProducts;
  int? inStockCount;
  int? lowStockCount;
  int? outOfStockCount;
  double? totalInventoryValue;
  List<LowStockProduct>? lowStockProducts;
  List<ExpiringProduct>? expiringProducts;

  StockOverviewModel({
    this.totalProducts,
    this.inStockCount,
    this.lowStockCount,
    this.outOfStockCount,
    this.totalInventoryValue,
    this.lowStockProducts,
    this.expiringProducts,
  });

  StockOverviewModel.fromJson(Map<String, dynamic> json) {
    totalProducts = json['total_products'];
    inStockCount = json['in_stock_count'];
    lowStockCount = json['low_stock_count'];
    outOfStockCount = json['out_of_stock_count'];
    totalInventoryValue = json['total_inventory_value']?.toDouble();
    if (json['low_stock_products'] != null) {
      lowStockProducts = [];
      json['low_stock_products'].forEach((v) {
        lowStockProducts!.add(LowStockProduct.fromJson(v));
      });
    }
    if (json['expiring_products'] != null) {
      expiringProducts = [];
      json['expiring_products'].forEach((v) {
        expiringProducts!.add(ExpiringProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_products'] = totalProducts;
    data['in_stock_count'] = inStockCount;
    data['low_stock_count'] = lowStockCount;
    data['out_of_stock_count'] = outOfStockCount;
    data['total_inventory_value'] = totalInventoryValue;
    if (lowStockProducts != null) {
      data['low_stock_products'] = lowStockProducts!.map((v) => v.toJson()).toList();
    }
    if (expiringProducts != null) {
      data['expiring_products'] = expiringProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  /// Get stock health percentage
  double get stockHealthPercentage {
    if (totalProducts == null || totalProducts == 0) return 100;
    return ((inStockCount ?? 0) / totalProducts!) * 100;
  }

  /// Check if there are critical stock issues
  bool get hasCriticalIssues {
    return (outOfStockCount ?? 0) > 0 || (lowStockCount ?? 0) > 5;
  }
}

/// Low stock product model
class LowStockProduct {
  int? id;
  String? name;
  String? imageFullUrl;
  int? currentStock;
  int? reorderPoint;
  String? stockType;
  String? barcode;
  double? price;
  int? categoryId;
  String? categoryName;

  LowStockProduct({
    this.id,
    this.name,
    this.imageFullUrl,
    this.currentStock,
    this.reorderPoint,
    this.stockType,
    this.barcode,
    this.price,
    this.categoryId,
    this.categoryName,
  });

  LowStockProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name'];
    // Handle both 'image_full_url' (from low-stock API) and 'image' (from out-of-stock API)
    imageFullUrl = json['image_full_url'] ?? json['image'];
    // Handle stock: current_stock (low-stock API) or calculate from item_stock - sell_count (out-of-stock API)
    if (json['current_stock'] != null) {
      currentStock = json['current_stock'] is int ? json['current_stock'] : int.tryParse(json['current_stock'].toString());
    } else if (json['item_stock'] != null && json['sell_count'] != null) {
      final itemStock = json['item_stock'] is int ? json['item_stock'] : int.tryParse(json['item_stock'].toString()) ?? 0;
      final sellCount = json['sell_count'] is int ? json['sell_count'] : int.tryParse(json['sell_count'].toString()) ?? 0;
      currentStock = itemStock - sellCount;
      if (currentStock! < 0) currentStock = 0;
    } else {
      currentStock = json['item_stock'] is int ? json['item_stock'] : int.tryParse(json['item_stock']?.toString() ?? '0');
    }
    reorderPoint = json['reorder_point'] is int ? json['reorder_point'] : int.tryParse(json['reorder_point']?.toString() ?? '');
    stockType = json['stock_type'];
    barcode = json['barcode'];
    price = json['price']?.toDouble();
    categoryId = json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? '');
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['current_stock'] = currentStock;
    data['reorder_point'] = reorderPoint;
    data['stock_type'] = stockType;
    data['barcode'] = barcode;
    data['price'] = price;
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    return data;
  }

  /// Get stock deficit (how many items needed to reach reorder point)
  int get stockDeficit {
    if (reorderPoint == null || currentStock == null) return 0;
    return reorderPoint! - currentStock!;
  }

  /// Check if out of stock
  bool get isOutOfStock => (currentStock ?? 0) <= 0;

  /// Get stock status label
  String get stockStatus {
    if (isOutOfStock) return 'out_of_stock';
    if (stockDeficit > 0) return 'low_stock';
    return 'in_stock';
  }
}

/// Out of stock products response model with pagination
class OutOfStockProductsResponse {
  int? totalSize;
  int? limit;
  int? offset;
  List<LowStockProduct>? products;

  OutOfStockProductsResponse({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
  });

  OutOfStockProductsResponse.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'] is int ? json['total_size'] : int.tryParse(json['total_size']?.toString() ?? '');
    limit = json['limit'] is int ? json['limit'] : int.tryParse(json['limit']?.toString() ?? '');
    offset = json['offset'] is int ? json['offset'] : int.tryParse(json['offset']?.toString() ?? '');
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        try {
          products!.add(LowStockProduct.fromJson(v));
        } catch (e) {
          print('Error parsing product: $e');
        }
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

/// Expiring product model
class ExpiringProduct {
  int? id;
  String? name;
  String? imageFullUrl;
  String? batchNumber;
  int? quantity;
  DateTime? expiryDate;
  int? daysUntilExpiry;
  String? status;  // 'expired', 'expiring_3_days', 'expiring_7_days'

  ExpiringProduct({
    this.id,
    this.name,
    this.imageFullUrl,
    this.batchNumber,
    this.quantity,
    this.expiryDate,
    this.daysUntilExpiry,
    this.status,
  });

  ExpiringProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    batchNumber = json['batch_number'];
    quantity = json['quantity'];
    expiryDate = json['expiry_date'] != null
        ? DateTime.tryParse(json['expiry_date'])
        : null;
    daysUntilExpiry = json['days_until_expiry'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['batch_number'] = batchNumber;
    data['quantity'] = quantity;
    data['expiry_date'] = expiryDate?.toIso8601String().split('T')[0];
    data['days_until_expiry'] = daysUntilExpiry;
    data['status'] = status;
    return data;
  }

  /// Check if expired
  bool get isExpired => (daysUntilExpiry ?? 0) < 0 || status == 'expired';

  /// Check if expiring within 3 days
  bool get isExpiringSoon {
    if (daysUntilExpiry == null) return false;
    return daysUntilExpiry! >= 0 && daysUntilExpiry! <= 3;
  }

  /// Get urgency level (0=normal, 1=warning, 2=critical, 3=expired)
  int get urgencyLevel {
    if (isExpired) return 3;
    if (daysUntilExpiry != null && daysUntilExpiry! <= 3) return 2;
    if (daysUntilExpiry != null && daysUntilExpiry! <= 7) return 1;
    return 0;
  }
}
