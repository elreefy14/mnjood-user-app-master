import 'package:mnjood_vendor/features/finance/domain/models/expense_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/finance_overview_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/invoice_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/purchase_order_model.dart';
import 'package:mnjood_vendor/features/finance/domain/models/supplier_model.dart';

abstract class FinanceServiceInterface {
  // Suppliers
  Future<List<SupplierModel>?> getSuppliers({String? status, String? search, int? page});
  Future<SupplierModel?> getSupplier(int id);
  Future<bool> storeSupplier(SupplierModel supplier);
  Future<bool> updateSupplier(int id, SupplierModel supplier);
  Future<bool> deleteSupplier(int id);

  // Purchase Orders
  Future<List<PurchaseOrderModel>?> getPurchaseOrders({String? status, int? page});
  Future<PurchaseOrderModel?> getPurchaseOrder(int id);
  Future<bool> storePurchaseOrder(PurchaseOrderModel order);
  Future<bool> updatePurchaseOrderStatus(int id, String status);

  // Invoices
  Future<List<InvoiceModel>?> getInvoices({String? status, int? page});
  Future<InvoiceModel?> getInvoice(int id);
  Future<bool> storeInvoice(InvoiceModel invoice);
  Future<bool> recordPayment(int invoiceId, PaymentRecordModel payment);

  // Expenses
  Future<List<ExpenseModel>?> getExpenses({int? categoryId, String? fromDate, String? toDate, int? page});
  Future<bool> storeExpense(ExpenseModel expense);
  Future<List<ExpenseCategoryModel>?> getExpenseCategories();

  // Overview & Reports
  Future<FinanceOverviewModel?> getOverview();
  Future<FinanceReportModel?> getReports({String? fromDate, String? toDate});
}
