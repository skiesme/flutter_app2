import 'package:flutter/material.dart';

class Style {
  static get primaryColor => Colors.blue.shade600;

  static TextStyle textStyleNormal = TextStyle(color: Colors.grey);
  static TextStyle textStyleSelect = TextStyle(color: Style.primaryColor);

  static double padding = 16.0;

  static Color backgroundColor = const Color(0xFFF0F0F0);

}