class SupplierModel {
  int? id;
  int? restaurantId;
  String? name;
  String? contactPerson;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? country;
  String? taxNumber;
  String? bankName;
  String? bankAccount;
  String? iban;
  String? paymentTerms;
  double? creditLimit;
  double? outstandingBalance;
  String? status;
  String? notes;
  String? createdAt;
  String? updatedAt;

  SupplierModel({
    this.id,
    this.restaurantId,
    this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.taxNumber,
    this.bankName,
    this.bankAccount,
    this.iban,
    this.paymentTerms,
    this.creditLimit,
    this.outstandingBalance,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  SupplierModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    name = json['name'];
    contactPerson = json['contact_person'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    country = json['country'];
    taxNumber = json['tax_number'];
    bankName = json['bank_name'];
    bankAccount = json['bank_account'];
    iban = json['iban'];
    paymentTerms = json['payment_terms'];
    creditLimit = json['credit_limit']?.toDouble();
    outstandingBalance = json['outstanding_balance']?.toDouble();
    status = json['status'];
    notes = json['notes'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'tax_number': taxNumber,
      'bank_name': bankName,
      'bank_account': bankAccount,
      'iban': iban,
      'payment_terms': paymentTerms,
      'credit_limit': creditLimit,
      'outstanding_balance': outstandingBalance,
      'status': status,
      'notes': notes,
    };
  }

  String get paymentTermsDisplay {
    switch (paymentTerms) {
      case 'immediate':
        return 'Immediate';
      case 'net_7':
        return 'Net 7 Days';
      case 'net_15':
        return 'Net 15 Days';
      case 'net_30':
        return 'Net 30 Days';
      case 'net_60':
        return 'Net 60 Days';
      default:
        return paymentTerms ?? 'N/A';
    }
  }

  bool get isActive => status == 'active';
}
