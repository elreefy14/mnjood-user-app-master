import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_text_field_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/domain/models/expense_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedPaymentMethod = 'cash';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<FinanceController>().getExpenseCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'add_expense'.tr),
      body: GetBuilder<FinanceController>(builder: (controller) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('expense_details'.tr, style: robotoBold),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Category Dropdown
                if (controller.expenseCategories != null)
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'category'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      prefixIcon: const Icon(HeroiconsOutline.squares2x2),
                    ),
                    items: controller.expenseCategories!.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'please_select_category'.tr;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextFieldWidget(
                  controller: _amountController,
                  hintText: 'amount'.tr,
                  prefixIcon: HeroiconsOutline.currencyDollar,
                  inputType: TextInputType.number,
                  required: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Row(
                      children: [
                        Icon(HeroiconsOutline.calendar, color: Theme.of(context).disabledColor),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: robotoRegular,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: InputDecoration(
                    labelText: 'payment_method'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    prefixIcon: const Icon(HeroiconsOutline.banknotes),
                  ),
                  items: ['cash', 'bank_transfer', 'card'].map((method) {
                    return DropdownMenuItem(value: method, child: Text(method.tr));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextFieldWidget(
                  controller: _descriptionController,
                  hintText: 'description'.tr,
                  prefixIcon: HeroiconsOutline.documentText,
                  inputType: TextInputType.text,
                  required: true,
                  maxLines: 3,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextFieldWidget(
                  controller: _referenceController,
                  hintText: 'reference_number'.tr,
                  prefixIcon: HeroiconsOutline.ticket,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                CustomButtonWidget(
                  isLoading: controller.isSubmitting,
                  buttonText: 'add_expense'.tr,
                  onPressed: _saveExpense,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      showCustomSnackBar('please_select_category'.tr);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      showCustomSnackBar('please_enter_valid_amount'.tr);
      return;
    }

    if (_descriptionController.text.isEmpty) {
      showCustomSnackBar('please_enter_description'.tr);
      return;
    }

    final expense = ExpenseModel(
      categoryId: _selectedCategoryId,
      amount: amount,
      expenseDate: _selectedDate.toIso8601String().split('T')[0],
      description: _descriptionController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      referenceNumber: _referenceController.text.trim(),
    );

    final success = await Get.find<FinanceController>().addExpense(expense);

    if (success) {
      showCustomSnackBar('expense_added_successfully'.tr, isError: false);
      Get.back();
    } else {
      showCustomSnackBar(Get.find<FinanceController>().errorMessage ?? 'something_went_wrong'.tr);
    }
  }
}
