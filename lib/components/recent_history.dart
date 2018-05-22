import 'package:flutter/material.dart';

import 'package:samex_app/utils/func.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/history.dart';

import 'package:after_layout/after_layout.dart';

class RecentHistory extends StatefulWidget {

  RecentHistory();

  @override
  _RecentHistoryState createState() => new _RecentHistoryState();
}

class _RecentHistoryState extends State<RecentHistory> with AfterLayoutMixin<RecentHistory> {
  OrderDetailData _data;
  @override
  Widget build(BuildContext context) {
    List<HistoryData> list = getModel(context).historyList;
    if(list == null || list.length == 0){
      _getHistory();
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: list.map((HistoryData f) => Text(f.toJson().toString())).toList(),
      );
    }
  }

  void _getHistory() async {

    _data = getModel(context).orderDetailData;
    OrderShortInfo info = getModel(context).order;


    if(_data != null && _data.sopnum.isNotEmpty){
      if(getOrderType(info.worktype) == OrderType.XJ){
        try {
          String response = await getApi(context).historyXj(_data.sopnum);
          HistoryResult result = new HistoryResult.fromJson(
              Func.decode(response));

          if(result.code != 0){
            Func.showMessage(result.message);
          } else {
            setState(() {
                getModel(context).historyList.clear();
               getModel(context).historyList.addAll(result.response);
            });
          }

        } catch (e){
          print (e);
          Func.showMessage('网络出现异常: 获取巡检历史失败');
        }
      }
    }


  }

  @override
  void afterFirstLayout(BuildContext context) {
    List<HistoryData> list = getModel(context).historyList;
    if(list == null || list.length == 0) {
      _getHistory();
    }
  }
}
