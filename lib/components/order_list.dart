import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/page/task_detail_page.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/components/load_more.dart';

import 'package:after_layout/after_layout.dart';

const double _padding = 16.0;
const TextStyle _status_style = TextStyle(color: Colors.red);
bool _isReversed = true;

const force_refresh = 'FORCEREFRESH';
const force_scroller_head = 'force_scroller_head';

class OrderList extends StatefulWidget {

  final PageHelper<OrderShortInfo> helper;
  final OrderType type;

  OrderList({Key key, @required this.helper, this.type = OrderType.ALL}) :super(key:key);
  @override
  _OrderListState createState() => new _OrderListState();
}

class _OrderListState extends State<OrderList>  with AfterLayoutMixin<OrderList>{

  String _query = '';

  bool _canLoadMore = true;

  ScrollController _scrollController;
  @override
  void afterFirstLayout(BuildContext context) {
    print('afterFirstLayout... type=${widget.type}');
    globalListeners.addListener(hashCode, (String query){

      if(query == force_scroller_head){
        if(_scrollController != null){
          _scrollController.animateTo(1.0,  duration: Duration(milliseconds: 400),  curve: Curves.decelerate);
        }
        return;
      }

      if(query == force_refresh){
        widget.helper.clear();

        setState(() {
          _handleRefresh();
          _query = '';
          widget.helper.inital = true;
        });
      } else {
        setState(() {
          _query = query;
        });
      }


    });

    if(widget.helper.itemCount() == 0 && widget.helper.inital){
      _handleRefresh();
    }

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
      return '';
    } else {
      return 'active';
    }
  }


  Future<Null> _handleRefresh([int older = 0]) async {
    try{

      int time = 0;

      if(_isReversed){
        older = older == 0 ? 1 : 0;
      }

      if(widget.helper.itemCount() > 0){
        var data = widget.helper.datas[0];
//        time = widget.type == OrderType.ALL ? data.actfinish : data.reportDate;
        time = data.reportDate;
      }

      if(older == 1 && widget.helper.itemCount() > 0){
        var data = widget.helper.datas[widget.helper.itemCount() - 1];

//        time = widget.type == OrderType.ALL ? data.actfinish : data.reportDate;
        time = data.reportDate;

        if(_canLoadMore) _canLoadMore = false;
        else {
          print('已经在loadMore了...');
        }
      }

      Map response = await getApi(context).orderList(
          type:_getWorkType(),
          status: _getQueryStatus(),
          time: time,
          older: older,
          count: 20);
      OrderListResult result = new OrderListResult.fromJson(response);

      if(older == 1) _canLoadMore = true;
      if(result.code != 0){
        Func.showMessage(result.message);
      } else {
        List<OrderShortInfo> info = result.response??[];
        if(info.length > 0){
          print('列表size: ${info.length}');
          if(older == 0){
            widget.helper.datas.insertAll(0, info);
          } else {
            widget.helper.addData(info);
          }
        }
      }

    } catch(e){
      print(e);

      Func.showMessage('网络出现异常, 获取工单列表失败');
    }

    if(widget.helper.inital) widget.helper.inital = false;

    try {
      setState(() {

      });
    } catch(e){

    }

  }

  Widget _getSyncStatus(OrderShortInfo info){
    return  Container(
        padding: new EdgeInsets.only(right: _padding),
        decoration: new BoxDecoration(border: new Border(right: new BorderSide(width: 0.5, color: Theme.of(context).dividerColor))),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            info.actfinish == 0 ?  new Image.asset( ImageAssets.order_no_sync , height: 40.0,)
            : new CircleAvatar(child: Icon(Icons.done, size: 30.0,)),
            Text(info.actfinish != 0 ? '已完成' : '未完成')
          ],
        ));
  }

  Color getColor(OrderShortInfo info){
    switch (getOrderType(info.worktype)){
      case OrderType.XJ:
        return Style.primaryColor;
      case OrderType.CM:
        return Colors.redAccent;
      default:
        return Colors.deepOrangeAccent;
    }
  }

  String getLeadName(OrderShortInfo info){
    if(info.actfinish == 0 && getOrderType(info.worktype) == OrderType.XJ){
      return '';
    } else  {
      return info.lead ?? info.changeby??'';
    }
  }

  Widget _getCell(OrderShortInfo info, int index){
    return new Column (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: Style.separateHeight/2,
            color: getColor(info),
          ),
          new Container(
              color: info.actfinish == 0 ? Colors.white : Colors.cyan.withOpacity(0.2),
              child: new SimpleButton(
                  onTap: () async {
                    final result  = await Navigator.push(context, new MaterialPageRoute(
                        builder: (_) => new TaskDetailPage(info:  info,),
                        settings: RouteSettings(name: TaskDetailPage.path)
                    ));
                    if(result != null) {
                      removeAt(index);

                      setState(() {

                      });
                    }

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
                            Text('工单 : ${info.wonum}',style: TextStyle(fontWeight: FontWeight.w700)),
                            Text(getLeadName(info), )
                          ],
                        ),
                      ),
                      Divider(height: 1.0,),
                      new Padding(padding: EdgeInsets.symmetric(horizontal: _padding, vertical: _padding/2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _getSyncStatus(info),

                            SizedBox(width: _padding,),
                            Expanded(child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('标题: ${info.description}', style: TextStyle(color: Style.primaryColor, fontWeight: FontWeight.w700),),
//                                Text('位置: ${info.locationDescription}'),
                                Text('设备: ${info.assetDescription}'),
//                                widget.type == OrderType.ALL ?
//                                Text('完成时间: ${Func.getFullTimeString(info.actfinish)}')
//                                Text('上报时间: ${Func.getFullTimeString(info.reportDate)}'):
                                Text('上报时间: ${Func.getFullTimeString(info.reportDate)}')
                              ],
                            ))
                          ],
                        ),

                      ),
                    ],
                  )
              )),
//          Divider(height: 1.0,),

        ]
    );
  }

  List<OrderShortInfo> filter(){
    if(_query.isEmpty) return widget.helper.datas;
    return widget.helper.datas.where((i) => i.wonum.contains(_query?.toUpperCase())).toList();
  }

  List<OrderShortInfo> getList(){
    List<OrderShortInfo> list = filter();
    if(_isReversed){
      return list.reversed.toList();
    } else {
      return list;
    }
  }

  void removeAt(int index) {
    if(widget.helper.datas == null) return;

    if(_isReversed){
      widget.helper.datas.removeAt(widget.helper.datas.length - index - 1);
    } else {
      widget.helper.datas.removeAt(index);
    }
  }


  @override
  Widget build(BuildContext context) {
//    print('${widget.type} ... build, ${widget.helper.itemCount()}');

    List<OrderShortInfo> list = filter().reversed.toList();
    _scrollController = widget.helper.createController();
    _scrollController.addListener((){
      if(_scrollController.offset > context.size.height){
        globalListeners.boolChanges(ChangeBool_Scroll, true);
      } else {
        globalListeners.boolChanges(ChangeBool_Scroll, false);
      }
    });

    Widget view = Scrollbar(child: new ListView.builder(

        physics: _query.isEmpty ? const AlwaysScrollableScrollPhysics() : new ClampingScrollPhysics(),
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index){
          return Container(
              color:  Colors.transparent,
              padding: Style.pagePadding2,
              child: Material(
                  borderRadius: new BorderRadius.circular(4.0),
                  elevation: 2.0,
                  child:_getCell(list[index], index)));
        }));

    List<Widget> children = <Widget>[
      _query.isEmpty ? new RefreshIndicator(
          onRefresh: _handleRefresh,
          child: new LoadMore(
              scrollNotification: widget.helper.handle,
              child: view,
              onLoadMore: () async{
                _handleRefresh(1);
              }
          )) : view
    ];

    if(list.length == 0){
      children.add(
          new Center(
              child: (widget.helper.inital && _query.isEmpty) ? CircularProgressIndicator() : Text('没发现任务')
          ));
    }

    return new Container(
        color: const Color(0xFFF0F0F0),
        child: new Stack( children: children));

  }

  @override
  void dispose() {
    super.dispose();

    globalListeners.removeListener(hashCode);

  }


}
