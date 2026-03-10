class FinanceOverviewModel {
  double? totalPayables;
  double? overduePayables;
  int? pendingInvoices;
  int? openPurchaseOrders;
  double? monthlyExpenses;
  List<ExpenseByCategory>? expenseBreakdown;

  FinanceOverviewModel({
    this.totalPayables,
    this.overduePayables,
    this.pendingInvoices,
    this.openPurchaseOrders,
    this.monthlyExpenses,
    this.expenseBreakdown,
  });

  FinanceOverviewModel.fromJson(Map<String, dynamic> json) {
    totalPayables = json['total_payables']?.toDouble() ?? 0;
    overduePayables = json['overdue_payables']?.toDouble() ?? 0;
    pendingInvoices = json['pending_invoices'] ?? 0;
    openPurchaseOrders = json['open_purchase_orders'] ?? 0;
    monthlyExpenses = json['monthly_expenses']?.toDouble() ?? 0;
    if (json['expense_breakdown'] != null) {
      expenseBreakdown = [];
      json['expense_breakdown'].forEach((v) {
        expenseBreakdown!.add(ExpenseByCategory.fromJson(v));
      });
    }
  }
}

class ExpenseByCategory {
  String? category;
  double? total;

  ExpenseByCategory({this.category, this.total});

  ExpenseByCategory.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    total = json['total']?.toDouble() ?? 0;
  }
}

class FinanceReportModel {
  String? fromDate;
  String? toDate;
  double? totalPurchases;
  double? totalPayments;
  double? totalExpenses;
  List<TopSupplier>? topSuppliers;

  FinanceReportModel({
    this.fromDate,
    this.toDate,
    this.totalPurchases,
    this.totalPayments,
    this.totalExpenses,
    this.topSuppliers,
  });

  FinanceReportModel.fromJson(Map<String, dynamic> json) {
    if (json['period'] != null) {
      fromDate = json['period']['from'];
      toDate = json['period']['to'];
    }
    totalPurchases = json['total_purchases']?.toDouble() ?? 0;
    totalPayments = json['total_payments']?.toDouble() ?? 0;
    totalExpenses = json['total_expenses']?.toDouble() ?? 0;
    if (json['top_suppliers'] != null) {
      topSuppliers = [];
      json['top_suppliers'].forEach((v) {
        topSuppliers!.add(TopSupplier.fromJson(v));
      });
    }
  }
}

class TopSupplier {
  String? supplier;
  double? total;

  TopSupplier({this.supplier, this.total});

  TopSupplier.fromJson(Map<String, dynamic> json) {
    supplier = json['supplier'];
    total = json['total']?.toDouble() ?? 0;
  }
}
