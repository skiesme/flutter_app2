import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/model/work_time.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/func.dart';

Dio _dio = new Dio();


class SaMexApi {
  static String ipAndPort = '192.168.60.12:40001';

//    static String ipAndPort = '172.19.1.30:40001';
//    static String ipAndPort = '192.168.50.152:40001';
  static String baseUrl = 'http://$ipAndPort/app/api';
  static Options _option;

  static Options _options({int connectTimeout = 6000, receiveTimeout = 3000, Map<String, dynamic> headers }){
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
    return 'http://$ipAndPort/static/stepimage/${Cache.instance.site}/$docinfoid';
  }

  Future<Map> login(String userName, String password) async {
    Response response =  await _dio.post(baseUrl+'/login', data: json.encode({
      'username': userName,
      'password': password
    }));
    print('login: ${response.data}');
    return response.data;
  }

  Future<Map> submit({String assigncode, int ownerid = 0, String notes = "", String actionid=""}) async{
    final data = json.encode({
      'assigncode': assigncode ??  Cache.instance.userName,
      'ownerid': ownerid,
      "notes": notes,
      "actionid": actionid
    });
    print('submit post: $data');

    Response response =  await _dio.post(baseUrl+'/workflow/submit', data: data, options: _options());
    print('submit: ${response.data}');
    return response.data;
  }

  Future<UserInfo> user([bool onlyCount = false]) async {

    UserInfo info;
    String url = baseUrl+'/user' +(onlyCount ? '/count':'');

    try {

      Response response = await _dio.get(url, options: _options());
      print('user: ${response.data}');

      UserResult result = new UserResult.fromJson(response.data);
      if(result.code != 0) {
        Func.showMessage(result.message);
      } else {
        info = result.response;
        if(!onlyCount){
          Cache.instance.setStringValue(KEY_SITE, info.defsite);
          Cache.instance.setStringValue(KEY_USER_TITLE, info.title);
          Cache.instance.setStringValue(KEY_USER_DISPLAY_NAME, info.displayname);
        }

        Cache.instance.setIntValue(KEY_ORDER_COUNT, info.orders);

      }
    } catch (e){
      print('$url :  $e');
      Func.showMessage('网络出现异常: 获取用户数据失败!');
    }

    return info;
  }


  static Future<int> getScheduleCount() async {
    UserInfo info;
    String url = baseUrl+'/user/count';

    try {

      Response response = await _dio.get(url, options: _options());
      print('user: ${response.data}');

      UserResult result = new UserResult.fromJson(response.data);
      if(result.code != 0) {
        print(result.message);
      } else {
        info = result.response;

      }
    } catch (e){
      print('$url :  $e');
//        Func.showMessage('网络出现异常: 获取用户数据失败!');
    }

    return info.orders;
  }

  Future<Map> userAll() async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/user/all');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }


  Future<int> orderCount() async {
    UserInfo info = await user(true);
    return info?.orders ?? 0;
  }

  Future<Map> orderList({
    String type='',           // 工单类型
    int time = 0,             // 末尾时间点
    int count = 20,           // 数量
    int older = 0,            // 前/后
    int start = 0,            // 开始时间点
    String query= '',         // 搜索内容(工单编号/资产编号)
    int all = 0,              // 0: 跟账号相关  1: 全部
    String status = 'active'  // 工单状态, '': 全部, 'active': 进行中, 'inactive':'完成'
  }) async {
    DateTime now = new DateTime.now();
    Uri uri = new Uri.http(ipAndPort, '/app/api/order', {
      'worktype': type,
      'time': '$time',
      'count': '$count',
      'older':'$older',
      'status': status,
      'start': '$start',
      'query': query,
      'all': '$all'
    });
    Response response = await _dio.get(uri.toString(), options: _options());

    print('time: ${new DateTime.now().millisecondsSinceEpoch - now.millisecondsSinceEpoch} - ${uri.toString()}: ${response.data}');

    return response.data;

  }

  Future<Map> orderDetail(String orderId, [int time]) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/order/$orderId', {
      'time': '${time?? '0'}',
    });

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> steps({String sopnum, String wonum, String site}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/orderstep', {
      'sopnum': sopnum,
      'wonum': wonum,
      'site': site
    });

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> historyXj(String sopnum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/ordernews/$sopnum');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> historyCM(String assetnum, {String location}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/ordercmnews/$assetnum', location == null ? null : {
      'location': location
    });

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> orderStatus(String wonum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/status/order/$wonum');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> postStep(OrderStep step, List<UploadFileInfo> files) async {
    Uri uri =  Uri.parse(baseUrl+ '/orderstep/upload');

    var request = new http.MultipartRequest("POST", uri);

    Map<String, dynamic> formData = step.toJson();

    print('${uri.toString()}: ${formData.toString()}, length=${files?.length}');

    request.fields.addAll(formData);

    request.headers .addAll( {
      'Authorization': Cache.instance.token
    });


    for(int i =0, len = files.length; i< len; i++){
      request.files.add( http.MultipartFile.fromBytes('files', await files[i].file.readAsBytes(), filename: files[i].fileName));
    }

    http.StreamedResponse response = await request.send();

    String result = await response.stream.bytesToString();

    print('${uri.toString()}: $result');

    return json.decode(result);
  }

  Future<Map> postAsset(String asset, List<UploadFileInfo> files) async{
    Uri uri =  Uri.parse(baseUrl+ '/asset/$asset');

    var request = new http.MultipartRequest("POST", uri);

    request.headers.addAll( {
      'Authorization': Cache.instance.token
    });


    for(int i =0, len = files.length; i< len; i++){
      request.files.add( http.MultipartFile.fromBytes('files', await files[i].file.readAsBytes(), filename: files[i].fileName));
    }

    http.StreamedResponse response = await request.send();

    String result = await response.stream.bytesToString();

    print('${uri.toString()}: $result');

    return json.decode(result);
  }


  Future<Map> postOrder({
    String worktype='CM',
    String description,
    String assetnum,
    String location,
    String reportedby,
    String images,
    List<UploadFileInfo> files}) async {
    Uri uri =  Uri.parse(baseUrl+ '/ordernew');

    var request = new http.MultipartRequest("POST", uri);

    Map<String, String> formData = {
      "worktype": worktype,
      "description": description,
      "assetnum":assetnum,
      "location":location,
      "reportedby": reportedby,
      "images": images,
    };

    print('${uri.toString()}: ${formData.toString()}, length=${files?.length}');

    request.fields.addAll(formData);

    request.headers.addAll( {
      'Authorization': Cache.instance.token
    });


    for(int i =0, len = files.length; i< len; i++){
      request.files.add( http.MultipartFile.fromBytes('files', await files[i].file.readAsBytes(), filename: files[i].fileName));
    }

    http.StreamedResponse response = await request.send();

    String result = await response.stream.bytesToString();

    print('${uri.toString()}: $result');

    return json.decode(result);
  }


  Future<Map> postXJ(String woNum) async {
    Response response =  await _dio.post(baseUrl+'/order/xj/$woNum', options: _options());
    print('postXJ: ${response.data}');
    return response.data;
  }

  Future<Map> getAssets({String location='', int count = 50, bool queryOne = false, String asset='' }) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/assetnums',{
      'location': location,
      'asset': asset,
      'queryOne':'${queryOne??''}',
      'count': '$count'
    });

    print(uri.toString());

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getLocations({String location='', int count = 50, bool queryOne}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/locations',{
      'location': location,
      'queryOne':'${queryOne??''}',
      'count': '$count'
    });

    print(uri.toString());

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getWorkTime(String wonum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/worktime/$wonum');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }


  Future<Map> getOrderMaterial(String wonum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/ordermaterial/$wonum');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }


  Future<Map> postWorkTime(WorkTimeData params) async {
    Response response =  await _dio.post(baseUrl+'/worktime',
        data: json.encode(params.toJson()), options: _options());
    print('postWorkTime: ${response.data}');
    return response.data;
  }

  Future<Map> delWorkTime(int id) async {
    Response response =  await _dio.delete(baseUrl+'/worktime/$id', options: _options());
    print('delWorkTime: ${response.data}');
    return response.data;
  }

  Future<Map> getCMAttachments(int id) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/cm/attactments/$id');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getMaterials() async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/material');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getAssetDetail(String asset) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/asset/$asset');

    Response response = await _dio.get(uri.toString(), options: _options());

    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

}