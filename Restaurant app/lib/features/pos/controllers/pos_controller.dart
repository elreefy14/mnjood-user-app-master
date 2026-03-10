import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mnjood_vendor/api/api_client.dart';
import 'package:mnjood_vendor/features/pos/domain/models/pos_cart_model.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/util/app_constants.dart';

class PosController extends GetxController implements GetxService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  PosController({required this.apiClient, required this.sharedPreferences});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Product> _products = [];
  List<Product> get products => _products;

  List<Product> _filteredProducts = [];
  List<Product> get filteredProducts => _filteredProducts;

  PosCart _cart = PosCart();
  PosCart get cart => _cart;

  String _searchQuery = '';

  // Payment related
  String _paymentMethod = 'cash';
  String get paymentMethod => _paymentMethod;

  double _cashReceived = 0;
  double get cashReceived => _cashReceived;

  double get changeAmount => _cashReceived - _cart.total;

  /// Get all products for POS
  Future<void> getProducts() async {
    _isLoading = true;
    update();

    try {
      Response response = await apiClient.getData(AppConstants.productListUri);
      if (response.statusCode == 200) {
        _products = [];
        response.body['products'].forEach((product) {
          _products.add(Product.fromJson(product));
        });
        _filteredProducts = List.from(_products);
      }
    } catch (e) {
      print('Error loading products: $e');
    }

    _isLoading = false;
    update();
  }

  /// Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        final name = product.name?.toLowerCase() ?? '';
        final barcode = product.barcode?.toLowerCase() ?? '';
        return name.contains(_searchQuery) || barcode.contains(_searchQuery);
      }).toList();
    }
    update();
  }

  /// Find product by barcode
  Future<bool> findProductByBarcode(String barcode) async {
    final product = _products.firstWhereOrNull(
      (p) => p.barcode?.toLowerCase() == barcode.toLowerCase(),
    );

    if (product != null) {
      addToCart(product);
      return true;
    }
    return false;
  }

  /// Add product to cart
  void addToCart(Product product) {
    final existingIndex = _cart.items.indexWhere((item) => item.foodId == product.id);

    if (existingIndex >= 0) {
      // Update quantity
      final items = List<PosCartItem>.from(_cart.items);
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + 1,
      );
      _cart = _cart.copyWith(items: items);
    } else {
      // Add new item
      final newItem = PosCartItem(
        foodId: product.id!,
        product: product,
        quantity: 1,
        unitPrice: product.price ?? 0,
        barcode: product.barcode,
      );
      _cart = _cart.copyWith(items: [..._cart.items, newItem]);
    }
    update();
  }

  /// Update item quantity
  void updateQuantity(int foodId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(foodId);
      return;
    }

    final items = List<PosCartItem>.from(_cart.items);
    final index = items.indexWhere((item) => item.foodId == foodId);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      _cart = _cart.copyWith(items: items);
      update();
    }
  }

  /// Remove item from cart
  void removeFromCart(int foodId) {
    final items = _cart.items.where((item) => item.foodId != foodId).toList();
    _cart = _cart.copyWith(items: items);
    update();
  }

  /// Clear cart
  void clearCart() {
    _cart = PosCart();
    _cashReceived = 0;
    _paymentMethod = 'cash';
    update();
  }

  /// Set payment method
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    update();
  }

  /// Set cash received
  void setCashReceived(double amount) {
    _cashReceived = amount;
    update();
  }

  /// Place POS order
  Future<Map<String, dynamic>?> placeOrder() async {
    _isLoading = true;
    update();

    try {
      final body = {
        'cart': _cart.items.map((item) => item.toApiJson()).toList(),
        'order_amount': _cart.subtotalAfterDiscount,
        'tax_amount': _cart.tax,
        'discount_amount': _cart.discountValue,
        'total_amount': _cart.total,
        'payment_method': _paymentMethod,
        'payment_status': 'paid',
        'order_type': 'pos',
        if (_paymentMethod == 'cash') 'cash_received': _cashReceived,
        if (_paymentMethod == 'cash') 'change_amount': changeAmount,
        if (_cart.customerId != null) 'customer_id': _cart.customerId,
        if (_cart.note != null) 'order_note': _cart.note,
      };

      Response response = await apiClient.postData(
        AppConstants.placeOrderUri,
        body,
      );

      if (response.statusCode == 200) {
        clearCart();
        return response.body;
      }
    } catch (e) {
      print('Error placing order: $e');
    }

    _isLoading = false;
    update();
    return null;
  }

  /// Hold order for later
  Future<void> holdOrder(String? note) async {
    final heldOrders = _getHeldOrders();
    final heldOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'cart': _cart.copyWith(note: note).toJson(),
      'created_at': DateTime.now().toIso8601String(),
    };
    heldOrders.add(heldOrder);
    await sharedPreferences.setString('held_orders', jsonEncode(heldOrders));
    clearCart();
    update();
  }

  /// Get held orders
  List<Map<String, dynamic>> _getHeldOrders() {
    final String? data = sharedPreferences.getString('held_orders');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  /// Get held orders list
  List<Map<String, dynamic>> get heldOrders => _getHeldOrders();

  /// Resume held order
  void resumeHeldOrder(String id) {
    final orders = _getHeldOrders();
    final orderIndex = orders.indexWhere((o) => o['id'] == id);
    if (orderIndex >= 0) {
      _cart = PosCart.fromJson(orders[orderIndex]['cart']);
      orders.removeAt(orderIndex);
      sharedPreferences.setString('held_orders', jsonEncode(orders));
      update();
    }
  }

  /// Delete held order
  void deleteHeldOrder(String id) {
    final orders = _getHeldOrders();
    orders.removeWhere((o) => o['id'] == id);
    sharedPreferences.setString('held_orders', jsonEncode(orders));
    update();
  }
}
