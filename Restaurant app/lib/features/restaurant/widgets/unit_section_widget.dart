import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class UnitSectionWidget extends StatelessWidget {
  const UnitSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (controller) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeLarge,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.productUnits.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
            ),
            itemBuilder: (context, index) {
              return _UnitItemWidget(index: index);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Center(
            child: TextButton.icon(
              onPressed: () => controller.addUnit(),
              icon: Icon(HeroiconsOutline.plus, size: 18, color: Theme.of(context).primaryColor),
              label: Text('add_unit'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
            ),
          ),
        ]),
      );
    });
  }
}

class _UnitItemWidget extends StatefulWidget {
  final int index;
  const _UnitItemWidget({required this.index});

  @override
  State<_UnitItemWidget> createState() => _UnitItemWidgetState();
}

class _UnitItemWidgetState extends State<_UnitItemWidget> {
  late TextEditingController _nameController;
  late TextEditingController _labelController;
  late TextEditingController _labelArController;
  late TextEditingController _symbolController;
  late TextEditingController _priceController;
  late TextEditingController _conversionController;
  late TextEditingController _minOrderController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final unit = Get.find<RestaurantController>().productUnits[widget.index];
    _nameController = TextEditingController(text: unit.name ?? '');
    _labelController = TextEditingController(text: unit.label ?? '');
    _labelArController = TextEditingController(text: unit.labelAr ?? '');
    _symbolController = TextEditingController(text: unit.symbol ?? '');
    _priceController = TextEditingController(text: (unit.sellingPrice ?? 0) > 0 ? unit.sellingPrice.toString() : '');
    _conversionController = TextEditingController(text: (unit.conversionRate ?? 1.0).toString());
    _minOrderController = TextEditingController(text: (unit.minOrderQty ?? 1).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _labelArController.dispose();
    _symbolController.dispose();
    _priceController.dispose();
    _conversionController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  void _syncUnit() {
    final controller = Get.find<RestaurantController>();
    final existing = controller.productUnits[widget.index];
    controller.updateUnit(widget.index, ProductUnit(
      id: existing.id,
      name: _nameController.text.trim(),
      label: _labelController.text.trim(),
      labelAr: _labelArController.text.trim(),
      symbol: _symbolController.text.trim(),
      sellingPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      conversionRate: double.tryParse(_conversionController.text.trim()) ?? 1.0,
      minOrderQty: int.tryParse(_minOrderController.text.trim()) ?? 1,
      isDefault: existing.isDefault,
      isPurchasable: existing.isPurchasable,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (controller) {
      final unit = controller.productUnits[widget.index];
      final isDefault = unit.isDefault ?? false;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Text(
            '${'unit'.tr} ${widget.index + 1}',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('default'.tr, style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).primaryColor,
              )),
            ),
          ],
          const Spacer(),
          if (!isDefault)
            InkWell(
              onTap: () => controller.setDefaultUnit(widget.index),
              child: Text('set_default'.tr, style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              )),
            ),
          if (controller.productUnits.length > 1) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () => controller.removeUnit(widget.index),
              child: Icon(HeroiconsOutline.trash, size: 18, color: Colors.red.shade400),
            ),
          ],
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Name + Symbol row
        Row(children: [
          Expanded(flex: 3, child: _buildField(
            controller: _nameController,
            label: 'name'.tr,
            hint: 'piece',
            onChanged: (_) => _syncUnit(),
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(flex: 2, child: _buildField(
            controller: _symbolController,
            label: 'symbol'.tr,
            hint: 'pc',
            onChanged: (_) => _syncUnit(),
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Label EN + Label AR
        Row(children: [
          Expanded(child: _buildField(
            controller: _labelController,
            label: 'label_en'.tr,
            hint: 'Piece',
            onChanged: (_) => _syncUnit(),
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: _buildField(
            controller: _labelArController,
            label: 'label_ar'.tr,
            hint: 'حبة',
            onChanged: (_) => _syncUnit(),
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Price + Conversion rate
        Row(children: [
          Expanded(child: _buildField(
            controller: _priceController,
            label: 'price'.tr,
            hint: '0.00',
            isNumber: true,
            onChanged: (_) => _syncUnit(),
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: _buildField(
            controller: _conversionController,
            label: 'conversion_rate'.tr,
            hint: '1.0',
            isNumber: true,
            onChanged: (_) => _syncUnit(),
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Min order + Purchasable toggle
        Row(children: [
          Expanded(child: _buildField(
            controller: _minOrderController,
            label: 'min_order_qty'.tr,
            hint: '1',
            isNumber: true,
            onChanged: (_) => _syncUnit(),
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Row(children: [
              Text('purchasable'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const Spacer(),
              Switch(
                value: unit.isPurchasable ?? true,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (val) {
                  controller.updateUnit(widget.index, ProductUnit(
                    id: unit.id,
                    name: unit.name,
                    label: unit.label,
                    labelAr: unit.labelAr,
                    symbol: unit.symbol,
                    sellingPrice: unit.sellingPrice,
                    conversionRate: unit.conversionRate,
                    minOrderQty: unit.minOrderQty,
                    isDefault: unit.isDefault,
                    isPurchasable: val,
                  ));
                },
              ),
            ]),
          ),
        ]),
      ]);
    });
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: 0.8), fontSize: Dimensions.fontSizeSmall),
          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor.withValues(alpha: 0.5), fontSize: Dimensions.fontSizeSmall),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}
