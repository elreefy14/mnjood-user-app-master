class VendorBannerModel {
  int? id;
  String? title;
  String? description;
  String? image;
  String? imageFullUrl;
  int? productId;
  int? categoryId;
  String? discountType;
  double? discountValue;
  String? startDate;
  String? endDate;
  bool? isActive;

  VendorBannerModel({
    this.id,
    this.title,
    this.description,
    this.image,
    this.imageFullUrl,
    this.productId,
    this.categoryId,
    this.discountType,
    this.discountValue,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  VendorBannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    imageFullUrl = json['image_full_url'];
    productId = json['product_id'];
    categoryId = json['category_id'];
    discountType = json['discount_type'];
    discountValue = json['discount_value']?.toDouble();
    startDate = json['start_date'];
    endDate = json['end_date'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['product_id'] = productId;
    data['category_id'] = categoryId;
    data['discount_type'] = discountType;
    data['discount_value'] = discountValue;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['is_active'] = isActive;
    return data;
  }
}
