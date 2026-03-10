import 'package:mnjood/common/models/online_cart_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/product_model.dart' as pv;
import 'package:mnjood/helper/price_converter.dart';

class CartHelper {

  static (List<OrderVariation>, List<int?>) getSelectedVariations ({required List<pv.Variation>? productVariations, required List<List<bool?>> selectedVariations}) {
    List<OrderVariation> variations = [];
    List<int?> optionIds = [];

    // Return empty lists if productVariations is null or empty (e.g., for campaign items)
    if (productVariations == null || productVariations.isEmpty) {
      return (variations, optionIds);
    }

    for(int i=0; i<productVariations.length; i++) {
      if(selectedVariations[i].contains(true)) {
        variations.add(OrderVariation(name: productVariations[i].name, values: OrderVariationValue(label: [])));
        final variationValues = productVariations[i].variationValues;
        if (variationValues != null) {
          for(int j=0; j<variationValues.length; j++) {
            if(selectedVariations[i][j] == true) {
              variations[variations.length-1].values?.label?.add(variationValues[j].level);
              if(variationValues[j].optionId != null) {
                optionIds.add(variationValues[j].optionId);
              }
            }
          }
        }
      }
    }

    return (variations, optionIds);
  }

  static List<int?> getSelectedAddonIds({required List<AddOn> addOnIdList }) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  static List<int?> getSelectedAddonQtnList({required List<AddOn> addOnIdList }) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  static List<CartModel> formatOnlineCartToLocalCart({required List<OnlineCartModel> onlineCartModel}) {

    List<CartModel> cartList = [];
    for (OnlineCartModel cart in onlineCartModel) {
      // Skip items without valid product or price
      if (cart.product == null || cart.price == null) continue;

      double price = cart.price!;
      double? restaurantDiscount = cart.product!.restaurantDiscount ?? 0;
      double? productDiscount = cart.product!.discount ?? 0;
      double? discount = restaurantDiscount == 0 ? productDiscount : restaurantDiscount;
      String? discountType = (restaurantDiscount == 0) ? cart.product!.discountType : 'percent';
      double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

      double? discountAmount = price - discountedPrice;
      int? quantity = cart.quantity;

      List<List<bool?>> selectedFoodVariations = [];
      List<bool> collapsVariation = [];
      List<List<int?>> variationsStock = [];

      // Safely handle variations - may be null for campaign items
      if (cart.product!.variations != null) {
        for(int index=0; index<cart.product!.variations!.length; index++) {
          selectedFoodVariations.add([]);
          collapsVariation.add(true);
          variationsStock.add([]);

          // Safely handle variationValues
          if (cart.product!.variations![index].variationValues != null) {
            for(int i=0; i < cart.product!.variations![index].variationValues!.length; i++) {
              variationsStock[index].add(cart.product!.variations![index].variationValues![i].currentStock);
              if(cart.product!.variations![index].variationValues![i].isSelected ?? false){
                selectedFoodVariations[index].add(true);
              } else {
                selectedFoodVariations[index].add(false);
              }
            }
          }
        }
      }

      List<AddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];

      // Safely handle addOnIds and addOnQtys
      if (cart.addOnIds != null && cart.addOnQtys != null) {
        for (int index = 0; index < cart.addOnIds!.length; index++) {
          int? addOnQty = index < cart.addOnQtys!.length ? cart.addOnQtys![index] : 1;
          addOnIdList.add(AddOn(id: cart.addOnIds![index], quantity: addOnQty));

          // Safely handle product addOns
          if (cart.product!.addOns != null) {
            for (int i=0; i< cart.product!.addOns!.length; i++) {
              if(cart.addOnIds![index] == cart.product!.addOns![i].id) {
                addOnsList.add(AddOns(id: cart.product!.addOns![i].id, name: cart.product!.addOns![i].name, price: cart.product!.addOns![i].price));
              }
            }
          }
        }
      }

      int? quantityLimit = cart.product!.cartQuantityLimit;

      cartList.add(
        CartModel(
          cart.id, price, discountedPrice, discountAmount, quantity,
          addOnIdList, addOnsList, false, cart.product, selectedFoodVariations, quantityLimit, variationsStock,
          unitId: cart.unitId,
          unitInfo: cart.unitInfo,
        ),
      );

    }


    return cartList;
  }

  static String setupVariationText({required CartModel cart}) {
    String variationText = '';

    // Null safety: check both cart.variations and cart.product?.variations
    if(cart.variations != null && cart.variations!.isNotEmpty &&
       cart.product?.variations != null && cart.product!.variations!.isNotEmpty) {
      for(int index=0; index<cart.variations!.length; index++) {
        // Bounds check
        if(index >= cart.product!.variations!.length) break;

        if(cart.variations![index].isNotEmpty && cart.variations![index].contains(true)) {
          variationText = '$variationText${variationText.isNotEmpty ? ', ' : ''}${cart.product!.variations![index].name} (';

          for(int i=0; i<cart.variations![index].length; i++) {
            // Bounds check for variationValues
            if(cart.product!.variations![index].variationValues == null ||
               i >= cart.product!.variations![index].variationValues!.length) continue;

            if(cart.variations![index][i] == true) {
              variationText = '$variationText${variationText.endsWith('(') ? '' : ', '}${cart.product!.variations![index].variationValues![i].level}';
            }
          }
          variationText = '$variationText)';
        }
      }
    }

    return variationText;
  }

  static String? setupAddonsText({required CartModel cart}) {
    String addOnText = '';

    // Null safety: check both cart.addOnIds and cart.product?.addOns
    if(cart.addOnIds == null || cart.product?.addOns == null) {
      return addOnText;
    }

    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.product!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText = '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0 = index0 + 1;
      }
    }
    return addOnText;
  }
}