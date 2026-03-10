import 'package:get/get_connect/http/src/response/response.dart';
import 'package:mnjood_vendor/features/finance/domain/models/expense_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/purchase_order_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/supplier_model.dart';

abstract class FinanceRepositoryInterface {
  // Suppliers
  Future<Response> getSuppliers({String? status, String? search, int? page});
  Future<Response> getSupplier(int id);
  Future<Response> storeSupplier(SupplierModel supplier);
  Future<Response> updateSupplier(int id, SupplierModel supplier);
  Future<Response> deleteSupplier(int id);

  // Purchase Orders
  Future<Response> getPurchaseOrders({String? status, int? page});
  Future<Response> getPurchaseOrder(int id);
  Future<Response> storePurchaseOrder(PurchaseOrderModel order);
  Future<Response> updatePurchaseOrderStatus(int id, String status);

  // Invoices
  Future<Response> getInvoices({String? status, int? page});
  Future<Response> getInvoice(int id);
  Future<Response> storeInvoice(InvoiceModel invoice);
  Future<Response> recordPayment(int invoiceId, PaymentRecordModel payment);

  // Expenses
  Future<Response> getExpenses({int? categoryId, String? fromDate, String? toDate, int? page});
  Future<Response> storeExpense(ExpenseModel expense);
  Future<Response> getExpenseCategories();

  // Overview & Reports
  Future<Response> getOverview();
  Future<Response> getReports({String? fromDate, String? toDate});
}
