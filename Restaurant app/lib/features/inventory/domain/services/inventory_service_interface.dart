import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

abstract class InventoryServiceInterface {
  Future<StockOverviewModel?> getStockOverview();
  Future<List<LowStockProduct>> getLowStockProducts({int? categoryId});
  Future<OutOfStockProductsResponse?> getOutOfStockProducts({int limit, int offset, int? categoryId});
  Future<List<ExpiringProduct>> getExpiringProducts({int? days, String? status});
  Future<bool> adjustStock({
    required int productId,
    required String adjustmentType,
    required int quantity,
    String? reason,
    String? batchNumber,
  });
  Future<Product?> findProductByBarcode(String barcode);
}
