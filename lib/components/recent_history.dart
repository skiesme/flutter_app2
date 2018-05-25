import 'package:flutter/material.dart';

import 'package:samex_app/utils/func.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/history.dart';
import 'package:samex_app/components/simple_button.dart';

import 'package:after_layout/after_layout.dart';

class RecentHistory extends StatefulWidget {

  RecentHistory({@required this.data});

  final OrderDetailData data;


  @override
  _RecentHistoryState createState() => new _RecentHistoryState();
}

class _RecentHistoryState extends State<RecentHistory> with AfterLayoutMixin<RecentHistory> {
  @override
  Widget build(BuildContext context) {
    List<HistoryData> list = getModel(context).historyList;
    if(list.length == 0){
      _getHistory();
      return Center(child: CircularProgressIndicator());
    } else {
      List<Widget> children = <Widget>[];
      for(int i = 0, len = list.length; i < len; i++){
        HistoryData f = list[i];
        children.add(SimpleButton( child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
              children: <Widget>[
                Text('记录:'),
                Text(f.changby),
                Expanded( child: Text(Func.getFullTimeString(f.actfinish), textAlign: TextAlign.center,)),
                Text(f.error == null ? '正常' : '异常', style: TextStyle(color: Colors.redAccent),),
              ]
          ),
        ),
        onTap: f.error == null ? null : (){
          showDialog(
              context: context,
              builder: (BuildContext context) =>
              new SimpleDialog(
                title: Text('工单编号:${f.wonum}',style: TextStyle(fontSize: 18.0),),
                children: f.error.map(
                        (String str) => Padding( padding:EdgeInsets.all(4.0) , child:Text(str))
                ).toList(),));

        },));
        children.add(Divider(height: 1.0,));
      }
      return Column(
          children: children
      );
    }
  }

  void _getHistory() async {

    OrderDetailData data = widget.data;

    if(data != null && data.sopnum.isNotEmpty){
      if(getOrderType(data.worktype) == OrderType.XJ){
        try {
          Map response = await getApi(context).historyXj(data.sopnum);
          HistoryResult result = new HistoryResult.fromJson(response);

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
//    List<HistoryData> list = getModel(context).historyList;
//    if(list.length == 0) {
//      _getHistory();
//    }
  }
}
