import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/data/root_model.dart';

import 'package:after_layout/after_layout.dart';

enum OrderType {
  ALL,            //全部
  PM,             //保养
  XJ,             //巡检
  CM,             //报修
}

const double _padding = 16.0;
const TextStyle _status_style = TextStyle(color: Colors.red);

class OrderList extends StatefulWidget {

  final PageHelper<OrderShortInfo> helper;
  final OrderType type;

  OrderList({@required this.helper, this.type = OrderType.ALL});
  @override
  _OrderListState createState() => new _OrderListState();
}

class _OrderListState extends State<OrderList>  with AfterLayoutMixin<OrderList>{

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

  Future<Null> _handleRefresh() async {
    try{
      String response = await getApi(context).orderList(
          type:_getWorkType(),
          status: _getQueryStatus(),
          count: widget.type != OrderType.ALL ? 100 : 20);
      OrderListResult result = new OrderListResult.fromJson(Func.decode(response));
      if(result.code != 0){
        Func.showMessage(result.message);
      } else {
        List<OrderShortInfo> info = result.response;
        widget.helper.addData(info, clear: widget.type != OrderType.ALL);

        try {
          setState(() {

          });
        } catch(e){

        }
      }

    } catch(e){
      print(e);

      Func.showMessage('网络出现异常, 获取工单列表失败');
    }
  }

  Widget _getSyncStatus(){
    return  Container(
        padding: new EdgeInsets.only(right: 20.0),
        decoration: new BoxDecoration(border: new Border(right: new BorderSide(color: Theme.of(context).dividerColor))),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Image.asset(ImageAssets.order_no_sync, height: 40.0,),
            Text(widget.type == OrderType.ALL ? '已完成' : '未同步')
          ],
        ));
  }

  Widget _getCell(int index){
    OrderShortInfo info = widget.helper.datas[index];

    return new InkWell(
        onTap: (){

        },
        child: new Column (
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Container(
                  color: Colors.white,
                  child: new Column(
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

                            SizedBox(width: 20.0,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('标题: ${info.description}', ),
                                Text('位置: ${info.locationDescription}'),
                                Text('设备: ${info.assetDescription}')
                              ],
                            )
                          ],
                        ),

                      ),
                      Divider(height: 1.0,),

                    ],
                  )
              ),

              Container(
                height: 6.0,
                color: Colors.transparent,
              )
            ]
        ));
  }

  @override
  Widget build(BuildContext context) {
    print('${widget.type} ... build');

    if(widget.helper.itemCount() == 0){
      return new Container(
          color: const Color(0xFFF0F0F0),
          child: new Stack( children: <Widget>[
            new RefreshIndicator(
                onRefresh: _handleRefresh,
                child: new NotificationListener(
                    onNotification: widget.helper.handle,
                    child: new ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),

                        itemCount: widget.helper.itemCount(),
                        itemBuilder: (BuildContext context, int index){
                          return _getCell(index);
                        })
                )),

            new Center(
                child: Text('没发现任务')
            )

          ]));
    }
    return new Container(
        color: const Color(0xFFF0F0F0),
        child: new RefreshIndicator(
            onRefresh: _handleRefresh,
            child: new NotificationListener(
                onNotification: widget.helper.handle,
                child: new ListView.builder(
                    controller: widget.helper.createController(),
                    physics: const AlwaysScrollableScrollPhysics(),

                    itemCount: widget.helper.itemCount(),
                    itemBuilder: (BuildContext context, int index){
                      return _getCell(index);
                    })
            )));
  }

  @override
  void afterFirstLayout(BuildContext context) {
//    if(widget.helper.itemCount() == 0)
    _handleRefresh();
  }
}
