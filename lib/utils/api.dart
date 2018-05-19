import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:samex_app/utils/cache.dart';

final http.Client _client = new http.Client();

class SamexApi {
  static const String BASE_URL = 'http://172.19.1.30:40001/app/api';

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



}