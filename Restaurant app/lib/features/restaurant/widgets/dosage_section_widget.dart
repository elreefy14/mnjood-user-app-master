import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget for entering medicine dosage information in pharmacy products
class DosageSectionWidget extends StatefulWidget {
  final PharmacyInfo? initialData;
  final Function(PharmacyInfo) onChanged;
  final bool isEnabled;

  const DosageSectionWidget({
    super.key,
    this.initialData,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<DosageSectionWidget> createState() => _DosageSectionWidgetState();
}

class _DosageSectionWidgetState extends State<DosageSectionWidget> {
  late TextEditingController _dosageController;
  late TextEditingController _durationController;
  late TextEditingController _instructionsController;
  late TextEditingController _activeIngredientController;

  String _selectedFrequency = 'once_daily';
  List<String> _selectedSideEffects = [];
  List<String> _selectedContraindications = [];
  List<MedicineWarning> _selectedWarnings = [];

  // Predefined options
  final List<String> _frequencyOptions = [
    'once_daily',
    'twice_daily',
    'three_times_daily',
    'four_times_daily',
    'every_4_hours',
    'every_6_hours',
    'every_8_hours',
    'every_12_hours',
    'as_needed',
    'before_meals',
    'after_meals',
    'at_bedtime',
  ];

  final List<String> _commonSideEffects = [
    'nausea',
    'dizziness',
    'headache',
    'drowsiness',
    'dry_mouth',
    'fatigue',
    'stomach_upset',
    'diarrhea',
    'constipation',
    'loss_of_appetite',
    'skin_rash',
    'insomnia',
  ];

  final List<String> _commonContraindications = [
    'pregnancy',
    'breastfeeding',
    'liver_disease',
    'kidney_disease',
    'heart_disease',
    'diabetes',
    'high_blood_pressure',
    'asthma',
    'allergies',
    'glaucoma',
    'thyroid_disorder',
    'elderly_patients',
    'children',
  ];

  final List<Map<String, dynamic>> _warningTypes = [
    {'type': 'pregnancy', 'icon': HeroiconsOutline.user, 'color': Colors.pink},
    {'type': 'driving', 'icon': HeroiconsOutline.truck, 'color': Colors.orange},
    {'type': 'alcohol', 'icon': HeroiconsOutline.xMark, 'color': Colors.red},
    {'type': 'sunlight', 'icon': HeroiconsSolid.sun, 'color': Colors.amber},
    {'type': 'machinery', 'icon': HeroiconsOutline.wrenchScrewdriver, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _dosageController = TextEditingController(text: widget.initialData?.dosage);
    _durationController = TextEditingController(text: widget.initialData?.duration);
    _instructionsController = TextEditingController(text: widget.initialData?.usageInstructions);
    _activeIngredientController = TextEditingController(text: widget.initialData?.activeIngredient);

    if (widget.initialData != null) {
      _selectedFrequency = widget.initialData!.frequency ?? 'once_daily';
      _selectedSideEffects = widget.initialData!.sideEffects ?? [];
      _selectedContraindications = widget.initialData!.contraindications ?? [];
      _selectedWarnings = widget.initialData!.warnings ?? [];
    }
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _activeIngredientController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(PharmacyInfo(
      dosage: _dosageController.text,
      frequency: _selectedFrequency,
      duration: _durationController.text,
      usageInstructions: _instructionsController.text,
      sideEffects: _selectedSideEffects,
      contraindications: _selectedContraindications,
      warnings: _selectedWarnings,
      activeIngredient: _activeIngredientController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
                HeroiconsOutline.beaker,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'dosage_information'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Active ingredient
          _buildTextField(
            controller: _activeIngredientController,
            label: 'active_ingredient'.tr,
            hint: 'enter_active_ingredient'.tr,
            icon: HeroiconsOutline.beaker,
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Dosage and frequency row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _dosageController,
                  label: 'dosage'.tr,
                  hint: 'e_g_500mg'.tr,
                  icon: HeroiconsOutline.beaker,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: _buildDropdown(
                  label: 'frequency'.tr,
                  value: _selectedFrequency,
                  items: _frequencyOptions,
                  onChanged: (value) {
                    setState(() => _selectedFrequency = value!);
                    _notifyChange();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Duration
          _buildTextField(
            controller: _durationController,
            label: 'duration'.tr,
            hint: 'e_g_7_days'.tr,
            icon: HeroiconsOutline.calendar,
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Usage instructions
          _buildTextField(
            controller: _instructionsController,
            label: 'usage_instructions'.tr,
            hint: 'enter_usage_instructions'.tr,
            icon: HeroiconsOutline.informationCircle,
            maxLines: 3,
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Warnings section
          Text(
            'warnings'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildWarningsSection(context),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Side effects section
          Text(
            'side_effects'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildChipSelector(
            context,
            _commonSideEffects,
            _selectedSideEffects,
            (selected) {
              setState(() => _selectedSideEffects = selected);
              _notifyChange();
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Contraindications section
          Text(
            'contraindications'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _buildChipSelector(
            context,
            _commonContraindications,
            _selectedContraindications,
            (selected) {
              setState(() => _selectedContraindications = selected);
              _notifyChange();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: widget.isEnabled,
      maxLines: maxLines,
      onChanged: (_) => _notifyChange(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: widget.isEnabled ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildWarningsSection(BuildContext context) {
    return Wrap(
      spacing: Dimensions.paddingSizeSmall,
      runSpacing: Dimensions.paddingSizeSmall,
      children: _warningTypes.map((warning) {
        final isSelected = _selectedWarnings.any((w) => w.type == warning['type']);

        return InkWell(
          onTap: widget.isEnabled
              ? () {
                  setState(() {
                    if (isSelected) {
                      _selectedWarnings.removeWhere((w) => w.type == warning['type']);
                    } else {
                      _selectedWarnings.add(MedicineWarning(
                        type: warning['type'],
                        description: '${warning['type']}_warning'.tr,
                        level: 'warning',
                      ));
                    }
                  });
                  _notifyChange();
                }
              : null,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (warning['color'] as Color).withOpacity(0.2)
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: isSelected
                    ? warning['color'] as Color
                    : Theme.of(context).disabledColor.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  warning['icon'] as IconData,
                  color: isSelected
                      ? warning['color'] as Color
                      : Theme.of(context).disabledColor,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  (warning['type'] as String).tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: isSelected
                        ? warning['color'] as Color
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChipSelector(
    BuildContext context,
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Wrap(
      spacing: Dimensions.paddingSizeExtraSmall,
      runSpacing: Dimensions.paddingSizeExtraSmall,
      children: options.map((option) {
        final isSelected = selected.contains(option);

        return FilterChip(
          label: Text(
            option.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          selected: isSelected,
          onSelected: widget.isEnabled
              ? (value) {
                  final newSelected = List<String>.from(selected);
                  if (value) {
                    newSelected.add(option);
                  } else {
                    newSelected.remove(option);
                  }
                  onChanged(newSelected);
                }
              : null,
          selectedColor: Theme.of(context).primaryColor,
          checkmarkColor: Colors.white,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        );
      }).toList(),
    );
  }
}

/// Compact dosage display widget for product details
class DosageDisplayWidget extends StatelessWidget {
  final PharmacyInfo pharmacyInfo;

  const DosageDisplayWidget({
    super.key,
    required this.pharmacyInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(HeroiconsOutline.beaker, color: Colors.blue, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'dosage_information'.tr,
                style: robotoBold.copyWith(
                  color: Colors.blue,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Dosage info grid
          if (pharmacyInfo.dosage != null)
            _buildInfoRow(context, 'dosage'.tr, pharmacyInfo.dosage!, HeroiconsOutline.beaker),

          if (pharmacyInfo.frequency != null)
            _buildInfoRow(context, 'frequency'.tr, pharmacyInfo.frequency!.tr, HeroiconsOutline.clock),

          if (pharmacyInfo.duration != null)
            _buildInfoRow(context, 'duration'.tr, pharmacyInfo.duration!, HeroiconsOutline.calendar),

          if (pharmacyInfo.usageInstructions != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'usage_instructions'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pharmacyInfo.usageInstructions!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],

          // Warnings
          if (pharmacyInfo.warnings != null && pharmacyInfo.warnings!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'warnings'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Wrap(
              spacing: Dimensions.paddingSizeSmall,
              runSpacing: Dimensions.paddingSizeSmall,
              children: pharmacyInfo.warnings!.map((warning) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    warning.type?.tr ?? '',
                    style: robotoMedium.copyWith(
                      color: Colors.red,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Side effects
          if (pharmacyInfo.sideEffects != null && pharmacyInfo.sideEffects!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'side_effects'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: pharmacyInfo.sideEffects!.map((effect) {
                return Chip(
                  label: Text(
                    effect.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).disabledColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            '$label: ',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
          Text(
            value,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}
