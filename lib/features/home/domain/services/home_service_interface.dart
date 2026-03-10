import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/home/domain/models/banner_model.dart';
import 'package:mnjood/features/home/domain/models/cashback_model.dart';
import 'package:mnjood/features/home/domain/models/home_section_model.dart';
import 'package:mnjood/features/home/domain/models/main_category_model.dart';
import 'package:mnjood/features/home/domain/models/slider_model.dart';

abstract class HomeServiceInterface {
  Future<BannerModel?> getBannerList({required DataSourceEnum source});
  Future<List<CashBackModel>?> getCashBackOfferList({DataSourceEnum? source});
  Future<CashBackModel?> getCashBackData(double amount);
  Future<List<MainCategoryModel>?> getMainCategories({DataSourceEnum? source});
  Future<ProductModel?> getMnjoodMartProducts({int page = 1, int? categoryId, DataSourceEnum? source});
  Future<SlidersResponse?> getSliders({DataSourceEnum? source});
  Future<List<CategoryModel>?> getRestaurantCategories({DataSourceEnum? source});
  Future<List<CategoryModel>?> getCategoriesByBusinessType(String businessType, {DataSourceEnum? source});
  Future<List<HomeSectionModel>?> getHomeSections({DataSourceEnum? source});
}