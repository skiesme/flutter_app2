import 'package:flutter/material.dart';

class Style {
  static get primaryColor => Colors.blue.shade600;

  static TextStyle textStyleNormal = TextStyle(color: Colors.grey);
  static TextStyle textStyleSelect = TextStyle(color: Style.primaryColor);

  static const double padding = 16.0;

  static Color backgroundColor = const Color(0xFFF0F0F0);

  static const pagePadding =
      const EdgeInsets.symmetric(horizontal: padding, vertical: padding);
  static const pagePadding2 =
      const EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2);
  static const pagePadding4 =
      const EdgeInsets.symmetric(horizontal: padding, vertical: padding / 4);

  static const separateHeight = 8.0;

  static TextStyle getStatusStyle(String _status) {
    if (_status.contains('正常')) {
      return TextStyle(color: Colors.green);
    }

    if (_status.contains('待用')) {
      return TextStyle(color: Colors.orange);
    }

    if (_status.contains('挂牌')) {
      return TextStyle(color: Colors.indigoAccent);
    }

    if (_status.contains('未处理')) {
      return TextStyle(color: Colors.grey);
    }

    return TextStyle(color: Colors.redAccent);
  }

  static Color assetStatusColor(String status) {
    Color avatarColor = Colors.blue.shade600;
    status = status ?? '';
    if (status == '停用' || status == 'DECOMMISSIONED') {
      avatarColor = Colors.grey.shade400;
    } else if (status == 'OPERATING') {
      // 正常
      avatarColor = Colors.green.shade400;
    }
    return avatarColor;
  }
}
