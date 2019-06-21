import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;

import 'package:dio/dio.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/model/work_time.dart';
import 'package:samex_app/model/order_material.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/func.dart';
//import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';

Dio _dio = new Dio();

class SaMexApi {
  static final SaMexApi _instance = SaMexApi();
  static SaMexApi get singleton => _instance;

  // static const bool inProduction = true;
  static const bool inProduction =
      const bool.fromEnvironment("dart.vm.product");
  static String ipAndPort =
      inProduction ? '172.19.1.63:40001' : '172.19.1.30:40001';
  //  static String ipAndPort = '10.18.40.7:40001'; // 嘉兴测试

  static String baseUrl = 'http://$ipAndPort/app/api';
  static Options _option;

  static CancelToken token;

  static StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static Options _options(
      {int connectTimeout = 6000,
      receiveTimeout = 3000,
      Map<String, dynamic> headers,
      OnUploadProgress onProgress}) {
    if (_option == null) {
      _option = new Options();

      _connectivitySubscription = new Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        // Got a new connectivity status!

        print('onConnectivityChanged : $result');
        if (result == ConnectivityResult.none) {
          token?.cancel('网络断开');
        }
      });
    }

    if (headers == null) {
      _option.headers = {'Authorization': SamexInstance.singleton.token};
    } else {
      _option.headers = headers;
    }

    _option.connectTimeout = connectTimeout;
    _option.receiveTimeout = receiveTimeout;
    _option.onUploadProgress = onProgress;

    return _option;
  }

  String getImageUrl(String docinfoid) {
    return 'http://$ipAndPort/static/stepimage/${Cache.instance.site}/$docinfoid';
  }

  Future<Map> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String projectCode = packageInfo.buildNumber;

    String url = 'http://$ipAndPort/app/version/$projectCode';

    Response response = await _dio.get(url, options: _option);
//    print('$url: ${response.data}');
    return response.data;
  }

  Future<String> download(String url, OnDownloadProgress cb) async {
    Io.Directory cacheDir = await getTemporaryDirectory();

    if (!url.startsWith('http')) {
      url = 'http://$ipAndPort$url';
    }

//    print('$url: download');

    String save = cacheDir.path + '/release.apk';

    await _dio.download(url, save, onProgress: cb);

    return save;
  }

  Future<Map> getSites() async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/site/all');
//    print(uri.toString());
    Response response = await _dio.get(uri.toString(), options: _options());
//    print('${uri.toString()}: ${response.data}');
    return response.data;
  }

  Future<Map> changeSite(String siteID) async {
    Response response = await _dio.post(baseUrl + '/changedefsite',
        data: json.encode({
          'defsite': siteID,
        }),
        options: _options());
//    print('changedefsite:$baseUrl ${response.data}');
    return response.data;
  }

  Future<Map> login(String userName, String password) async {
    Response response = await _dio.post(baseUrl + '/login',
        data: json.encode({'username': userName, 'password': password}));
    print('login:$baseUrl ${response.data}');
    return response.data;
  }

  Future<Map> submit({
    String assigncode,
    int ownerid = 0,
    String notes = "",
    String actionid = "",
    String action = '',
    String site = '',
    String wonum = '',
    String woprof = '',
    String faultlev = '',
  }) async {
    final data = json.encode({
      'assigncode': assigncode ?? Cache.instance.userName,
      'ownerid': ownerid,
      "notes": notes,
      "actionid": actionid,
      "action": action,
      "site": site,
      "wonum": wonum,
      "woprof": woprof,
      "faultlev": faultlev,
    });
//    print('submit post: $data');

    Response response = await _dio.post(baseUrl + '/workflow/submit',
        data: data, options: _options());
//    print('submit: ${response.data}');
    return response.data;
  }

  Future<UserInfo> user([bool onlyCount = false]) async {
    UserInfo info;
    String url = baseUrl + '/user' + (onlyCount ? '/count' : '');

    try {
      Response response = await _dio.get(url, options: _options());
//      print('user: ${response.data}');

      UserResult result = new UserResult.fromJson(response.data);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        info = result.response;
        if (!onlyCount) {
          Cache.instance.setStringValue(KEY_SITE, info.defsite);
          Cache.instance.setStringValue(KEY_USER_TITLE, info.title);
          Cache.instance
              .setStringValue(KEY_USER_DISPLAY_NAME, info.displayname);
          Cache.instance.setStringValue(KEY_USER_PHONE, info.phone);
        }

        Cache.instance.setIntValue(KEY_ORDER_COUNT, info.orders);
      }
    } catch (e) {
//      print('$url :  $e');
      Func.showMessage('网络出现异常: 获取用户数据失败!');
    }

    return info;
  }

  static Future<int> getScheduleCount() async {
    UserInfo info;
    String url = baseUrl + '/user/count';

    try {
      Response response = await _dio.get(url, options: _options());
//      print('user: ${response.data}');

      UserResult result = new UserResult.fromJson(response.data);
      if (result.code != 0) {
//        print(result.message);
      } else {
        info = result.response;
      }
    } catch (e) {
//      print('$url :  $e');
//        Func.showMessage('网络出现异常: 获取用户数据失败!');
    }

    return info.orders;
  }

  Future<Map> userAll() async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/user/all');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<int> orderCount() async {
    UserInfo info = await user(true);
    return info?.orders ?? 0;
  }

  Future<Map> orderList(
      {String type = '', // 工单类型
      int time = 0, // 末尾时间点
      int count = 20, // 数量
      int older = 0, // 前/后l
      int start = 0, // 开始时间点
      String query = '', // 搜索内容(工单编号/资产编号)
      int all = 0, // 0: 跟账号相关  1: 全部
      int task = 0, // 1: 任务箱  0:工单箱
      String status = 'active' // 工单状态, '': 全部, 'active': 进行中, 'inactive':'完成'
      }) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/order', {
      'worktype': type,
      'time': '$time',
      'count': '$count',
      'older': '$older',
      'status': status,
      'start': '$start',
      'query': query,
      'task': '$task',
      'all': '$all'
    });
    Response response = await _dio.get(uri.toString(), options: _options());

//    print('time: ${new DateTime.now().millisecondsSinceEpoch - now.millisecondsSinceEpoch} - ${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> orderDetail(String orderId, [int time]) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/order/$orderId', {
      'time': '${time ?? '0'}',
    });

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> steps({String sopnum, String wonum, String site}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/orderstep',
        {'sopnum': sopnum, 'wonum': wonum, 'site': site});

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> historyXj(String sopnum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/ordernews/$sopnum');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> historyCM(String assetnum, {String location}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/ordercmnews/$assetnum',
        location == null ? null : {'location': location});

    Response response = await _dio.get(uri.toString(), options: _options());
//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> orderStatus(String wonum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/status/order/$wonum');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> postStep(OrderStep step, List<UploadFileInfo> files,
      {OnUploadProgress onProgress}) async {
    Uri uri = Uri.parse(baseUrl + '/orderstep/upload');

    Map<String, dynamic> jsonData = step.toJson();
    jsonData["files"] = files;

    FormData formData = new FormData.from(jsonData);
    Response response = await _dio.post(uri.toString(),
        data: formData,
        options: _options(
            connectTimeout: 60000,
            receiveTimeout: 60000,
            onProgress: onProgress),
        cancelToken: token = new CancelToken());
//    print('${uri.toString()}: ${response.data}');
    return response.data;
  }

  Future<Map> postAsset(String asset, List<UploadFileInfo> files,
      {OnUploadProgress onProgress}) async {
    Uri uri = Uri.parse(baseUrl + '/asset/$asset');

    FormData formData = new FormData.from({"files": files});

    Response response = await _dio.post(uri.toString(),
        data: formData,
        options: _options(
            connectTimeout: 60000,
            receiveTimeout: 60000,
            onProgress: onProgress),
        cancelToken: token = new CancelToken());
//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> postOrder(
      {String worktype = 'CM',
      String description,
      String assetnum,
      String location,
      String reportedby,
      String images,
      String phone,
      String woprof, // 故障分类
      String faultlev, // 故障等级
      List<UploadFileInfo> files,
      OnUploadProgress onProgress}) async {
    Uri uri = Uri.parse(baseUrl + '/ordernew');

    Map<String, dynamic> jsonData = {
      "worktype": worktype,
      "description": description,
      "assetnum": assetnum,
      "location": location,
      "reportedby": reportedby,
      "images": images,
      "phone": phone,
      "files": files,
      "woprof": woprof,
      "faultlev": faultlev,
    };

//    print('${uri.toString()}: ${jsonData.toString()}, length=${files?.length}');

    FormData formData = new FormData.from(jsonData);

    Response response = await _dio.post(uri.toString(),
        data: formData,
        options: _options(
            connectTimeout: 60000,
            receiveTimeout: 60000,
            onProgress: onProgress),
        cancelToken: token = new CancelToken());
//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> postOrderUpdate(OrderDetailData params) async {
    Response response = await _dio.post(baseUrl + '/orderupdate',
        data: json.encode(params.toJson()), options: _options());
    // print('postWorkTime: ${response.data}');
    return response.data;
  }

  Future<Map> postXJ(String woNum) async {
    Response response =
        await _dio.post(baseUrl + '/order/xj/$woNum', options: _options());
//    print('postXJ: ${response.data}');
    return response.data;
  }

  Future<Map> getAssets(
      {String location = '',
      int count = 50,
      bool queryOne = false,
      String asset = ''}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/assetnums', {
      'location': location,
      'asset': asset,
      'queryOne': '${queryOne ?? ''}',
      'count': '$count'
    });

//    print(uri.toString());

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getLocations(
      {String location = '', int count = 50, bool queryOne}) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/locations', {
      'location': location,
      'queryOne': '${queryOne ?? ''}',
      'count': '$count'
    });

//    print(uri.toString());

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getWorkTime(String wonum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/worktime/$wonum');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getOrderMaterial(String wonum) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/ordermaterial/$wonum');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> postOrderMaterial(OrderMaterialData params) async {
    Response response = await _dio.post(baseUrl + '/ordermaterial',
        data: json.encode(params.toJson()), options: _options());
//    print('postOrderMaterial: ${response.data}');
    return response.data;
  }

  Future<Map> delOrderMaterial(int id) async {
    Response response =
        await _dio.delete(baseUrl + '/ordermaterial/$id', options: _options());
//    print('delOrderMaterial: ${response.data}');
    return response.data;
  }

  Future<Map> postWorkTime(WorkTimeData params) async {
    Response response = await _dio.post(baseUrl + '/worktime',
        data: json.encode(params.toJson()), options: _options());
//    print('postWorkTime: ${response.data}');
    return response.data;
  }

  Future<Map> delWorkTime(int id) async {
    Response response =
        await _dio.delete(baseUrl + '/worktime/$id', options: _options());
//    print('delWorkTime: ${response.data}');
    return response.data;
  }

  Future<Map> getCMAttachments(int id) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/cm/attactments/$id');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getMaterials() async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/material');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }

  Future<Map> getAssetDetail(String asset) async {
    Uri uri = new Uri.http(ipAndPort, '/app/api/asset/$asset');

    Response response = await _dio.get(uri.toString(), options: _options());

//    print('${uri.toString()}: ${response.data}');

    return response.data;
  }
}
