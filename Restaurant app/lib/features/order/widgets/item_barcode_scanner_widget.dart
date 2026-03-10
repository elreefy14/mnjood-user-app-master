import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/order/controllers/order_controller.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_details_model.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Bottom sheet widget for scanning order item barcodes
class ItemBarcodeScannerWidget extends StatefulWidget {
  final int orderId;
  final List<OrderDetailsModel> orderItems;
  final VoidCallback onAllItemsScanned;

  const ItemBarcodeScannerWidget({
    super.key,
    required this.orderId,
    required this.orderItems,
    required this.onAllItemsScanned,
  });

  @override
  State<ItemBarcodeScannerWidget> createState() => _ItemBarcodeScannerWidgetState();
}

class _ItemBarcodeScannerWidgetState extends State<ItemBarcodeScannerWidget> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _torchEnabled = false;
  String? _lastScannedBarcode;
  final TextEditingController _manualBarcodeController = TextEditingController();
  bool _showScanner = true;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _manualBarcodeController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? barcode = barcodes.first.rawValue;
    if (barcode == null || barcode == _lastScannedBarcode) return;

    setState(() {
      _lastScannedBarcode = barcode;
    });

    _processBarcode(barcode);
  }

  void _processBarcode(String barcode) {
    final orderController = Get.find<OrderController>();
    final item = orderController.findItemByBarcode(barcode, widget.orderItems);

    if (item != null) {
      if (item.foodId != null) {
        if (orderController.isItemScanned(widget.orderId, item.foodId!)) {
          showCustomSnackBar('already_scanned'.tr, isError: false);
        } else {
          orderController.markItemScanned(widget.orderId, item.foodId!);
          showCustomSnackBar('${'item_scanned'.tr}: ${item.foodDetails?.name ?? ''}', isError: false);

          // Check if all items are now scanned
          if (orderController.allItemsScanned(widget.orderId, widget.orderItems)) {
            Future.delayed(const Duration(milliseconds: 500), () {
              showCustomSnackBar('all_items_scanned'.tr, isError: false);
            });
          }
        }
      }
    } else {
      showCustomSnackBar('item_not_in_order'.tr, isError: true);
    }

    // Reset for next scan after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _lastScannedBarcode = null;
        });
      }
    });
  }

  void _toggleTorch() {
    _scannerController?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _showManualEntryDialog() {
    _manualBarcodeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('enter_barcode_manually'.tr),
        content: TextField(
          controller: _manualBarcodeController,
          decoration: InputDecoration(
            hintText: 'barcode'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            prefixIcon: const Icon(HeroiconsOutline.qrCode),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final barcode = _manualBarcodeController.text.trim();
              if (barcode.isNotEmpty) {
                Navigator.pop(context);
                _processBarcode(barcode);
              }
            },
            child: Text('search'.tr),
          ),
        ],
      ),
    );
  }

  void _onItemTap(OrderDetailsModel item) {
    // Show dialog to manually mark item as scanned (for items without barcode)
    if (item.foodDetails?.barcode == null || item.foodDetails!.barcode!.isEmpty) {
      // Item has no barcode - show error
      showCustomSnackBar('${'item_no_barcode'.tr}: ${item.foodDetails?.name ?? ''}', isError: true);
      return;
    }

    // Show info about the item's barcode
    Get.dialog(
      AlertDialog(
        title: Text(item.foodDetails?.name ?? 'item'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'barcode'.tr}: ${item.foodDetails?.barcode ?? 'N/A'}'),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('scan_this_barcode'.tr, style: robotoRegular.copyWith(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        final scannedCount = orderController.getScannedCount(widget.orderId);
        final totalCount = widget.orderItems.where((item) => item.foodId != null).length;
        final allScanned = orderController.allItemsScanned(widget.orderId, widget.orderItems);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    const Icon(HeroiconsOutline.qrCode, size: 24),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'scan_items'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                          Text(
                            '$scannedCount/$totalCount ${'items_scanned'.tr}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: allScanned ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (allScanned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(HeroiconsOutline.checkCircle, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'all_items_scanned'.tr,
                              style: robotoMedium.copyWith(
                                color: Colors.green,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Items list
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.25,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.orderItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.orderItems[index];
                    final isScanned = item.foodId != null &&
                        orderController.isItemScanned(widget.orderId, item.foodId!);
                    final hasBarcode = item.foodDetails?.barcode != null &&
                        item.foodDetails!.barcode!.isNotEmpty;

                    return InkWell(
                      onTap: () => _onItemTap(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        decoration: BoxDecoration(
                          color: isScanned
                              ? Colors.green.withValues(alpha: 0.05)
                              : !hasBarcode
                                  ? Colors.red.withValues(alpha: 0.05)
                                  : null,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Status icon
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isScanned
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : !hasBarcode
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isScanned
                                    ? HeroiconsOutline.check
                                    : !hasBarcode
                                        ? HeroiconsOutline.exclamationTriangle
                                        : HeroiconsOutline.qrCode,
                                size: 18,
                                color: isScanned
                                    ? Colors.green
                                    : !hasBarcode
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImageWidget(
                                image: item.foodDetails?.imageFullUrl ?? '',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.foodDetails?.name ?? '',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      decoration: isScanned ? TextDecoration.lineThrough : null,
                                      color: isScanned ? Colors.grey : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Status text
                            Text(
                              isScanned
                                  ? 'scanned'.tr
                                  : !hasBarcode
                                      ? 'no_barcode'.tr
                                      : 'tap_to_scan'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isScanned
                                    ? Colors.green
                                    : !hasBarcode
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Scanner section
              if (_showScanner && !allScanned) ...[
                const Divider(height: 1),
                Container(
                  height: 200,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onBarcodeDetected,
                      ),
                      // Scan overlay
                      Center(
                        child: Container(
                          width: 200,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                        ),
                      ),
                      // Last scanned indicator
                      if (_lastScannedBarcode != null)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Text(
                              '${'scanned'.tr}: $_lastScannedBarcode',
                              style: robotoRegular.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Scanner controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: _torchEnabled ? HeroiconsSolid.bolt : HeroiconsOutline.bolt,
                        label: _torchEnabled ? 'flash_on'.tr : 'flash_off'.tr,
                        onTap: _toggleTorch,
                      ),
                      _buildControlButton(
                        icon: HeroiconsOutline.commandLine,
                        label: 'manual'.tr,
                        onTap: _showManualEntryDialog,
                      ),
                      _buildControlButton(
                        icon: _showScanner ? HeroiconsOutline.eyeSlash : HeroiconsOutline.eye,
                        label: _showScanner ? 'hide_scanner'.tr : 'show_scanner'.tr,
                        onTap: () => setState(() => _showScanner = !_showScanner),
                      ),
                    ],
                  ),
                ),
              ],

              // Done button
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: CustomButtonWidget(
                  buttonText: allScanned ? 'done'.tr : '${'scan_remaining_items'.tr} (${totalCount - scannedCount})',
                  onPressed: allScanned
                      ? () {
                          Get.back();
                          widget.onAllItemsScanned();
                        }
                      : null,
                  color: allScanned ? Theme.of(context).primaryColor : Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
