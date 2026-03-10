import 'package:mnjood/features/dine_in/domain/model/dine_in_model.dart';
import 'package:mnjood/interface/repository_interface.dart';

abstract class DineInRepositoryInterface extends RepositoryInterface {
  Future<DineInModel?> getRestaurantList({int? offset, required bool isDistance, required bool isRating, required bool isVeg, required bool isNonVeg, required bool isDiscounted, required List<int> selectedCuisines});
}