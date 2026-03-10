import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import 'package:mnjood/features/order/domain/models/order_model.dart';
import 'package:mnjood/features/order/domain/models/order_details_model.dart';
import 'package:mnjood/helper/price_converter.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/util/styles.dart';
import 'package:mnjood/common/widgets/custom_snackbar_widget.dart';

class InvoicePrintScreen extends StatefulWidget {
  final OrderModel order;
  final List<OrderDetailsModel> orderDetails;
  final double itemsPrice;
  final double addOns;
  final double discount;
  final double couponDiscount;
  final double tax;
  final double deliveryCharge;
  final double dmTips;
  final double total;

  const InvoicePrintScreen({
    super.key,
    required this.order,
    required this.orderDetails,
    required this.itemsPrice,
    required this.addOns,
    required this.discount,
    required this.couponDiscount,
    required this.tax,
    required this.deliveryCharge,
    required this.dmTips,
    required this.total,
  });

  @override
  State<InvoicePrintScreen> createState() => _InvoicePrintScreenState();
}

class _InvoicePrintScreenState extends State<InvoicePrintScreen> {
  bool _isSunmi = false;
  bool _isPrinting = false;
  String _printerStatus = '';

  final GlobalKey _invoiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _detectPrinter();
  }

  Future<void> _detectPrinter() async {
    try {
      final status = await SunmiConfig.getStatus();
      if (status != null) {
        _isSunmi = true;
        _printerStatus = 'sunmi_printer_ready'.tr;
      } else {
        _isSunmi = false;
        _printerStatus = 'no_printer_detected'.tr;
      }
    } catch (e) {
      _isSunmi = false;
      _printerStatus = 'no_printer_detected'.tr;
    }
    if (mounted) setState(() {});
  }

  Future<void> _printReceipt() async {
    if (!_isSunmi) {
      showCustomSnackBar('no_printer_detected'.tr);
      return;
    }
    setState(() => _isPrinting = true);

    try {
      // Wait for widget to fully render
      await Future.delayed(const Duration(milliseconds: 200));

      RenderRepaintBoundary boundary =
          _invoiceKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await SunmiPrinter.printImage(pngBytes, align: SunmiPrintAlign.CENTER);
      await SunmiPrinter.lineWrap(4);
      await SunmiPrinter.cutPaper();

      if (mounted) {
        showCustomSnackBar('print_success'.tr, isError: false);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar('${'print_failed'.tr}: $e');
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('print_invoice'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
      ),
      body: Column(children: [
        // Printer status bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _isSunmi
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Row(children: [
            Icon(
              _isSunmi ? Icons.print : Icons.print_disabled,
              color: _isSunmi ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_printerStatus,
                  style: robotoMedium.copyWith(
                    color: _isSunmi ? Colors.green : Colors.orange,
                  )),
            ),
          ]),
        ),

        // Invoice preview
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: RepaintBoundary(
                key: _invoiceKey,
                child: Container(
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildInvoiceContent(),
                ),
              ),
            ),
          ),
        ),

        // Print button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2))
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isPrinting ? null : _printReceipt,
              icon: _isPrinting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.print, color: Colors.white),
              label: Text(
                _isPrinting ? 'printing'.tr : 'print_invoice'.tr,
                style: robotoBold.copyWith(
                    color: Colors.white, fontSize: Dimensions.fontSizeLarge),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isSunmi ? Theme.of(context).primaryColor : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildInvoiceContent() {
    final order = widget.order;
    final restaurantName = order.restaurant?.name ?? '';
    final orderId = order.id?.toString() ?? '';
    final orderDate = order.createdAt != null
        ? DateConverter.dateTimeStringToDateTime(order.createdAt!)
        : '';
    bool taxIncluded = order.taxStatus ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTextStyle(
        style: const TextStyle(
            color: Colors.black, fontFamily: 'GraphikArabic', fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Restaurant name
            Text(restaurantName,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 8),

            // Order info
            Text('${'order'.tr} #$orderId',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 2),
            Text(orderDate,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black54)),
            if (order.orderType != null) ...[
              const SizedBox(height: 2),
              Text(order.orderType!.replaceAll('_', ' ').tr,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.black54)),
            ],

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 8),

            // Items header
            Row(
              children: [
                Expanded(
                    flex: 5,
                    child: Text('item'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black))),
                SizedBox(
                    width: 35,
                    child: Text('qty'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black),
                        textAlign: TextAlign.center)),
                Expanded(
                    flex: 2,
                    child: Text('price'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black),
                        textAlign: TextAlign.end)),
              ],
            ),
            const SizedBox(height: 4),
            _thinDivider(),
            const SizedBox(height: 4),

            // Items
            ...widget.orderDetails.map((detail) => _buildItemRow(detail)),

            const SizedBox(height: 8),
            _divider(),
            const SizedBox(height: 8),

            // Pricing
            _pricingRow('item_price'.tr, widget.itemsPrice),
            if (widget.addOns > 0)
              _pricingRow('addons'.tr, widget.addOns, prefix: '+'),
            _thinDivider(),
            const SizedBox(height: 4),
            _pricingRow('subtotal'.tr, widget.itemsPrice + widget.addOns,
                bold: true),
            if (widget.discount > 0)
              _pricingRow('discount'.tr, widget.discount,
                  prefix: '-', color: const Color(0xFF2ECC71)),
            if (widget.couponDiscount > 0)
              _pricingRow('coupon_discount'.tr, widget.couponDiscount,
                  prefix: '-', color: const Color(0xFF2ECC71)),
            if (!taxIncluded && widget.tax > 0)
              _pricingRow('vat_tax'.tr, widget.tax, prefix: '+'),
            if (widget.dmTips > 0)
              _pricingRow('delivery_man_tips'.tr, widget.dmTips, prefix: '+'),
            if (order.orderType != 'dine_in' &&
                order.orderType != 'take_away')
              _pricingRow('delivery_fee'.tr, widget.deliveryCharge,
                  prefix: widget.deliveryCharge > 0 ? '+' : ''),

            const SizedBox(height: 4),
            _divider(),
            const SizedBox(height: 6),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total_amount'.tr +
                      (taxIncluded ? ' (${'vat_tax_inc'.tr})' : ''),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  PriceConverter.convertPrice(widget.total),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),

            const SizedBox(height: 8),
            _thinDivider(),
            const SizedBox(height: 6),

            // Payment method
            Text(
                '${'payment_method'.tr}: ${order.paymentMethod?.replaceAll('_', ' ').tr ?? ''}',
                style:
                    const TextStyle(fontSize: 11, color: Colors.black54),
                textAlign: TextAlign.center),

            const SizedBox(height: 16),

            // Footer
            Text('شكراً لطلبك من منجود',
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('mnjood.sa',
                style:
                    const TextStyle(fontSize: 10, color: Colors.black38),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderDetailsModel detail) {
    final name = detail.foodDetails?.name ?? '';
    final qty = detail.quantity ?? 1;
    final price = (detail.price ?? 0) * qty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                  flex: 5,
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black))),
              SizedBox(
                  width: 35,
                  child: Text('x$qty',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black),
                      textAlign: TextAlign.center)),
              Expanded(
                  flex: 2,
                  child: Text(PriceConverter.convertPrice(price),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.ltr)),
            ],
          ),
        ),
        // Add-ons
        if (detail.addOns != null && detail.addOns!.isNotEmpty)
          ...detail.addOns!.map((addon) => Padding(
                padding: const EdgeInsets.only(right: 12, top: 1, bottom: 1),
                child: Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Text('  + ${addon.name ?? ''}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54))),
                    SizedBox(
                        width: 35,
                        child: Text('x${addon.quantity ?? 1}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 2,
                        child: Text(
                            PriceConverter.convertPrice(
                                (addon.price ?? 0) * (addon.quantity ?? 1)),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                            textAlign: TextAlign.end,
                            textDirection: TextDirection.ltr)),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _pricingRow(String label, double amount,
      {bool bold = false, String prefix = '', Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
          Text(
            '${prefix.isNotEmpty ? '$prefix ' : ''}${PriceConverter.convertPrice(amount)}',
            style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: Colors.black);
  Widget _thinDivider() =>
      Container(height: 0.5, color: Colors.grey.shade400);
}
