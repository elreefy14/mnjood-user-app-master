import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mnjood/common/models/online_cart_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mnjood/helper/guest_manager.dart';

class CartRepository implements CartRepositoryInterface<OnlineCart> {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts) async {
    // List<OnlineCartModel> onlineCartList = [];
    List<Map<String, dynamic>> cartList = [];
    for (var cart in carts) {
      cartList.add(cart.toJson());
    }
    Response response = await apiClient.postData(AppConstants.addMultipleItemCartUri, {'item_list': cartList});
    // if(response.statusCode == 200) {
    //   onlineCartList = [];
    //   response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
    // }
    return response;
  }

  @override
  void addToSharedPrefCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    for (var cartModel in cartProductList) {
      carts.add(jsonEncode(cartModel));
    }
    sharedPreferences.setStringList(AppConstants.cartList, carts);
  }

  @override
  Future<bool> clearCartOnline(String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.removeAllCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', {"_method": "delete"});
    return (response.statusCode == 200);
  }

  @override
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', data);
    return (response.statusCode == 200);
  }

  ///Add To Cart Online
  @override
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.addCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', cart.toJson(), handleError: false);
    return response;
  }

  @override
  Future<bool> delete(int? id, {String? guestId}) async {
    // V3 API: Use RESTful endpoint with item ID in path
    String url = '${AppConstants.removeItemCartUri}$id${guestId != null ? '?guest_id=$guestId' : ''}';
    Response response = await apiClient.deleteData(url);
    return (response.statusCode == 200);
  }

  @override
  Future<List<OnlineCartModel>> get(String? id) async {
    List<OnlineCartModel> onlineCartList = [];
    try {
      // Only pass guest_id if provided (for guest users), otherwise rely on auth token
      String url = AppConstants.getCartListUri;
      if (id != null && id.isNotEmpty) {
        url = '$url?guest_id=$id';
      }

      Response response = await apiClient.getData(url);

      if(response.statusCode == 200) {
        onlineCartList = [];
        // V3 API: Extract data from response
        var responseData = response.body;

        if(responseData is Map && responseData.containsKey('data')) {
          var data = responseData['data'];

          // Check if data contains items array
          if(data is Map && data.containsKey('items') && data['items'] is List) {
            List items = data['items'];
            for (var cart in items) {
              try {
                onlineCartList.add(OnlineCartModel.fromJson(cart));
              } catch (parseError) {
                if (kDebugMode) {
                  print('Cart item parse error: $parseError');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cart API Error: $e');
      }
    }
    return onlineCartList;
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<Response> update(Map<String, dynamic> cart, int? id) async {
    return await _updateCartOnline(cart, id);
  }

  Future<Response> _updateCartOnline(Map<String, dynamic> cart, int? guestId) async {
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', cart, handleError: false);
    return response;
  }

  @override
  Future add(OnlineCart value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  
}