import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget for entering expiry date and inventory settings for supermarket/pharmacy products
class ExpiryDateSectionWidget extends StatefulWidget {
  final DateTime? initialExpiryDate;
  final int? initialReorderPoint;
  final int? initialReorderQuantity;
  final Function(DateTime?, int?, int?) onChanged;
  final bool isEnabled;

  const ExpiryDateSectionWidget({
    super.key,
    this.initialExpiryDate,
    this.initialReorderPoint,
    this.initialReorderQuantity,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<ExpiryDateSectionWidget> createState() => _ExpiryDateSectionWidgetState();
}

class _ExpiryDateSectionWidgetState extends State<ExpiryDateSectionWidget> {
  DateTime? _selectedDate;
  late TextEditingController _reorderPointController;
  late TextEditingController _reorderQuantityController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialExpiryDate;
    _reorderPointController = TextEditingController(
      text: widget.initialReorderPoint?.toString() ?? '10',
    );
    _reorderQuantityController = TextEditingController(
      text: widget.initialReorderQuantity?.toString() ?? '20',
    );
  }

  @override
  void dispose() {
    _reorderPointController.dispose();
    _reorderQuantityController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      _selectedDate,
      int.tryParse(_reorderPointController.text),
      int.tryParse(_reorderQuantityController.text),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'select_expiry_date'.tr,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _notifyChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                HeroiconsOutline.cube,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'inventory_settings'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Expiry date picker
          Text(
            'expiry_date'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: widget.isEnabled ? _selectDate : null,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).disabledColor.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    HeroiconsOutline.calendar,
                    color: _selectedDate != null
                        ? _getExpiryColor()
                        : Theme.of(context).disabledColor,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? dateFormat.format(_selectedDate!)
                          : 'select_expiry_date'.tr,
                      style: robotoRegular.copyWith(
                        color: _selectedDate != null
                            ? _getExpiryColor()
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  if (_selectedDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getExpiryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        _getExpiryLabel(),
                        style: robotoMedium.copyWith(
                          color: _getExpiryColor(),
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                    ),
                  if (_selectedDate != null && widget.isEnabled)
                    IconButton(
                      icon: const Icon(HeroiconsOutline.xMark, size: 18),
                      onPressed: () {
                        setState(() => _selectedDate = null);
                        _notifyChange();
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Reorder settings
          Text(
            'stock_settings'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _reorderPointController,
                  enabled: widget.isEnabled,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _notifyChange(),
                  decoration: InputDecoration(
                    labelText: 'reorder_point'.tr,
                    hintText: '10',
                    prefixIcon: const Icon(HeroiconsOutline.exclamationTriangle),
                    border: const OutlineInputBorder(),
                    helperText: 'alert_when_below'.tr,
                    helperMaxLines: 2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: TextField(
                  controller: _reorderQuantityController,
                  enabled: widget.isEnabled,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _notifyChange(),
                  decoration: InputDecoration(
                    labelText: 'reorder_quantity'.tr,
                    hintText: '20',
                    prefixIcon: const Icon(HeroiconsOutline.shoppingCart),
                    border: const OutlineInputBorder(),
                    helperText: 'suggested_restock'.tr,
                    helperMaxLines: 2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Info card
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(HeroiconsOutline.informationCircle, color: Colors.blue, size: 20),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    'inventory_settings_info'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getExpiryColor() {
    if (_selectedDate == null) return Colors.grey;

    final daysUntilExpiry = _selectedDate!.difference(DateTime.now()).inDays;

    if (daysUntilExpiry < 0) return Colors.red;
    if (daysUntilExpiry <= 7) return Colors.orange;
    if (daysUntilExpiry <= 30) return Colors.amber;
    return Colors.green;
  }

  String _getExpiryLabel() {
    if (_selectedDate == null) return '';

    final daysUntilExpiry = _selectedDate!.difference(DateTime.now()).inDays;

    if (daysUntilExpiry < 0) return 'expired'.tr;
    if (daysUntilExpiry == 0) return 'expires_today'.tr;
    if (daysUntilExpiry == 1) return 'expires_tomorrow'.tr;
    if (daysUntilExpiry <= 7) return '$daysUntilExpiry ${'days_left'.tr}';
    if (daysUntilExpiry <= 30) return '${(daysUntilExpiry / 7).ceil()} ${'weeks_left'.tr}';
    return '${(daysUntilExpiry / 30).ceil()} ${'months_left'.tr}';
  }
}
