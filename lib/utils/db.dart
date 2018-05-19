import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DB {

  static const String _db_name = 'sms.db';

  static Database _db;
  static DB _instance;

  static DB get instance => _instance;

  static Future<Null> getDB() async {
    if(_db == null){
      String path = await _initDeleteDb(_db_name);

      _db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            /// keyValue table
//            await db.execute('''
//create table ${KeyValueTable.name} (
//  ${KeyValueTable.id} integer primary key autoincrement,
//  ${KeyValueTable.key} text not null,
//  ${KeyValueTable.value} text not null)
//''');
//
//            /// commandValue table
//            await db.execute('''
//create table ${CommandValueTable.name} (
//  ${CommandValueTable.id} integer primary key autoincrement,
//  ${CommandValueTable.title} text not null,
//  ${CommandValueTable.content} text not null)
//''');
//            /// commandValue table
//            await db.execute('''
//create table ${CardValueTable.name} (
//  ${CardValueTable.id} integer primary key autoincrement,
//  ${CardValueTable.no} text not null,
//  ${CardValueTable.cdno} text not null)
//''');
          });

      _instance = new DB();
    }
  }

  static Future<String> _initDeleteDb(String dbName) async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, dbName);

    print(documentsDirectory);

    // make sure the folder exists
    if (!await new Directory(dirname(path)).exists()) {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        if (!await new Directory(dirname(path)).exists()) {
          print(e);
        }
      }
    }
    return path;
  }

  Future close() async => _db.close();
}