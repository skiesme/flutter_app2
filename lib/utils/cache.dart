import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String KEY_TOKEN = "__token";
const String KEY_SITE = "__site";
const String KEY_USERNAME = '__username';
const String KEY_USERINFO = '__userinfo';
const String KEY_FONTSIZE = '__textfontsize';

class Cache {
  Cache._(this._prefs);

  static Cache instance;
  final SharedPreferences _prefs;

  static Future<Cache> getInstance() async {
    if(instance == null){
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      instance = new Cache._(await prefs);
    }

    return instance;
  }

  String get token => _getString(KEY_TOKEN);
  String get site => _getString(KEY_SITE);
  String get userName => _getString(KEY_USERNAME);
  String get userInfo => _getString(KEY_USERINFO);
  double get textScaleFactor => _getDouble(KEY_FONTSIZE);

  String _getString(String key){
    return  _prefs.getString(key)?? "";
  }

  bool _getBool(String key) {
    return _prefs.getBool(key)?? false;
  }

  int _getInt(String key) {
    return _prefs.getInt(key);
  }

  double _getDouble(String key){
    return _prefs.getDouble(key);
  }

  Future<bool> setStringValue(String key, String value) async {
    return _prefs.setString(key, value);
  }

  Future<bool> setBoolValue(String key, bool value) async => _prefs.setBool(key, value);

  Future<bool> setIntValue(String key, int value) async => _prefs.setInt(key, value);

  Future<bool> setDoubleValue(String key, double value) async => _prefs.setDouble(key, value);

  void remove(String key) {
    _prefs.remove(key);
  }
}

