class OrderCancellationBody {
  int? totalSize;
  String? limit;
  String? offset;
  List<CancellationData>? reasons;

  OrderCancellationBody({this.totalSize, this.limit, this.offset, this.reasons});

  OrderCancellationBody.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['reasons'] != null) {
      reasons = <CancellationData>[];
      json['reasons'].forEach((v) {
        reasons!.add(CancellationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (reasons != null) {
      data['reasons'] = reasons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CancellationData {
  int? id;
  String? reason;
  String? userType;
  int? status;
  double? feePercentage;
  bool? requiresText;
  String? createdAt;
  String? updatedAt;

  CancellationData(
      {this.id,
        this.reason,
        this.userType,
        this.status,
        this.feePercentage,
        this.requiresText,
        this.createdAt,
        this.updatedAt});

  CancellationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    userType = json['user_type'];
    status = json['status'];
    feePercentage = json['fee_percentage']?.toDouble();
    requiresText = json['requires_text'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    data['user_type'] = userType;
    data['status'] = status;
    data['fee_percentage'] = feePercentage;
    data['requires_text'] = requiresText;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}