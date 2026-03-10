import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/features/search/domain/models/search_suggestion_model.dart';
import 'package:mnjood/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class SearchRepositoryInterface extends RepositoryInterface {
  Future<List<Product>?> getSuggestedFoods();
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText);

  /// Search products with optional business type filter
  /// [businessType] can be: 'restaurant', 'supermarket', 'pharmacy', or null for all
  Future<Response> getSearchData({
    required String query,
    required bool isRestaurant,
    required int offset,
    String? type,
    int? isNew = 0,
    int? isPopular = 0,
    double? minPrice,
    double? maxPrice,
    int? isOneRatting = 0,
    int? isTwoRatting = 0,
    int? isThreeRatting = 0,
    int? isFourRatting = 0,
    int? isFiveRatting = 0,
    String? sortBy,
    int? discounted = 0,
    required List<int> selectedCuisines,
    int? isOpenRestaurant,
    String? businessType,
  });

  /// Search vendors by business type
  /// [businessType] can be: 'restaurants', 'supermarkets', 'pharmacies'
  Future<Response> searchVendorsByType({
    required String query,
    required String businessType,
    required int offset,
    String? type,
    int? isNew = 0,
    int? isPopular = 0,
    int? isOneRatting = 0,
    int? isTwoRatting = 0,
    int? isThreeRatting = 0,
    int? isFourRatting = 0,
    int? isFiveRatting = 0,
    String? sortBy,
    int? discounted = 0,
    List<int>? selectedCuisines,
    int? isOpenRestaurant,
  });

  /// Search products filtered by business type
  /// [businessType] can be: 'restaurant', 'supermarket', 'pharmacy'
  Future<Response> searchProductsByBusinessType({
    required String query,
    required String businessType,
    required int offset,
    String? type,
    int? isNew = 0,
    int? isPopular = 0,
    double? minPrice,
    double? maxPrice,
    int? isOneRatting = 0,
    int? isTwoRatting = 0,
    int? isThreeRatting = 0,
    int? isFourRatting = 0,
    int? isFiveRatting = 0,
    String? sortBy,
    int? discounted = 0,
  });

  Future<bool> saveSearchHistory(List<String> searchHistories);
  List<String> getSearchHistory();
  Future<bool> clearSearchHistory();
}
