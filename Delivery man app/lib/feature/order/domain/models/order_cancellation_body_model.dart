class OrderCancellationBodyModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<CancellationData>? reasons;

  OrderCancellationBodyModel({this.totalSize, this.limit, this.offset, this.reasons});

  OrderCancellationBodyModel.fromJson(Map<String, dynamic> json) {
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
  String? createdAt;
  String? updatedAt;
  int? feePercentage;
  bool? requiresText;

  CancellationData({
    this.id,
    this.reason,
    this.userType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.feePercentage,
    this.requiresText,
  });

  CancellationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    userType = json['user_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    feePercentage = json['fee_percentage'];
    requiresText = json['requires_text'] == true || json['requires_text'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    data['user_type'] = userType;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['fee_percentage'] = feePercentage;
    data['requires_text'] = requiresText;
    return data;
  }
}