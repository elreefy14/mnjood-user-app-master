class PurchaseOrderModel {
  int? id;
  int? restaurantId;
  int? supplierId;
  String? supplierName;
  String? supplierPhone;
  String? supplierEmail;
  String? poNumber;
  String? status;
  String? orderDate;
  String? expectedDeliveryDate;
  double? subtotal;
  double? taxAmount;
  double? discountAmount;
  double? shippingCost;
  double? totalAmount;
  String? notes;
  List<PurchaseOrderItemModel>? items;
  String? createdAt;
  String? updatedAt;

  PurchaseOrderModel({
    this.id,
    this.restaurantId,
    this.supplierId,
    this.supplierName,
    this.supplierPhone,
    this.supplierEmail,
    this.poNumber,
    this.status,
    this.orderDate,
    this.expectedDeliveryDate,
    this.subtotal,
    this.taxAmount,
    this.discountAmount,
    this.shippingCost,
    this.totalAmount,
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    supplierPhone = json['supplier_phone'];
    supplierEmail = json['supplier_email'];
    poNumber = json['po_number'];
    status = json['status'];
    orderDate = json['order_date'];
    expectedDeliveryDate = json['expected_delivery_date'];
    subtotal = json['subtotal']?.toDouble();
    taxAmount = json['tax_amount']?.toDouble();
    discountAmount = json['discount_amount']?.toDouble();
    shippingCost = json['shipping_cost']?.toDouble();
    totalAmount = json['total_amount']?.toDouble();
    notes = json['notes'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(PurchaseOrderItemModel.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'expected_delivery_date': expectedDeliveryDate,
      'notes': notes,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'partially_received':
        return 'Partially Received';
      case 'received':
        return 'Received';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  bool get isDraft => status == 'draft';
  bool get isOpen => ['draft', 'sent', 'partially_received'].contains(status);
  bool get isClosed => ['received', 'cancelled'].contains(status);
}

class PurchaseOrderItemModel {
  int? id;
  int? purchaseOrderId;
  int? foodId;
  String? productName;
  String? productImage;
  double? quantity;
  double? unitPrice;
  double? receivedQuantity;
  double? totalPrice;

  PurchaseOrderItemModel({
    this.id,
    this.purchaseOrderId,
    this.foodId,
    this.productName,
    this.productImage,
    this.quantity,
    this.unitPrice,
    this.receivedQuantity,
    this.totalPrice,
  });

  PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    purchaseOrderId = json['purchase_order_id'];
    foodId = json['food_id'];
    productName = json['product_name'];
    productImage = json['product_image'];
    quantity = json['quantity']?.toDouble();
    unitPrice = json['unit_price']?.toDouble();
    receivedQuantity = json['received_quantity']?.toDouble();
    totalPrice = json['total_price']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  double get pendingQuantity => (quantity ?? 0) - (receivedQuantity ?? 0);
}
