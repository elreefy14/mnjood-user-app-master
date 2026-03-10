import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';

class HomeSectionModel {
  int? id;
  String? titleEn;
  String? titleAr;
  String? businessType;
  String? sortBy;
  int? vendorLimit;
  int? displayOrder;
  bool? isActive;
  String? icon;
  String? badgeColor;
  List<Restaurant>? vendors;
  List<Product>? products;

  HomeSectionModel({
    this.id,
    this.titleEn,
    this.titleAr,
    this.businessType,
    this.sortBy,
    this.vendorLimit,
    this.displayOrder,
    this.isActive,
    this.icon,
    this.badgeColor,
    this.vendors,
    this.products,
  });

  HomeSectionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    // Normalize: V1 API uses "coffeeshop", app uses "coffee_shop"
    final rawBizType = json['business_type']?.toString();
    businessType = rawBizType == 'coffeeshop' ? 'coffee_shop' : rawBizType;
    sortBy = json['sort_by'];
    vendorLimit = json['vendor_limit'];
    displayOrder = json['display_order'];
    isActive = json['is_active'];
    icon = json['icon'];
    badgeColor = json['badge_color'];

    if (json['vendors'] != null) {
      vendors = [];
      for (var v in json['vendors']) {
        if (v is Map<String, dynamic>) {
          // Normalize coffeeshop → coffee_shop for vendor_type and business_type
          if (v['vendor_type'] == 'coffeeshop') v['vendor_type'] = 'coffee_shop';
          if (v['business_type'] == 'coffeeshop') v['business_type'] = 'coffee_shop';
          // Inject business_type so Restaurant.fromJson picks it up
          v['business_type'] ??= businessType ?? 'restaurant';
        }
        vendors!.add(Restaurant.fromJson(v));
      }
    }

    if (json['products'] != null) {
      products = [];
      for (var p in json['products']) {
        Product product = Product.fromJson(p);
        product.supermarketId ??= 12;
        product.restaurantId ??= 12;
        products!.add(product);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['business_type'] = businessType;
    data['sort_by'] = sortBy;
    data['vendor_limit'] = vendorLimit;
    data['display_order'] = displayOrder;
    data['is_active'] = isActive;
    data['icon'] = icon;
    data['badge_color'] = badgeColor;
    if (vendors != null) {
      data['vendors'] = vendors!.map((v) => v.toJson()).toList();
    }
    if (products != null) {
      data['products'] = products!.map((p) => p.toJson()).toList();
    }
    return data;
  }
}
