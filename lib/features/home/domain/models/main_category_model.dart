class MainCategoryModel {
  int? id;
  String? name;
  String? nameAr;
  String? slug;
  String? image;
  String? imageFullUrl;
  String? icon;
  String? iconFullUrl;
  int? sortOrder;
  bool? isActive;
  String? description;
  String? descriptionAr;
  int? vendorCount;

  MainCategoryModel({
    this.id,
    this.name,
    this.nameAr,
    this.slug,
    this.image,
    this.imageFullUrl,
    this.icon,
    this.iconFullUrl,
    this.sortOrder,
    this.isActive,
    this.description,
    this.descriptionAr,
    this.vendorCount,
  });

  MainCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    slug = json['slug'];
    image = json['image'];
    // V1 API returns image_full_url, V3 returns image as full URL
    // Check if image_full_url exists, otherwise use image if it's a full URL
    String? imgFullUrl = json['image_full_url'];
    String? img = json['image'];
    if (imgFullUrl != null && imgFullUrl.isNotEmpty) {
      imageFullUrl = imgFullUrl;
    } else if (img != null && img.startsWith('http')) {
      imageFullUrl = img;
    }
    icon = json['icon'];
    iconFullUrl = json['icon_full_url'];
    sortOrder = json['sort_order'];
    isActive = json['is_active'] is bool ? json['is_active'] : (json['is_active'] == 1);
    description = json['description'];
    descriptionAr = json['description_ar'];
    vendorCount = json['vendor_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['slug'] = slug;
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['icon'] = icon;
    data['icon_full_url'] = iconFullUrl;
    data['sort_order'] = sortOrder;
    data['is_active'] = isActive;
    data['description'] = description;
    data['description_ar'] = descriptionAr;
    data['vendor_count'] = vendorCount;
    return data;
  }
}
