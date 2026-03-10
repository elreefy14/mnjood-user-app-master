import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/favourite/domain/repositories/favourite_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class FavouriteRepository implements FavouriteRepositoryInterface<Response> {
  final ApiClient apiClient;
  FavouriteRepository({required this.apiClient});

  @override
  Future<Response> add(dynamic a, {bool isRestaurant = false, int? id, String? itemType}) async {
    // V3 API: POST to base URI with body containing the ID
    // For vendors: itemType determines key: 'supermarket' -> supermarket_id, 'pharmacy' -> pharmacy_id, default -> restaurant_id
    // For products: itemType 'product' -> product_id, default -> food_id
    String key;
    if (isRestaurant) {
      // Vendor favorites
      if (itemType == 'supermarket') {
        key = 'supermarket_id';
      } else if (itemType == 'pharmacy') {
        key = 'pharmacy_id';
      } else {
        key = 'restaurant_id';
      }
    } else if (itemType == 'product') {
      key = 'product_id';
    } else {
      key = 'food_id';
    }
    return await apiClient.postData(
      AppConstants.addWishListUri,
      {key: id}
    );
  }

  @override
  Future<Response> delete(int? id, {bool isRestaurant = false, String? itemType}) async {
    // V3 API: DELETE to /wishlist/{type}/{id}
    // For vendors: itemType determines type: 'supermarket', 'pharmacy', or 'restaurant'
    // For products: itemType 'product' -> 'product', default -> 'food'
    String type;
    if (isRestaurant) {
      // Vendor favorites
      if (itemType == 'supermarket') {
        type = 'supermarket';
      } else if (itemType == 'pharmacy') {
        type = 'pharmacy';
      } else {
        type = 'restaurant';
      }
    } else if (itemType == 'product') {
      type = 'product';
    } else {
      type = 'food';
    }
    return await apiClient.deleteData(
      '${AppConstants.removeWishListUri}$type/$id'
    );
  }

  @override
  Future<Response> getList({int? offset}) async {
    return await apiClient.getData(AppConstants.wishListGetUri);
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}