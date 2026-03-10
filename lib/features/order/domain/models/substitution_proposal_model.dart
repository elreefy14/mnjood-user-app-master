class SubstitutionProposal {
  int? id;
  int? orderId;
  SubstitutionItem? originalItem;
  SubstitutionItem? proposedItem;
  double? priceDifference;
  String? storeNote;
  String? status; // pending, accepted, rejected

  SubstitutionProposal({
    this.id,
    this.orderId,
    this.originalItem,
    this.proposedItem,
    this.priceDifference,
    this.storeNote,
    this.status,
  });

  SubstitutionProposal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    originalItem = json['original_item'] != null ? SubstitutionItem.fromJson(json['original_item']) : null;
    proposedItem = json['proposed_item'] != null ? SubstitutionItem.fromJson(json['proposed_item']) : null;
    priceDifference = double.tryParse(json['price_difference']?.toString() ?? '0');
    storeNote = json['store_note'];
    status = json['status'] ?? 'pending';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    if (originalItem != null) data['original_item'] = originalItem!.toJson();
    if (proposedItem != null) data['proposed_item'] = proposedItem!.toJson();
    data['price_difference'] = priceDifference;
    data['store_note'] = storeNote;
    data['status'] = status;
    return data;
  }
}

class SubstitutionItem {
  int? id;
  String? name;
  String? image;
  double? price;

  SubstitutionItem({this.id, this.name, this.image, this.price});

  SubstitutionItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    price = double.tryParse(json['price']?.toString() ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['price'] = price;
    return data;
  }
}
