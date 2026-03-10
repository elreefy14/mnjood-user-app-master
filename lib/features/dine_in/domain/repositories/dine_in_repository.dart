import 'package:get/get.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/dine_in/domain/model/dine_in_model.dart';
import 'package:mnjood/features/dine_in/domain/repositories/dine_in_repository_interface.dart';
import 'package:mnjood/util/app_constants.dart';

class DineInRepository implements DineInRepositoryInterface {
  final ApiClient apiClient;
  DineInRepository({required this.apiClient});

  @override
  Future<DineInModel?> getRestaurantList({int? offset, required bool isDistance, required bool isRating, required bool isVeg, required bool isNonVeg, required bool isDiscounted, required List<int> selectedCuisines}) async {
    DineInModel? dineInModel;
    Response response = await apiClient.getData('${AppConstants.dineInRestaurantListUri}?offset=$offset&limit=10&sort_by=${isDistance ? 'distance' : isRating ? 'rating' : ''}&veg=${isVeg ? 1 : 0}&non_veg=${isNonVeg ? 1 : 0}&discount=${isDiscounted ? 1 : 0}&cuisine=$selectedCuisines');
    if (response.statusCode == 200) {
      // V3 API: Extract data from wrapper and map to expected structure
      var responseData = response.body;
      var restaurants = responseData['data'];

      // Create structure that DineInModel expects
      Map<String, dynamic> modelData = {
        'total_size': restaurants is List ? restaurants.length : 0,
        'limit': '10',
        'offset': offset ?? 1,
        'restaurants': restaurants,
      };

      dineInModel = DineInModel.fromJson(modelData);
    }
    return dineInModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

}