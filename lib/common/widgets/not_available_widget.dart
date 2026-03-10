import 'package:mnjood/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotAvailableWidget extends StatelessWidget {
  final double fontSize;
  final bool isRestaurant;
  final double opacity;
  final Color color;
  final bool isOutOfStock;
  const NotAvailableWidget({super.key, this.fontSize = 8, this.isRestaurant = false, this.opacity = 0.6, this.color = Colors.white, this.isOutOfStock = false});

  @override
  Widget build(BuildContext context) {
    // Determine the message to show
    String message;
    if (isRestaurant) {
      message = 'closed'.tr;
    } else if (isOutOfStock) {
      message = 'out_of_stock'.tr;
    } else {
      message = 'not_available_now'.tr;
    }

    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          message,
          style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
