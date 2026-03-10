import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Screen for pharmacists to verify prescriptions attached to orders
class PrescriptionVerificationScreen extends StatefulWidget {
  final OrderModel order;

  const PrescriptionVerificationScreen({
    super.key,
    required this.order,
  });

  @override
  State<PrescriptionVerificationScreen> createState() => _PrescriptionVerificationScreenState();
}

class _PrescriptionVerificationScreenState extends State<PrescriptionVerificationScreen> {
  int _currentImageIndex = 0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rejectionReasonController = TextEditingController();
  bool _isProcessing = false;

  List<String> get _prescriptionImages {
    return widget.order.prescription?.prescriptionImageUrls ?? [];
  }

  @override
  void dispose() {
    _notesController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'verify_prescription'.tr,
        menuWidget: IconButton(
          icon: const Icon(HeroiconsOutline.informationCircle),
          onPressed: _showOrderDetails,
        ),
      ),
      body: _prescriptionImages.isEmpty
          ? _buildNoPrescription(context)
          : Column(
              children: [
                // Prescription image viewer
                Expanded(
                  flex: 3,
                  child: _buildImageViewer(context),
                ),

                // Order info and actions
                Expanded(
                  flex: 2,
                  child: _buildDetailsSection(context),
                ),
              ],
            ),
    );
  }

  Widget _buildNoPrescription(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            HeroiconsOutline.documentText,
            size: 80,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'no_prescription_attached'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'contact_customer'.tr,
            style: robotoRegular.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButtonWidget(
            buttonText: 'reject_order'.tr,
            color: Colors.red,
            width: 200,
            onPressed: () => _showRejectDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return Stack(
      children: [
        // Zoomable image gallery
        PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(_prescriptionImages[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 3,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      HeroiconsOutline.photo,
                      size: 64,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('image_load_failed'.tr),
                  ],
                ),
              ),
            );
          },
          itemCount: _prescriptionImages.length,
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event?.expectedTotalBytes != null
                  ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                  : null,
            ),
          ),
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          pageController: PageController(initialPage: _currentImageIndex),
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
        ),

        // Page indicator
        if (_prescriptionImages.length > 1)
          Positioned(
            bottom: Dimensions.paddingSizeDefault,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _prescriptionImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

        // Image counter
        Positioned(
          top: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${_prescriptionImages.length}',
              style: robotoMedium.copyWith(color: Colors.white),
            ),
          ),
        ),

        // Zoom hint
        Positioned(
          top: Dimensions.paddingSizeDefault,
          left: Dimensions.paddingSizeDefault,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(HeroiconsOutline.magnifyingGlass, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'pinch_to_zoom'.tr,
                  style: robotoRegular.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final prescription = widget.order.prescription;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'order'.tr} #${widget.order.id}',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.order.customer?.fName ?? ''} ${widget.order.customer?.lName ?? ''}'.trim().isEmpty ? 'guest'.tr : '${widget.order.customer?.fName ?? ''} ${widget.order.customer?.lName ?? ''}',
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusBadge(context, prescription?.status),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Prescription items count
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Icon(HeroiconsOutline.beaker, color: Colors.blue, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          '${widget.order.prescriptionItemsCount ?? 0} ${'prescription_items'.tr}',
                          style: robotoMedium.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Notes input
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'pharmacist_notes'.tr,
                      hintText: 'add_notes_optional'.tr,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Action buttons
                  if (prescription?.status == 'pending_verification' ||
                      prescription?.status == null)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButtonWidget(
                            buttonText: 'reject'.tr,
                            color: Colors.red,
                            isLoading: _isProcessing,
                            onPressed: () => _showRejectDialog(context),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: CustomButtonWidget(
                            buttonText: 'approve'.tr,
                            color: Colors.green,
                            isLoading: _isProcessing,
                            onPressed: _approvePrescription,
                          ),
                        ),
                      ],
                    ),

                  // Already processed info
                  if (prescription?.status == 'approved')
                    _buildProcessedInfo(
                      context,
                      'prescription_approved'.tr,
                      Colors.green,
                      HeroiconsSolid.checkCircle,
                      prescription?.verifiedBy,
                      prescription?.verifiedAt,
                    ),

                  if (prescription?.status == 'rejected')
                    Column(
                      children: [
                        _buildProcessedInfo(
                          context,
                          'prescription_rejected'.tr,
                          Colors.red,
                          HeroiconsSolid.xCircle,
                          prescription?.verifiedBy,
                          prescription?.verifiedAt,
                        ),
                        if (prescription?.rejectionReason != null)
                          Container(
                            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                const Icon(HeroiconsOutline.informationCircle, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prescription!.rejectionReason!,
                                    style: robotoRegular.copyWith(
                                      color: Colors.red,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'approved'.tr;
        icon = HeroiconsSolid.checkCircle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'rejected'.tr;
        icon = HeroiconsSolid.xCircle;
        break;
      default:
        color = Colors.orange;
        text = 'pending'.tr;
        icon = HeroiconsOutline.clock;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: robotoMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedInfo(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    String? verifiedBy,
    String? verifiedAt,
  ) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            title,
            style: robotoBold.copyWith(
              color: color,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          if (verifiedBy != null || verifiedAt != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              '${verifiedBy ?? ''} ${verifiedAt != null ? '• $verifiedAt' : ''}',
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showOrderDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusLarge),
            topRight: Radius.circular(Dimensions.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Text(
                'order_details'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ),
            const Divider(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      HeroiconsOutline.beaker,
                      size: 48,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      '${widget.order.prescriptionItemsCount ?? 0} ${'prescription_items'.tr}',
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'review_prescription_to_verify'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reject_prescription'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('rejection_reason_hint'.tr),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'enter_rejection_reason'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _rejectPrescription();
            },
            child: Text(
              'reject'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePrescription() async {
    setState(() => _isProcessing = true);

    // TODO: Implement API call to approve prescription
    // await Get.find<OrderController>().verifyPrescription(
    //   orderId: widget.order.id,
    //   action: 'approve',
    //   notes: _notesController.text,
    // );

    await Future.delayed(const Duration(seconds: 1)); // Placeholder

    setState(() => _isProcessing = false);

    showCustomSnackBar('prescription_approved'.tr, isError: false);
    Get.back(result: 'approved');
  }

  Future<void> _rejectPrescription() async {
    if (_rejectionReasonController.text.isEmpty) {
      showCustomSnackBar('enter_rejection_reason'.tr);
      return;
    }

    setState(() => _isProcessing = true);

    // TODO: Implement API call to reject prescription
    // await Get.find<OrderController>().verifyPrescription(
    //   orderId: widget.order.id,
    //   action: 'reject',
    //   rejectionReason: _rejectionReasonController.text,
    //   notes: _notesController.text,
    // );

    await Future.delayed(const Duration(seconds: 1)); // Placeholder

    setState(() => _isProcessing = false);

    showCustomSnackBar('prescription_rejected'.tr, isError: false);
    Get.back(result: 'rejected');
  }
}
