/// Stock adjustment model for tracking inventory changes
class StockAdjustmentModel {
  int? id;
  int? productId;
  String? productName;
  String? adjustmentType;  // 'add', 'remove', 'set', 'damage', 'return', 'expired'
  int? quantity;
  int? previousStock;
  int? newStock;
  String? reason;
  String? batchNumber;
  String? adjustedBy;
  String? createdAt;

  StockAdjustmentModel({
    this.id,
    this.productId,
    this.productName,
    this.adjustmentType,
    this.quantity,
    this.previousStock,
    this.newStock,
    this.reason,
    this.batchNumber,
    this.adjustedBy,
    this.createdAt,
  });

  StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    productName = json['product_name'];
    adjustmentType = json['adjustment_type'];
    quantity = json['quantity'];
    previousStock = json['previous_stock'];
    newStock = json['new_stock'];
    reason = json['reason'];
    batchNumber = json['batch_number'];
    adjustedBy = json['adjusted_by'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['adjustment_type'] = adjustmentType;
    data['quantity'] = quantity;
    data['previous_stock'] = previousStock;
    data['new_stock'] = newStock;
    data['reason'] = reason;
    data['batch_number'] = batchNumber;
    data['adjusted_by'] = adjustedBy;
    data['created_at'] = createdAt;
    return data;
  }

  /// Get the change amount (positive or negative)
  int get changeAmount {
    if (newStock == null || previousStock == null) return quantity ?? 0;
    return newStock! - previousStock!;
  }

  /// Check if this was an increase in stock
  bool get isIncrease => changeAmount > 0;

  /// Get adjustment type display label
  String get adjustmentTypeLabel {
    switch (adjustmentType) {
      case 'add':
        return 'add_stock';
      case 'remove':
        return 'remove_stock';
      case 'set':
        return 'stock_adjustment';
      case 'damage':
        return 'damaged_stock';
      case 'return':
        return 'returned_stock';
      case 'expired':
        return 'expired';
      default:
        return 'stock_adjustment';
    }
  }
}

/// Model for creating new stock adjustment
class StockAdjustmentBody {
  int productId;
  String adjustmentType;
  int quantity;
  String? reason;
  String? batchNumber;

  StockAdjustmentBody({
    required this.productId,
    required this.adjustmentType,
    required this.quantity,
    this.reason,
    this.batchNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['adjustment_type'] = adjustmentType;
    data['quantity'] = quantity;
    if (reason != null) data['reason'] = reason;
    if (batchNumber != null) data['batch_number'] = batchNumber;
    return data;
  }
}

/// Paginated stock adjustment history model
class StockAdjustmentHistoryModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<StockAdjustmentModel>? adjustments;

  StockAdjustmentHistoryModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.adjustments,
  });

  StockAdjustmentHistoryModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = json['offset']?.toString();
    if (json['adjustments'] != null) {
      adjustments = [];
      json['adjustments'].forEach((v) {
        adjustments!.add(StockAdjustmentModel.fromJson(v));
      });
    }
    // Alternative key
    if (adjustments == null && json['data'] != null) {
      adjustments = [];
      json['data'].forEach((v) {
        adjustments!.add(StockAdjustmentModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (adjustments != null) {
      data['adjustments'] = adjustments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
