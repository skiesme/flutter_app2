import 'package:samex_app/main.dart' as Main;

import 'package:samex_app/utils/api.dart';

void main() async {
  SamexApi.ipAndPort = '172.19.1.30:40001';
  Main.main();
}