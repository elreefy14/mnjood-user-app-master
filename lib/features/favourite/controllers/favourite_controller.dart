import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController implements GetxService {
  final FavouriteServiceInterface favouriteServiceInterface;
  FavouriteController({required this.favouriteServiceInterface});

  List<Product?>? _wishProductList;
  List<Product?>? get wishProductList => _wishProductList;

  List<Restaurant?>? _wishRestList;
  List<Restaurant?>? get wishRestList => _wishRestList;

  List<int?> _wishProductIdList = [];
  List<int?> get wishProductIdList => _wishProductIdList;

  List<int?> _wishRestIdList = [];
  List<int?> get wishRestIdList => _wishRestIdList;

  bool _isDisable = false;
  bool get isDisable => _isDisable;

  void addToFavouriteList(Product? product, int? restaurantId, bool isRestaurant, {String? businessType}) async {
    _isDisable = true;
    update();
    // Determine itemType based on businessType
    // For vendors (isRestaurant=true): 'supermarket', 'pharmacy', or null (defaults to 'restaurant')
    // For products (isRestaurant=false): 'product' for supermarket/pharmacy items, null (defaults to 'food')
    String? itemType;
    if (isRestaurant) {
      // Vendor favorites - pass businessType directly
      itemType = businessType; // 'supermarket', 'pharmacy', or null for 'restaurant'
    } else {
      // Product favorites
      itemType = (businessType == 'supermarket' || businessType == 'pharmacy') ? 'product' : null;
    }
    Response response = await favouriteServiceInterface.addFavouriteList(isRestaurant ? restaurantId : product!.id, isRestaurant, itemType: itemType);
    // V3 API returns 201 Created for successful add
    if (response.statusCode == 200 || response.statusCode == 201) {
      if(isRestaurant) {
        _wishRestIdList.add(restaurantId);
        _wishRestList!.add(Restaurant());
        _isDisable = false;
        // Show appropriate message based on businessType
        String vendorLabel = businessType == 'supermarket' ? 'supermarket'.tr
                          : businessType == 'pharmacy' ? 'pharmacy'.tr
                          : 'restaurant'.tr;
        showCustomSnackBar('$vendorLabel ${'added_to_favorites'.tr}', isError: false);
      }else {
        _wishProductList!.add(product);
        _wishProductIdList.add(product!.id);
        showCustomSnackBar(response.body['message'] ?? 'added_to_favorites'.tr, isError: false);
      }
    }
    _isDisable = false;
    update();
  }

  void removeFromFavouriteList(int? id, bool isRestaurant, {String? businessType}) async {
    _isDisable = true;
    update();
    // Determine itemType based on businessType
    // For vendors (isRestaurant=true): 'supermarket', 'pharmacy', or null (defaults to 'restaurant')
    // For products (isRestaurant=false): 'product' for supermarket/pharmacy items, null (defaults to 'food')
    String? itemType;
    if (isRestaurant) {
      // Vendor favorites - pass businessType directly
      itemType = businessType; // 'supermarket', 'pharmacy', or null for 'restaurant'
    } else {
      // Product favorites
      itemType = (businessType == 'supermarket' || businessType == 'pharmacy') ? 'product' : null;
    }
    Response response = await favouriteServiceInterface.removeFavouriteList(id, isRestaurant, itemType: itemType);
    // V3 API returns 204 No Content for successful DELETE
    if (response.statusCode == 200 || response.statusCode == 204) {
      int idIndex = -1;
      if(isRestaurant) {
        idIndex = _wishRestIdList.indexOf(id);
        if (idIndex >= 0) {
          _wishRestIdList.removeAt(idIndex);
          _wishRestList!.removeAt(idIndex);
        }
        // Show appropriate message based on businessType
        String vendorLabel = businessType == 'supermarket' ? 'supermarket'.tr
                          : businessType == 'pharmacy' ? 'pharmacy'.tr
                          : 'restaurant'.tr;
        showCustomSnackBar('$vendorLabel ${'removed_from_favourites'.tr}', isError: false);
      }else {
        idIndex = _wishProductIdList.indexOf(id);
        if (idIndex >= 0) {
          _wishProductIdList.removeAt(idIndex);
          _wishProductList?.removeAt(idIndex);
        }
        // 204 No Content has no body, use hardcoded message
        String message = response.statusCode == 204
            ? 'removed_from_favourites'.tr
            : (response.body?['message'] ?? 'removed_from_favourites'.tr);
        showCustomSnackBar(message, isError: false);
      }
    }
    _isDisable = false;
    update();
  }

  Future<void> getFavouriteList({bool fromFavScreen = false}) async {
    if(fromFavScreen){
      _wishProductList = null;
      _wishProductIdList = [];
      _wishRestList = null;
      _wishRestIdList = [];
    }else {
      _wishProductList = [];
      _wishProductIdList = [];
      _wishRestList = [];
      _wishRestIdList = [];
    }
    Response response = await favouriteServiceInterface.getFavouriteList();
    if (response.statusCode == 200) {
      if(fromFavScreen){
        _wishProductList = [];
        _wishProductIdList = [];
        _wishRestList = [];
        _wishRestIdList = [];
      }
      update();

      // Handle V3 API response structure (data wrapper)
      // V3 returns: {data: [{item_type: "restaurant", item: {...}, vendor: {...}}]}
      var responseData = response.body;
      if (responseData is Map && responseData.containsKey('data')) {
        var data = responseData['data'];

        // V3 format: data is a List of items with item_type field
        if (data is List) {
          for (var wishItem in data) {
            String itemType = wishItem['item_type']?.toString() ?? '';
            var itemData = wishItem['item'];

            if ((itemType == 'food' || itemType == 'product') && itemData != null) {
              // Handle both food (restaurant/pharmacy) and product (supermarket) types
              try {
                Product product = Product.fromJson(itemData);
                _wishProductList!.add(product);
                _wishProductIdList.add(product.id);
              } catch (e) {
                debugPrint('Error parsing product from wishlist: $e - itemData: $itemData');
              }
            } else if (itemType == 'restaurant' && itemData != null) {
              try {
                Restaurant restaurant = Restaurant.fromJson(itemData);
                _wishRestList!.add(restaurant);
                _wishRestIdList.add(restaurant.id);
              } catch (e) {
                debugPrint('Error parsing restaurant from wishlist: $e');
              }
            }
          }
        }
        // Legacy format: data is a Map with food/restaurant arrays
        else if (data is Map) {
          if (data['food'] != null) {
            data['food'].forEach((food) async {
              Product product = Product.fromJson(food);
              _wishProductList!.add(product);
              _wishProductIdList.add(product.id);
            });
          }
          if (data['restaurant'] != null) {
            data['restaurant'].forEach((res) async {
              Restaurant? restaurant;
              try {
                restaurant = Restaurant.fromJson(res);
              } catch (e) {
                debugPrint('exception create in restaurant list create : $e');
              }
              _wishRestList!.add(restaurant);
              _wishRestIdList.add(restaurant!.id);
            });
          }
        }
      } else {
        // Legacy V1 response format (no data wrapper)
        if (responseData != null && responseData['food'] != null) {
          responseData['food'].forEach((food) async {
            Product product = Product.fromJson(food);
            _wishProductList!.add(product);
            _wishProductIdList.add(product.id);
          });
        }
        if (responseData != null && responseData['restaurant'] != null) {
          responseData['restaurant'].forEach((res) async {
            Restaurant? restaurant;
            try {
              restaurant = Restaurant.fromJson(res);
            } catch (e) {
              debugPrint('exception create in restaurant list create : $e');
            }
            _wishRestList!.add(restaurant);
            _wishRestIdList.add(restaurant!.id);
          });
        }
      }
    }
    update();
  }

  void removeFavourites() {
    _wishProductIdList = [];
    _wishRestIdList = [];
  }
}
