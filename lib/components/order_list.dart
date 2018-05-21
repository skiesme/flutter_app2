import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/page/task_detail.dart';
import 'package:samex_app/components/simple_button.dart';

import 'package:after_layout/after_layout.dart';

const double _padding = 16.0;
const TextStyle _status_style = TextStyle(color: Colors.red);

class OrderList extends StatefulWidget {

  final PageHelper<OrderShortInfo> helper;
  final OrderType type;

  OrderList({Key key, @required this.helper, this.type = OrderType.ALL}) :super(key:key);
  @override
  _OrderListState createState() => new _OrderListState();
}

class _OrderListState extends State<OrderList>  with AfterLayoutMixin<OrderList>{

  String _query = '';

  bool _first = true;

  @override
  void afterFirstLayout(BuildContext context) {
    print('afterFirstLayout... type=${widget.type}');
    getModel(context).addListener(hashCode, (String query){

      setState(() {
        _query = query;
      });

    });

    _handleRefresh();
  }

  String _getWorkType(){
    switch (widget.type){
      case OrderType.ALL:
        return '';
      case OrderType.CM:
        return 'CM';
      case OrderType.XJ:
        return 'XJ';
      default:
        return 'PM';
    }
  }

  String _getQueryStatus() {
    if(widget.type == OrderType.ALL){
      return 'inactive';
    } else {
      return 'active';
    }
  }

  Future<Null> _handleRefresh([int older = 0]) async {
    try{

      int time = 0;

      if(widget.helper.itemCount() > 0){
        time = widget.helper.datas[0].reportDate;
      }

      String response = await getApi(context).orderList(
          type:_getWorkType(),
          status: _getQueryStatus(),
          time: time,
          older: older,
          count: 100);
      OrderListResult result = new OrderListResult.fromJson(Func.decode(response));


      if(result.code != 0){
        Func.showMessage(result.message);
      } else {
        List<OrderShortInfo> info = result.response??[];
        widget.helper.addData(info, clear: widget.type != OrderType.ALL);
      }

    } catch(e){
      print(e);

      Func.showMessage('网络出现异常, 获取工单列表失败');
    }

    if(_first) _first = false;

    try {
      setState(() {

      });
    } catch(e){

    }

  }

  Widget _getSyncStatus(){
    return  Container(
        padding: new EdgeInsets.only(right: _padding),
        decoration: new BoxDecoration(border: new Border(right: new BorderSide(width: 0.5, color: Theme.of(context).dividerColor))),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Image.asset(ImageAssets.order_no_sync, height: 40.0,),
            Text(widget.type == OrderType.ALL ? '已完成' : '未同步')
          ],
        ));
  }

  Widget _getCell(OrderShortInfo info, int index){
    return new Column (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
              color: Colors.white,
              child: new SimpleButton(
                  onTap: (){
                    getModel(context).order = info;

                    Navigator.push(context, new MaterialPageRoute(builder: (_) => new TaskDetailPage()));

                  },
                  child:  new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _padding, vertical: _padding/2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('工单${index+1} : ${info.wonum}'),
                            Text(info.status, style: _status_style,)
                          ],
                        ),
                      ),
                      Divider(height: 1.0,),
                      new Padding(padding: EdgeInsets.symmetric(horizontal: _padding, vertical: _padding/2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _getSyncStatus(),

                            SizedBox(width: _padding,),
                            Expanded(child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('标题: ${info.description}'),
                                Text('位置: ${info.locationDescription}'),
                                Text('设备: ${info.assetDescription}'),
                                Text('上报时间: ${Func.getFullTimeString(info.reportDate)}')
                              ],
                            ))
                          ],
                        ),

                      ),
                    ],
                  )
              )),
          Divider(height: 1.0,),

          Container(
            height: 6.0,
            color: Colors.transparent,
          )
        ]
    );
  }

  List<OrderShortInfo> filter(){
    if(_query.isEmpty) return widget.helper.datas;
    return widget.helper.datas.where((i) => i.wonum.contains(_query?.toUpperCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
//    print('${widget.type} ... build');

    List<OrderShortInfo> list = filter();

    Widget view = new ListView.builder(
        physics: _query.isEmpty ? const AlwaysScrollableScrollPhysics() : new ClampingScrollPhysics(),

        itemCount: list.length,
        itemBuilder: (BuildContext context, int index){
          return _getCell(list[index], index);
        });

    List<Widget> children = <Widget>[
      _query.isEmpty ? new RefreshIndicator(
          onRefresh: _handleRefresh,
          child: new NotificationListener(
              onNotification: widget.helper.handle,
              child: view
          )) : view
    ];

    if(list.length == 0){
      children.add(
          new Center(
              child: _first ? CircularProgressIndicator() : Text('没发现任务')
          ));
    }

    return new Container(
        color: const Color(0xFFF0F0F0),
        child: new Stack( children: children));

  }

  @override
  void deactivate() {
    super.deactivate();
    getModel(context).removeListener(hashCode);

  }

  @override
  void dispose() {
    super.dispose();
  }


}
