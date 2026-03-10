import 'package:mnjood_vendor/features/finance/domain/models/expense_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/finance_overview_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/purchase_order_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/supplier_model.dart';
import 'package:mnjood_vendor/features/finance/domain/repositories/finance_repository_interface.dart';
import 'package:mnjood_vendor/features/finance/domain/services/finance_service_interface.dart';

class FinanceService implements FinanceServiceInterface {
  final FinanceRepositoryInterface financeRepositoryInterface;

  FinanceService({required this.financeRepositoryInterface});

  // ==================== SUPPLIERS ====================

  @override
  Future<List<SupplierModel>?> getSuppliers({String? status, String? search, int? page}) async {
    List<SupplierModel>? suppliers;
    var response = await financeRepositoryInterface.getSuppliers(status: status, search: search, page: page);
    if (response.statusCode == 200) {
      suppliers = [];
      if (response.body['data'] != null) {
        response.body['data'].forEach((supplier) {
          suppliers!.add(SupplierModel.fromJson(supplier));
        });
      }
    }
    return suppliers;
  }

  @override
  Future<SupplierModel?> getSupplier(int id) async {
    SupplierModel? supplier;
    var response = await financeRepositoryInterface.getSupplier(id);
    if (response.statusCode == 200) {
      supplier = SupplierModel.fromJson(response.body);
    }
    return supplier;
  }

  @override
  Future<bool> storeSupplier(SupplierModel supplier) async {
    var response = await financeRepositoryInterface.storeSupplier(supplier);
    return response.statusCode == 200;
  }

  @override
  Future<bool> updateSupplier(int id, SupplierModel supplier) async {
    var response = await financeRepositoryInterface.updateSupplier(id, supplier);
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteSupplier(int id) async {
    var response = await financeRepositoryInterface.deleteSupplier(id);
    return response.statusCode == 200;
  }

  // ==================== PURCHASE ORDERS ====================

  @override
  Future<List<PurchaseOrderModel>?> getPurchaseOrders({String? status, int? page}) async {
    List<PurchaseOrderModel>? orders;
    var response = await financeRepositoryInterface.getPurchaseOrders(status: status, page: page);
    if (response.statusCode == 200) {
      orders = [];
      if (response.body['data'] != null) {
        response.body['data'].forEach((order) {
          orders!.add(PurchaseOrderModel.fromJson(order));
        });
      }
    }
    return orders;
  }

  @override
  Future<PurchaseOrderModel?> getPurchaseOrder(int id) async {
    PurchaseOrderModel? order;
    var response = await financeRepositoryInterface.getPurchaseOrder(id);
    if (response.statusCode == 200) {
      order = PurchaseOrderModel.fromJson(response.body);
    }
    return order;
  }

  @override
  Future<bool> storePurchaseOrder(PurchaseOrderModel order) async {
    var response = await financeRepositoryInterface.storePurchaseOrder(order);
    return response.statusCode == 200;
  }

  @override
  Future<bool> updatePurchaseOrderStatus(int id, String status) async {
    var response = await financeRepositoryInterface.updatePurchaseOrderStatus(id, status);
    return response.statusCode == 200;
  }

  // ==================== INVOICES ====================

  @override
  Future<List<InvoiceModel>?> getInvoices({String? status, int? page}) async {
    List<InvoiceModel>? invoices;
    var response = await financeRepositoryInterface.getInvoices(status: status, page: page);
    if (response.statusCode == 200) {
      invoices = [];
      if (response.body['data'] != null) {
        response.body['data'].forEach((invoice) {
          invoices!.add(InvoiceModel.fromJson(invoice));
        });
      }
    }
    return invoices;
  }

  @override
  Future<InvoiceModel?> getInvoice(int id) async {
    InvoiceModel? invoice;
    var response = await financeRepositoryInterface.getInvoice(id);
    if (response.statusCode == 200) {
      invoice = InvoiceModel.fromJson(response.body);
    }
    return invoice;
  }

  @override
  Future<bool> storeInvoice(InvoiceModel invoice) async {
    var response = await financeRepositoryInterface.storeInvoice(invoice);
    return response.statusCode == 200;
  }

  @override
  Future<bool> recordPayment(int invoiceId, PaymentRecordModel payment) async {
    var response = await financeRepositoryInterface.recordPayment(invoiceId, payment);
    return response.statusCode == 200;
  }

  // ==================== EXPENSES ====================

  @override
  Future<List<ExpenseModel>?> getExpenses({int? categoryId, String? fromDate, String? toDate, int? page}) async {
    List<ExpenseModel>? expenses;
    var response = await financeRepositoryInterface.getExpenses(
      categoryId: categoryId,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
    );
    if (response.statusCode == 200) {
      expenses = [];
      if (response.body['data'] != null) {
        response.body['data'].forEach((expense) {
          expenses!.add(ExpenseModel.fromJson(expense));
        });
      }
    }
    return expenses;
  }

  @override
  Future<bool> storeExpense(ExpenseModel expense) async {
    var response = await financeRepositoryInterface.storeExpense(expense);
    return response.statusCode == 200;
  }

  @override
  Future<List<ExpenseCategoryModel>?> getExpenseCategories() async {
    List<ExpenseCategoryModel>? categories;
    var response = await financeRepositoryInterface.getExpenseCategories();
    if (response.statusCode == 200) {
      categories = [];
      response.body.forEach((category) {
        categories!.add(ExpenseCategoryModel.fromJson(category));
      });
    }
    return categories;
  }

  // ==================== OVERVIEW & REPORTS ====================

  @override
  Future<FinanceOverviewModel?> getOverview() async {
    FinanceOverviewModel? overview;
    var response = await financeRepositoryInterface.getOverview();
    if (response.statusCode == 200) {
      overview = FinanceOverviewModel.fromJson(response.body);
    }
    return overview;
  }

  @override
  Future<FinanceReportModel?> getReports({String? fromDate, String? toDate}) async {
    FinanceReportModel? report;
    var response = await financeRepositoryInterface.getReports(fromDate: fromDate, toDate: toDate);
    if (response.statusCode == 200) {
      report = FinanceReportModel.fromJson(response.body);
    }
    return report;
  }
}
