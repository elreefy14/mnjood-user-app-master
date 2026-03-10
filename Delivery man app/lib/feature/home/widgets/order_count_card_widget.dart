import 'package:mnjood_delivery/util/dimensions.dart';
import 'package:mnjood_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderCountCardWidget extends StatelessWidget {
  final String title;
  final String? value;
  const OrderCountCardWidget({super.key, required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [

          value != null ? Text(
            value!, style: robotoBold.copyWith(fontSize: 22, color: Colors.grey.shade800), textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ) : Shimmer(
            duration: const Duration(seconds: 2),
            color: Colors.orange.shade100,
            child: Container(height: 20, width: 20, decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4))),
          ),
          const SizedBox(height: 4),

          Text(
            title,
            style: robotoRegular.copyWith(color: Colors.grey.shade600, fontSize: Dimensions.fontSizeExtraSmall),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

        ]),
      ),
    );
  }
}
