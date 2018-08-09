import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/utils/api.dart';
import 'package:samex_app/model/user.dart';

SaMexApi getApi(BuildContext context){
  return RootModelWidget.of(context).model.api;
}

void setToken(BuildContext context, String token){
  RootModelWidget.of(context).model.token = token;
}

UserInfo getUserInfo(BuildContext context) {
  return RootModelWidget.of(context).model.user;
}

String getCountUrl(){
  return SaMexApi.baseUrl +'/user/count';
}

void setUserInfo(BuildContext context, UserInfo info){
  if(info == null) return;
  RootModelWidget.of(context).model.user = info;
}

RootModel getModel(BuildContext context){
  return RootModelWidget.of(context).model;
}

typedef  QueryListener(String value);

typedef  CallBackListener(bool show);

enum OrderType {
  ALL,            //全部
  PM,             //保养
  XJ,             //巡检
  CM,             //报修
}

OrderType getOrderType(String type){
  if(type == null) return OrderType.ALL;

  if(type.startsWith('XJ')) return OrderType.XJ;
  if(type.startsWith('PM')) return OrderType.PM;
  if(type.startsWith('CM')) return OrderType.CM;

  return OrderType.ALL;
}

const ChangeBool_Scroll = 'changevoid_scroll';

GlobListeners globalListeners = new GlobListeners();

class TimeCache<T> {
  int time =  DateTime.now().millisecondsSinceEpoch;
  T data;

  TimeCache({this.data});
}

Map<String, TimeCache> _memoryCache = new Map();

T getMemoryCache<T>(String key, {bool expired = false, VoidCallback callback}){
  if(key == null || key.length == 0 || !_memoryCache.containsKey(key)){
    if(callback != null){
      callback();
    }

    return null;
  }
  TimeCache<T> cache = _memoryCache[key];
  int diff = DateTime.now().millisecondsSinceEpoch - cache.time;
//  print('key=$key, time = $diff');
  if( diff > 10 * 60 * 1000){
    if(callback != null){
      callback();
    }

    if(expired){
      _memoryCache.remove(key);
      return null;
    }

  }

  return cache.data;
}

void setMemoryCache<T>(String key, T data){
  if(key == null || key.isEmpty) return;
  TimeCache<T> cache = new TimeCache<T>(data: data);
  _memoryCache[key] = cache;
}

void clearMemoryCacheWithKeys(String key){
  if(key == null || key.isEmpty) return;
  _memoryCache.forEach((String key2, TimeCache t) {
    if(key2.contains(key)){
      t.time = 0;
    }
  });
}

void clearMemoryCache(){
  _memoryCache.clear();
}

class GlobListeners {

  Map<String, Map<int, CallBackListener>> _listeners2 = new Map<String,
      Map<int, CallBackListener>>();

  Map<int, QueryListener> _listeners = new Map();

  void addListener(int key, QueryListener listener){
    _listeners[key] = listener;
  }

  void queryChanges(String query){
//    print('queryChanges... $query, ${_listeners.length}');
    try{
      _listeners.map((int key, QueryListener value) => value(query));
    } catch(e){

    }
  }

  void clearListeners(){
    _listeners.clear();
  }

  void removeListener(int key){
    _listeners.remove(key);
  }

  void boolChanges(String key, bool show) {
    try {
      _listeners2[key].map((int key, CallBackListener value) => value(show));
    } catch (e) {

    }
  }

  void addBoolListener(String key, int key2, CallBackListener listener) {
    if (_listeners2.containsKey(key)) {
      _listeners2[key][key2] = listener;
    } else {
      Map<int, CallBackListener> map = new Map();
      map[key2] = listener;
      _listeners2[key] = map;
    }
  }

  void removeBoolListener(String key) {
    if (_listeners2.containsKey(key)) {
      _listeners2[key].clear();
      _listeners2.remove(key);
    }
  }
}

class RootModel {
  RootModel({ this.token, this.onTextScaleChanged}) : this.api = new SaMexApi();

  String token;

  UserInfo user;

  final ValueChanged<double> onTextScaleChanged;

  final SaMexApi api;
}

class RootModelWidget extends InheritedWidget {

  final RootModel model;
  RootModelWidget({
    Key key,
    @required Widget child,
    @required this.model
  }) :
        assert(child != null),
        assert(model != null),
        super(key: key, child: child);

  static RootModelWidget of(BuildContext context){
    return context.inheritFromWidgetOfExactType(RootModelWidget);
  }

  @override
  bool updateShouldNotify(RootModelWidget oldWidget) {
    return oldWidget.model.token != model.token;
  }

}