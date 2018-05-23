import 'dart:async';
import 'dart:convert';

import 'package:samex_app/utils/cache.dart';

import 'package:dio/dio.dart';

Dio _dio = new Dio();

class SamexApi {
  static const String BASE = '172.19.1.30:40001';
  static const String BASE_URL = 'http://$BASE/app/api';
  static Options _option;

  Options _options(){
    if(_option == null){
      _option = new Options();
    }

    _option.headers = {
      'Authorization': Cache.instance.token
    };
    _option.connectTimeout = 5000;
    _option.receiveTimeout = 3000;

    return _option;
  }

  String getImageUrl(String docinfoid){
    return 'http://$BASE/app/stepimage/$docinfoid';
  }

  Future<Map> login(String userName, String password) async {
    Response response =  await _dio.post(BASE_URL+'/login', data: json.encode({
      'username': userName,
      'password': password
    }));
    print('login: ${response.data}');
    return response.data;
  }

  Future<Map> user() async {
    Response response = await _dio.get(BASE_URL+'/user', options: _options());
    print('user: ${response.data}');

    return response.data;
  }

  Future<Map> orderList({String type='', int time = 0,  int count = 20,  int older = 0, String status = 'active' }) async {
    Uri uri = new Uri.http(BASE, '/app/api/order', {
      'worktype': type,
      'time': '$time',
      'count': '$count',
      'older':'$older',
      'status': status
    });
    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;

  }

  Future<Map> orderDetail(String orderId, [int time]) async {
    Uri uri = new Uri.http(BASE, '/app/api/order/$orderId', {
      'time': '${time?? '0'}',
    });

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> steps({String sopnum, String wonum, String site}) async {
    Uri uri = new Uri.http(BASE, '/app/api/orderstep', {
      'sopnum': sopnum,
      'wonum': wonum,
      'site': site
    });

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> historyXj(String sopnum) async {
    Uri uri = new Uri.http(BASE, '/app/api/ordernews/$sopnum');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }


}