import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/home/domain/models/banner_model.dart';
import 'package:mnjood/features/home/domain/models/cashback_model.dart';
import 'package:mnjood/features/home/domain/models/home_section_model.dart';
import 'package:mnjood/features/home/domain/models/main_category_model.dart';
import 'package:mnjood/features/home/domain/models/slider_model.dart';
import 'package:mnjood/features/home/domain/repositories/home_repository_interface.dart';
import 'package:mnjood/features/home/domain/services/home_service_interface.dart';

class HomeService implements HomeServiceInterface {
  final HomeRepositoryInterface homeRepositoryInterface;
  HomeService({required this.homeRepositoryInterface});

  @override
  Future<BannerModel?> getBannerList({required DataSourceEnum source}) async {
    return await homeRepositoryInterface.getList(source: source);
  }

  @override
  Future<List<CashBackModel>?> getCashBackOfferList({DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getCashBackOfferList(source: source);
  }

  @override
  Future<CashBackModel?> getCashBackData(double amount) async {
    return await homeRepositoryInterface.getCashBackData(amount);
  }

  @override
  Future<List<MainCategoryModel>?> getMainCategories({DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getMainCategories(source: source);
  }

  @override
  Future<ProductModel?> getMnjoodMartProducts({int page = 1, int? categoryId, DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getMnjoodMartProducts(page: page, categoryId: categoryId, source: source);
  }

  @override
  Future<SlidersResponse?> getSliders({DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getSliders(source: source);
  }

  @override
  Future<List<CategoryModel>?> getRestaurantCategories({DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getRestaurantCategories(source: source);
  }

  @override
  Future<List<CategoryModel>?> getCategoriesByBusinessType(String businessType, {DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getCategoriesByBusinessType(businessType, source: source);
  }

  @override
  Future<List<HomeSectionModel>?> getHomeSections({DataSourceEnum? source}) async {
    return await homeRepositoryInterface.getHomeSections(source: source);
  }
}