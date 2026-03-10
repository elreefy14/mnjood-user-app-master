class CuisineModel {
  List<Cuisines>? cuisines;

  CuisineModel({this.cuisines});

  CuisineModel.fromJson(Map<String, dynamic> json) {
    // V3 API: Check if data exists (V3 format)
    var cuisineData = json['data'] ?? json['Cuisines'];

    if (cuisineData != null) {
      cuisines = <Cuisines>[];
      if (cuisineData is List) {
        cuisineData.forEach((v) {
          cuisines!.add(Cuisines.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cuisines != null) {
      data['Cuisines'] = cuisines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cuisines {
  int? id;
  String? name;
  String? imageFullUrl;
  int? status;
  String? slug;
  String? createdAt;
  String? updatedAt;

  Cuisines({
    this.id,
    this.name,
    this.imageFullUrl,
    this.status,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  Cuisines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    // V3 API returns 'image' instead of 'image_full_url'
    imageFullUrl = json['image_full_url'] ?? json['image'];
    status = json['status'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['status'] = status;
    data['slug'] = slug;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
