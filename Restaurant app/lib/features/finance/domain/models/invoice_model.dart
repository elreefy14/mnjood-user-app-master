class InvoiceModel {
  int? id;
  int? restaurantId;
  int? supplierId;
  String? supplierName;
  int? purchaseOrderId;
  String? invoiceNumber;
  String? supplierInvoiceNumber;
  String? invoiceDate;
  String? dueDate;
  String? status;
  double? subtotal;
  double? taxAmount;
  double? totalAmount;
  double? amountPaid;
  double? amountDue;
  List<PaymentRecordModel>? payments;
  String? createdAt;
  String? updatedAt;

  InvoiceModel({
    this.id,
    this.restaurantId,
    this.supplierId,
    this.supplierName,
    this.purchaseOrderId,
    this.invoiceNumber,
    this.supplierInvoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.status,
    this.subtotal,
    this.taxAmount,
    this.totalAmount,
    this.amountPaid,
    this.amountDue,
    this.payments,
    this.createdAt,
    this.updatedAt,
  });

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    purchaseOrderId = json['purchase_order_id'];
    invoiceNumber = json['invoice_number'];
    supplierInvoiceNumber = json['supplier_invoice_number'];
    invoiceDate = json['invoice_date'];
    dueDate = json['due_date'];
    status = json['status'];
    subtotal = json['subtotal']?.toDouble();
    taxAmount = json['tax_amount']?.toDouble();
    totalAmount = json['total_amount']?.toDouble();
    amountPaid = json['amount_paid']?.toDouble();
    amountDue = json['amount_due']?.toDouble();
    if (json['payments'] != null) {
      payments = [];
      json['payments'].forEach((v) {
        payments!.add(PaymentRecordModel.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'purchase_order_id': purchaseOrderId,
      'supplier_invoice_number': supplierInvoiceNumber,
      'invoice_date': invoiceDate,
      'due_date': dueDate,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'partial':
        return 'Partially Paid';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  bool get isPending => status == 'pending';
  bool get isPartial => status == 'partial';
  bool get isPaid => status == 'paid';
  bool get isOverdue {
    if (status == 'paid' || status == 'cancelled') return false;
    if (dueDate == null) return false;
    return DateTime.parse(dueDate!).isBefore(DateTime.now());
  }

  double get paymentProgress {
    if (totalAmount == null || totalAmount == 0) return 0;
    return (amountPaid ?? 0) / totalAmount!;
  }
}

class PaymentRecordModel {
  int? id;
  int? restaurantId;
  int? supplierId;
  int? invoiceId;
  double? amount;
  String? paymentMethod;
  String? paymentDate;
  String? referenceNumber;
  String? notes;
  String? createdAt;

  PaymentRecordModel({
    this.id,
    this.restaurantId,
    this.supplierId,
    this.invoiceId,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.referenceNumber,
    this.notes,
    this.createdAt,
  });

  PaymentRecordModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    supplierId = json['supplier_id'];
    invoiceId = json['invoice_id'];
    amount = json['amount']?.toDouble();
    paymentMethod = json['payment_method'];
    paymentDate = json['payment_date'];
    referenceNumber = json['reference_number'];
    notes = json['notes'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate,
      'reference_number': referenceNumber,
      'notes': notes,
    };
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'check':
        return 'Check';
      case 'card':
        return 'Card';
      default:
        return paymentMethod ?? 'N/A';
    }
  }
}
