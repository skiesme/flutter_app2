import 'package:flutter/material.dart';

class Style {
  static get primaryColor => Colors.blue.shade600;

  static TextStyle textStyleNormal = TextStyle(color: Colors.grey);
  static TextStyle textStyleSelect = TextStyle(color: Style.primaryColor);

  static const double padding = 16.0;

  static Color backgroundColor = const Color(0xFFF0F0F0);

  static const pagePadding = const EdgeInsets.symmetric(horizontal: padding, vertical: padding/2);
  static const pagePadding2 = const EdgeInsets.symmetric(horizontal: padding, vertical: padding/4);

  static const separateHeight = 8.0;

}