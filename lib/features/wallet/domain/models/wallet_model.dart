
class WalletModel {

  int? totalSize;
  String? limit;
  String? offset;
  List<Transaction>? data;

  WalletModel({this.totalSize, this.limit, this.offset, this.data});

  WalletModel.fromJson(Map<String, dynamic> json) {
     totalSize = json["total_size"];
     limit = json["limit"].toString();
     offset = json["offset"].toString();
     if (json['data'] != null) {
       data = [];
     json['data'].forEach((v) {
       data!.add(Transaction.fromJson(v));
     });
     }
  }

  Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['total_size'] = totalSize;
      data['limit'] = limit;
      data['offset'] = offset;
      if (this.data != null) {
       data['data'] = this.data!.map((v) => v.toJson()).toList();
      }
      return data;
  }
}

class Transaction {

  int? userId;
  String? transactionId;
  double? credit;
  double? debit;
  double? adminBonus;
  double? balance;
  String? transactionType;
  String? reference;
  DateTime? createdAt;
  DateTime? updatedAt;

  Transaction({
    this.userId,
    this.transactionId,
    this.credit,
    this.debit,
    this.adminBonus,
    this.balance,
    this.transactionType,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });


  Transaction.fromJson(Map<String, dynamic> json) {
    userId = json["user_id"] != null ? int.tryParse(json["user_id"].toString()) : null;
    transactionId = (json["transaction_id"] ?? json["id"])?.toString();

    // V3 API uses "amount" + "type" instead of separate credit/debit fields
    double amount = json["amount"] != null ? double.tryParse(json["amount"].toString()) ?? 0 : 0;
    String? type = json["transaction_type"] ?? json["type"];
    transactionType = type;

    bool isDebit = (type == 'order_place' || type == 'partial_payment');
    credit = json["credit"] != null ? double.tryParse(json["credit"].toString()) ?? 0 : (isDebit ? 0 : amount);
    debit = json["debit"] != null ? double.tryParse(json["debit"].toString()) ?? 0 : (isDebit ? amount : 0);
    adminBonus = json["admin_bonus"] != null ? double.tryParse(json["admin_bonus"].toString()) ?? 0 : 0;

    balance = double.tryParse((json["balance"] ?? json["balance_after"])?.toString() ?? '0') ?? 0;
    reference = json["reference"]?.toString() ?? json["reference_id"]?.toString();
    createdAt = DateTime.tryParse((json["created_at"] ?? json["transaction_date"])?.toString() ?? '');
    updatedAt = json["updated_at"] != null ? DateTime.tryParse(json["updated_at"].toString()) : null;
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"] = userId;
    data["transaction_id"] = transactionId;
    data["credit"] = credit;
    data["debit"] = debit;
    data["admin_bonus"] = adminBonus;
    data["balance"] = balance;
    data["transaction_type"] = transactionType;
    data["reference"] = reference;
    data["created_at"] = createdAt?.toIso8601String();
    data["updated_at"] = updatedAt?.toIso8601String();
  return data;
  }
}
