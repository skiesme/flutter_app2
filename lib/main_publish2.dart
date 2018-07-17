import 'package:samex_app/main.dart' as Main;

import 'package:samex_app/utils/api.dart';

void main() async {
  SaMexApi.ipAndPort = '172.19.1.63:40001';
  Main.main();
}