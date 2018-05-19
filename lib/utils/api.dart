import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

final http.Client _client = new http.Client();

class SamexApi {
  static const String BASE_URL = 'http://172.19.1.30:40001/app/api';

  Future<String> login(String userName, String password) async {
    var response =  await _client.post(BASE_URL+'/login', body: json.encode({
      'username': userName,
      'password': password
    }));
    print(response.body);
    return response.body;
  }



}