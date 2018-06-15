import 'package:flutter/material.dart';

import 'package:samex_app/utils/func.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/history.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/model/cm_history.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/page/task_detail_page.dart';
import 'package:samex_app/model/order_status.dart';
import 'package:samex_app/utils/style.dart';

import 'package:after_layout/after_layout.dart';

class RecentHistory extends StatefulWidget {

  RecentHistory({@required this.data});

  final OrderDetailData data;


  @override
  _RecentHistoryState createState() => new _RecentHistoryState();
}

class _RecentHistoryState extends State<RecentHistory> with AfterLayoutMixin<RecentHistory> {

  bool _first = true;

  OrderType getType() {
    return  getOrderType(widget.data?.worktype??'');
  }

  List<Widget> getXJHistoryWidget() {
    List<Widget> children = <Widget>[];
    List<HistoryData> _historyList = getMemoryCache<List<HistoryData>>(cacheKey, expired: false);
    for (int i = 0, len = _historyList.length; i < len; i++) {
      HistoryData f = _historyList[i];
      children.add(SimpleButton(child: new Padding(
        padding: Style.pagePadding,
        child: Row(
            children: <Widget>[
              Text('记录:'),
              Text(f.changby),
              Expanded(child: Text(Func.getFullTimeString(f.actfinish),
                textAlign: TextAlign.center,)),
              Text(f.error == null ? '正常' : '异常',
                style: TextStyle(color: Colors.redAccent),),
            ]
        ),
      ),
        onTap: f.error == null ? null : () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
              new SimpleDialog(
                title: Text(
                  '工单编号:${f.wonum}', style: TextStyle(fontSize: 18.0),),
                children: f.error.map(
                        (String str) =>
                        Padding(padding: EdgeInsets.all(4.0), child: Text(str))
                ).toList(),));
        },));
      children.add(Divider(height: 1.0,));
    }
    return children;

  }

  List<Widget> getCMHistoryWidget(){
    List<CMHistoryData> _cmHistoryList = getMemoryCache<List<CMHistoryData>>(cacheKey, expired: false);
//    print('getCMHistoryWidget, length=${_cmHistoryList.length}');

    List<Widget> children = <Widget>[];
    for (int i = 0, len = _cmHistoryList.length; i < len; i++) {
      CMHistoryData f = _cmHistoryList[i];
      children.add(SimpleButton(
        child: new Padding(
          padding: Style.pagePadding,
          child: Row(
              children: <Widget>[
                Text('记录:'),
                Text(f.lead),
                Expanded(child: Text(Func.getFullTimeString(f.actfinish),
                  textAlign: TextAlign.center,)),
                Text(f.status),
              ]
          ),
        ),
        onDoubleTap: (){
          OrderShortInfo info = new OrderShortInfo(wonum: f.wonum, worktype: "CM");
          Navigator.push(context, new MaterialPageRoute(
              builder: (_) => new TaskDetailPage(info: info)));

        },
      ));
      children.add(Divider(height: 1.0,));
    }
    return children;
  }

  List<Widget> getOrderStatusWidget() {
    List<OrderStatusData> list = getMemoryCache<List<OrderStatusData>>(cacheKey, expired: false);

    List<Widget> children = <Widget>[];

    for (int i = 0, len = list.length; i < len; i++) {
      OrderStatusData f = list[i];
      children.add(SimpleButton(
        padding: Style.pagePadding,
        child: ListTile(
              title: Text('操作人: ${f.changeby}', style: TextStyle(fontSize: 16.0),),
              subtitle: Text('时间: '+Func.getFullTimeString(f.statusdate)),
              trailing: Text(f.status),
            ),
          ),
      );
      children.add(Divider(height: 1.0,));
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
//    print('cacheKey:$cacheKey, data:${widget.data.toJson()}');

    var data = getMemoryCache(cacheKey, callback: (){
      _getHistory();
    });
    if(data == null){
//      if(_first) _getHistory();
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: _first ? CircularProgressIndicator() : Text('没有发现历史记录')),
      ) ;

    }

    List<Widget> children ;
    switch( getType()){
      case OrderType.XJ:
        children = getXJHistoryWidget();
        break;
      case OrderType.CM:
        if(widget.data.actfinish == 0){
          children = getCMHistoryWidget();
        } else {
          children = getOrderStatusWidget();
        }
        break;
      case OrderType.PM:
        children = getCMHistoryWidget();
        break;
      default:
        break;
    }

    if(children.length == 0){
      return Center(child: Text('没有发现历史记录'));
    }

    return Column(
        children: children
    );

  }

  void _getHistory() async {

    OrderDetailData data = widget.data;

    try {
      if(data != null){
        OrderType type =  getType() ;
        if(type == OrderType.XJ &&  data.sopnum != null && data.sopnum.length > 0){
          Map response = await getApi(context).historyXj(data.sopnum);
          HistoryResult result = new HistoryResult.fromJson(response);
          if(result.code != 0){
            Func.showMessage(result.message);
          } else {
            setMemoryCache<List<HistoryData>>(cacheKey, result.response);
          }
        } else if(type == OrderType.CM){
          if(data.actfinish != 0) {
            Map response = await getApi(context).orderStatus(data.wonum);
            OrderStatusResult result = new OrderStatusResult.fromJson(response);

            if (result.code != 0) {
              Func.showMessage(result.message);
            } else {
              setMemoryCache<List<OrderStatusData>>(cacheKey, result.response);
            }
          } else {
            if( data.assetnum != null && data.assetnum.length > 0) {
              Map response = await getApi(context).historyCM(data.assetnum);
              CMHistoryResult result = new CMHistoryResult.fromJson(response);

              if (result.code != 0) {
                Func.showMessage(result.message);
              } else {
                setMemoryCache<List<CMHistoryData>>(cacheKey, result.response);
              }
            }
          }
        }

      } else {

      }
      if(mounted){
        setState(() {

        });
      }
    } catch (e){
      print (e);
      Func.showMessage('网络出现异常: 获取巡检历史失败');
    }


  }

  String  get cacheKey {
    OrderType type = getType();
    if(type == OrderType.XJ){
      return 'history_xj_${widget.data.wonum}_${widget.data.sopnum}';
    } else if(type == OrderType.CM){
      if(widget.data.actfinish != 0){
        return 'history_cm2_${widget.data.wonum}';
      }
      return 'history_cm_${widget.data.wonum}_${widget.data.assetnum}';
    }

    return '';
  }

  @override
  void didUpdateWidget(RecentHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterFirstLayout(BuildContext context) {
//    _getHistory();
    _first = false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
