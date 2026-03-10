import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:mnjood/features/restaurant/domain/models/vendor_banner_model.dart';
import 'package:mnjood/interface/repository_interface.dart';

abstract class RestaurantRepositoryInterface extends RepositoryInterface {
  @override
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode, String? businessType});
  @override
  Future<RestaurantModel?> getList({int? offset, String? filterBy, int? topRated, int? discount, int? veg, int? nonVeg, bool fromMap = false, DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getRestaurantList({String? type, bool isRecentlyViewed = false, bool isOrderAgain = false, bool isPopular = false, bool isLatest = false, DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getDiscountRestaurantList({required String businessType, required DataSourceEnum source});
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId, {String? businessType});
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID);
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, String type, {String? businessType});
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type, {String? businessType});
  Future<List<VendorBannerModel>?> getVendorBanners(int vendorId);
  Future<List<CategoryModel>?> getVendorCategories(int vendorId, String? businessType);
}
