import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/helper/product_helper.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/category/domain/services/category_service_interface.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Product>? _categoryProductList;
  List<Product>? get categoryProductList => _categoryProductList;

  List<Restaurant>? _categoryRestaurantList;
  List<Restaurant>? get categoryRestaurantList => _categoryRestaurantList;

  List<Product>? _searchProductList = [];
  List<Product>? get searchProductList => _searchProductList;

  List<Restaurant>? _searchRestaurantList = [];
  List<Restaurant>? get searchRestaurantList => _searchRestaurantList;

  // Top supermarket categories for homepage
  List<CategoryModel>? _topSupermarketCategories;
  List<CategoryModel>? get topSupermarketCategories => _topSupermarketCategories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restaurantPageSize;
  int? get restaurantPageSize => _restaurantPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  String? _businessType;
  String? get businessType => _businessType;

  void setBusinessType(String? type) {
    _businessType = type;
  }

  /// Get top supermarket categories for homepage
  Future<void> getTopSupermarketCategories(bool reload, {bool notify = true}) async {
    if (reload) {
      _topSupermarketCategories = null;
    }
    if (notify) {
      update();
    }
    if (_topSupermarketCategories == null || reload) {
      List<CategoryModel>? categories = await categoryServiceInterface.getTopSupermarketCategories();
      if (categories != null) {
        _topSupermarketCategories = [];
        _topSupermarketCategories!.addAll(categories.take(5).toList());
      }
      update();
    }
  }

  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryProductList = null;
    _isRestaurant = false;
    _subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if(_subCategoryList != null) {
      getCategoryProductList(categoryID, 1, 'all', false);
    }
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    if(_isRestaurant) {
      getCategoryRestaurantList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true, businessType: _businessType);
    }else {
      getCategoryProductList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }
  }

  void getCategoryProductList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryProductList = null;
    }
    ProductModel? productModel = await categoryServiceInterface.getCategoryProductList(categoryID, offset, type);
    if(productModel != null) {
      if (offset == 1) {
        _categoryProductList = [];
      }
      _categoryProductList!.addAll(productModel.products!.where((p) => ProductHelper.isInStock(p)).toList());
      _pageSize = productModel.totalSize;
      _isLoading = false;
    }
    update();
  }

  void getCategoryRestaurantList(String? categoryID, int offset, String type, bool notify, {String? businessType}) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryRestaurantList = null;
    }
    RestaurantModel? restaurantModel = await categoryServiceInterface.getCategoryRestaurantList(categoryID, offset, type, businessType: businessType);
    if(restaurantModel != null) {
      if (offset == 1) {
        _categoryRestaurantList = [];
      }
      _categoryRestaurantList!.addAll(restaurantModel.restaurants!);
      _restaurantPageSize = restaurantModel.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if((_isRestaurant && query!.isNotEmpty) || (!_isRestaurant && query!.isNotEmpty)) {
      _searchText = query;
      _type = type;
      if (_isRestaurant) {
        _searchRestaurantList = null;
      } else {
        _searchProductList = null;
      }
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(query, categoryID, _isRestaurant, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isRestaurant) {
            _searchRestaurantList = [];
          } else {
            _searchProductList = [];
          }
        } else {
          if (_isRestaurant) {
            _searchRestaurantList = [];
            _searchRestaurantList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
          } else {
            _searchProductList = [];
            _searchProductList!.addAll(ProductModel.fromJson(response.body).products!.where((p) => ProductHelper.isInStock(p)).toList());
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchProductList = [];
    if(_categoryProductList != null) {
      _searchProductList!.addAll(_categoryProductList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isRestaurant = isRestaurant;
    update();
  }

  void clearSearch({bool isUpdate = true}) {
    _searchText = '';
    _isSearching = false;
    _searchProductList = [];
    _searchRestaurantList = [];
    if(isUpdate) {
      update();
    }
  }

}
