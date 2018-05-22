import 'package:flutter/material.dart';

import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';

class RecentHistory extends StatefulWidget {

  RecentHistory();

  @override
  _RecentHistoryState createState() => new _RecentHistoryState();
}

class _RecentHistoryState extends State<RecentHistory> {
  @override
  Widget build(BuildContext context) {
    return Text('历史记录');
  }
}
