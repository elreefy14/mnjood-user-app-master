import 'package:flutter/scheduler.dart';
import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood/features/address/domain/models/address_model.dart';
import 'package:mnjood/features/checkout/controllers/checkout_controller.dart';
import 'package:mnjood/features/language/controllers/localization_controller.dart';
import 'package:mnjood/features/location/controllers/location_controller.dart';
import 'package:mnjood/features/location/domain/models/zone_response_model.dart';
import 'package:mnjood/features/restaurant/domain/models/cart_suggested_item_model.dart';
import 'package:mnjood/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:mnjood/features/restaurant/domain/models/vendor_banner_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/restaurant/domain/services/restaurant_service_interface.dart';
import 'package:mnjood/helper/address_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantServiceInterface restaurantServiceInterface;

  RestaurantController({required this.restaurantServiceInterface});

  RestaurantModel? _restaurantModel;
  RestaurantModel? get restaurantModel => _restaurantModel;

  List<Restaurant>? _restaurantList;
  List<Restaurant>? get restaurantList => _restaurantList;

  List<Restaurant>? _popularRestaurantList;
  List<Restaurant>? get popularRestaurantList => _popularRestaurantList;

  List<Restaurant>? _latestRestaurantList;
  List<Restaurant>? get latestRestaurantList => _latestRestaurantList;

  List<Restaurant>? _recentlyViewedRestaurantList;
  List<Restaurant>? get recentlyViewedRestaurantList => _recentlyViewedRestaurantList;

  // Discount restaurant lists by business type
  final Map<String, List<Restaurant>> _discountRestaurantListByType = {};
  List<Restaurant>? getDiscountRestaurantListByType(String? type) => _discountRestaurantListByType[type ?? 'all'];

  // Top pharmacies list for homepage (independent of current business type filter)
  List<Restaurant>? _topPharmacyList;
  List<Restaurant>? get topPharmacyList => _topPharmacyList;

  // Top restaurants list for homepage (independent of current business type filter)
  List<Restaurant>? _topRestaurantList;
  List<Restaurant>? get topRestaurantList => _topRestaurantList;

  // Top coffee shops list for homepage (independent of current business type filter)
  List<Restaurant>? _topCoffeeShopList;
  List<Restaurant>? get topCoffeeShopList => _topCoffeeShopList;

  Restaurant? _restaurant;
  Restaurant? get restaurant => _restaurant;

  List<Product>? _restaurantProducts;
  List<Product>? get restaurantProducts => _restaurantProducts;

  ProductModel? _restaurantProductModel;
  ProductModel? get restaurantProductModel => _restaurantProductModel;

  ProductModel? _restaurantSearchProductModel;
  ProductModel? get restaurantSearchProductModel => _restaurantSearchProductModel;

  int _categoryIndex = 0;
  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _restaurantType = 'all';
  String get restaurantType => _restaurantType;

  bool _foodPaginate = false;
  bool get foodPaginate => _foodPaginate;

  int? _foodPageSize;
  int? get foodPageSize => _foodPageSize;

  List<int> _foodOffsetList = [];

  int _foodOffset = 1;
  int get foodOffset => _foodOffset;

  String _type = 'all';
  String get type => _type;

  String _searchType = 'all';
  String get searchType => _searchType;

  String _searchText = '';
  String get searchText => _searchText;

  RecommendedProductModel? _recommendedProductModel;
  RecommendedProductModel? get recommendedProductModel => _recommendedProductModel;

  CartSuggestItemModel? _cartSuggestItemModel;
  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;

  List<Product>? _suggestedItems;
  List<Product>? get suggestedItems => _suggestedItems;

  int? _foodPageOffset;
  int? get foodPageOffset => _foodPageOffset;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<Restaurant>? _orderAgainRestaurantList;
  List<Restaurant>? get orderAgainRestaurantList => _orderAgainRestaurantList;

  int _topRated = 0;
  int get topRated => _topRated;

  int _discount = 0;
  int get discount => _discount;

  int _veg = 0;
  int get veg => _veg;

  int _nonVeg = 0;
  int get nonVeg => _nonVeg;

  String _businessType = 'all'; // all, restaurant, supermarket, pharmacy
  String get businessType => _businessType;

  int _nearestRestaurantIndex = -1;
  int get nearestRestaurantIndex => _nearestRestaurantIndex;

  List<VendorBannerModel>? _vendorBanners;
  List<VendorBannerModel>? get vendorBanners => _vendorBanners;

  int _vendorBannerIndex = 0;
  int get vendorBannerIndex => _vendorBannerIndex;

  /// Safely update the controller, avoiding setState during build errors
  void _safeUpdate() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're in the middle of a frame, schedule update for after the frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        update();
      });
    } else {
      update();
    }
  }

  void setNearestRestaurantIndex(int index, {bool notify = true}) {
    _nearestRestaurantIndex = index;
    if(notify) {
      _safeUpdate();
    }
  }

  double getRestaurantDistance(LatLng restaurantLatLng){
    return restaurantServiceInterface.getRestaurantDistanceFromUser(restaurantLatLng);
  }

  String filteringUrl(String slug){
    return restaurantServiceInterface.filterRestaurantLinkUrl(slug, _restaurant?.id, _restaurant?.zoneId);
  }

  Future<void> getOrderAgainRestaurantList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local}) async {
    if(reload) {
      _orderAgainRestaurantList = null;
      _safeUpdate();
    }
    List<Restaurant>? orderAgainRestaurantList;
    if(dataSource == DataSourceEnum.local) {
      orderAgainRestaurantList = await restaurantServiceInterface.getOrderAgainRestaurantList(source: DataSourceEnum.local, businessType: _businessType);
      _prepareOrderAgainRestaurantList(orderAgainRestaurantList);
      getOrderAgainRestaurantList(false, dataSource: DataSourceEnum.client);
    } else {
      orderAgainRestaurantList = await restaurantServiceInterface.getOrderAgainRestaurantList(source: DataSourceEnum.client, businessType: _businessType);
      _prepareOrderAgainRestaurantList(orderAgainRestaurantList);
    }
  }

  void _prepareOrderAgainRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _orderAgainRestaurantList = [];
      _orderAgainRestaurantList = restaurantList;
    }
    _safeUpdate();
  }

  Future<void> getRecentlyViewedRestaurantList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    _type = type;
    if(reload && !fromRecall){
      _recentlyViewedRestaurantList = null;
    }
    if(notify) {
      _safeUpdate();
    }
    List<Restaurant>? recentlyViewedRestaurantList;
    if(_recentlyViewedRestaurantList == null || reload || fromRecall) {
      if(dataSource == DataSourceEnum.local) {
        recentlyViewedRestaurantList = await restaurantServiceInterface.getRecentlyViewedRestaurantList(type, source: DataSourceEnum.local, businessType: _businessType);
        _prepareRecentlyViewedRestaurantList(recentlyViewedRestaurantList);
        getRecentlyViewedRestaurantList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        recentlyViewedRestaurantList = await restaurantServiceInterface.getRecentlyViewedRestaurantList(type, source: DataSourceEnum.client, businessType: _businessType);
        _prepareRecentlyViewedRestaurantList(recentlyViewedRestaurantList);
      }
    }
  }

  void _prepareRecentlyViewedRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _recentlyViewedRestaurantList = [];
      _recentlyViewedRestaurantList = restaurantList;
    }
    _safeUpdate();
  }

  Future<void> getRestaurantRecommendedItemList(int? restaurantId, bool reload, {String? businessType}) async {
    _recommendedProductModel = null;
    if(reload) {
      _restaurantModel = null;
      _safeUpdate();
    }
    // Use restaurant's business type for the API call
    final type = businessType ?? _restaurant?.businessType;
    _recommendedProductModel = await restaurantServiceInterface.getRestaurantRecommendedItemList(restaurantId, businessType: type);
    _safeUpdate();
  }

  Future<void> getRestaurantList(int offset, bool reload, {bool fromMap = false, DataSourceEnum source = DataSourceEnum.local}) async {
    if(reload) {
      _restaurantModel = null;
      _safeUpdate();
    }

    RestaurantModel? restaurantModel;
    if(source == DataSourceEnum.local && offset == 1) {
      restaurantModel = await restaurantServiceInterface.getRestaurantList(offset, _restaurantType, _topRated, _discount, _veg, _nonVeg, fromMap: fromMap, source: DataSourceEnum.local, businessType: _businessType);
      _prepareRestaurantList(restaurantModel, offset);
      getRestaurantList(1, false, fromMap: fromMap, source: DataSourceEnum.client);
    } else {
      restaurantModel = await restaurantServiceInterface.getRestaurantList(offset, _restaurantType, _topRated, _discount, _veg, _nonVeg, fromMap: fromMap, source: DataSourceEnum.client, businessType: _businessType);
      _prepareRestaurantList(restaurantModel, offset);
    }
  }

  void _prepareRestaurantList(RestaurantModel? restaurantModel, int offset) {
    if (restaurantModel != null) {
      if (offset == 1) {
        _restaurantModel = restaurantModel;
      }else {
        _restaurantModel!.totalSize = restaurantModel.totalSize;
        _restaurantModel!.offset = restaurantModel.offset;
        _restaurantModel!.restaurants!.addAll(restaurantModel.restaurants!);
      }
      _safeUpdate();
    }
  }

  void setRestaurantType(String type) {
    _restaurantType = type;
    getRestaurantList(1, true);
  }

  void setTopRated() {
    _topRated = restaurantServiceInterface.setTopRated(_topRated);
    getRestaurantList(1, true);
  }

  void setDiscount() {
    _discount = restaurantServiceInterface.setDiscounted(_discount);
    getRestaurantList(1, true);
  }

  void setVeg() {
    _veg = restaurantServiceInterface.setVeg(_veg);
    getRestaurantList(1, true);
  }

  void setNonVeg() {
    _nonVeg = restaurantServiceInterface.setNonVeg(_nonVeg);
    getRestaurantList(1, true);
  }

  void setBusinessType(String type, {bool reload = true}) {
    _businessType = type;
    if (reload) {
      getRestaurantList(1, true);
    }
    _safeUpdate();
  }

  Future<void> getPopularRestaurantList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false, String? businessType}) async {
    _type = type;
    if (reload && !fromRecall) {
      _popularRestaurantList = null;
    }
    if (notify) {
      _safeUpdate();
    }
    List<Restaurant>? popularRestaurantList;
    final effectiveBusinessType = businessType ?? _businessType;
    if (_popularRestaurantList == null || reload || fromRecall) {

      if (dataSource == DataSourceEnum.local) {
        popularRestaurantList = await restaurantServiceInterface.getPopularRestaurantList(type, source: DataSourceEnum.local, businessType: effectiveBusinessType);
        _preparePopularRestaurantList(popularRestaurantList);
        getPopularRestaurantList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true, businessType: businessType);
      } else {
        popularRestaurantList = await restaurantServiceInterface.getPopularRestaurantList(type, source: DataSourceEnum.client, businessType: effectiveBusinessType);
        _preparePopularRestaurantList(popularRestaurantList);
      }
    }
  }

  void _preparePopularRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _popularRestaurantList = [];
      _popularRestaurantList!.addAll(restaurantList);
    }
    _safeUpdate();
  }

  /// Get top pharmacies for homepage (always fetches pharmacy business type)
  Future<void> getTopPharmacyList(bool reload, {bool notify = true}) async {
    if (reload) {
      _topPharmacyList = null;
    }
    if (notify) {
      _safeUpdate();
    }
    if (_topPharmacyList == null || reload) {
      // Always fetch pharmacies specifically, regardless of current business type filter
      List<Restaurant>? pharmacyList = await restaurantServiceInterface.getPopularRestaurantList(
        'all',
        source: DataSourceEnum.client,
        businessType: 'pharmacy'
      );
      if (pharmacyList != null) {
        _topPharmacyList = [];
        _topPharmacyList!.addAll(pharmacyList.take(5).toList());
      }
      _safeUpdate();
    }
  }

  /// Get top restaurants for homepage (always fetches restaurant business type)
  Future<void> getTopRestaurantList(bool reload, {bool notify = true}) async {
    if (reload) {
      _topRestaurantList = null;
    }
    if (notify) {
      _safeUpdate();
    }
    if (_topRestaurantList == null || reload) {
      // Always fetch restaurants specifically, regardless of current business type filter
      List<Restaurant>? restaurantList = await restaurantServiceInterface.getPopularRestaurantList(
        'all',
        source: DataSourceEnum.client,
        businessType: 'restaurant'
      );
      if (restaurantList != null) {
        _topRestaurantList = [];
        _topRestaurantList!.addAll(restaurantList.take(8).toList());
      }
      _safeUpdate();
    }
  }

  /// Get top coffee shops for homepage (always fetches coffee_shop business type)
  Future<void> getTopCoffeeShopList(bool reload, {bool notify = true}) async {
    if (reload) {
      _topCoffeeShopList = null;
    }
    if (notify) {
      _safeUpdate();
    }
    if (_topCoffeeShopList == null || reload) {
      // Always fetch coffee shops specifically, regardless of current business type filter
      List<Restaurant>? coffeeShopList = await restaurantServiceInterface.getPopularRestaurantList(
        'all',
        source: DataSourceEnum.client,
        businessType: 'coffee_shop'
      );
      if (coffeeShopList != null) {
        _topCoffeeShopList = [];
        _topCoffeeShopList!.addAll(coffeeShopList.take(8).toList());
      }
      _safeUpdate();
    }
  }

  Future<void> getLatestRestaurantList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    _type = type;
    if(reload){
      _latestRestaurantList = null;
    }
    if(notify) {
      _safeUpdate();
    }

    List<Restaurant>? latestRestaurantList;
    if(_latestRestaurantList == null || reload || fromRecall) {

      if(dataSource == DataSourceEnum.local) {
        latestRestaurantList = await restaurantServiceInterface.getLatestRestaurantList(type, source: DataSourceEnum.local, businessType: _businessType);
        _prepareLatestRestaurantList(latestRestaurantList);
        getLatestRestaurantList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        latestRestaurantList = await restaurantServiceInterface.getLatestRestaurantList(type, source: DataSourceEnum.client, businessType: _businessType);
        _prepareLatestRestaurantList(latestRestaurantList);
      }
    }
  }

  void _prepareLatestRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _latestRestaurantList = [];
      _latestRestaurantList = restaurantList;
    }
    _safeUpdate();
  }

  Future<void> getDiscountRestaurantList(bool reload, String businessType, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    bool hasData = _discountRestaurantListByType.containsKey(businessType);

    if (reload && !fromRecall) {
      _discountRestaurantListByType.remove(businessType);
      hasData = false;
    }
    if (notify) {
      _safeUpdate();
    }

    List<Restaurant>? discountRestaurantList;
    if (!hasData || reload || fromRecall) {
      if (dataSource == DataSourceEnum.local) {
        discountRestaurantList = await restaurantServiceInterface.getDiscountRestaurantList(businessType: businessType, source: DataSourceEnum.local);
        _prepareDiscountRestaurantList(discountRestaurantList, businessType);
        getDiscountRestaurantList(false, businessType, false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        discountRestaurantList = await restaurantServiceInterface.getDiscountRestaurantList(businessType: businessType, source: DataSourceEnum.client);
        _prepareDiscountRestaurantList(discountRestaurantList, businessType);
      }
    }
  }

  void _prepareDiscountRestaurantList(List<Restaurant>? restaurantList, String businessType) {
    // Always store the list (empty if null) so widgets can properly hide when no data
    _discountRestaurantListByType[businessType] = restaurantList ?? [];
    _safeUpdate();
  }

  Future<void> setCategoryList({int? vendorId, String? businessType}) async {
    // Fetch vendor-specific categories from the V1 filter API for all business types
    final type = businessType ?? _restaurant?.businessType;
    final id = vendorId ?? _restaurant?.vendorId ?? _restaurant?.id;

    if ((type == 'pharmacy' || type == 'supermarket' || type == 'coffee_shop' || type == 'restaurant') && id != null) {
      List<CategoryModel>? vendorCategories = await restaurantServiceInterface.getVendorCategories(id, type);
      if (vendorCategories != null && vendorCategories.isNotEmpty) {
        _categoryList = [CategoryModel(id: 0, name: 'all'.tr)];
        _categoryList!.addAll(vendorCategories);
        _safeUpdate();
        return;
      }
    }

    // No fallback — vendor-specific categories are the only source
  }


  Future<Restaurant?> getRestaurantDetails(Restaurant restaurant, {bool fromCart = false, String slug = '', String? businessType}) async {
    _categoryIndex = 0;
    // Use businessType from parameter, or fall back to restaurant's businessType
    final effectiveBusinessType = businessType ?? restaurant.businessType;

    if(restaurant.name != null) {
      _restaurant = restaurant;
    }else {
      _isLoading = true;
      _restaurant = null;
      _restaurant = await restaurantServiceInterface.getRestaurantDetails(
        restaurant.id.toString(),
        slug,
        Get.find<LocalizationController>().locale.languageCode,
        businessType: effectiveBusinessType,
      );
      if(_restaurant != null && _restaurant!.latitude != null){
        await _setRequiredDataAfterRestaurantGet(slug, fromCart);
      }
      Get.find<CheckoutController>().setOrderType(
        (_restaurant != null && _restaurant!.delivery != null) ? _restaurant!.delivery! ? 'delivery' : 'take_away' : 'delivery', notify: false,
      );

      _isLoading = false;
      _safeUpdate();
    }
    return _restaurant;
  }

  Future<void> _setRequiredDataAfterRestaurantGet(String slug, bool fromCart) async {
    if(_restaurant == null) return;

    Get.find<CheckoutController>().initializeTimeSlot(_restaurant!);

    final address = AddressHelper.getAddressFromSharedPref();
    final hasValidAddress = address != null && address.latitude != null && address.longitude != null;
    final hasValidRestaurantCoords = _restaurant!.latitude != null && _restaurant!.longitude != null;

    if(!fromCart && slug.isEmpty && hasValidAddress && hasValidRestaurantCoords){
      Get.find<CheckoutController>().getDistanceInKM(
        LatLng(
          double.parse(address.latitude!),
          double.parse(address.longitude!),
        ),
        LatLng(double.parse(_restaurant!.latitude!), double.parse(_restaurant!.longitude!)),
      );
    }
    if(slug.isNotEmpty && hasValidRestaurantCoords){
      await _setStoreAddressToUserAddress(LatLng(double.parse(_restaurant!.latitude!), double.parse(_restaurant!.longitude!)));
    }
  }

  Future<void> _setStoreAddressToUserAddress(LatLng restaurantAddress) async {
    Position storePosition = Position(
      latitude: restaurantAddress.latitude, longitude: restaurantAddress.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
    );
    String addressFromGeocode = await Get.find<LocationController>().getAddressFromGeocode(LatLng(restaurantAddress.latitude, restaurantAddress.longitude));
    ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(storePosition.latitude.toString(), storePosition.longitude.toString(), true);
    AddressModel addressModel = restaurantServiceInterface.prepareAddressModel(storePosition, responseModel, addressFromGeocode);
    await AddressHelper.saveAddressInSharedPref(addressModel);
  }

  void makeEmptyRestaurant({bool willUpdate = true}) {
    _restaurant = null;
    if(willUpdate) {
      _safeUpdate();
    }
  }

  Future<void> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    final items = await restaurantServiceInterface.getCartRestaurantSuggestedItemList(restaurantID);
    _suggestedItems = items?.toList();
    _safeUpdate();
  }

  Future<void> getRestaurantProductList(int? restaurantID, int offset, String type, bool notify, {String? businessType}) async {
    _foodOffset = offset;
    if(offset == 1 || _restaurantProducts == null) {
      _type = type;
      _foodOffsetList = [];
      _restaurantProducts = null;
      _foodOffset = 1;
      if(notify) {
        _safeUpdate();
      }
    }
    if (!_foodOffsetList.contains(offset)) {
      _foodOffsetList.add(offset);
      // Use restaurant's business type for the API call
      final vendorType = businessType ?? _restaurant?.businessType;
      ProductModel? productModel = await restaurantServiceInterface.getRestaurantProductList(restaurantID, offset,
          (_categoryIndex != 0 && _categoryList != null && _categoryIndex < _categoryList!.length)
          ? _categoryList![_categoryIndex].id : 0, type, businessType: vendorType);

      if (productModel != null) {
        if (offset == 1) {
          _restaurantProducts = [];
        }
        if (productModel.products != null) {
          _restaurantProducts!.addAll(productModel.products!);
        }
        _foodPageSize = productModel.totalSize;
        _foodPageOffset = productModel.offset;
        _foodPaginate = false;

        _safeUpdate();
      }
    } else {
      if(_foodPaginate) {
        _foodPaginate = false;
        _safeUpdate();
      }
    }
  }

  void showFoodBottomLoader() {
    _foodPaginate = true;
    _safeUpdate();
  }

  void setFoodOffset(int offset) {
    _foodOffset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    _safeUpdate();
  }

  Future<void> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type, {String? businessType}) async {
    if(searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    }else {
      _isSearching = true;
      _searchText = searchText;
      if(offset == 1 || _restaurantSearchProductModel == null) {
        _searchType = type;
        _restaurantSearchProductModel = null;
        _safeUpdate();
      }
      // Use restaurant's business type for the API call
      final vendorType = businessType ?? _restaurant?.businessType;
      ProductModel? productModel = await restaurantServiceInterface.getRestaurantSearchProductList(searchText, storeID, offset, type, businessType: vendorType);
      if (productModel != null) {
        if (offset == 1) {
          _restaurantSearchProductModel = productModel;
        }else {
          _restaurantSearchProductModel!.products!.addAll(productModel.products!);
          _restaurantSearchProductModel!.totalSize = productModel.totalSize;
          _restaurantSearchProductModel!.offset = productModel.offset;
        }
      }
      _safeUpdate();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if(isUpdate) {
      _safeUpdate();
    }
  }

  void initSearchData() {
    _restaurantSearchProductModel = ProductModel(products: []);
    _searchText = '';
    _searchType = 'all';
  }

  void setCategoryIndex(int index) {
    _categoryIndex = index;
    _restaurantProducts = null;
    // Use vendorId for supermarkets/pharmacies, fallback to id for restaurants
    getRestaurantProductList(_restaurant!.vendorId ?? _restaurant!.id, 1, type, false);
    _safeUpdate();
  }

  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules, {int? customDateDuration}) {
    return restaurantServiceInterface.isRestaurantClosed(dateTime, active, schedules);
  }

  bool isRestaurantOpenNow(bool active, List<Schedules>? schedules) {
    return restaurantServiceInterface.isRestaurantOpenNow(active, schedules);
  }

  bool isOpenNow(Restaurant restaurant) => restaurant.open == 1 && restaurant.active!;

  double? getDiscount(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discount : 0;

  String? getDiscountType(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discountType : 'percent';

  Future<void> getVendorBanners(int vendorId, {bool reload = false}) async {
    if (reload) {
      _vendorBanners = null;
      _safeUpdate();
    }
    if (_vendorBanners == null || reload) {
      _vendorBanners = await restaurantServiceInterface.getVendorBanners(vendorId);
      _safeUpdate();
    }
  }

  void setVendorBannerIndex(int index, bool notify) {
    _vendorBannerIndex = index;
    if (notify) {
      _safeUpdate();
    }
  }

  void clearVendorBanners() {
    _vendorBanners = null;
    _vendorBannerIndex = 0;
  }

}