import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/features/inventory/domain/repositories/inventory_repository_interface.dart';
import 'package:mnjood_vendor/features/inventory/domain/services/inventory_service_interface.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

class InventoryService implements InventoryServiceInterface {
  final InventoryRepositoryInterface inventoryRepositoryInterface;

  InventoryService({required this.inventoryRepositoryInterface});

  @override
  Future<StockOverviewModel?> getStockOverview() async {
    try {
      final response = await inventoryRepositoryInterface.getStockOverview();
      print('Stock Overview API response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 && response.body != null) {
        return StockOverviewModel.fromJson(response.body);
      }
    } catch (e) {
      print('getStockOverview error: $e');
    }
    // Return null if API fails - don't use mock data in production
    return null;
  }

  @override
  Future<List<LowStockProduct>> getLowStockProducts({int? categoryId}) async {
    try {
      final response = await inventoryRepositoryInterface.getLowStockProducts(categoryId: categoryId);
      if (response.statusCode == 200 && response.body != null) {
        // API returns 'low_stock_products' key
        return (response.body['low_stock_products'] as List?)
            ?.map((item) => LowStockProduct.fromJson(item))
            .toList() ?? [];
      }
    } catch (e) {
      // Log error for debugging
      print('getLowStockProducts error: $e');
    }
    return [];  // Return empty list instead of mock data
  }

  @override
  Future<OutOfStockProductsResponse?> getOutOfStockProducts({int limit = 25, int offset = 1, int? categoryId}) async {
    try {
      final response = await inventoryRepositoryInterface.getOutOfStockProducts(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
      );
      print('Out of Stock API response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 && response.body != null) {
        return OutOfStockProductsResponse.fromJson(response.body);
      }
    } catch (e) {
      print('getOutOfStockProducts error: $e');
    }
    return null;
  }

  @override
  Future<List<ExpiringProduct>> getExpiringProducts({int? days, String? status}) async {
    try {
      final response = await inventoryRepositoryInterface.getExpiringProducts(days: days, status: status);
      if (response.statusCode == 200 && response.body != null) {
        return (response.body['products'] as List?)
            ?.map((item) => ExpiringProduct.fromJson(item))
            .toList() ?? [];
      }
    } catch (e) {
      // API not available
    }
    return _getMockExpiringProducts();
  }

  @override
  Future<bool> adjustStock({
    required int productId,
    required String adjustmentType,
    required int quantity,
    String? reason,
    String? batchNumber,
  }) async {
    try {
      final response = await inventoryRepositoryInterface.adjustStock({
        'product_id': productId,
        'adjustment_type': adjustmentType,
        'quantity': quantity,
        'reason': reason,
        'batch_number': batchNumber,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Product?> findProductByBarcode(String barcode) async {
    try {
      final response = await inventoryRepositoryInterface.findProductByBarcode(barcode);
      if (response.statusCode == 200 && response.body != null) {
        return Product.fromJson(response.body['product']);
      }
    } catch (e) {
      // API not available
    }
    return null;
  }

  // ========== MOCK DATA FOR DEVELOPMENT ==========

  StockOverviewModel _getMockStockOverview() {
    return StockOverviewModel(
      totalProducts: 150,
      inStockCount: 120,
      lowStockCount: 20,
      outOfStockCount: 10,
      totalInventoryValue: 25000.0,
      lowStockProducts: _getMockLowStockProducts(),
      expiringProducts: _getMockExpiringProducts(),
    );
  }

  List<LowStockProduct> _getMockLowStockProducts() {
    return [
      LowStockProduct(
        id: 1,
        name: 'Paracetamol 500mg',
        currentStock: 5,
        reorderPoint: 20,
        categoryName: 'Pain Relief',
        imageFullUrl: '',
      ),
      LowStockProduct(
        id: 2,
        name: 'Vitamin C 1000mg',
        currentStock: 8,
        reorderPoint: 15,
        categoryName: 'Vitamins',
        imageFullUrl: '',
      ),
      LowStockProduct(
        id: 3,
        name: 'Bandages Pack',
        currentStock: 3,
        reorderPoint: 10,
        categoryName: 'First Aid',
        imageFullUrl: '',
      ),
    ];
  }

  List<ExpiringProduct> _getMockExpiringProducts() {
    return [
      ExpiringProduct(
        id: 4,
        name: 'Antibiotic Cream',
        batchNumber: 'BATCH001',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        quantity: 15,
        status: 'expiring_soon',
      ),
      ExpiringProduct(
        id: 5,
        name: 'Eye Drops',
        batchNumber: 'BATCH002',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 10,
        status: 'expiring_soon',
      ),
      ExpiringProduct(
        id: 6,
        name: 'Cough Syrup',
        batchNumber: 'BATCH003',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        quantity: 5,
        status: 'expired',
      ),
    ];
  }
}
