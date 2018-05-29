import 'dart:async';
import 'dart:convert';

import 'package:samex_app/utils/cache.dart';

import 'package:dio/dio.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/model/user.dart';


Dio _dio = new Dio();

class SamexApi {
    static const String BASE = '192.168.60.18:40001';

//  static const String BASE = '172.19.1.30:40001';
//  static const String BASE = '192.168.50.162:40001';
  static const String BASE_URL = 'http://$BASE/app/api';
  static Options _option;

  Options _options({int connectTimeout = 6000, receiveTimeout = 3000, Map<String, dynamic> headers }){
    if(_option == null){
      _option = new Options();
    }

    if(headers == null){
      _option.headers = {
        'Authorization': Cache.instance.token
      };
    } else {
      _option.headers = headers;
    }

    _option.connectTimeout = connectTimeout;
    _option.receiveTimeout = receiveTimeout;


    return _option;
  }

  String getImageUrl(String docinfoid){
    return 'http://$BASE/static/stepimage/${Cache.instance.site}/$docinfoid';
  }

  Future<Map> login(String userName, String password) async {
    Response response =  await _dio.post(BASE_URL+'/login', data: json.encode({
      'username': userName,
      'password': password
    }));
    print('login: ${response.data}');
    return response.data;
  }

  Future<UserInfo> user([bool onlyCount = false]) async {

    UserInfo info;

    try {

      String url = BASE_URL+'/user' +(onlyCount ? '/count':'');

      Response response = await _dio.get(url, options: _options());
      print('user: ${response.data}');

      UserResult result = new UserResult.fromJson(response.data);
      if(result.code != 0) {
        Func.showMessage(result.message);
      } else {
        info = result.response;
        if(!onlyCount){
          Cache.instance.setStringValue(KEY_SITE, info.defsite);
        }
      }
    } catch (e){
      print(e);
      Func.showMessage('网络出现异常: 获取用户数据失败!');
    }


    return info;
  }

  Future<int> orderCount() async {
    UserInfo info = await user(true);
    return info?.orders ?? 0;
  }

  Future<Map> orderList({String type='', int time = 0,  int count = 20,  int older = 0, String status = 'active' }) async {
    DateTime now = new DateTime.now();
    Uri uri = new Uri.http(BASE, '/app/api/order', {
      'worktype': type,
      'time': '$time',
      'count': '$count',
      'older':'$older',
      'status': status
    });
    Response response = await _dio.get(uri.toString(), options: _options());

    print('time: ${new DateTime.now().millisecondsSinceEpoch - now.millisecondsSinceEpoch} - ${uri.toString()}: ${response.data}');

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

  Future<Map> postStep(OrderStep step) async {
    Uri uri = new Uri.http(BASE, '/app/api/orderstep/upload');

    FormData formData = new FormData.from(step.toJson());
    List<UploadFileInfo> list = await step.getUploadImage();

    formData['site'] = Cache.instance.site;

    for(int i =0, len = list.length; i< len; i++){
      formData['file${i+1}'] = list[i];
    }

    print('${uri.toString()}: ${formData.toString()}');


    Response response = await _dio.post(uri.toString(), data: formData, options: new Options( headers: {
      'Authorization': Cache.instance.token
    }));

    print('${uri.toString()}: ${response.data}');

    return response.data;

  }

  Future<Map> postXJ(String woNum) async {
    Response response =  await _dio.post(BASE_URL+'/order/xj/$woNum', options: _options());
    print('postXJ: ${response.data}');
    return response.data;
  }


}