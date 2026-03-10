import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerHelper{

  /// Creates a delivery driver marker from the scooter asset image
  static Future<BitmapDescriptor> create3DDriverMarker() async {
    try {
      return await convertAssetToBitmapDescriptor(
        imagePath: 'assets/image/driver_marker.png',
        width: 50,
        height: 50,
      );
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  /// Creates a custom marker from a Heroicon
  static Future<BitmapDescriptor> createHeroiconMarker({
    required IconData icon,
    required Color backgroundColor,
    Color iconColor = Colors.white,
    double size = 50,
  }) async {
    try {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw circle background
      final Paint paint = Paint()..color = backgroundColor;
      canvas.drawCircle(Offset(size/2, size/2), size/2, paint);

      // Draw white border
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(size/2, size/2), size/2 - 1.5, borderPaint);

      // Draw icon using TextPainter with icon font
      final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size * 0.5,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ));

      final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      } else {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  static Future<BitmapDescriptor> convertAssetToBitmapDescriptor({
    required final String imagePath,
    final int? width,
    final int? height,
  }) async {
    try {
      if(GetPlatform.isWeb) {
        return BitmapDescriptor.asset(const ImageConfiguration(devicePixelRatio: 2.5, size: Size(50, 50), ), imagePath);
      }
      final ByteData byteDataFromImage = await rootBundle.load(imagePath).timeout(const Duration(seconds: 8));
      final ui.Codec codec = await ui
          .instantiateImageCodec(byteDataFromImage.buffer.asUint8List(), targetHeight: height, targetWidth: width)
          .timeout(const Duration(seconds: 8));
      final ui.FrameInfo frameInfo = await codec.getNextFrame().timeout(const Duration(seconds: 8));
      final ByteData? byteDataFromFrame =
      await frameInfo.image.toByteData(format: ui.ImageByteFormat.png).timeout(const Duration(seconds: 8));
      if (byteDataFromFrame != null) {
        final Uint8List uint8List = byteDataFromFrame.buffer.asUint8List();
        return BitmapDescriptor.bytes(uint8List);
      } else {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      }
    } catch(_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }
}