class SliderModel {
  int? id;
  String? title;
  String? description;
  String? image;
  String? imageFullUrl;
  int? status;

  SliderModel({
    this.id,
    this.title,
    this.description,
    this.image,
    this.imageFullUrl,
    this.status,
  });

  SliderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    imageFullUrl = json['image_full_url'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['status'] = status;
    return data;
  }
}

class SlidersResponse {
  List<SliderModel>? sliders;
  int? total;

  SlidersResponse({this.sliders, this.total});

  SlidersResponse.fromJson(Map<String, dynamic> json) {
    if (json['sliders'] != null) {
      sliders = <SliderModel>[];
      json['sliders'].forEach((v) {
        sliders!.add(SliderModel.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sliders != null) {
      data['sliders'] = sliders!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}
