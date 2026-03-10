import 'dart:async';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:mnjood_vendor/common/widgets/custom_button_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_snackbar_widget.dart';
import 'package:mnjood_vendor/features/language/controllers/localization_controller.dart';
import 'package:mnjood_vendor/features/order/controllers/order_controller.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_details_model.dart';
import 'package:mnjood_vendor/features/order/domain/models/order_model.dart';
import 'package:mnjood_vendor/features/order/widgets/invoice_dialog_widget.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class InVoicePrintScreen extends StatefulWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  const InVoicePrintScreen({super.key, required this.order, required this.orderDetails});

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {

  // Printer mode
  bool _isSunmi = false;
  bool _sunmiChecked = false;

  // Bluetooth state
  bool connected = false;
  List<BluetoothInfo>? availableBluetoothDevices;
  bool _isLoading = false;
  String? _warningMessage;

  // Shared state
  final List<int> _paperSizeList = [80, 58];
  int _selectedSize = 80;
  ScreenshotController screenshotController = ScreenshotController();
  bool _printLoading = false;

  @override
  void initState() {
    super.initState();
    _detectPrinter();
  }

  Future<void> _detectPrinter() async {
    setState(() => _isLoading = true);

    // Try Sunmi first
    try {
      final status = await SunmiConfig.getStatus();
      if (status != null) {
        _isSunmi = true;
        connected = true;
      }
    } catch (_) {
      _isSunmi = false;
    }
    _sunmiChecked = true;

    // If not Sunmi, scan Bluetooth
    if (!_isSunmi) {
      await _scanBluetooth();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _scanBluetooth() async {
    final List<BluetoothInfo> bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (kDebugMode) {
      print("Bluetooth list: $bluetoothDevices");
    }
    connected = await PrintBluetoothThermal.connectionStatus;

    if (!connected) {
      _warningMessage = null;
      Get.find<OrderController>().setBluetoothMacAddress('');
    } else {
      _warningMessage = 'please_enable_your_location_and_bluetooth_in_your_system'.tr;
    }

    if (mounted) {
      setState(() {
        availableBluetoothDevices = bluetoothDevices;
      });
    }
  }

  Future<void> getBluetooth() async {
    setState(() => _isLoading = true);
    await _scanBluetooth();
    setState(() => _isLoading = false);
  }

  Future<void> setConnect(String mac) async {
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      setState(() {
        connected = true;
      });
    }
  }

  // --- Print methods ---

  Future<void> _printViaSunmi(Uint8List screenshot) async {
    try {
      // Resize for thermal paper width
      final img.Image? image = img.decodeImage(screenshot);
      if (image == null) {
        showCustomSnackBar('print_failed'.tr);
        return;
      }
      final int targetWidth = _selectedSize == 80 ? 500 : 365;
      final img.Image resized = img.copyResize(image, width: targetWidth);
      final Uint8List pngBytes = Uint8List.fromList(img.encodePng(resized));

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
    }
  }

  Future<void> _printViaBluetooth(Uint8List screenshot) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await _buildBluetoothTicket(screenshot);
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      if (kDebugMode) {
        print("print result: $result");
      }
    } else {
      showCustomSnackBar('no_thermal_printer_connected'.tr);
    }
  }

  Future<List<int>> _buildBluetoothTicket(Uint8List screenshot) async {
    List<int> bytes = [];
    final img.Image? image = img.decodeImage(screenshot);
    img.Image resized = img.copyResize(image!, width: _selectedSize == 80 ? 500 : 365);
    final profile = await CapabilityProfile.load();
    final generator = Generator(_selectedSize == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);

    bytes += generator.image(resized);
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<void> _doPrint() async {
    setState(() => _printLoading = true);

    try {
      final Uint8List? capturedImage = await screenshotController.capture(delay: const Duration(milliseconds: 10));
      if (capturedImage == null) {
        showCustomSnackBar('print_failed'.tr);
        return;
      }

      if (_isSunmi) {
        await _printViaSunmi(capturedImage);
      } else {
        await _printViaBluetooth(capturedImage);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showCustomSnackBar('${'print_failed'.tr}: $e');
    } finally {
      if (mounted) setState(() => _printLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // --- Printer header ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Left: printer info
              Expanded(child: Row(children: [
                if (_isSunmi) ...[
                  Icon(Icons.print, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Flexible(child: Text('sunmi_printer_ready'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.green))),
                ] else ...[
                  Text('paired_bluetooth'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  SizedBox(height: 20, width: 20,
                    child: _isLoading ? CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ) : InkWell(
                      onTap: () => getBluetooth(),
                      child: Icon(HeroiconsOutline.arrowPath, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ])),

              // Right: paper size dropdown
              SizedBox(width: 100, child: DropdownButton<int>(
                hint: Text('select'.tr),
                value: _selectedSize,
                items: _paperSizeList.map((int? value) {
                  return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value''mm'));
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSize = value!;
                  });
                },
                isExpanded: true, underline: const SizedBox(),
              )),

            ],
          ),
        ),

        // --- Content ---
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [

              // Bluetooth device list (only when NOT Sunmi)
              if (!_isSunmi && _sunmiChecked) ...[
                availableBluetoothDevices != null && (availableBluetoothDevices?.length ?? 0) > 0 ? ListView.builder(
                  itemCount: availableBluetoothDevices?.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GetBuilder<OrderController>(
                      builder: (orderController) {
                        bool isConnected = connected && availableBluetoothDevices![index].macAdress == orderController.getBluetoothMacAddress();

                        return Stack(children: [

                          ListTile(
                            selected: isConnected,
                            onTap: () {
                              if (availableBluetoothDevices?[index].macAdress.isNotEmpty ?? false) {
                                if (!connected) {
                                  orderController.setBluetoothMacAddress(availableBluetoothDevices?[index].macAdress);
                                }
                                setConnect(availableBluetoothDevices?[index].macAdress ?? '');
                              }
                            },
                            title: Text(availableBluetoothDevices?[index].name ?? ''),
                            subtitle: Text(
                              isConnected ? 'connected'.tr : "click_to_connect".tr,
                              style: robotoRegular.copyWith(color: isConnected ? null : Theme.of(context).primaryColor),
                            ),
                          ),

                          if (availableBluetoothDevices?[index].macAdress == orderController.getBluetoothMacAddress())
                            Positioned.fill(
                              child: Align(alignment: Get.find<LocalizationController>().isLtr ? Alignment.centerRight : Alignment.centerLeft, child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                  horizontal: Dimensions.paddingSizeLarge,
                                ),
                                child: Icon(HeroiconsOutline.checkCircle, color: Theme.of(context).primaryColor),
                              )),
                            ),
                        ]);
                      },
                    );
                  },
                ) : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Text(
                    _warningMessage ?? '',
                    style: robotoRegular.copyWith(color: Colors.redAccent),
                  ),
                ),
              ],

              // Invoice preview
              InvoiceDialogWidget(
                order: widget.order, orderDetails: widget.orderDetails,
                screenshotController: screenshotController,
              ),
            ]),
          ),
        ),

        // --- Print button ---
        CustomButtonWidget(
          buttonText: _printLoading ? 'printing'.tr : 'print_invoice'.tr, height: 40,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          onPressed: _printLoading ? null : _doPrint,
        ),

      ],
    );
  }
}
