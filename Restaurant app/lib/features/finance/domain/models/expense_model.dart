class ExpenseModel {
  int? id;
  int? restaurantId;
  int? categoryId;
  String? categoryName;
  double? amount;
  String? expenseDate;
  String? description;
  String? paymentMethod;
  String? referenceNumber;
  String? createdAt;
  String? updatedAt;

  ExpenseModel({
    this.id,
    this.restaurantId,
    this.categoryId,
    this.categoryName,
    this.amount,
    this.expenseDate,
    this.description,
    this.paymentMethod,
    this.referenceNumber,
    this.createdAt,
    this.updatedAt,
  });

  ExpenseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    amount = json['amount']?.toDouble();
    expenseDate = json['expense_date'];
    description = json['description'];
    paymentMethod = json['payment_method'];
    referenceNumber = json['reference_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'amount': amount,
      'expense_date': expenseDate,
      'description': description,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
    };
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'card':
        return 'Card';
      default:
        return paymentMethod ?? 'N/A';
    }
  }
}

class ExpenseCategoryModel {
  int? id;
  String? name;
  String? nameAr;
  String? description;
  String? status;

  ExpenseCategoryModel({
    this.id,
    this.name,
    this.nameAr,
    this.description,
    this.status,
  });

  ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    description = json['description'];
    status = json['status'];
  }

  bool get isActive => status == 'active';
}
