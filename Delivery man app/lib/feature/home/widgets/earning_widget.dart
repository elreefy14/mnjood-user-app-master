import 'package:mnjood_delivery/helper/price_converter_helper.dart';
import 'package:mnjood_delivery/util/color_resources.dart';
import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class EarningWidget extends StatelessWidget {
  final String title;
  final double? amount;
  const EarningWidget({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [

      Text(
        title,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey.shade500),
      ),
      const SizedBox(height: 4),

      amount != null ? Text(
        PriceConverter.convertPrice(amount),
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey.shade800),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ) : Shimmer(
        duration: const Duration(seconds: 2),
        enabled: amount == null,
        color: Colors.grey[300]!,
        child: Container(height: 16, width: 40, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
      ),

    ]));
  }
}