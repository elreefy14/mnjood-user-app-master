import 'package:flutter/material.dart';

class ColorConverter{
  static Color stringToColor(String? color){
    int value = 0xFFEF7822;
    if(color != null) {
      value = int.parse(color.replaceAll('#', '0xFF'));
    }
    return Color(value);
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFff9e1b);
      case 'processing':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'confirmed':
        return Colors.green;
      case 'handover':
        return Colors.green;
      case 'picked_up':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

}