import 'package:get/get.dart';
import 'package:mnjood_vendor/api/api_client.dart';
import 'package:mnjood_vendor/features/inventory/domain/repositories/inventory_repository_interface.dart';
import 'package:mnjood_vendor/util/app_constants.dart';

class InventoryRepository implements InventoryRepositoryInterface {
  final ApiClient apiClient;

  InventoryRepository({required this.apiClient});

  @override
  Future<Response> getStockOverview() async {
    return await apiClient.getData(AppConstants.inventoryOverviewUri);
  }

  @override
  Future<Response> getLowStockProducts({int? categoryId}) async {
    String uri = AppConstants.lowStockProductsUri;
    if (categoryId != null) {
      uri += '?category_id=$categoryId';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> getOutOfStockProducts({int limit = 25, int offset = 1, int? categoryId}) async {
    String uri = '${AppConstants.outOfStockProductsUri}?limit=$limit&offset=$offset';
    if (categoryId != null) {
      uri += '&category_id=$categoryId';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> getExpiringProducts({int? days, String? status}) async {
    String uri = AppConstants.expiringProductsUri;
    List<String> params = [];
    if (days != null) params.add('days=$days');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) {
      uri += '?${params.join('&')}';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> adjustStock(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.adjustStockUri, body);
  }

  @override
  Future<Response> findProductByBarcode(String barcode) async {
    return await apiClient.getData('${AppConstants.productByBarcodeUri}/$barcode');
  }
}
