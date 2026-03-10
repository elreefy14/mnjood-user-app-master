import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget for entering barcode/SKU information in supermarket products
class BarcodeSectionWidget extends StatefulWidget {
  final String? initialBarcode;
  final String? initialSku;
  final Function(String?, String?) onChanged;
  final bool isEnabled;

  const BarcodeSectionWidget({
    super.key,
    this.initialBarcode,
    this.initialSku,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<BarcodeSectionWidget> createState() => _BarcodeSectionWidgetState();
}

class _BarcodeSectionWidgetState extends State<BarcodeSectionWidget> {
  late TextEditingController _barcodeController;
  late TextEditingController _skuController;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.initialBarcode);
    _skuController = TextEditingController(text: widget.initialSku);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(_barcodeController.text, _skuController.text);
  }

  void _openBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BarcodeScannerSheet(
        onBarcodeScanned: (barcode) {
          setState(() {
            _barcodeController.text = barcode;
          });
          _notifyChange();
          Navigator.pop(context);
        },
      ),
    );
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
                HeroiconsOutline.qrCode,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'product_identification'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Barcode field with scan button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barcodeController,
                  enabled: widget.isEnabled,
                  onChanged: (_) => _notifyChange(),
                  decoration: InputDecoration(
                    labelText: 'barcode'.tr,
                    hintText: 'enter_or_scan_barcode'.tr,
                    prefixIcon: const Icon(HeroiconsOutline.qrCode),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              if (widget.isEnabled)
                InkWell(
                  onTap: _openBarcodeScanner,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: const Icon(
                      HeroiconsOutline.qrCode,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // SKU field
          TextField(
            controller: _skuController,
            enabled: widget.isEnabled,
            onChanged: (_) => _notifyChange(),
            decoration: InputDecoration(
              labelText: 'sku'.tr,
              hintText: 'enter_sku'.tr,
              prefixIcon: const Icon(HeroiconsOutline.cube),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Info text
          Row(
            children: [
              Icon(
                HeroiconsOutline.informationCircle,
                size: 14,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'barcode_sku_help'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modal sheet for scanning barcode
class _BarcodeScannerSheet extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const _BarcodeScannerSheet({required this.onBarcodeScanned});

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  MobileScannerController? _controller;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isScanned) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode != null && barcode.isNotEmpty) {
      setState(() => _isScanned = true);
      widget.onBarcodeScanned(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'scan_barcode'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                IconButton(
                  icon: const Icon(HeroiconsOutline.xMark),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scanner
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onBarcodeDetected,
                  ),
                  // Scan frame overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              'position_barcode_in_frame'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
