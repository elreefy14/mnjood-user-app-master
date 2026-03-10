import 'package:mnjood_vendor/features/category/domain/models/category_model.dart';
import 'package:mnjood_vendor/features/category/domain/services/categoty_service_interface.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  String? _selectedCategoryID;
  String? get selectedCategoryID => _selectedCategoryID;

  String? _selectedSubCategoryID;
  String? get selectedSubCategoryID => _selectedSubCategoryID;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  int? _selectedCategoryIndex = 0;
  int? get selectedCategoryIndex => _selectedCategoryIndex;

  Future<void> getCategoryList() async {
    _categoryList = null;
    List<CategoryModel>? categoryList = await categoryServiceInterface.getCategoryList();
    if(categoryList != null) {
      _categoryList = [];
      _categoryList = categoryList;
    }
    update();
  }

  Future<void> getSubCategoryList(int categoryID) async {
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if(subCategoryList != null){
      _subCategoryList = [];
      _subCategoryList = subCategoryList;
    }
    update();
  }

  Future<void> initCategoryData(Product? product) async {
    await getCategoryList();
    if (product != null && product.categoryIds?.isNotEmpty == true) {
      final mainId = product.categoryIds![0].id;
      if (mainId != null) {
        setSelectedCategory(mainId, isUpdate: false);

        if (product.categoryIds!.length > 1) {
          final subId = product.categoryIds![1].id;
          if (subId != null) {
            await getSubCategoryList(int.parse(mainId));
            setSelectedSubCategory(subId, isUpdate: false);
          }
        }
      }
    }
    update();
  }

  void setSelectedCategory(String id, {bool isUpdate = true}) {
    _selectedCategoryID = id;
    getSubCategoryList(int.parse(id));
    if (isUpdate) update();
  }

  void setSelectedSubCategory(String id, {bool isUpdate = true}) {
    _selectedSubCategoryID = id;
    if (isUpdate) update();
  }

  Future<void> setCategoryAndSubCategoryForAiData({String? categoryId, String? subCategoryId}) async {
    if(categoryId != null){
      _selectedCategoryID = categoryId;
      await getSubCategoryList(int.parse(categoryId)).then((value) {
        if(_subCategoryList != null && _subCategoryList!.isNotEmpty){
          if(subCategoryId != null && _subCategoryList!.any((element) => element.id == int.parse(subCategoryId))){
            _selectedSubCategoryID = subCategoryId;
          }
          update();
        }
      });
    }
    update();
  }

  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    update();
  }

}