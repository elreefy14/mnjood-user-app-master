import 'package:get/get.dart';
import 'package:mnjood_vendor/api/api_client.dart';
import 'package:mnjood_vendor/features/finance/domain/models/expense_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/purchase_order_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/supplier_model.dart';
import 'package:mnjood_vendor/features/finance/domain/repositories/finance_repository_interface.dart';
import 'package:mnjood_vendor/util/app_constants.dart';

class FinanceRepository implements FinanceRepositoryInterface {
  final ApiClient apiClient;

  FinanceRepository({required this.apiClient});

  // ==================== SUPPLIERS ====================

  @override
  Future<Response> getSuppliers({String? status, String? search, int? page}) async {
    String uri = AppConstants.financeSuppliersUri;
    List<String> params = [];
    if (status != null) params.add('status=$status');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (page != null) params.add('page=$page');
    if (params.isNotEmpty) {
      uri += '?${params.join('&')}';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> getSupplier(int id) async {
    return await apiClient.getData('${AppConstants.financeSuppliersUri}/$id');
  }

  @override
  Future<Response> storeSupplier(SupplierModel supplier) async {
    return await apiClient.postData(AppConstants.financeSuppliersUri, supplier.toJson());
  }

  @override
  Future<Response> updateSupplier(int id, SupplierModel supplier) async {
    return await apiClient.putData('${AppConstants.financeSuppliersUri}/$id', supplier.toJson());
  }

  @override
  Future<Response> deleteSupplier(int id) async {
    return await apiClient.deleteData('${AppConstants.financeSuppliersUri}/$id');
  }

  // ==================== PURCHASE ORDERS ====================

  @override
  Future<Response> getPurchaseOrders({String? status, int? page}) async {
    String uri = AppConstants.financePurchaseOrdersUri;
    List<String> params = [];
    if (status != null) params.add('status=$status');
    if (page != null) params.add('page=$page');
    if (params.isNotEmpty) {
      uri += '?${params.join('&')}';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> getPurchaseOrder(int id) async {
    return await apiClient.getData('${AppConstants.financePurchaseOrdersUri}/$id');
  }

  @override
  Future<Response> storePurchaseOrder(PurchaseOrderModel order) async {
    return await apiClient.postData(AppConstants.financePurchaseOrdersUri, order.toJson());
  }

  @override
  Future<Response> updatePurchaseOrderStatus(int id, String status) async {
    return await apiClient.putData(
      '${AppConstants.financePurchaseOrdersUri}/$id/status',
      {'status': status},
    );
  }

  // ==================== INVOICES ====================

  @override
  Future<Response> getInvoices({String? status, int? page}) async {
    String uri = AppConstants.financeInvoicesUri;
    List<String> params = [];
    if (status != null) params.add('status=$status');
    if (page != null) params.add('page=$page');
    if (params.isNotEmpty) {
      uri += '?${params.join('&')}';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> getInvoice(int id) async {
    return await apiClient.getData('${AppConstants.financeInvoicesUri}/$id');
  }

  @override
  Future<Response> storeInvoice(InvoiceModel invoice) async {
    return await apiClient.postData(AppConstants.financeInvoicesUri, invoice.toJson());
  }

  @override
  Future<Response> recordPayment(int invoiceId, PaymentRecordModel payment) async {
    return await apiClient.postData(
      '${AppConstants.financeInvoicesUri}/$invoiceId/payment',
      payment.toJson(),
    );
  }

  // ==================== EXPENSES ====================

  @override
  Future<Response> getExpenses({int? categoryId, String? fromDate, String? toDate, int? page}) async {
    String uri = AppConstants.financeExpensesUri;
    List<String> params = [];
    if (categoryId != null) params.add('category_id=$categoryId');
    if (fromDate != null) params.add('from_date=$fromDate');
    if (toDate != null) params.add('to_date=$toDate');
    if (page != null) params.add('page=$page');
    if (params.isNotEmpty) {
      uri += '?${params.join('&')}';
    }
    return await apiClient.getData(uri);
  }

  @override
  Future<Response> storeExpense(ExpenseModel expense) async {
    return await apiClient.postData(AppConstants.financeExpensesUri, expense.toJson());
  }

  @override
  Future<Response> getExpenseCategories() async {
    return await apiClient.getData(AppConstants.financeExpenseCategoriesUri);
  }

  // ==================== OVERVIEW & REPORTS ====================

  @override
  Future<Response> getOverview() async {
    return await apiClient.getData(AppConstants.financeOverviewUri);
  }

  @override
  Future<Response> getReports({String? fromDate, String? toDate}) async {
    String uri = AppConstants.financeReportsUri;
    List<String> params = [];
    if (fromDate != null) params.add('from_date=$fromDate');
    if (toDate != null) params.add('to_date=$toDate');
    if (params.isNotEmpty) {
      uri += '?${params.join('&')}';
    }
    return await apiClient.getData(uri);
  }
}
