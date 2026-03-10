import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mnjood_vendor/features/inventory/controllers/inventory_controller.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';

/// Barcode scanner screen for inventory management
class BarcodeScannerScreen extends StatefulWidget {
  final bool quickAdjustMode;

  const BarcodeScannerScreen({
    super.key,
    this.quickAdjustMode = false,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _torchEnabled = false;
  String? _lastScannedBarcode;
  final TextEditingController _manualBarcodeController = TextEditingController();

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
      _isScanning = false;
      _lastScannedBarcode = barcode;
    });

    _processBarcode(barcode);
  }

  Future<void> _processBarcode(String barcode) async {
    final inventoryController = Get.find<InventoryController>();
    final product = await inventoryController.findProductByBarcode(barcode);

    if (product != null) {
      _showProductBottomSheet(product, barcode);
    } else {
      _showNotFoundDialog(barcode);
    }
  }

  void _showProductBottomSheet(Product product, String barcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductResultSheet(
        product: product,
        barcode: barcode,
        onAdjustStock: () {
          Navigator.pop(context);
          _showStockAdjustmentDialog(product);
        },
        onViewDetails: () {
          Navigator.pop(context);
          // TODO: Navigate to product details
        },
        onScanAgain: () {
          Navigator.pop(context);
          _resetScanner();
        },
      ),
    );
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(HeroiconsOutline.exclamationTriangle, color: Colors.orange),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text('product_not_found'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('no_product_with_barcode'.tr),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(HeroiconsOutline.qrCode, color: Colors.grey[600]),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      barcode,
                      style: robotoMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: Text('scan_again'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to add product with pre-filled barcode
            },
            child: Text('add_new'.tr),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustmentDialog(Product product) {
    final quantityController = TextEditingController();
    String adjustmentType = 'add';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('adjust_stock'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: product.imageFullUrl != null
                        ? Image.network(
                            product.imageFullUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: Icon(BusinessTypeHelper.getItemIcon()),
                          ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? '',
                          style: robotoMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${'current_stock'.tr}: ${product.itemStock ?? 0}',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Adjustment type
              Text('adjustment_type'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  _buildAdjustmentTypeChip(
                    'add',
                    'add_stock'.tr,
                    HeroiconsOutline.plus,
                    Colors.green,
                    adjustmentType == 'add',
                    () => setDialogState(() => adjustmentType = 'add'),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  _buildAdjustmentTypeChip(
                    'remove',
                    'remove_stock'.tr,
                    HeroiconsOutline.minus,
                    Colors.red,
                    adjustmentType == 'remove',
                    () => setDialogState(() => adjustmentType = 'remove'),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Quantity input
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'quantity'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  prefixIcon: Icon(HeroiconsOutline.hashtag),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetScanner();
              },
              child: Text('cancel'.tr),
            ),
            GetBuilder<InventoryController>(
              builder: (controller) => ElevatedButton(
                onPressed: controller.isAdjusting
                    ? null
                    : () async {
                        final quantity = int.tryParse(quantityController.text);
                        if (quantity == null || quantity <= 0) {
                          showCustomSnackBar('enter_valid_quantity'.tr);
                          return;
                        }

                        final success = await controller.adjustStock(
                          productId: product.id!,
                          adjustmentType: adjustmentType,
                          quantity: quantity,
                        );

                        if (success) {
                          Navigator.pop(context);
                          showCustomSnackBar('stock_adjusted_successfully'.tr, isError: false);
                          _resetScanner();
                        }
                      },
                child: controller.isAdjusting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('confirm'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentTypeChip(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: robotoRegular.copyWith(
                color: isSelected ? color : Colors.grey,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _lastScannedBarcode = null;
    });
  }

  void _toggleTorch() {
    _scannerController?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _showManualEntryDialog() {
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
            prefixIcon: Icon(HeroiconsOutline.qrCode),
          ),
          keyboardType: TextInputType.number,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'scan_barcode'.tr),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Stack(
              children: [
                // Scan area cutout
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.srcOut,
                        ),
                        child: Container(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Text(
                    'position_barcode_in_frame'.tr,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),

                // Last scanned
                if (_lastScannedBarcode != null)
                  Positioned(
                    bottom: 180,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(HeroiconsOutline.qrCode, color: Colors.green),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'barcode_scanned'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                Text(
                                  _lastScannedBarcode!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom controls
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Torch toggle
                      _buildControlButton(
                        icon: _torchEnabled ? HeroiconsSolid.bolt : HeroiconsOutline.bolt,
                        label: _torchEnabled ? 'flash_on'.tr : 'flash_off'.tr,
                        onTap: _toggleTorch,
                      ),

                      // Manual entry
                      _buildControlButton(
                        icon: HeroiconsOutline.commandLine,
                        label: 'manual'.tr,
                        onTap: _showManualEntryDialog,
                      ),

                      // Reset
                      if (!_isScanning)
                        _buildControlButton(
                          icon: HeroiconsOutline.arrowPath,
                          label: 'scan_again'.tr,
                          onTap: _resetScanner,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          GetBuilder<InventoryController>(
            builder: (controller) {
              if (controller.isLoading) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: robotoRegular.copyWith(
              color: Colors.white,
              fontSize: Dimensions.fontSizeExtraSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing product result after barcode scan
class _ProductResultSheet extends StatelessWidget {
  final Product product;
  final String barcode;
  final VoidCallback onAdjustStock;
  final VoidCallback onViewDetails;
  final VoidCallback onScanAgain;

  const _ProductResultSheet({
    required this.product,
    required this.barcode,
    required this.onAdjustStock,
    required this.onViewDetails,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
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

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: product.imageFullUrl != null
                          ? Image.network(
                              product.imageFullUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: Icon(
                                BusinessTypeHelper.getItemIcon(),
                                size: 40,
                              ),
                            ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? '',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(HeroiconsOutline.qrCode, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                barcode,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Stock info
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'current_stock'.tr,
                        '${product.itemStock ?? 0}',
                        _getStockColor(product),
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildInfoItem(
                        'reorder_point'.tr,
                        '${product.reorderPoint ?? '-'}',
                        Colors.grey[600]!,
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildInfoItem(
                        'price'.tr,
                        '${product.price ?? 0}',
                        Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWidget(
                        buttonText: 'adjust_stock'.tr,
                        onPressed: onAdjustStock,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: CustomButtonWidget(
                        buttonText: 'view_details'.tr,
                        onPressed: onViewDetails,
                        transparent: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Scan again
                Center(
                  child: TextButton.icon(
                    onPressed: onScanAgain,
                    icon: Icon(HeroiconsOutline.qrCode),
                    label: Text('scan_again'.tr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getStockColor(Product product) {
    if (product.isOutOfStock) return Colors.red;
    if (product.hasLowStock) return Colors.orange;
    return Colors.green;
  }
}
