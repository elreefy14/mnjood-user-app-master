
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/location/domain/models/zone_response_model.dart';
import 'package:mnjood/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:mnjood/features/restaurant/domain/models/vendor_banner_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RestaurantServiceInterface {
  double getRestaurantDistanceFromUser(LatLng restaurantLatLng);
  String filterRestaurantLinkUrl(String slug, int? restaurantId, int? restaurantZoneId);
  Future<RestaurantModel?> getRestaurantList(int offset, String filterBy, int topRated, int discount, int veg, int nonVeg, {bool fromMap = false, DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getOrderAgainRestaurantList({DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getRecentlyViewedRestaurantList(String type, {DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getPopularRestaurantList(String type, {DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getLatestRestaurantList(String type, {DataSourceEnum? source, String? businessType});
  Future<List<Restaurant>?> getDiscountRestaurantList({required String businessType, required DataSourceEnum source});
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId, {String? businessType});
  int setTopRated(int rated);
  int setDiscounted(int discounted);
  int setVeg(int isVeg);
  int setNonVeg(int isNonVeg);
  List<CategoryModel>? setCategories(List<CategoryModel> categoryList, Restaurant restaurant);
  Future<Restaurant?> getRestaurantDetails(String restaurantID, String slug, String? languageCode, {String? businessType});
  AddressModel prepareAddressModel(Position storePosition, ZoneResponseModel responseModel, String addressFromGeocode);
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID);
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, String type, {String? businessType});
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type, {String? businessType});
  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules);
  bool isRestaurantOpenNow(bool active, List<Schedules>? schedules);
  Future<List<VendorBannerModel>?> getVendorBanners(int vendorId);
  Future<List<CategoryModel>?> getVendorCategories(int vendorId, String? businessType);
}