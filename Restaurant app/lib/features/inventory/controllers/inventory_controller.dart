import 'package:get/get.dart';
import 'package:mnjood_vendor/features/inventory/domain/models/stock_model.dart';
import 'package:mnjood_vendor/features/inventory/domain/models/stock_adjustment_model.dart';
import 'package:mnjood_vendor/features/inventory/domain/services/inventory_service_interface.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';

/// Controller for managing inventory and stock operations
class InventoryController extends GetxController implements GetxService {
  final InventoryServiceInterface inventoryServiceInterface;

  InventoryController({required this.inventoryServiceInterface});

  // ========== STATE ==========

  StockOverviewModel? _stockOverview;
  StockOverviewModel? get stockOverview => _stockOverview;

  List<LowStockProduct>? _lowStockProducts;
  List<LowStockProduct>? get lowStockProducts => _lowStockProducts;

  OutOfStockProductsResponse? _outOfStockResponse;
  OutOfStockProductsResponse? get outOfStockResponse => _outOfStockResponse;
  List<LowStockProduct>? get outOfStockProducts => _outOfStockResponse?.products;

  List<ExpiringProduct>? _expiringProducts;
  List<ExpiringProduct>? get expiringProducts => _expiringProducts;

  List<StockAdjustmentModel>? _adjustmentHistory;
  List<StockAdjustmentModel>? get adjustmentHistory => _adjustmentHistory;

  Product? _scannedProduct;
  Product? get scannedProduct => _scannedProduct;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAdjusting = false;
  bool get isAdjusting => _isAdjusting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter state
  String _selectedFilter = 'all';  // 'all', 'low_stock', 'out_of_stock', 'expiring'
  String get selectedFilter => _selectedFilter;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  // ========== STOCK OVERVIEW METHODS ==========

  /// Get stock overview for dashboard
  Future<void> getStockOverview() async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _stockOverview = await inventoryServiceInterface.getStockOverview();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  /// Get low stock products
  Future<void> getLowStockProducts({int? categoryId}) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCategoryId = categoryId;
    update();

    try {
      _lowStockProducts = await inventoryServiceInterface.getLowStockProducts(categoryId: categoryId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  /// Get out of stock products
  Future<void> getOutOfStockProducts({int limit = 25, int offset = 1, int? categoryId}) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCategoryId = categoryId;
    update();

    try {
      _outOfStockResponse = await inventoryServiceInterface.getOutOfStockProducts(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  /// Get expiring products
  Future<void> getExpiringProducts({int? days, String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _expiringProducts = await inventoryServiceInterface.getExpiringProducts(days: days, status: status);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  // ========== STOCK ADJUSTMENT METHODS ==========

  /// Adjust stock for a product
  Future<bool> adjustStock({
    required int productId,
    required String adjustmentType,
    required int quantity,
    String? reason,
    String? batchNumber,
  }) async {
    _isAdjusting = true;
    _errorMessage = null;
    update();

    bool success = false;

    try {
      success = await inventoryServiceInterface.adjustStock(
        productId: productId,
        adjustmentType: adjustmentType,
        quantity: quantity,
        reason: reason,
        batchNumber: batchNumber,
      );

      if (success) {
        // Refresh stock overview
        await getStockOverview();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isAdjusting = false;
    update();
    return success;
  }

  /// Update reorder point for a product
  Future<bool> updateReorderPoint(int productId, int reorderPoint) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    bool success = false;

    try {
      // This would need its own API endpoint
      success = true;  // Placeholder
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
    return success;
  }

  /// Get stock adjustment history
  Future<void> getAdjustmentHistory({
    int? productId,
    String? dateFrom,
    String? dateTo,
    String? adjustmentType,
    int offset = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _adjustmentHistory = [];  // Placeholder until API is implemented
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  // ========== BARCODE SCANNING METHODS ==========

  /// Find product by barcode
  Future<Product?> findProductByBarcode(String barcode) async {
    _isLoading = true;
    _errorMessage = null;
    _scannedProduct = null;
    update();

    try {
      _scannedProduct = await inventoryServiceInterface.findProductByBarcode(barcode);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
    return _scannedProduct;
  }

  /// Clear scanned product
  void clearScannedProduct() {
    _scannedProduct = null;
    update();
  }

  // ========== FILTER METHODS ==========

  /// Set selected filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    update();
  }

  /// Set selected category
  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    update();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedFilter = 'all';
    _selectedCategoryId = null;
    update();
  }

  // ========== HELPER METHODS ==========

  /// Check if there are any stock alerts
  bool get hasStockAlerts {
    if (_stockOverview == null) return false;
    return (_stockOverview!.lowStockCount ?? 0) > 0 ||
        (_stockOverview!.outOfStockCount ?? 0) > 0;
  }

  /// Get total alert count
  int get totalAlertCount {
    if (_stockOverview == null) return 0;
    return (_stockOverview!.lowStockCount ?? 0) +
        (_stockOverview!.outOfStockCount ?? 0);
  }

  /// Get expiring products count
  int get expiringCount => _expiringProducts?.length ?? 0;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    update();
  }

  /// Reset controller state
  void resetState() {
    _stockOverview = null;
    _lowStockProducts = null;
    _outOfStockResponse = null;
    _expiringProducts = null;
    _adjustmentHistory = null;
    _scannedProduct = null;
    _isLoading = false;
    _isAdjusting = false;
    _errorMessage = null;
    _selectedFilter = 'all';
    _selectedCategoryId = null;
    update();
  }
}
