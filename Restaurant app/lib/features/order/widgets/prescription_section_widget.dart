import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/features/order/screens/prescription_verification_screen.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget to display prescription information in order details
class PrescriptionSectionWidget extends StatelessWidget {
  final OrderModel order;

  const PrescriptionSectionWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    if (!order.hasPrescriptionItems!) return const SizedBox.shrink();

    final prescription = order.prescription;
    final status = prescription?.status ?? 'pending_verification';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
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
          // Header
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  HeroiconsOutline.beaker,
                  color: _getStatusColor(status),
                  size: 24,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'prescription_required'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      Text(
                        '${order.prescriptionItemsCount ?? 0} ${'items_require_prescription'.tr}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, status),
              ],
            ),
          ),

          // Prescription images preview
          if (prescription?.prescriptionImageUrls != null &&
              prescription!.prescriptionImageUrls!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'prescription_images'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: prescription.prescriptionImageUrls!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => Get.to(() => PrescriptionVerificationScreen(order: order)),
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: EdgeInsets.only(
                              right: index < prescription.prescriptionImageUrls!.length - 1
                                  ? Dimensions.paddingSizeSmall
                                  : 0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(
                                color: Theme.of(context).disabledColor.withOpacity(0.3),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Image.network(
                                prescription.prescriptionImageUrls![index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    HeroiconsOutline.photo,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // No prescription attached warning
          if (prescription?.prescriptionImageUrls == null ||
              prescription!.prescriptionImageUrls!.isEmpty)
            Container(
              margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(HeroiconsOutline.exclamationTriangle, color: Colors.red, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      'no_prescription_attached'.tr,
                      style: robotoRegular.copyWith(
                        color: Colors.red,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Rejection reason
          if (status == 'rejected' && prescription?.rejectionReason != null)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'rejection_reason'.tr,
                    style: robotoMedium.copyWith(
                      color: Colors.red,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription!.rejectionReason!,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),

          // Action button
          if (status == 'pending_verification')
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => PrescriptionVerificationScreen(order: order)),
                  icon: const Icon(HeroiconsSolid.shieldCheck, color: Colors.white),
                  label: Text(
                    'verify_prescription'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          // Verification info
          if (status == 'approved' || status == 'rejected')
            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'approved' ? HeroiconsSolid.checkCircle : HeroiconsSolid.xCircle,
                    color: status == 'approved' ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '${status == 'approved' ? 'verified_by'.tr : 'rejected_by'.tr}: ${prescription?.verifiedBy ?? '-'}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  if (prescription?.verifiedAt != null) ...[
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      '• ${prescription!.verifiedAt}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Text(
        _getStatusText(status),
        style: robotoMedium.copyWith(
          color: Colors.white,
          fontSize: Dimensions.fontSizeSmall,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'verified'.tr;
      case 'rejected':
        return 'rejected'.tr;
      default:
        return 'pending'.tr;
    }
  }
}
