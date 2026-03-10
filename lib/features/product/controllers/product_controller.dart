import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/features/cart/controllers/cart_controller.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/cart/domain/models/cart_model.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/product/domain/services/product_service_interface.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/images.dart';
import 'package:mnjood/common/widgets/confirmation_dialog_widget.dart';
import 'package:mnjood/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductController extends GetxController implements GetxService {
  final ProductServiceInterface productServiceInterface;
  ProductController({required this.productServiceInterface});

  List<Product>? _popularProductList;
  List<Product>? get popularProductList => _popularProductList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<List<bool?>> _selectedVariations = [];
  List<List<bool?>> get selectedVariations => _selectedVariations;

  int? _quantity = 1;
  int? get quantity => _quantity;

  List<bool> _addOnActiveList = [];
  List<bool> get addOnActiveList => _addOnActiveList;

  List<int?> _addOnQtyList = [];
  List<int?> get addOnQtyList => _addOnQtyList;

  String _popularType = 'all';
  String get popularType => _popularType;

  static final List<String> _productTypeList = ['all', 'veg', 'non_veg'];
  List<String> get productTypeList => _productTypeList;

  int _cartIndex = -1;
  int get cartIndex => _cartIndex;

  int _imageIndex = 0;
  int get imageIndex => _imageIndex;

  List<bool> _collapseVariation = [];
  List<bool> get collapseVariation => _collapseVariation;

  bool _canAddToCartProduct = true;
  bool get canAddToCartProduct => _canAddToCartProduct;

  List<List<int?>> _variationsStock = [];
  List<List<int?>> get variationsStock => _variationsStock;

  int? _selectedUnitIndex;
  int? get selectedUnitIndex => _selectedUnitIndex;
  ProductUnit? get selectedUnit {
    if (_product == null || _product!.units == null || _product!.units!.isEmpty || _selectedUnitIndex == null) return null;
    return _product!.units![_selectedUnitIndex!];
  }

  Product? _product;
  Product? get product => _product;


  void changeCanAddToCartProduct(bool status) {
    _canAddToCartProduct = status;
  }

  void setSelectedUnit(int index) {
    _selectedUnitIndex = index;
    final unit = _product?.units?[index];
    if (unit != null && unit.minOrderQty != null && (_quantity ?? 1) < unit.minOrderQty!) {
      _quantity = unit.minOrderQty;
    }
    update();
  }

  Future<Product?> getProductDetails(int id, CartModel? cart, {bool isCampaign = false, int? vendorId, String? businessType}) async {
    _product = null;
    _product = await productServiceInterface.getProductDetails(id: id, isCampaign: isCampaign, vendorId: vendorId, businessType: businessType);
    if(_product != null) {
      initData(_product, cart);
    }
    update();
    return _product;
  }

  Future<void> getPopularProductList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    _popularType = type;
    if(reload) {
      _popularProductList = null;
    }
    if(notify) {
      update();
    }
    if(_popularProductList == null || reload || fromRecall) {
      _popularProductList = null;

      List<Product>? popularProductList;

      // For pharmacy type, use dedicated pharmacy products endpoint
      if (type == 'pharmacy') {
        if(dataSource == DataSourceEnum.local) {
          popularProductList = await productServiceInterface.getPharmacyProducts(source: DataSourceEnum.local);
          _preparePharmacyProductList(popularProductList);
          getPopularProductList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
        } else {
          popularProductList = await productServiceInterface.getPharmacyProducts(source: DataSourceEnum.client);
          _preparePharmacyProductList(popularProductList);
        }
      } else {
        if(dataSource == DataSourceEnum.local) {
          popularProductList = await productServiceInterface.getPopularProductList(type: type, source: DataSourceEnum.local);
          _preparePopularProductList(popularProductList);
          getPopularProductList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
        } else {
          popularProductList = await productServiceInterface.getPopularProductList(type: type, source: DataSourceEnum.client);
          _preparePopularProductList(popularProductList);
        }
      }
    }
  }

  void _preparePharmacyProductList(List<Product>? pharmacyProductList) {
    if(pharmacyProductList != null) {
      _popularProductList = [];
      _popularProductList!.addAll(pharmacyProductList.where((p) => ProductHelper.isInStock(p)).toList());
    }
    update();
  }

  void _preparePopularProductList(List<Product>? popularProductList) {
    if(popularProductList != null) {
      _popularProductList = [];
      // Filter by business type if specified
      if (_popularType == 'pharmacy') {
        // Only include pharmacy products (have pharmacy_id or business type is pharmacy)
        _popularProductList!.addAll(popularProductList.where((p) =>
          ProductHelper.isInStock(p) && (p.pharmacyId != null || p.businessType == 'pharmacy')
        ).toList());
      } else if (_popularType == 'supermarket') {
        // Only include supermarket products
        _popularProductList!.addAll(popularProductList.where((p) =>
          ProductHelper.isInStock(p) && (p.supermarketId != null || p.businessType == 'supermarket')
        ).toList());
      } else if (_popularType == 'restaurant' || _popularType == 'food' || _popularType == 'all') {
        // Include restaurant/food products (no pharmacy_id or supermarket_id)
        _popularProductList!.addAll(popularProductList.where((p) =>
          ProductHelper.isInStock(p) && p.pharmacyId == null && p.supermarketId == null
        ).toList());
      } else {
        // Default: add all
        _popularProductList!.addAll(popularProductList.where((p) => ProductHelper.isInStock(p)).toList());
      }
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if(notify) {
      update();
    }
  }

  void initData(Product? product, CartModel? cart) {
    _canAddToCartProduct = true;
    _selectedVariations = [];
    _variationsStock = [];
    _addOnQtyList = [];
    _addOnActiveList = [];
    _collapseVariation = [];

    // Initialize unit selection
    _selectedUnitIndex = null;
    if (product != null && product.units != null && product.units!.isNotEmpty) {
      // If editing a cart item with a unit, match it
      if (cart != null && cart.unitId != null) {
        _selectedUnitIndex = product.units!.indexWhere((u) => u.unitId == cart.unitId);
        if (_selectedUnitIndex == -1) _selectedUnitIndex = 0;
      } else {
        // Find default unit
        _selectedUnitIndex = product.units!.indexWhere((u) => u.isDefault == true);
        if (_selectedUnitIndex == -1) _selectedUnitIndex = 0;
      }
    }

    if(cart != null) {
      _quantity = cart.quantity;
      _selectedVariations.addAll(cart.variations!);
      _variationsStock = productServiceInterface.initializeVariationsStock(product!.variations);
      _addOnActiveList = productServiceInterface.initializeCartAddonActiveList(product, cart.addOnIds);
      _addOnQtyList = productServiceInterface.initializeCartAddonQuantityList(product, cart.addOnIds);
      _collapseVariation = productServiceInterface.initializeCollapseVariation(product.variations);

    }else {
      _quantity = 1;
      _selectedVariations = productServiceInterface.initializeSelectedVariation(product!.variations);
      _variationsStock = productServiceInterface.initializeVariationsStock(product.variations);
      _collapseVariation = productServiceInterface.initializeCollapseVariation(product.variations);
      _addOnActiveList = productServiceInterface.initializeAddonActiveList(product.addOns);
      _addOnQtyList = productServiceInterface.initializeAddonQuantityList(product.addOns);

    }
    setExistInCartForBottomSheet(product, selectedVariations);
  }

  String? checkOutOfStockVariationSelected(List<Variation>? variations) {
    for(int i=0; i< _selectedVariations.length; i++) {
      for(int j=0; j< _selectedVariations[i].length; j++) {
        if(_selectedVariations[i][j]!) {
          if (variations![i].variationValues![j].currentStock != null && variations[i].variationValues![j].currentStock! <= 0 && variations[i].variationValues![j].stockType != 'unlimited') {
            return '${variations[i].variationValues![j].level} ${'variation_is_out_of_stock'.tr}';
          }
        }
      }
    }
    return null;
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    return productServiceInterface.selectedVariationLength(selectedVariations, index);
  }

  int setExistInCart(Product product, {bool notify = true}) {
    _cartIndex = Get.find<CartController>().isExistInCart(product.id, null);
    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
      _addOnActiveList = productServiceInterface.initializeCartAddonActiveList(product, Get.find<CartController>().cartList[_cartIndex].addOnIds!);
      _addOnQtyList = productServiceInterface.initializeCartAddonQuantityList(product, Get.find<CartController>().cartList[_cartIndex].addOnIds!);
    }
    return _cartIndex;
  }

  int setExistInCartForBottomSheet(Product product, List<List<bool?>>? selectedVariations, {bool notify = true}) {

    _cartIndex = productServiceInterface.isExistInCartForBottomSheet(Get.find<CartController>().cartList, product.id, null, selectedVariations);
    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
      _addOnActiveList = productServiceInterface.initializeCartAddonActiveList(product, Get.find<CartController>().cartList[_cartIndex].addOnIds!);
      _addOnQtyList = productServiceInterface.initializeCartAddonQuantityList(product, Get.find<CartController>().cartList[_cartIndex].addOnIds!);
    } else {
      _quantity = 1;
    }
    return _cartIndex;
  }

  void setAddOnQuantity(bool isIncrement, int index, String? stockType, int? addonStock) {
    _addOnQtyList[index] = productServiceInterface.setAddonQuantity(_addOnQtyList[index]!, isIncrement, stockType, addonStock);
    update();
  }

  void setQuantity(bool isIncrement, int? cartQuantityLimit, int? maxQtyPerUser, String? stockType, int? itemStock, bool isCampaign) {
    _quantity = productServiceInterface.setQuantity(isIncrement, cartQuantityLimit, maxQtyPerUser, _quantity!, _selectedVariations, _variationsStock, stockType, itemStock, isCampaign);
    update();
  }

  void setCartVariationIndex(int index, int i, Product? product, bool isMultiSelect) {
    _selectedVariations = productServiceInterface.setCartVariationIndex(index, i, product!.variations, isMultiSelect, _selectedVariations);
    update();
  }

  void addAddOn(bool isAdd, int index, String? stockType, int? stock) {
    if(stock != null && (stock > 0 && stockType != 'unlimited') || (stockType == 'unlimited')) {
      _addOnActiveList[index] = isAdd;
    }/* else {
      // showCustomSnackBar('addon_out_of_stock'.tr, showToaster: true);
    }*/
    update();
  }

  void showMoreSpecificSection(int index){
    _collapseVariation[index] = !_collapseVariation[index];
    update();
  }

  void productDirectlyAddToCart(Product? product, BuildContext context, {bool inStore = false, bool isCampaign = false, String? businessType, int? vendorId}) {
    // Check if user is logged in before adding to cart - redirect to login
    if(!AuthHelper.isLoggedIn()) {
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
      return;
    }

    // If product has multiple units (supermarket), always show bottom sheet for unit selection
    if (product!.hasMultipleUnits && (businessType == 'supermarket' || product.businessType == 'supermarket')) {
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
        ProductBottomSheetWidget(product: product, isCampaign: false, businessType: businessType, vendorId: vendorId),
        backgroundColor: Colors.transparent, isScrollControlled: true,
      ) : Get.dialog(
        Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: businessType, vendorId: vendorId)),
      );
      return;
    }

    if (product.variations == null || (product.variations != null && product.variations!.isEmpty)) {
      double price = product.price!;
      double discount = product.discount!;
      double discountPrice = PriceConverter.convertWithDiscount(price, discount, product.discountType)!;

      CartModel cartModel = CartModel(
        null, price, discountPrice, (price - discountPrice),
        1, [], [], false, product, [], product.cartQuantityLimit, [],
      );

      OnlineCart onlineCart = OnlineCart(
        null, isCampaign ? null : product.id, isCampaign ? product.id : null,
        discountPrice.toString(), [], 1, [], [], [], 'Food',
        vendorId: vendorId ?? (product.supermarketId != null && product.supermarketId != 0 ? product.supermarketId : (product.pharmacyId != null && product.pharmacyId != 0 ? product.pharmacyId : product.restaurantId)),
        vendorType: businessType ?? 'restaurant',
      );

      setExistInCart(product);

      if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
        Get.dialog(ConfirmationDialogWidget(
          icon: Images.warning,
          title: 'are_you_sure_to_reset'.tr,
          description: 'if_you_continue'.tr,
          onYesPressed: () {
            Get.find<CartController>().clearCartOnline().then((success) async {
              if (success) {
                Get.back();
                await Get.find<CartController>().addToCartOnline(onlineCart, fromDirectlyAdd: true);
              }
            });
          },
        ), barrierDismissible: false);
      } else {
        Get.find<CartController>().addToCartOnline(onlineCart, fromDirectlyAdd: true);
      }
    } else {
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
        ProductBottomSheetWidget(product: product, isCampaign: false, businessType: businessType, vendorId: vendorId),
        backgroundColor: Colors.transparent, isScrollControlled: true,
      ) : Get.dialog(
        Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false, businessType: businessType, vendorId: vendorId)),
      );
    }
  }

}
