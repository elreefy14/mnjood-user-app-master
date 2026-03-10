import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:mnjood/common/models/online_cart_model.dart';
import 'package:mnjood/common/models/product_model.dart' as product_model;
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:mnjood/features/cart/domain/services/cart_service_interface.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:get/get_utils/get_utils.dart';

// Type aliases to resolve naming conflicts
typedef Variation = product_model.Variation;
typedef VariationValue = product_model.VariationValue;
typedef AddOns = product_model.AddOns;

class CartService implements CartServiceInterface {
  final CartRepositoryInterface cartRepositoryInterface;
  CartService({required this.cartRepositoryInterface});

  @override
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts) async {
    return cartRepositoryInterface.addMultipleCartItemOnline(carts);
  }

  @override
  List<CartModel> formatOnlineCartToLocalCart({required List<OnlineCartModel> onlineCartModel}) {
    List<CartModel> cartList = [];
    for (OnlineCartModel cart in onlineCartModel) {
      if (cart.product == null) continue; // Skip if product is null

      double price = cart.price ?? cart.product?.price ?? 0;
      double? discount = (cart.product?.restaurantDiscount ?? 0) == 0
          ? (cart.product?.discount ?? 0)
          : (cart.product?.restaurantDiscount ?? 0);
      String? discountType = ((cart.product?.restaurantDiscount ?? 0) == 0)
          ? (cart.product?.discountType ?? 'percent')
          : 'percent';
      double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

      double? discountAmount = price - discountedPrice;
      int? quantity = cart.quantity;

      List<List<bool?>> selectedFoodVariations = [];
      List<List<int?>> variationsStock = [];
      List<bool> collapsVariation = [];

      // Handle variations with null safety
      List<Variation> variations = cart.product?.variations ?? [];
      for(int index=0; index<variations.length; index++) {
        selectedFoodVariations.add([]);
        collapsVariation.add(true);
        variationsStock.add([]);
        List<VariationValue> variationValues = variations[index].variationValues ?? [];
        for(int i=0; i < variationValues.length; i++) {
          variationsStock[index].add(variationValues[i].currentStock);
          if(variationValues[i].isSelected ?? false){
            selectedFoodVariations[index].add(true);
          } else {
            selectedFoodVariations[index].add(false);
          }
        }
      }

      List<AddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];
      List<int> cartAddOnIds = cart.addOnIds ?? [];
      List<int> cartAddOnQtys = cart.addOnQtys ?? [];
      List<AddOns> productAddOns = cart.product?.addOns ?? [];
      for (int index = 0; index < cartAddOnIds.length; index++) {
        int qty = index < cartAddOnQtys.length ? cartAddOnQtys[index] : 1;
        addOnIdList.add(AddOn(id: cartAddOnIds[index], quantity: qty));
        for (int i=0; i< productAddOns.length; i++) {
          if(cartAddOnIds[index] == productAddOns[i].id) {
            addOnsList.add(AddOns(id: productAddOns[i].id, name: productAddOns[i].name, price: productAddOns[i].price));
          }
        }
      }
      int? quantityLimit = cart.product?.cartQuantityLimit;
      cartList.add(
        CartModel(
          cart.id, price, discountedPrice, discountAmount, quantity, addOnIdList,
          addOnsList, false, cart.product, selectedFoodVariations, quantityLimit, variationsStock,
        ),
      );
    }
    return cartList;
  }

  @override
  void addToSharedPrefCartList(List<CartModel> cartProductList) {
    cartRepositoryInterface.addToSharedPrefCartList(cartProductList);
  }

  @override
  Future<bool> clearCartOnline(String? guestId) async {
    return await cartRepositoryInterface.clearCartOnline(guestId);
  }

  @override
  Future<int> decideProductQuantity(List<CartModel> cartList, bool isIncrement, int index) async {
    int quantity = cartList[index].quantity ?? 1;
    if (isIncrement) {
      quantity = await _quantityLimitCheck(cartList[index].variations ?? [], cartList[index].variationsStock ?? [], cartList[index].product?.cartQuantityLimit, cartList[index].product?.maxQtyPerUser, quantity, cartList[index].product?.stockType, cartList[index].product?.itemStock);
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  Future<int> _quantityLimitCheck(List<List<bool?>> selectedVariations, List<List<int?>> variationsStock, int? cartQuantityLimit, int? maxQtyPerUser, int quantity, String? stockType, int? itemStock) async {
    int qty = quantity;
    int? minimumStock;
    if(await _haveSelectedVariation(selectedVariations) && stockType != 'unlimited') {
      minimumStock = _minimumVariationStock(selectedVariations, variationsStock);
    }

    if(stockType != 'unlimited' && itemStock != null && qty >= itemStock) {
      showCustomSnackBar('${'maximum_food_quantity_limit'.tr} $itemStock');
    } else if(minimumStock != null && qty >= minimumStock) {
      showCustomSnackBar('${'maximum_variation_quantity_limit'.tr} $minimumStock');
    } else if(maxQtyPerUser != null && maxQtyPerUser > 0 && qty >= maxQtyPerUser) {
      showCustomSnackBar('${'purchase_limit_per_user'.tr} $maxQtyPerUser');
    } else if(cartQuantityLimit != null && qty >= cartQuantityLimit && cartQuantityLimit != 0) {
      showCustomSnackBar('${'maximum_cart_quantity_limit'.tr} $cartQuantityLimit');
    } else {
      qty = qty + 1;
    }
    return qty;
  }

  Future<bool> _haveSelectedVariation(List<List<bool?>> selectedVariations) async{
    bool hasSelected = false;
    for(int i=0; i<selectedVariations.length; i++) {
      for(int j=0; j<selectedVariations[i].length; j++) {
        if(selectedVariations[i][j] == true) {
          hasSelected = true;
        }
      }
    }
    return hasSelected;
  }

  int _minimumVariationStock(List<List<bool?>> selectedVariations, List<List<int?>> variationsStock) {
    List<int> stocks = [];
    for (int i=0; i<selectedVariations.length; i++) {
      for(int j=0; j<selectedVariations[i].length; j++) {
        if(selectedVariations[i][j] == true) {
          final stock = variationsStock[i][j];
          if (stock != null) stocks.add(stock);
        }
      }
    }
    if (stocks.isEmpty) return 0;
    int minimumStock = stocks.reduce((curr, next) => curr < next? curr: next);
    return minimumStock;
  }

  @override
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId) async {
    return await cartRepositoryInterface.updateCartQuantityOnline(cartId, price, quantity, guestId);
  }

  @override
  int isExistInCart(int? productID, int? cartIndex, List<CartModel> cartList) {
    for(int index=0; index<cartList.length; index++) {
      if(cartList[index].product?.id == productID) {
        if((index == cartIndex)) {
          return -1;
        }else {
          return index;
        }
      }
    }
    return -1;
  }

  /// Helper method to get the effective vendor ID based on business type
  int? _getEffectiveVendorId(product_model.Product? product) {
    if (product == null) return null;
    // Use the specific vendor ID based on business type
    // Supermarket products have supermarketId
    if (product.supermarketId != null && product.supermarketId != 0) {
      return product.supermarketId;
    }
    // Pharmacy products have pharmacyId
    if (product.pharmacyId != null && product.pharmacyId != 0) {
      return product.pharmacyId;
    }
    // Restaurant products use restaurantId
    return product.restaurantId;
  }

  @override
  bool existAnotherRestaurantProduct(int? restaurantID, List<CartModel> cartList) {
    for(CartModel cartModel in cartList) {
      int? cartVendorId = _getEffectiveVendorId(cartModel.product);
      if(cartVendorId != restaurantID) {
        return true;
      }
    }
    return false;
  }

  @override
  int setAvailableIndex(int index, int notAvailableIndex) {
    int finalIndex = notAvailableIndex;
    if (notAvailableIndex == index) {
      finalIndex = -1;
    } else {
      finalIndex = index;
    }
    return finalIndex;
  }

  @override
  int cartQuantity(int productID, List<CartModel> cartList) {
    int quantity = 0;
    for(CartModel cart in cartList) {
      if(cart.product?.id == productID) {
        quantity += cart.quantity ?? 0;
      }
    }
    return quantity;
  }

  @override
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId) async {
    return await cartRepositoryInterface.addToCartOnline(cart, guestId);
  }

  @override
  Future<Response> updateCartOnline(OnlineCart cart, int? guestId) async {
    return await cartRepositoryInterface.update(cart.toJson(), guestId);
  }

  @override
  Future<List<OnlineCartModel>> getCartDataOnline(String? id) async {
    return await cartRepositoryInterface.get(id);
  }

  @override
  Future<bool> removeCartItemOnline(int? cartId, String? guestId) async {
    return await cartRepositoryInterface.delete(cartId, guestId: guestId);
  }

  @override
  List<AddOns> prepareAddonList(CartModel cartModel) {
    List<AddOns> addOnList = [];
    final addOnIds = cartModel.addOnIds ?? [];
    final productAddOns = cartModel.product?.addOns ?? [];
    for (var addOnId in addOnIds) {
      for(AddOns addOns in productAddOns) {
        if(addOns.id == addOnId.id) {
          addOnList.add(addOns);
          break;
        }
      }
    }
    return addOnList;
  }

  @override
  double calculateAddonsPrice(List<AddOns> addOnList, double price, CartModel cartModel) {
    double addOnsPrice = price;
    final addOnIds = cartModel.addOnIds ?? [];
    for(int index=0; index<addOnList.length; index++) {
      final addOnPrice = addOnList[index].price ?? 0;
      final addOnQty = index < addOnIds.length ? (addOnIds[index].quantity ?? 1) : 1;
      addOnsPrice = addOnsPrice + (addOnPrice * addOnQty);
    }
    return addOnsPrice;
  }

  @override
  double calculateVariationWithoutDiscountPrice(CartModel cartModel, double price, double? discount, String? discountType) {
    double variationWithoutDiscountPrice = price;
    final variations = cartModel.product?.variations ?? [];
    if(variations.isNotEmpty) {
      for(int index = 0; index < variations.length; index++) {
        final variationValues = variations[index].variationValues ?? [];
        for(int i=0; i < variationValues.length; i++) {
          final cartVariations = cartModel.variations ?? [];
          if(index < cartVariations.length && i < cartVariations[index].length && cartVariations[index][i] == true) {
            final optionPrice = variationValues[i].optionPrice ?? 0;
            final convertedPrice = PriceConverter.convertWithDiscount(optionPrice, discount, discountType, isVariation: true) ?? optionPrice;
            variationWithoutDiscountPrice += (convertedPrice * (cartModel.quantity ?? 1));
          }
        }
      }
    } else {
      variationWithoutDiscountPrice = 0;
    }
    return variationWithoutDiscountPrice;
  }

  @override
  double calculateVariationPrice(CartModel cartModel, double price) {
    double variationPrice = price;
    final variations = cartModel.product?.variations ?? [];
    if(variations.isNotEmpty) {
      for(int index = 0; index < variations.length; index++) {
        final variationValues = variations[index].variationValues ?? [];
        for(int i=0; i < variationValues.length; i++) {
          final cartVariations = cartModel.variations ?? [];
          if(index < cartVariations.length && i < cartVariations[index].length && cartVariations[index][i] == true) {
            final optionPrice = variationValues[i].optionPrice ?? 0;
            variationPrice += (optionPrice * (cartModel.quantity ?? 1));
          }
        }
      }
    } else {
      variationPrice = 0;
    }
    return variationPrice;
  }

}