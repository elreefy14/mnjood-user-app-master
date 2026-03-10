import 'package:mnjood_vendor/features/addon/domain/models/addon_category_model.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

abstract class AddonServiceInterface {
  Future<List<AddOns>?> getAddonList();
  Future<bool> addAddon(AddOns addonModel);
  Future<bool> updateAddon(AddOns addonModel);
  Future<bool> deleteAddon(int id);
  List<int?> prepareAddonIds(List<AddOns> addonList);
  Future<List<AddonCategoryModel>?> getAddonCategory({required int moduleId});
}