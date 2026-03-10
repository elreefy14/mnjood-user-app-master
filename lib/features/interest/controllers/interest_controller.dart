import 'package:mnjood/features/category/domain/models/category_model.dart';
import 'package:mnjood/features/home/controllers/home_controller.dart';
import 'package:mnjood/features/interest/domain/services/interest_service_interface.dart';
import 'package:get/get.dart';

class InterestController extends GetxController implements GetxService {
  final InterestServiceInterface interestServiceInterface;

  InterestController({required this.interestServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<bool>? _interestCategorySelectedList;
  List<bool>? get interestCategorySelectedList => _interestCategorySelectedList;

  Future<void> getCategoryList(bool reload) async {
    final homeController = Get.find<HomeController>();
    if(homeController.restaurantCategories == null || homeController.restaurantCategories!.isEmpty) {
      await homeController.getBusinessTypeCategories('restaurant');
    }
    _categoryList = homeController.getCategoriesForBusinessType('restaurant') ?? homeController.restaurantCategories;
    _interestCategorySelectedList = interestServiceInterface.processCategorySelectedList(_categoryList);

    update();
  }

  void addInterestSelection(int index) {
    _interestCategorySelectedList![index] = !_interestCategorySelectedList![index];
    update();
  }

  Future<bool> saveInterest(List<int?> interests) async {
    _isLoading = true;
    update();
    bool isSuccess = await interestServiceInterface.saveUserInterests(interests);
    _isLoading = false;
    update();
    return isSuccess;
  }

}
