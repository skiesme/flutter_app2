import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'dart:io';


class Alarm {

  static const MethodChannel _channel =
  const MethodChannel('com.hdkj.samex/alarm_service');

  static Future<Null> start ({
    @required String token,
    @required int workers,
    @required String url,
    int interval = 3,
  }) async {

    final Map<String, dynamic> params = <String, dynamic> {
      'token': token,
      'workers': workers,
      'url': url,
      'interval' : interval
    };

    if(Platform.isIOS) return;


    await _channel?.invokeMethod('start', params);
  }

  static Future<Null> stop () async {

    final Map<String, dynamic> params = <String, dynamic> {};

    if(Platform.isIOS) return;
    await _channel?.invokeMethod('stop', params);
  }

}