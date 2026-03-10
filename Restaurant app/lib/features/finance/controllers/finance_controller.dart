import 'package:get/get.dart';
import 'package:mnjood_vendor/features/finance/domain/models/expense_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/finance_overview_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/purchase_order_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/supplier_model.dart';
import 'package:mnjood_vendor/features/finance/domain/services/finance_service_interface.dart';

class FinanceController extends GetxController implements GetxService {
  final FinanceServiceInterface financeServiceInterface;

  FinanceController({required this.financeServiceInterface});

  // ========== STATE ==========

  FinanceOverviewModel? _overview;
  FinanceOverviewModel? get overview => _overview;

  FinanceReportModel? _report;
  FinanceReportModel? get report => _report;

  List<SupplierModel>? _suppliers;
  List<SupplierModel>? get suppliers => _suppliers;

  SupplierModel? _selectedSupplier;
  SupplierModel? get selectedSupplier => _selectedSupplier;

  List<PurchaseOrderModel>? _purchaseOrders;
  List<PurchaseOrderModel>? get purchaseOrders => _purchaseOrders;

  PurchaseOrderModel? _selectedPurchaseOrder;
  PurchaseOrderModel? get selectedPurchaseOrder => _selectedPurchaseOrder;

  List<InvoiceModel>? _invoices;
  List<InvoiceModel>? get invoices => _invoices;

  InvoiceModel? _selectedInvoice;
  InvoiceModel? get selectedInvoice => _selectedInvoice;

  List<ExpenseModel>? _expenses;
  List<ExpenseModel>? get expenses => _expenses;

  List<ExpenseCategoryModel>? _expenseCategories;
  List<ExpenseCategoryModel>? get expenseCategories => _expenseCategories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter state
  String _supplierStatusFilter = 'active';
  String get supplierStatusFilter => _supplierStatusFilter;

  String _poStatusFilter = 'all';
  String get poStatusFilter => _poStatusFilter;

  String _invoiceStatusFilter = 'all';
  String get invoiceStatusFilter => _invoiceStatusFilter;

  int? _expenseCategoryFilter;
  int? get expenseCategoryFilter => _expenseCategoryFilter;

  // ========== OVERVIEW METHODS ==========

  Future<void> getOverview() async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _overview = await financeServiceInterface.getOverview();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<void> getReports({String? fromDate, String? toDate}) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _report = await financeServiceInterface.getReports(fromDate: fromDate, toDate: toDate);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  // ========== SUPPLIER METHODS ==========

  Future<void> getSuppliers({String? status, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    if (status != null) _supplierStatusFilter = status;
    update();

    try {
      _suppliers = await financeServiceInterface.getSuppliers(
        status: _supplierStatusFilter == 'all' ? null : _supplierStatusFilter,
        search: search,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<void> getSupplier(int id) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _selectedSupplier = await financeServiceInterface.getSupplier(id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<bool> addSupplier(SupplierModel supplier) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.storeSupplier(supplier);
      if (success) {
        getSuppliers();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  Future<bool> updateSupplier(int id, SupplierModel supplier) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.updateSupplier(id, supplier);
      if (success) {
        getSuppliers();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  Future<bool> deleteSupplier(int id) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.deleteSupplier(id);
      if (success) {
        getSuppliers();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  void setSupplierStatusFilter(String status) {
    _supplierStatusFilter = status;
    update();
  }

  // ========== PURCHASE ORDER METHODS ==========

  Future<void> getPurchaseOrders({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    if (status != null) _poStatusFilter = status;
    update();

    try {
      _purchaseOrders = await financeServiceInterface.getPurchaseOrders(
        status: _poStatusFilter == 'all' ? null : _poStatusFilter,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<void> getPurchaseOrder(int id) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _selectedPurchaseOrder = await financeServiceInterface.getPurchaseOrder(id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<bool> createPurchaseOrder(PurchaseOrderModel order) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.storePurchaseOrder(order);
      if (success) {
        getPurchaseOrders();
        getOverview();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  Future<bool> updatePurchaseOrderStatus(int id, String status) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.updatePurchaseOrderStatus(id, status);
      if (success) {
        getPurchaseOrders();
        getOverview();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  void setPoStatusFilter(String status) {
    _poStatusFilter = status;
    update();
  }

  // ========== INVOICE METHODS ==========

  Future<void> getInvoices({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    if (status != null) _invoiceStatusFilter = status;
    update();

    try {
      _invoices = await financeServiceInterface.getInvoices(
        status: _invoiceStatusFilter == 'all' ? null : _invoiceStatusFilter,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<void> getInvoice(int id) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      _selectedInvoice = await financeServiceInterface.getInvoice(id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<bool> createInvoice(InvoiceModel invoice) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.storeInvoice(invoice);
      if (success) {
        getInvoices();
        getOverview();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  Future<bool> recordPayment(int invoiceId, PaymentRecordModel payment) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.recordPayment(invoiceId, payment);
      if (success) {
        getInvoices();
        getOverview();
        if (_selectedInvoice?.id == invoiceId) {
          getInvoice(invoiceId);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  void setInvoiceStatusFilter(String status) {
    _invoiceStatusFilter = status;
    update();
  }

  // ========== EXPENSE METHODS ==========

  Future<void> getExpenses({int? categoryId, String? fromDate, String? toDate}) async {
    _isLoading = true;
    _errorMessage = null;
    if (categoryId != null) _expenseCategoryFilter = categoryId;
    update();

    try {
      _expenses = await financeServiceInterface.getExpenses(
        categoryId: _expenseCategoryFilter,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    update();
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    _isSubmitting = true;
    _errorMessage = null;
    update();

    bool success = false;
    try {
      success = await financeServiceInterface.storeExpense(expense);
      if (success) {
        getExpenses();
        getOverview();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSubmitting = false;
    update();
    return success;
  }

  Future<void> getExpenseCategories() async {
    try {
      _expenseCategories = await financeServiceInterface.getExpenseCategories();
      update();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void setExpenseCategoryFilter(int? categoryId) {
    _expenseCategoryFilter = categoryId;
    update();
  }

  void clearExpenseCategoryFilter() {
    _expenseCategoryFilter = null;
    update();
  }
}
