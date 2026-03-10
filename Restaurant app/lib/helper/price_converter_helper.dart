import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mnjood_vendor/features/splash/controllers/splash_controller.dart';
import 'package:mnjood_vendor/util/images.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:get/get.dart';

class PriceConverter {
  static String convertPrice(double? price, {double? discount, String? discountType, int? asFixed, bool isVariation = false}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount' && !isVariation) {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    final configModel = Get.find<SplashController>().configModel;
    bool isRightSide = configModel?.currencySymbolDirection == 'right';
    String currencySymbol = Get.locale?.languageCode == 'ar'
        ? (configModel?.currencySymbol ?? 'ر.س')
        : 'SAR';
    int decimalPoint = configModel?.digitAfterDecimalPoint ?? 2;
    return '${isRightSide ? '' : '$currencySymbol '}'
        '${(toFixed(price ?? 0)).toStringAsFixed(decimalPoint)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${isRightSide ? ' $currencySymbol' : ''}';
  }

  static double? convertWithDiscount(double? price, double? discount, String? discountType, {bool isVariation = false}) {
    if(discountType == 'amount' && !isVariation) {
      price = price! - discount!;
    }else if(discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(double amount, double? discount, String type, int quantity) {
    double calculatedAmount = 0;
    if(type == 'amount') {
      calculatedAmount = discount! * quantity;
    }else if(type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static Widget convertAnimationPrice(double? price, {double? discount, String? discountType, bool forDM = false, TextStyle? textStyle}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount') {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    final configModel = Get.find<SplashController>().configModel;
    bool isRightSide = configModel?.currencySymbolDirection == 'right';
    String currencySymbol = Get.locale?.languageCode == 'ar'
        ? (configModel?.currencySymbol ?? 'ر.س')
        : 'SAR';
    int decimalPoint = configModel?.digitAfterDecimalPoint ?? 2;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price ?? 0),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM ? 0 : decimalPoint,
        prefix: isRightSide ? '' : currencySymbol,
        suffix: isRightSide ? currencySymbol : '',
      ),
    );
  }

  static String percentageCalculation(String price, String discount, String discountType) {
    final configModel = Get.find<SplashController>().configModel;
    String currencySymbol = Get.locale?.languageCode == 'ar'
        ? (configModel?.currencySymbol ?? 'ر.س')
        : 'SAR';
    return '$discount${discountType == 'percent' ? '%' : currencySymbol} OFF';
  }

  static double toFixed(double val) {
    final configModel = Get.find<SplashController>().configModel;
    int decimalPoint = configModel?.digitAfterDecimalPoint ?? 2;
    num mod = power(10, decimalPoint);
    return (((val * mod).toPrecision(decimalPoint)).floor().toDouble() / mod);
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }

  /// Returns a Widget with price and SAR SVG symbol
  static Widget convertPriceWithSvg(
    double? price, {
    double? discount,
    String? discountType,
    bool forDM = false,
    bool isVariation = false,
    TextStyle? textStyle,
    double symbolSize = 14,
    Color? symbolColor,
    MainAxisAlignment alignment = MainAxisAlignment.start,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' && !isVariation) {
        price = (price ?? 0) - discount;
      } else if (discountType == 'percent') {
        price = (price ?? 0) - ((discount / 100) * (price ?? 0));
      }
    }

    final configModel = Get.find<SplashController>().configModel;
    int digitAfterDecimalPoint = configModel?.digitAfterDecimalPoint ?? 2;
    bool isRightSide = configModel?.currencySymbolDirection == 'right';

    String priceText = (toFixed(price ?? 0))
        .toStringAsFixed(forDM ? 0 : digitAfterDecimalPoint)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    final style = textStyle ?? robotoMedium;
    final color = symbolColor ?? style.color ?? Colors.black;

    Widget sarSymbol = SvgPicture.asset(
      Images.sarSymbol,
      height: symbolSize,
      width: symbolSize,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: isRightSide
          ? [
              Text(priceText, style: style),
              const SizedBox(width: 4),
              sarSymbol,
            ]
          : [
              sarSymbol,
              const SizedBox(width: 4),
              Text(priceText, style: style),
            ],
    );
  }

  /// Returns just the SAR SVG symbol widget
  static Widget sarSymbolWidget({
    double size = 14,
    Color color = Colors.black,
  }) {
    return SvgPicture.asset(
      Images.sarSymbol,
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Returns a WidgetSpan for use in RichText/TextSpan contexts
  static WidgetSpan convertPriceSpan(
    double? price, {
    double? discount,
    String? discountType,
    bool forDM = false,
    bool isVariation = false,
    TextStyle? textStyle,
    double symbolSize = 14,
    Color? symbolColor,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: convertPriceWithSvg(
        price,
        discount: discount,
        discountType: discountType,
        forDM: forDM,
        isVariation: isVariation,
        textStyle: textStyle,
        symbolSize: symbolSize,
        symbolColor: symbolColor,
      ),
    );
  }

  /// Returns discount tag with SVG symbol
  static Widget percentageCalculationWithSvg(
    String discount,
    String discountType, {
    TextStyle? textStyle,
    double symbolSize = 12,
    Color? symbolColor,
  }) {
    final style = textStyle ?? robotoMedium;
    final color = symbolColor ?? style.color ?? Colors.black;

    if (discountType == 'percent') {
      return Text('$discount% OFF', style: style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(discount, style: style),
        const SizedBox(width: 2),
        SvgPicture.asset(
          Images.sarSymbol,
          height: symbolSize,
          width: symbolSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        Text(' OFF', style: style),
      ],
    );
  }

  /// Returns animated price with SVG symbol
  static Widget convertAnimationPriceWithSvg(
    double? price, {
    double? discount,
    String? discountType,
    bool forDM = false,
    TextStyle? textStyle,
    double symbolSize = 14,
    Color? symbolColor,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = (price ?? 0) - discount;
      } else if (discountType == 'percent') {
        price = (price ?? 0) - ((discount / 100) * (price ?? 0));
      }
    }

    final configModel = Get.find<SplashController>().configModel;
    bool isRightSide = configModel?.currencySymbolDirection == 'right';
    int digitAfterDecimalPoint = configModel?.digitAfterDecimalPoint ?? 2;
    final style = textStyle ?? robotoMedium;
    final color = symbolColor ?? style.color ?? Colors.black;

    Widget sarSymbol = SvgPicture.asset(
      Images.sarSymbol,
      height: symbolSize,
      width: symbolSize,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

    Widget animatedNumber = AnimatedFlipCounter(
      duration: const Duration(milliseconds: 500),
      value: toFixed(price ?? 0),
      textStyle: style,
      fractionDigits: forDM ? 0 : digitAfterDecimalPoint,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isRightSide
            ? [animatedNumber, const SizedBox(width: 4), sarSymbol]
            : [sarSymbol, const SizedBox(width: 4), animatedNumber],
      ),
    );
  }

}