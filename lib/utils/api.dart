import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:samex_app/utils/cache.dart';

final _client = new http.Client();

class SamexApi {
  static const String BASE = '172.19.1.30:40001';
  static const String BASE_URL = 'http://$BASE/app/api';

  Future<String> login(String userName, String password) async {
    var response =  await _client.post(BASE_URL+'/login', body: json.encode({
      'username': userName,
      'password': password
    }));
    print('login: ${response.body}');
    return response.body;
  }

  Future<String> user() async {
    var response = await _client.get(BASE_URL+'/user', headers: {
        'Authorization': Cache.instance.token
    });
    print('user: ${response.body}');

    return response.body;
  }

  Future<String> orderList({String type='', int time = 0,  int count = 20,  int older = 0, String status = 'active' }) async {
    Uri uri = new Uri.http(BASE, '/app/api/order', {
      'worktype': type,
      'time': '$time',
      'count': '$count',
      'older':'$older',
      'status': status
    });
    var response = await _client.get(uri.toString(), headers: {
      'Authorization': Cache.instance.token
    });

    print('${uri.toString()}: ${response.body}');

    return response.body;

  }

  Future<String> orderDetail(String orderId, [int time]) async {
    Uri uri = new Uri.http(BASE, '/app/api/order/$orderId', {
      'time': '${time?? '0'}',
    });

    var response = await _client.get(uri.toString(), headers: {
      'Authorization': Cache.instance.token
    });

    print('${uri.toString()}: ${response.body}');

    return response.body;
  }


}