import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/home/domain/models/banner_model.dart';
import 'package:mnjood/features/home/domain/models/cashback_model.dart';
import 'package:mnjood/features/home/domain/models/home_section_model.dart';
import 'package:mnjood/features/home/domain/models/main_category_model.dart';
import 'package:mnjood/features/home/domain/models/slider_model.dart';
import 'package:mnjood/features/home/domain/services/home_service_interface.dart';
import 'package:get/get.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;

  HomeController({required this.homeServiceInterface});

  List<String?>? _bannerImageList;
  List<dynamic>? _bannerDataList;

  List<String?>? get bannerImageList => _bannerImageList;
  List<dynamic>? get bannerDataList => _bannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  List<MainCategoryModel>? _mainCategoriesList;
  List<MainCategoryModel>? get mainCategoriesList => _mainCategoriesList;

  List<Product>? _mnjoodMartProducts;
  List<Product>? get mnjoodMartProducts => _mnjoodMartProducts;

  int _mnjoodMartProductsPage = 1;
  int get mnjoodMartProductsPage => _mnjoodMartProductsPage;

  bool _mnjoodMartHasMore = true;
  bool get mnjoodMartHasMore => _mnjoodMartHasMore;

  bool _mnjoodMartLoading = false;
  bool get mnjoodMartLoading => _mnjoodMartLoading;

  int? _currentMartCategoryId;
  int? get currentMartCategoryId => _currentMartCategoryId;

  List<SliderModel>? _sliderList;
  List<SliderModel>? get sliderList => _sliderList;

  int _sliderIndex = 0;
  int get sliderIndex => _sliderIndex;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  List<CategoryModel>? _restaurantCategories;
  List<CategoryModel>? get restaurantCategories => _restaurantCategories;

  // Business type specific categories (keyed by business type)
  final Map<String, List<CategoryModel>?> _businessTypeCategories = {};
  List<CategoryModel>? getCategoriesForBusinessType(String type) => _businessTypeCategories[type];

  // Dynamic home sections from API
  List<HomeSectionModel>? _homeSections;
  List<HomeSectionModel>? get homeSections => _homeSections;

  Future<void> getHomeSections({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_homeSections == null || fromRecall) {
      if(!fromRecall) {
        _homeSections = null;
      }
      List<HomeSectionModel>? sectionList;

      if(dataSource == DataSourceEnum.local){
        sectionList = await homeServiceInterface.getHomeSections(source: DataSourceEnum.local);
        _prepareHomeSections(sectionList);
        getHomeSections(dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        sectionList = await homeServiceInterface.getHomeSections(source: DataSourceEnum.client);
        _prepareHomeSections(sectionList);
      }
    }
  }

  void _prepareHomeSections(List<HomeSectionModel>? sectionList){
    if(sectionList != null) {
      _homeSections = [];
      // Only add active sections that have vendors or products
      for (var section in sectionList) {
        if(section.isActive == true &&
            ((section.vendors != null && section.vendors!.isNotEmpty) ||
             (section.products != null && section.products!.isNotEmpty))) {
          _homeSections!.add(section);
        }
      }
      // Sort by display_order
      _homeSections!.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
    }
    update();
  }

  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(!fromRecall) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local){
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.local);
        _prepareBannerList(bannerModel);
        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.client);
        _prepareBannerList(bannerModel);
      }
    }
  }

  void _prepareBannerList(BannerModel? bannerModel){
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      if(bannerModel.campaigns != null) {
        for (var campaign in bannerModel.campaigns!) {
          _bannerImageList!.add(campaign.imageFullUrl);
          _bannerDataList!.add(campaign);
        }
      }
      if(bannerModel.banners != null) {
        for (var banner in bannerModel.banners!) {
          // Only add banners that have clickable data (food or restaurant)
          if(banner.food != null || banner.restaurant != null) {
            if(_bannerImageList!.contains(banner.imageFullUrl)){
              _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
            }else {
              _bannerImageList!.add(banner.imageFullUrl);
            }
            if(banner.food != null) {
              _bannerDataList!.add(banner.food);
            }else {
              _bannerDataList!.add(banner.restaurant);
            }
          }
        }
      }
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }


  Future<void> getCashBackOfferList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _cashBackOfferList = null;
    List<CashBackModel>? cashBackOfferList;

    if(dataSource == DataSourceEnum.local){
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.local);
      _prepareCashBackOfferList(cashBackOfferList);
      getCashBackOfferList(dataSource: DataSourceEnum.client);
    }else{
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.client);
      _prepareCashBackOfferList(cashBackOfferList);
    }
  }

  void _prepareCashBackOfferList(List<CashBackModel>? cashBackOfferList){
    if(cashBackOfferList != null) {
      _cashBackOfferList = [];
      _cashBackOfferList!.addAll(cashBackOfferList);
    }
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel = await homeServiceInterface.getCashBackData(amount);
    if(cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility(){
    _showFavButton = !_showFavButton;
    update();
  }

  Future<void> getMainCategoriesList({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_mainCategoriesList == null || fromRecall) {
      if(!fromRecall) {
        _mainCategoriesList = null;
      }
      List<MainCategoryModel>? mainCategoriesList;

      if(dataSource == DataSourceEnum.local){
        mainCategoriesList = await homeServiceInterface.getMainCategories(source: DataSourceEnum.local);
        _prepareMainCategoriesList(mainCategoriesList);
        getMainCategoriesList(dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        mainCategoriesList = await homeServiceInterface.getMainCategories(source: DataSourceEnum.client);
        _prepareMainCategoriesList(mainCategoriesList);
      }
    }
  }

  void _prepareMainCategoriesList(List<MainCategoryModel>? mainCategoriesList){
    if(mainCategoriesList != null) {
      _mainCategoriesList = [];
      _mainCategoriesList!.addAll(mainCategoriesList);
    }
    update();
  }

  Future<void> getMnjoodMartProducts({int? categoryId, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    // Store category for pagination
    _currentMartCategoryId = categoryId;

    if(_mnjoodMartProducts == null || fromRecall) {
      if(!fromRecall) {
        _mnjoodMartProducts = null;
        _mnjoodMartProductsPage = 1;
        _mnjoodMartHasMore = true;
      }
      ProductModel? productModel;

      if(dataSource == DataSourceEnum.local){
        productModel = await homeServiceInterface.getMnjoodMartProducts(page: 1, categoryId: categoryId, source: DataSourceEnum.local);
        _prepareMnjoodMartProducts(productModel, isLoadMore: false);
        getMnjoodMartProducts(categoryId: categoryId, dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        productModel = await homeServiceInterface.getMnjoodMartProducts(page: 1, categoryId: categoryId, source: DataSourceEnum.client);
        _prepareMnjoodMartProducts(productModel, isLoadMore: false);
      }
    }
  }

  Future<void> loadMoreMnjoodMartProducts() async {
    if(_mnjoodMartLoading || !_mnjoodMartHasMore) return;

    _mnjoodMartLoading = true;
    update();

    int nextPage = _mnjoodMartProductsPage + 1;
    ProductModel? productModel = await homeServiceInterface.getMnjoodMartProducts(page: nextPage, categoryId: _currentMartCategoryId, source: DataSourceEnum.client);

    if(productModel != null && productModel.products != null && productModel.products!.isNotEmpty) {
      _mnjoodMartProductsPage = nextPage;
      _mnjoodMartProducts ??= [];
      _mnjoodMartProducts!.addAll(productModel.products!);

      // Check if we have more pages
      if(productModel.totalSize != null && _mnjoodMartProducts!.length >= productModel.totalSize!) {
        _mnjoodMartHasMore = false;
      }
    } else {
      _mnjoodMartHasMore = false;
    }

    _mnjoodMartLoading = false;
    update();
  }

  void _prepareMnjoodMartProducts(ProductModel? productModel, {bool isLoadMore = false}){
    if(productModel != null && productModel.products != null) {
      if(!isLoadMore) {
        _mnjoodMartProducts = [];
        _mnjoodMartProductsPage = 1;
      }
      _mnjoodMartProducts!.addAll(productModel.products!);

      // Check if we have more pages
      if(productModel.totalSize != null && _mnjoodMartProducts!.length >= productModel.totalSize!) {
        _mnjoodMartHasMore = false;
      } else {
        _mnjoodMartHasMore = true;
      }
    }
    update();
  }

  Future<void> getSliders({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_sliderList == null || fromRecall) {
      if(!fromRecall) {
        _sliderList = null;
      }
      SlidersResponse? slidersResponse;

      if(dataSource == DataSourceEnum.local){
        slidersResponse = await homeServiceInterface.getSliders(source: DataSourceEnum.local);
        _prepareSliderList(slidersResponse);
        getSliders(dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        slidersResponse = await homeServiceInterface.getSliders(source: DataSourceEnum.client);
        _prepareSliderList(slidersResponse);
      }
    }
  }

  void _prepareSliderList(SlidersResponse? slidersResponse){
    if(slidersResponse != null && slidersResponse.sliders != null) {
      _sliderList = [];
      // Only add active sliders (status == 1)
      for (var slider in slidersResponse.sliders!) {
        if(slider.status == 1) {
          _sliderList!.add(slider);
        }
      }
    }
    update();
  }

  void setSliderIndex(int index, bool notify) {
    _sliderIndex = index;
    if(notify) {
      update();
    }
  }

  Future<void> getRestaurantCategories({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_restaurantCategories == null || fromRecall) {
      if(!fromRecall) {
        _restaurantCategories = null;
      }
      List<CategoryModel>? categoryList;

      if(dataSource == DataSourceEnum.local){
        categoryList = await homeServiceInterface.getRestaurantCategories(source: DataSourceEnum.local);
        _prepareRestaurantCategories(categoryList);
        getRestaurantCategories(dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        categoryList = await homeServiceInterface.getRestaurantCategories(source: DataSourceEnum.client);
        _prepareRestaurantCategories(categoryList);
      }
    }
  }

  void _prepareRestaurantCategories(List<CategoryModel>? categoryList){
    if(categoryList != null) {
      _restaurantCategories = [];
      _restaurantCategories!.addAll(categoryList);
    }
    update();
  }

  Future<void> getBusinessTypeCategories(String businessType, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_businessTypeCategories[businessType] == null || fromRecall) {
      if(!fromRecall) {
        _businessTypeCategories[businessType] = null;
      }
      List<CategoryModel>? categoryList;

      if(dataSource == DataSourceEnum.local){
        categoryList = await homeServiceInterface.getCategoriesByBusinessType(businessType, source: DataSourceEnum.local);
        _prepareBusinessTypeCategories(businessType, categoryList);
        getBusinessTypeCategories(businessType, dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        categoryList = await homeServiceInterface.getCategoriesByBusinessType(businessType, source: DataSourceEnum.client);
        _prepareBusinessTypeCategories(businessType, categoryList);
      }
    }
  }

  void _prepareBusinessTypeCategories(String businessType, List<CategoryModel>? categoryList){
    if(categoryList != null) {
      _businessTypeCategories[businessType] = [];
      _businessTypeCategories[businessType]!.addAll(categoryList);
    }
    update();
  }
}