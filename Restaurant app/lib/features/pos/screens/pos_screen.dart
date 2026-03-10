import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/pos/controllers/pos_controller.dart';
import 'package:mnjood_vendor/features/pos/widgets/pos_cart_widget.dart';
import 'package:mnjood_vendor/features/pos/widgets/pos_product_tile.dart';
import 'package:mnjood_vendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isScanning = false;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    Get.find<PosController>().getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _startScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() => _isScanning = true);
  }

  void _stopScanner() {
    _scannerController?.dispose();
    _scannerController = null;
    setState(() => _isScanning = false);
  }

  void _onBarcodeScanned(String barcode) {
    _stopScanner();
    Get.find<PosController>().findProductByBarcode(barcode).then((found) {
      if (found) {
        showCustomSnackBar('product_added'.tr, isError: false);
      } else {
        showCustomSnackBar('product_not_found'.tr, isError: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'pos'.tr),
      body: GetBuilder<PosController>(builder: (posController) {
        return isLandscape || isTablet
            ? _buildSplitLayout(posController)
            : _buildMobileLayout(posController);
      }),
    );
  }

  Widget _buildSplitLayout(PosController posController) {
    return Row(
      children: [
        // Left side - Products
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildSearchBar(posController),
              if (_isScanning) _buildScannerView(),
              Expanded(child: _buildProductGrid(posController)),
            ],
          ),
        ),
        // Right side - Cart
        Expanded(
          flex: 4,
          child: PosCartWidget(posController: posController),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(PosController posController) {
    return Column(
      children: [
        _buildSearchBar(posController),
        if (_isScanning) _buildScannerView(),
        Expanded(child: _buildProductGrid(posController)),
        _buildCartSummaryBar(posController),
      ],
    );
  }

  Widget _buildSearchBar(PosController posController) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'scan_or_search'.tr,
                prefixIcon: const Icon(HeroiconsOutline.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => posController.searchProducts(value),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            decoration: BoxDecoration(
              color: _isScanning ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: IconButton(
              onPressed: _isScanning ? _stopScanner : _startScanner,
              icon: Icon(
                _isScanning ? HeroiconsOutline.xMark : HeroiconsOutline.qrCode,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault - 2),
        child: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull?.rawValue;
                if (barcode != null) {
                  _onBarcodeScanned(barcode);
                }
              },
            ),
            Center(
              child: Container(
                width: 250,
                height: 2,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Text(
                'point_camera_at_barcode'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(color: Colors.white, shadows: [
                  const Shadow(color: Colors.black, blurRadius: 4),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(PosController posController) {
    if (posController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = posController.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(HeroiconsOutline.shoppingBag, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text('no_product_available'.tr, style: robotoMedium),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return PosProductTile(
          product: product,
          onTap: () => posController.addToCart(product),
        );
      },
    );
  }

  Widget _buildCartSummaryBar(PosController posController) {
    final cart = posController.cart;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.itemCount} ${'items'.tr}',
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                  Text(
                    PriceConverter.convertPrice(cart.total),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                ],
              ),
            ),
            CustomButtonWidget(
              buttonText: 'view_cart'.tr,
              width: 120,
              onPressed: cart.isEmpty
                  ? null
                  : () => _showCartBottomSheet(posController),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartBottomSheet(PosController posController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: PosCartWidget(
            posController: posController,
            scrollController: scrollController,
            showHeader: true,
          ),
        ),
      ),
    );
  }
}
