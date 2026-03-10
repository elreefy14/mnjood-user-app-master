import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_text_field_widget.dart';
import 'package:mnjood_vendor/features/finance/controllers/finance_controller.dart';
import 'package:mnjood_vendor/features/finance/domain/models/supplier_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class AddSupplierScreen extends StatefulWidget {
  final SupplierModel? supplier;

  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ibanController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentTerms = 'net_30';
  final List<String> _paymentTermsOptions = [
    'immediate',
    'net_7',
    'net_15',
    'net_30',
    'net_60',
  ];

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.supplier!.name ?? '';
      _contactPersonController.text = widget.supplier!.contactPerson ?? '';
      _emailController.text = widget.supplier!.email ?? '';
      _phoneController.text = widget.supplier!.phone ?? '';
      _addressController.text = widget.supplier!.address ?? '';
      _cityController.text = widget.supplier!.city ?? '';
      _taxNumberController.text = widget.supplier!.taxNumber ?? '';
      _bankNameController.text = widget.supplier!.bankName ?? '';
      _bankAccountController.text = widget.supplier!.bankAccount ?? '';
      _ibanController.text = widget.supplier!.iban ?? '';
      _creditLimitController.text = widget.supplier!.creditLimit?.toString() ?? '';
      _notesController.text = widget.supplier!.notes ?? '';
      _selectedPaymentTerms = widget.supplier!.paymentTerms ?? 'net_30';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _taxNumberController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _ibanController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: isEditing ? 'edit_supplier'.tr : 'add_supplier'.tr,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('basic_info'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                controller: _nameController,
                hintText: 'supplier_name'.tr,
                prefixIcon: HeroiconsOutline.buildingOffice,
                inputType: TextInputType.text,
                required: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _contactPersonController,
                hintText: 'contact_person'.tr,
                prefixIcon: HeroiconsOutline.user,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _phoneController,
                hintText: 'phone'.tr,
                prefixIcon: HeroiconsOutline.phone,
                inputType: TextInputType.phone,
                required: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _emailController,
                hintText: 'email'.tr,
                prefixIcon: HeroiconsOutline.envelope,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _addressController,
                hintText: 'address'.tr,
                prefixIcon: HeroiconsOutline.mapPin,
                inputType: TextInputType.streetAddress,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _cityController,
                hintText: 'city'.tr,
                prefixIcon: HeroiconsOutline.buildingOffice2,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('payment_info'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              DropdownButtonFormField<String>(
                value: _selectedPaymentTerms,
                decoration: InputDecoration(
                  labelText: 'payment_terms'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  prefixIcon: const Icon(HeroiconsOutline.clock),
                ),
                items: _paymentTermsOptions.map((term) {
                  return DropdownMenuItem(
                    value: term,
                    child: Text(_getPaymentTermLabel(term)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentTerms = value!;
                  });
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _creditLimitController,
                hintText: 'credit_limit'.tr,
                prefixIcon: HeroiconsOutline.creditCard,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _taxNumberController,
                hintText: 'tax_number'.tr,
                prefixIcon: HeroiconsOutline.receiptPercent,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('bank_details'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                controller: _bankNameController,
                hintText: 'bank_name'.tr,
                prefixIcon: HeroiconsOutline.buildingLibrary,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _bankAccountController,
                hintText: 'bank_account'.tr,
                prefixIcon: HeroiconsOutline.creditCard,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextFieldWidget(
                controller: _ibanController,
                hintText: 'iban'.tr,
                prefixIcon: HeroiconsOutline.ticket,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('additional_info'.tr, style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                controller: _notesController,
                hintText: 'notes'.tr,
                prefixIcon: HeroiconsOutline.documentText,
                inputType: TextInputType.multiline,
                maxLines: 3,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              GetBuilder<FinanceController>(builder: (controller) {
                return CustomButtonWidget(
                  isLoading: controller.isSubmitting,
                  buttonText: isEditing ? 'update_supplier'.tr : 'add_supplier'.tr,
                  onPressed: _saveSupplier,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentTermLabel(String term) {
    switch (term) {
      case 'immediate':
        return 'immediate'.tr;
      case 'net_7':
        return 'net_7_days'.tr;
      case 'net_15':
        return 'net_15_days'.tr;
      case 'net_30':
        return 'net_30_days'.tr;
      case 'net_60':
        return 'net_60_days'.tr;
      default:
        return term;
    }
  }

  void _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.isEmpty) {
      showCustomSnackBar('please_enter_supplier_name'.tr);
      return;
    }

    if (_phoneController.text.isEmpty) {
      showCustomSnackBar('please_enter_phone_number'.tr);
      return;
    }

    final supplier = SupplierModel(
      name: _nameController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      taxNumber: _taxNumberController.text.trim(),
      bankName: _bankNameController.text.trim(),
      bankAccount: _bankAccountController.text.trim(),
      iban: _ibanController.text.trim(),
      paymentTerms: _selectedPaymentTerms,
      creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
      notes: _notesController.text.trim(),
    );

    final controller = Get.find<FinanceController>();
    bool success;

    if (isEditing) {
      success = await controller.updateSupplier(widget.supplier!.id!, supplier);
    } else {
      success = await controller.addSupplier(supplier);
    }

    if (success) {
      showCustomSnackBar(
        isEditing ? 'supplier_updated_successfully'.tr : 'supplier_added_successfully'.tr,
        isError: false,
      );
      Get.back();
    } else {
      showCustomSnackBar(controller.errorMessage ?? 'something_went_wrong'.tr);
    }
  }
}
