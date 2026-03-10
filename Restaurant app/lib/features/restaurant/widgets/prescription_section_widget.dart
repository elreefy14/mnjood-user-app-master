import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget for setting prescription requirement status in pharmacy products
class PrescriptionSectionWidget extends StatefulWidget {
  final bool initialPrescriptionRequired;
  final Function(bool) onChanged;
  final bool isEnabled;

  const PrescriptionSectionWidget({
    super.key,
    this.initialPrescriptionRequired = false,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<PrescriptionSectionWidget> createState() => _PrescriptionSectionWidgetState();
}

class _PrescriptionSectionWidgetState extends State<PrescriptionSectionWidget> {
  late bool _prescriptionRequired;

  @override
  void initState() {
    super.initState();
    _prescriptionRequired = widget.initialPrescriptionRequired;
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
                color: _prescriptionRequired ? Colors.red : Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'prescription_settings'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Prescription toggle card
          InkWell(
            onTap: widget.isEnabled
                ? () {
                    setState(() => _prescriptionRequired = !_prescriptionRequired);
                    widget.onChanged(_prescriptionRequired);
                  }
                : null,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: _prescriptionRequired
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: _prescriptionRequired
                      ? Colors.red.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: _prescriptionRequired
                          ? Colors.red.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _prescriptionRequired
                          ? HeroiconsSolid.clipboardDocumentCheck
                          : HeroiconsOutline.clipboardDocumentList,
                      color: _prescriptionRequired ? Colors.red : Colors.green,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _prescriptionRequired
                              ? 'prescription_required'.tr
                              : 'no_prescription_required'.tr,
                          style: robotoBold.copyWith(
                            color: _prescriptionRequired ? Colors.red : Colors.green,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _prescriptionRequired
                              ? 'customer_must_upload_prescription'.tr
                              : 'customer_can_order_directly'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Switch
                  Switch(
                    value: _prescriptionRequired,
                    onChanged: widget.isEnabled
                        ? (value) {
                            setState(() => _prescriptionRequired = value);
                            widget.onChanged(value);
                          }
                        : null,
                    activeColor: Colors.red,
                    inactiveThumbColor: Colors.green,
                    inactiveTrackColor: Colors.green.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Info/Warning boxes based on state
          if (_prescriptionRequired)
            _buildInfoBox(
              context,
              icon: HeroiconsOutline.exclamationTriangle,
              color: Colors.orange,
              title: 'prescription_verification_info'.tr,
              message: 'prescription_verification_message'.tr,
            )
          else
            _buildInfoBox(
              context,
              icon: HeroiconsOutline.informationCircle,
              color: Colors.blue,
              title: 'otc_medicine_info'.tr,
              message: 'otc_medicine_message'.tr,
            ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Prescription badge preview
          Text(
            'badge_preview'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPreviewBadge(context),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Text(
                  'appears_on_product'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoMedium.copyWith(
                    color: color,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBadge(BuildContext context) {
    if (_prescriptionRequired) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(HeroiconsOutline.beaker, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'rx'.tr,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(HeroiconsSolid.checkCircle, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'otc'.tr,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ),
      );
    }
  }
}
