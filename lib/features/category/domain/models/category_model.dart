class CategoryModel {
  int? _id;
  String? _name;
  String? _nameAr;
  int? _parentId;
  int? _position;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  String? _imageFullUrl;
  String? _type;
  List<CategoryModel>? _childes;

  CategoryModel(
      {int? id,
        String? name,
        String? nameAr,
        int? parentId,
        int? position,
        int? status,
        String? createdAt,
        String? updatedAt,
        String? imageFullUrl,
        String? type,
        List<CategoryModel>? childes}) {
    _id = id;
    _name = name;
    _nameAr = nameAr;
    _parentId = parentId;
    _position = position;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _imageFullUrl = imageFullUrl;
    _type = type;
    _childes = childes;
  }

  int? get id => _id;
  String? get name => _name;
  String? get nameAr => _nameAr;
  int? get parentId => _parentId;
  int? get position => _position;
  int? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get imageFullUrl => _imageFullUrl;
  String? get type => _type;
  List<CategoryModel>? get childes => _childes;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _nameAr = json['name_ar'];
    _parentId = json['parent_id'];
    _position = json['position'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    // Handle both image and image_full_url
    String? imgFullUrl = json['image_full_url'];
    String? img = json['image'];
    if (imgFullUrl != null && imgFullUrl.isNotEmpty) {
      _imageFullUrl = imgFullUrl;
    } else if (img != null && img.startsWith('http')) {
      _imageFullUrl = img;
    } else {
      _imageFullUrl = img;
    }
    _type = json['type'];
    // Parse childes if available
    if (json['childes'] != null) {
      _childes = [];
      json['childes'].forEach((child) {
        _childes!.add(CategoryModel.fromJson(child));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['name_ar'] = _nameAr;
    data['parent_id'] = _parentId;
    data['position'] = _position;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['image_full_url'] = _imageFullUrl;
    data['type'] = _type;
    if (_childes != null) {
      data['childes'] = _childes!.map((child) => child.toJson()).toList();
    }
    return data;
  }
}
