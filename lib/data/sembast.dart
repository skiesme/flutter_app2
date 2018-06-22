import 'dart:io';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class SemBast {
  static Database _db;

  SemBast(){
   init();
  }

  void init() async {
    if(_db != null) return;

    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, 'key.db');

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

// We use the database factory to open the database
    _db = await ioDatabaseFactory.openDatabase(path);
  }

  get db => _db;

}