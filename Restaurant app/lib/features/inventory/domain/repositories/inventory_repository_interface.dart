abstract class InventoryRepositoryInterface {
  Future<dynamic> getStockOverview();
  Future<dynamic> getLowStockProducts({int? categoryId});
  Future<dynamic> getOutOfStockProducts({int limit, int offset, int? categoryId});
  Future<dynamic> getExpiringProducts({int? days, String? status});
  Future<dynamic> adjustStock(Map<String, dynamic> body);
  Future<dynamic> findProductByBarcode(String barcode);
}
