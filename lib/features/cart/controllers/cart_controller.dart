import 'package:mnjood/api/api_checker.dart';
import 'package:mnjood/common/models/online_cart_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/cart_snackbar_widget.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/cart/domain/services/cart_service_interface.dart';
import 'package:mnjood/features/product/controllers/product_controller.dart';
import 'package:mnjood/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mnjood/helper/route_helper.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});


  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOnsPrice = 0;
  double get addOns => _addOnsPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];

  int? _editingOrderId;
  int? get editingOrderId => _editingOrderId;

  void setEditingOrderId(int? id) {
    _editingOrderId = id;
  }

  void clearEditingOrderId() {
    _editingOrderId = null;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isClearCartLoading = false;
  bool get isClearCartLoading => _isClearCartLoading;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if(willUpdate) {
      update();
    }
  }

  void setNeedExtraPackage(bool needExtraPackage) {
    _needExtraPackage = needExtraPackage;
    update();
  }

  double calculationCart(){
    _itemPrice = 0 ;
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOnsPrice = 0;
    _availableList= [];
    _addOnsList = [];
    _variationPrice = 0;
    double variationWithoutDiscountPrice = 0;
    double variationPrice = 0;
    for (var cartModel in _cartList) {
      // Skip cart items with null product
      if(cartModel.product == null) continue;

      variationWithoutDiscountPrice = 0;
      variationPrice = 0;

      double? discount = (cartModel.product?.restaurantDiscount ?? 0) == 0 ? (cartModel.product?.discount ?? 0) : (cartModel.product?.restaurantDiscount ?? 0);
      String? discountType = (cartModel.product?.restaurantDiscount ?? 0) == 0 ? (cartModel.product?.discountType ?? 'percent') : 'percent';

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(cartModel.product != null ? ProductHelper.isAvailable(cartModel.product!) : true);

      _addOnsPrice = cartServiceInterface.calculateAddonsPrice(addOnList, _addOnsPrice, cartModel);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(cartModel, variationWithoutDiscountPrice, discount, discountType);
      variationPrice = cartServiceInterface.calculateVariationPrice(cartModel, variationPrice);

      double price = ((cartModel.product?.price ?? 0) * (cartModel.quantity ?? 1));
      double discountPrice =  (price - ((PriceConverter.convertWithDiscount(cartModel.product?.price ?? 0, discount, discountType) ?? 0) * (cartModel.quantity ?? 1)));

      _variationPrice += variationPrice;
      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice + (variationPrice - variationWithoutDiscountPrice);

    }
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;

    final restaurantDiscount = Get.find<RestaurantController>().restaurant?.discount;
    if (restaurantDiscount != null) {
      final maxDiscount = restaurantDiscount.maxDiscount ?? 0;
      final minPurchase = restaurantDiscount.minPurchase ?? 0;
      if (maxDiscount != 0 && maxDiscount < _itemDiscountPrice) {
        _itemDiscountPrice = maxDiscount;
        _subTotal = (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
      if (minPurchase != 0 && minPurchase > _subTotal) {
        _itemDiscountPrice = 0;
        _subTotal = (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
    }
    return _subTotal;
  }

  Future<int?> reorderAddToCart(List<OnlineCart> cartList) async {
    await clearCartList();
    return _addMultipleCartItemOnline(cartList);
  }

  Future<void> setQuantity(bool isIncrement, CartModel cart, {int? cartIndex}) async {
    _isLoading = true;
    update();
    int index = cartIndex ?? _cartList.indexOf(cart);
    _cartList[index].quantity = await cartServiceInterface.decideProductQuantity(_cartList, isIncrement, index);
    cartServiceInterface.addToSharedPrefCartList(_cartList);

    calculationCart();
    final cartItem = _cartList[index];
    if (cartItem.id != null && cartItem.price != null && cartItem.quantity != null) {
      await updateCartQuantityOnline(cartItem.id!, cartItem.price!, cartItem.quantity!);
    }
    _isLoading = false;
    update();
  }

  void removeFromCart(int index) {
    _isLoading = true;
    int? cartId = _cartList[index].id;
    _cartList.removeAt(index);
    update();
    if (cartId != null) {
      removeCartItemOnline(cartId);
    }
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds?.removeAt(addOnIndex);
    cartServiceInterface.addToSharedPrefCartList(_cartList);
    calculationCart();
    update();
  }

  Future<void> clearCartList() async {
    _cartList = [];
    if(AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
      await clearCartOnline();
    }
  }


  int isExistInCart(int? productID, int? cartIndex) {
    return cartServiceInterface.isExistInCart(productID, cartIndex, _cartList);
  }

  bool existAnotherRestaurantProduct(int? restaurantID) {
    return cartServiceInterface.existAnotherRestaurantProduct(restaurantID, _cartList);
  }

  void updateCutlery({bool isUpdate = true}){
    _addCutlery = !_addCutlery;
    if(isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}){
    _notAvailableIndex = cartServiceInterface.setAvailableIndex(index, _notAvailableIndex);
    if(willUpdate) {
      update();
    }
  }

  int cartQuantity(int productID) {
    return cartServiceInterface.cartQuantity(productID, _cartList);
  }

  Future<void> addToCartOnline(OnlineCart onlineCart, {CartModel? existCartData, bool fromDirectlyAdd = false}) async {
    // Check if user is logged in before adding to cart
    if(!AuthHelper.isLoggedIn()) {
      showCustomSnackBar('you_are_not_logged_in'.tr);
      return;
    }

    _isLoading = true;
    update();
    Response response = await cartServiceInterface.addToCartOnline(onlineCart, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

    if(response.statusCode == 200 || response.statusCode == 201) {
      List<OnlineCartModel> onlineCartList = [];
      // Handle V3 API response wrapper
      var responseData = response.body;
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      // V3 API wraps cart items in 'items' array
      if (responseData is Map && responseData.containsKey('items')) {
        responseData = responseData['items'];
      }
      if (responseData is List) {
        responseData.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      }
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
      if(!fromDirectlyAdd) {
        Get.back();
      }
      if(!Get.currentRoute.contains(RouteHelper.restaurant)) {
        showCartSnackBarWidget();
      }
    } else if(response.statusCode == 400 && response.body is Map && response.body['error_code'] == 'PURCHASE_LIMIT_EXCEEDED') {
      String message = response.body['message'] ?? 'purchase_limit_exceeded'.tr;
      showCustomSnackBar(message);
    } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>().getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<int?> _addMultipleCartItemOnline(List<OnlineCart> cartList) async {
    // Check if user is logged in before adding to cart
    if(!AuthHelper.isLoggedIn()) {
      showCustomSnackBar('you_are_not_logged_in'.tr);
      return null;
    }

    _isLoading = true;
    update();
    Response response = await cartServiceInterface.addMultipleCartItemOnline(cartList);
    if(response.statusCode == 200 || response.statusCode == 201) {
      List<OnlineCartModel> onlineCartList = [];
      // Handle V3 API response wrapper
      var responseData = response.body;
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      // V3 API wraps cart items in 'items' array
      if (responseData is Map && responseData.containsKey('items')) {
        responseData = responseData['items'];
      }
      if (responseData is List) {
        responseData.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      }
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
    }
    _isLoading = false;
    update();
    return response.statusCode;
  }

  Future<void> updateCartOnline(OnlineCart onlineCart, {CartModel? existCartData}) async {
    // Check if user is logged in before updating cart
    if(!AuthHelper.isLoggedIn()) {
      showCustomSnackBar('you_are_not_logged_in'.tr);
      return;
    }

    _isLoading = true;
    update();
    Response response = await cartServiceInterface.updateCartOnline(onlineCart, AuthHelper.isLoggedIn() ? null : int.parse(AuthHelper.getGuestId()));
    if(response.statusCode == 200 || response.statusCode == 201) {
      List<OnlineCartModel> onlineCartList = [];
      // Handle V3 API response wrapper
      var responseData = response.body;
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      // V3 API wraps cart items in 'items' array
      if (responseData is Map && responseData.containsKey('items')) {
        responseData = responseData['items'];
      }
      if (responseData is List) {
        responseData.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      }
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
      Get.back();
      if(!Get.currentRoute.contains(RouteHelper.restaurant)) {
        showCartSnackBarWidget();
      }
    } else if(response.statusCode == 400 && response.body is Map && response.body['error_code'] == 'PURCHASE_LIMIT_EXCEEDED') {
      String message = response.body['message'] ?? 'purchase_limit_exceeded'.tr;
      showCustomSnackBar(message);
    } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>().getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity) async {
    // _isLoading = true;
    // update();
    bool success = await cartServiceInterface.updateCartQuantityOnline(cartId, price, quantity, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if(success) {
      getCartDataOnline();
      calculationCart();
    }
    // _isLoading = false;
    // update();
  }

  Future<void> getCartDataOnline() async {
    _isLoading = true;
    List<OnlineCartModel> onlineCartList = await cartServiceInterface.getCartDataOnline(AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    _cartList = [];
    _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
    calculationCart();
    _isLoading = false;
    update();
  }

  Future<bool> removeCartItemOnline(int cartId) async {
    _isLoading = true;
    update();
    bool isSuccess = await cartServiceInterface.removeCartItemOnline(cartId, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    getCartDataOnline();
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    _isClearCartLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline(AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if(success) {
      getCartDataOnline();
    }
    _isLoading = false;
    _isClearCartLoading = false;
    update();
    return success;
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }

}