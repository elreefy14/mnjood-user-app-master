class SubstitutionProposal {
  int? id;
  String? originalFood;
  String? substituteFood;
  int? quantity;
  String? status;
  double? originalPrice;
  double? substitutePrice;

  SubstitutionProposal({
    this.id,
    this.originalFood,
    this.substituteFood,
    this.quantity,
    this.status,
    this.originalPrice,
    this.substitutePrice,
  });

  SubstitutionProposal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    originalFood = json['original_food'];
    substituteFood = json['substitute_food'];
    quantity = json['quantity'];
    status = json['status'];
    originalPrice = json['original_price']?.toDouble();
    substitutePrice = json['substitute_price']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['original_food'] = originalFood;
    data['substitute_food'] = substituteFood;
    data['quantity'] = quantity;
    data['status'] = status;
    data['original_price'] = originalPrice;
    data['substitute_price'] = substitutePrice;
    return data;
  }
}
