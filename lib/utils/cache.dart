import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

const String KEY_TOKEN = "__token";
const String KEY_SITE = "__site";
const String KEY_USER_NAME = '__username';
const String KEY_FONT_SIZE = '__textfontsize';
const String KEY_USER_TITLE = '__usertitle';
const String KEY_USER_DISPLAY_NAME = '_userdisplayname';

class Cache {
  Cache._(this._prefs);

  static Cache instance;
  final SharedPreferences _prefs;
  Directory documentsDirectory;
  static Future<Cache> getInstance() async {
    if(instance == null){
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      instance = new Cache._(await prefs);
      instance.documentsDirectory = await getApplicationDocumentsDirectory();
    }

    return instance;
  }

  String getThumbPath(String thumbnail )  {
    var path = join(documentsDirectory.path, thumbnail);

    // make sure the folder exists
    if ( new Directory(dirname(path)).existsSync()) {
      try {
        new Directory(dirname(path)).createSync(recursive: true);
      } catch (e) {
        if (! new Directory(dirname(path)).existsSync()) {
          print(e);
        }
      }
    }
    return path;
  }

  String get token => _getString(KEY_TOKEN);
  String get site => _getString(KEY_SITE);
  String get userName => _getString(KEY_USER_NAME);
  String get userTitle => _getString(KEY_USER_TITLE);
  String get userDisplayName => _getString(KEY_USER_DISPLAY_NAME);
  double get textScaleFactor => _getDouble(KEY_FONT_SIZE);

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

