class UpdateStatusBody {
  String? token;
  int? orderId;
  String? status;
  String? otp;
  String method = 'put';
  String? reason;
  int? reasonId;
  String? latitude;
  String? longitude;

  UpdateStatusBody({this.token, this.orderId, this.status, this.otp, this.reason, this.reasonId, this.latitude, this.longitude});

  UpdateStatusBody.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    orderId = json['order_id'];
    status = json['status'];
    otp = json['otp'];
    status = json['_method'];
    reason = json['reason'];
    reasonId = json['reason_id'] != null ? int.tryParse(json['reason_id'].toString()) : null;
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['token'] = token!;
    data['order_id'] = orderId.toString();
    data['status'] = status!;
    data['otp'] = otp??'';
    data['_method'] = method;
    if(reason != '' && reason != null) {
      data['reason'] = reason!;
    }
    if(reasonId != null) {
      data['reason_id'] = reasonId.toString();
    }
    if(latitude != null) {
      data['latitude'] = latitude!;
    }
    if(longitude != null) {
      data['longitude'] = longitude!;
    }
    return data;
  }
}
