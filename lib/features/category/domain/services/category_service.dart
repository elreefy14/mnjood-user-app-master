import 'package:mnjood/common/enums/data_source_enum.dart';
import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:mnjood/features/category/domain/services/category_service_interface.dart';
import 'package:get/get_connect/connect.dart';

class CategoryService implements CategoryServiceInterface {
  final CategoryRepositoryInterface categoryRepositoryInterface;

  CategoryService({required this.categoryRepositoryInterface});

  @override
  Future<List<CategoryModel>?> getCategoryList({DataSourceEnum? source, String? search}) async {
    return await categoryRepositoryInterface.getList(source: source, search: search);
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID) async {
    return await categoryRepositoryInterface.getSubCategoryList(parentID);
  }

  @override
  Future<ProductModel?> getCategoryProductList(String? categoryID, int offset, String type) async {
    return await categoryRepositoryInterface.getCategoryProductList(categoryID, offset, type);
  }

  @override
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, int offset, String type, {String? businessType}) async {
    return await categoryRepositoryInterface.getCategoryRestaurantList(categoryID, offset, type, businessType: businessType);
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, String type) async {
    return await categoryRepositoryInterface.getSearchData(query, categoryID, isRestaurant, type);
  }

  @override
  Future<List<CategoryModel>?> getTopSupermarketCategories() async {
    return await categoryRepositoryInterface.getTopSupermarketCategories();
  }

}