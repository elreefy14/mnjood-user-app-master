import 'package:mnjood/common/models/product_model.dart';
import 'package:mnjood/api/api_client.dart';
import 'package:mnjood/features/search/domain/repositories/search_repository_interface.dart';
import 'package:mnjood/features/search/domain/models/search_suggestion_model.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepository implements SearchRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SearchRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText) async {
    SearchSuggestionModel? searchSuggestionModel;
    Response response = await apiClient.getData('${AppConstants.searchSuggestionsUri}?name=${Uri.encodeQueryComponent(searchText)}');
    if(response.statusCode == 200) {
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      searchSuggestionModel = SearchSuggestionModel.fromJson(data);
    }
    return searchSuggestionModel;
  }

  @override
  Future<List<Product>?> getSuggestedFoods() async {
    List<Product>? suggestedFoodList;
    Response response = await apiClient.getData(AppConstants.suggestedFoodUri);
    if(response.statusCode == 200) {
      suggestedFoodList = [];
      // V3 API: Extract data from response wrapper
      var data = response.body['data'] ?? response.body;
      if (data is List) {
        data.forEach((suggestedFood) => suggestedFoodList!.add(Product.fromJson(suggestedFood)));
      }
    }
    return suggestedFoodList;
  }

  @override
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
  }) async {

    // Build query parameters, excluding empty values to avoid backend SQL errors
    // For vendor search, use correct endpoint based on business type
    String endpoint;
    if (isRestaurant) {
      // Use correct vendor endpoint based on business type
      if (businessType == 'pharmacy') {
        endpoint = 'pharmacies';
      } else if (businessType == 'supermarket') {
        endpoint = 'supermarkets';
      } else {
        endpoint = 'restaurants';
      }
    } else {
      endpoint = 'products';
    }
    String url;
    if (isRestaurant) {
      url = '${AppConstants.searchUri}$endpoint/search?search=${Uri.encodeQueryComponent(query)}&offset=$offset&limit=10';
    } else {
      url = '${AppConstants.productSearchUri}?search=${Uri.encodeQueryComponent(query)}&offset=$offset&limit=10';
    }

    // Only add type if not null/empty
    if (type != null && type.isNotEmpty) {
      url += '&type=$type';
    }

    url += '&new=$isNew&popular=$isPopular';
    url += '&rating_1=$isOneRatting&rating_2=$isTwoRatting&rating_3=$isThreeRatting&rating_4=$isFourRatting&rating_5=$isFiveRatting';
    url += '&discounted=$discounted';

    // Only add sort_by if not null/empty
    if (sortBy != null && sortBy.isNotEmpty) {
      url += '&sort_by=$sortBy';
    }

    // For product search only
    if (!isRestaurant) {
      if (minPrice != null && minPrice > 0) {
        url += '&min_price=$minPrice';
      }
      if (maxPrice != null && maxPrice > 0) {
        url += '&max_price=$maxPrice';
      }
      // Add business_type filter for products
      if (businessType != null && businessType.isNotEmpty) {
        url += '&business_type=$businessType';
      }
    }

    // For restaurant search only
    if (isRestaurant) {
      if (selectedCuisines.isNotEmpty) {
        url += '&cuisine=${selectedCuisines.join(',')}';
      }
      if (isOpenRestaurant != null) {
        url += '&open=$isOpenRestaurant';
      }
    }

    return await apiClient.getData(url);
  }

  @override
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
  }) async {
    // Determine the correct endpoint based on business type
    // businessType should be 'restaurants', 'supermarkets', or 'pharmacies'
    String endpoint = '${AppConstants.searchUri}vendors/$businessType/search';

    String url = '$endpoint?search=${Uri.encodeQueryComponent(query)}&offset=$offset&limit=10';

    // Only add type if not null/empty
    if (type != null && type.isNotEmpty) {
      url += '&type=$type';
    }

    url += '&new=$isNew&popular=$isPopular';
    url += '&rating_1=$isOneRatting&rating_2=$isTwoRatting&rating_3=$isThreeRatting&rating_4=$isFourRatting&rating_5=$isFiveRatting';
    url += '&discounted=$discounted';

    // Only add sort_by if not null/empty
    if (sortBy != null && sortBy.isNotEmpty) {
      url += '&sort_by=$sortBy';
    }

    // For restaurant search only
    if (businessType == 'restaurants') {
      if (selectedCuisines != null && selectedCuisines.isNotEmpty) {
        url += '&cuisine=${selectedCuisines.join(',')}';
      }
      if (isOpenRestaurant != null) {
        url += '&open=$isOpenRestaurant';
      }
    }

    return await apiClient.getData(url);
  }

  @override
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
  }) async {
    // Use the products/search endpoint with business_type filter
    String url = '${AppConstants.productSearchUri}?search=${Uri.encodeQueryComponent(query)}&offset=$offset&limit=10';

    // Only add type if not null/empty
    if (type != null && type.isNotEmpty) {
      url += '&type=$type';
    }

    url += '&new=$isNew&popular=$isPopular';
    url += '&rating_1=$isOneRatting&rating_2=$isTwoRatting&rating_3=$isThreeRatting&rating_4=$isFourRatting&rating_5=$isFiveRatting';
    url += '&discounted=$discounted';

    // Only add sort_by if not null/empty
    if (sortBy != null && sortBy.isNotEmpty) {
      url += '&sort_by=$sortBy';
    }

    // Add price filters
    if (minPrice != null && minPrice > 0) {
      url += '&min_price=$minPrice';
    }
    if (maxPrice != null && maxPrice > 0) {
      url += '&max_price=$maxPrice';
    }

    // Add business_type filter
    if (businessType.isNotEmpty) {
      url += '&business_type=$businessType';
    }

    return await apiClient.getData(url);
  }

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(AppConstants.searchHistory, searchHistories);
  }

  @override
  List<String> getSearchHistory() {
    return sharedPreferences.getStringList(AppConstants.searchHistory) ?? [];
  }

  @override
  Future<bool> clearSearchHistory() async {
    return sharedPreferences.setStringList(AppConstants.searchHistory, []);
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
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
