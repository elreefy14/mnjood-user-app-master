import 'package:flutter/material.dart';

class MenuModel {
  IconData? iconData;
  String title;
  String route;
  bool isBlocked;
  bool isNotSubscribe;
  bool isLanguage;
  Color? iconColor;

  MenuModel({this.iconData, required this.title, required this.route, this.isBlocked = false, this.isNotSubscribe = false, this.isLanguage = false, this.iconColor});
}