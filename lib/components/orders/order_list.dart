import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/page/task_detail_page.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/components/load_more.dart';

import 'package:after_layout/after_layout.dart';

import 'package:samex_app/data/badge_bloc.dart';
import 'package:samex_app/data/bloc_provider.dart';

const double _padding = 16.0;

const force_refresh = 'FORCEREFRESH';
const force_scroller_head = 'force_scroller_head';
const option_cache_key = 'filter_option_key';

final List<_OrderTypeSelect> _orderTypeList = <_OrderTypeSelect>[
  _OrderTypeSelect(OrderType.ALL, '全部'),
  _OrderTypeSelect(OrderType.CM, '报修'),
  _OrderTypeSelect(OrderType.XJ, '巡检'),
  _OrderTypeSelect(OrderType.PM, '保养'),
];

final List<_OrderTypeSelect> _orderXJTypeList = <_OrderTypeSelect>[
  _OrderTypeSelect(OrderType.XJ1, '一级巡检'),
  _OrderTypeSelect(OrderType.XJ2, '二级巡检'),
  _OrderTypeSelect(OrderType.XJ3, '三级巡检'),
  _OrderTypeSelect(OrderType.XJ4, '四级巡检'),
];

class _OrderTypeSelect{
  OrderType key;
  String value;

  _OrderTypeSelect(this.key, this.value);
}

final List<_OrderStatusSelect> _orderStatusList = <_OrderStatusSelect>[
  _OrderStatusSelect('', '全部'),
  _OrderStatusSelect('inactive', '已完成'),
  _OrderStatusSelect('active', '进行中'),
];

final List<_OrderStatusSelect> _orderXJStatusList = <_OrderStatusSelect>[
  _OrderStatusSelect('一级巡检', '一级巡检'),
  _OrderStatusSelect('二级巡检', '二级巡检'),
  _OrderStatusSelect('三级巡检', '三级巡检'),
  _OrderStatusSelect('四级巡检', '四级巡检'),
];

final List<_OrderStatusSelect> _orderCMStatusList = <_OrderStatusSelect>[
  _OrderStatusSelect('', '全部'),
  _OrderStatusSelect('inactive', '已完成'),
  _OrderStatusSelect('待批准', '待批准'),
  _OrderStatusSelect('已批准', '已批准'),
  _OrderStatusSelect('待验收', '待验收'),

];

final List<_OrderStatusSelect> _orderPMStatusList = <_OrderStatusSelect>[
  _OrderStatusSelect('', '全部'),
  _OrderStatusSelect('inactive', '已完成'),
  _OrderStatusSelect('进行中', '进行中'),
  _OrderStatusSelect('待验收', '待验收'),
];

final List<_OrderStatusSelect> _orderALLStatusList = <_OrderStatusSelect>[
  _OrderStatusSelect('', '全部'),
  _OrderStatusSelect('inactive', '已完成'),
  _OrderStatusSelect('进行中', '进行中'),
  _OrderStatusSelect('待验收', '待验收'),
  _OrderStatusSelect('待批准', '待批准'),
  _OrderStatusSelect('已批准', '已批准'),
];

class _OrderStatusSelect{
  String key;
  String value;

  _OrderStatusSelect(this.key, this.value);
}

class OrderList extends StatefulWidget {

  final PageHelper<OrderShortInfo> helper;
  final OrderType type;
  _OrderListState _state;

  OrderList({Key key, @required this.helper, this.type = OrderType.ALL}) :super(key:key);


  @override
    State<StatefulWidget> createState() {
      _state = new _OrderListState();
      return _state;
    }
}

class _OrderListState extends State<OrderList>  with AfterLayoutMixin<OrderList>{

  String _query = '';

  bool _canLoadMore = true;

  ScrollController _scrollController;

  bool needAutoScroller;

  bool _expend = false;
  bool _timeDescend = false;

  FilterOption _option = new FilterOption();

  TextEditingController _searchQuery;

  @override
  void initState() {
    super.initState();
    switch(widget.type){
      case OrderType.PM:
        _option.type = _orderTypeList[3];
        _option.status = _orderStatusList[2];
        break;
      case OrderType.XJ:
        _option.type = _orderTypeList[2];
        _option.status = _orderStatusList[2];
        break;
      case OrderType.CM:
        _option.type = _orderTypeList[1];
        _option.status = _orderStatusList[2];
        break;
      default:
        FilterOption  option = getMemoryCache<FilterOption>(option_cache_key, expired: false);
        if(option != null){
          _option = option;
        }
        _option.type = _orderTypeList[0];
        _option.status = _orderStatusList[0];
        _searchQuery = new TextEditingController(text: '');
        break;
    }

    Future.delayed(Duration.zero,() =>_handleLoadData());
  }

  @override
  void afterFirstLayout(BuildContext context) {
//    print('afterFirstLayout... type=${widget.type}');

    if(_scrollController.initialScrollOffset > 0){
      Future.delayed(new Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.initialScrollOffset + 0.1);
      });
    }

    globalListeners.addListener(hashCode, (String query){

      if(query == force_scroller_head){
        if(_scrollController != null){
          _scrollController.animateTo(1.0,  duration: Duration(milliseconds: 400),  curve: Curves.decelerate);
        }
        return;
      }

      if(query == force_refresh){
        widget.helper.clear();

        _handleRefresh();
        setState(() {
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
    switch (_option.type.key){
      case OrderType.ALL:
        return '';
      case OrderType.CM:
        return 'CM';
      case OrderType.XJ:
        return 'XJ';
      case OrderType.XJ1:
        return 'XJM';
      case OrderType.XJ2:
        return 'XJ2';
      case OrderType.XJ3:
        return 'XJ3';
      case OrderType.XJ4:
        return 'XJ4';
      default:
        return 'PM';
    }
  }

  Future<Null> _handleRefresh([int older = 0]) async {
    try{

      if(!_canLoadMore){
//        print('已经在loadMore了...');
        return;
      }

      Func.closeKeyboard(context);
      int time = 0;

      int startTime = 0;

      if(widget.type == OrderType.ALL){
        time = _option.endTime;
        startTime = _option.startTime;

        if(older == 0 && widget.helper.itemCount() > 0) {
          var data = widget.helper.datas[0];
          startTime = data.reportDate;
        }

        if(older == 1 && widget.helper.itemCount() > 0){
          var data = widget.helper.datas[widget.helper.itemCount() - 1];

          time = data.reportDate;
        }
      } else {
        if(widget.helper.itemCount() > 0){
          var data = widget.helper.datas[0];
          time = data.reportDate;
        }

        if(older == 1 && widget.helper.itemCount() > 0){
          var data = widget.helper.datas[widget.helper.itemCount() - 1];

          time = data.reportDate;
        }
      }

      _canLoadMore = false;


      Map response = await getApi(context).orderList(
          type:_getWorkType(),
          status: _option.status.key,
          time: time,
          query: _searchQuery?.text,
          all: _option.isMe ? 0 : 1,
          start: startTime,
          older: older,
          task: widget.type == OrderType.ALL ? 0 : 1,
          count: widget.type == OrderType.ALL ? 20 : 100);
      OrderListResult result = new OrderListResult.fromJson(response);

      _canLoadMore = true;

      if(result.code != 0){
        Func.showMessage(result.message);
      } else {

        if(widget.type == OrderType.ALL) {
          setMemoryCache<FilterOption>(option_cache_key, _option);
        }

        List<OrderShortInfo> info = result.response??[];
        if(info.length > 0){
          print('列表size: ${info.length}');
          if(older == 0){
            widget.helper.datas.insertAll(0, info);
          } else {
            widget.helper.addData(info);
          }
          // 加载步骤
          for (var item in info) {
            if (item.steps == null) {
              String wonum = item.wonum;
              String site = wonum.replaceAll(new RegExp('\\d+'), '');
              loadSteps(wonum, site);
            }
          }
        }

        try {
          final BadgeBloc bloc = BlocProvider.of<BadgeBloc>(context);

          if (widget.type != OrderType.ALL) {
//            print('send BadgeInEvent : ${widget.helper.itemCount()},  ${widget
//                .type}');
            bloc.badgeChange.add(
                new BadgeInEvent(widget.helper.itemCount(), widget.type));
          }
        } catch (e){
          print('badgeChange   error: $e');
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


  Future<Null> _handleLoadData([int older = 0]) async {
    try{

      int time = 0;
      int startTime = 0;

      if(widget.type == OrderType.ALL){
        time = _option.endTime;
        startTime = _option.startTime;
      }

      Map response = await getApi(context).orderList(
          type:_getWorkType(),
          status: _option.status.key,
          time: time,
          query: _searchQuery?.text,
          all: _option.isMe ? 0 : 1,
          start: startTime,
          older: older,
          task: widget.type == OrderType.ALL ? 0 : 1,
          count: widget.type == OrderType.ALL ? 20 : 100);
      OrderListResult result = new OrderListResult.fromJson(response);

      if(result.code == 0){
        widget.helper.datas = new List();
        
        if(widget.type == OrderType.ALL) {
          setMemoryCache<FilterOption>(option_cache_key, _option);
        }

        List<OrderShortInfo> info = result.response??[];
        if(info.length > 0){
          print('列表size: ${info.length}');
          if(older == 0){
            widget.helper.datas.insertAll(0, info);
          } else {
            widget.helper.addData(info);
          }

          // 加载步骤
          for (var item in info) {
            if (item.steps == null) {
              String wonum = item.wonum;
              String site = wonum.replaceAll(new RegExp('\\d+'), '');
              loadSteps(wonum, site);
            }
          }
        }

        try {
          final BadgeBloc bloc = BlocProvider.of<BadgeBloc>(context);

          if (widget.type != OrderType.ALL) {
            bloc.badgeChange.add(
                new BadgeInEvent(widget.helper.itemCount(), widget.type));
          }
        } catch (e){
          print('badgeChange   error: $e');
        }
      }

    } catch(e){
      print(e);
      Func.showMessage('网络出现异常, 获取工单列表失败');
    }
  }

  void loadSteps(String wonum, String site) async {
    try{
      Map response = await getApi(context).steps(sopnum: '', wonum: wonum, site: site);
      StepsResult result = new StepsResult.fromJson(response);
      if(result.code == 0){
        if(mounted) {
          setState(() {
            List<OrderShortInfo> infos = widget.helper.datas.toList();
            OrderShortInfo info = infos.where((e) => e.wonum == wonum).toList().first;
            info.steps = result.response.steps;
          });
        }
      }

    } catch (e){
      print (e);
    }
  }

  Widget _getSyncStatus(OrderShortInfo info){

    List<Widget> children = new List();
    switch (getOrderType(info.worktype)) {
      case OrderType.XJ:

        String image = info.actfinish == 0 ? ImageAssets.order_ing : ImageAssets.order_done;
        if(info.status.contains('进行中')){
          List<OrderStep> steps = info.steps;
          bool isDid = false;
          if (steps != null && steps.length > 0) {
            for (var item in steps) {
              String status = item.status??'';
              if (status.length > 0) {
                isDid = true;
                break;
              }
            }
          }
          image = isDid ? ImageAssets.order_ing_red : ImageAssets.order_ing;
        }
        children.addAll(<Widget>[
//          Text('巡检工单', style: TextStyle(color: getOrderTextColor(info), fontWeight: FontWeight.w700),),
          new CircleAvatar(child:new Padding(padding: EdgeInsets.all(8.0), child:  new Image.asset( image , height: 40.0,)), backgroundColor: getColor(info),),
          Text(info.status, style: TextStyle(color: getColor(info)),)
        ]);
        break;
      case OrderType.CM:
//        children.add(Text('报修工单', style: TextStyle(color: getOrderTextColor(info), fontWeight: FontWeight.w700),),);
        String image= '';

        if(info.status.contains('待批准')){
          image = ImageAssets.order_pending_approved;
        } else if(info.status.contains('已批准')){
          image = ImageAssets.order_approved;
        } else if(info.status.contains('待验收')){
          image = ImageAssets.order_pending_accept;
        } else {
          image = ImageAssets.order_done;
        }

        children.add(new CircleAvatar(child: new Padding(padding: EdgeInsets.all(8.0), child: new Image.asset(image, height: 40.0,)), backgroundColor: getColor(info),),);
        children.add(Text(info.status.length > 3 ? info.status.substring(info.status.length - 3) : info.status, style: TextStyle(color: getColor(info))));
        break;
      default:
//        children.add(Text('保养工单', style: TextStyle(color: getOrderTextColor(info), fontWeight: FontWeight.w700),),);
        String image= '';

        if(info.status.contains('进行中')){
          List<OrderStep> steps = info.steps;
          bool isDid = false;
          if (steps != null && steps.length > 0) {
            for (var item in steps) {
              String status = item.status??'';
              if (status.length > 0) {
                isDid = true;
                break;
              }
            }
          }
          image = isDid ? ImageAssets.order_ing_red : ImageAssets.order_ing;
        }  else if(info.status.contains('待验收')){
          image = ImageAssets.order_pending_accept;
        } else {
          image = ImageAssets.order_done;
        }

        children.add(new CircleAvatar(child: new Padding(padding: EdgeInsets.all(8.0), child: new Image.asset(image, height: 40.0,)), backgroundColor: getColor(info),),);
        children.add(Text(info.status.length > 3 ? info.status.substring(info.status.length - 3) : info.status, style: TextStyle(color: getColor(info))));
        break;
    }


    return  Container(
        padding: new EdgeInsets.only(right: _padding),
        decoration: new BoxDecoration(border: new Border(right: new BorderSide(width: 0.5, color: Theme.of(context).dividerColor))),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ));
  }

  Color getColor(OrderShortInfo info){
    switch (getOrderType(info.worktype)) {
      case OrderType.XJ:
        if(info.actfinish == 0){
          return Colors.blue.shade900;
        } else {
          return Colors.green;
        }
        break;
      case OrderType.CM:
        if(info.status.contains('待批准')){
          return Colors.red.shade900;
        } else if(info.status.contains('已批准')){
          return Colors.cyan;
        } else if(info.status.contains('待验收')){
          return Colors.orange.shade600;
        } else if(info.status.contains('重做')){
          return Colors.red.shade400;
        } else {
          return Colors.green;
        }
        break;
      case OrderType.PM:
        if(info.status.contains('进行中')){
          return Colors.blue.shade900;
        } else if(info.status.contains('待验收')){
          return Colors.orange.shade600;
        } else if(info.status.contains('重做')){
          return Colors.red.shade400;
        } else {
          return Colors.green;
        }
        break;
      default:
        return Colors.deepOrangeAccent;
    }
  }

  Color getOrderTextColor(OrderShortInfo info){
    switch (getOrderType(info.worktype)) {
      case OrderType.XJ:
        return Colors.pink.shade600;
      case OrderType.CM:
        return Colors.deepPurpleAccent;
      default:
        return Colors.orange.shade600;
    }
  }

  Color getBackGroundColor(OrderShortInfo info){
    return Colors.white;
//    switch (getOrderType(info.worktype)) {
//      case OrderType.XJ:
//        return const Color(0xFFd9c0c6);
//      case OrderType.CM:
//        return const Color(0xFFd4ded6);
//      default:
//        return const Color(0xFFe7dc9e);
//    }
  }

  String getLeadName(OrderShortInfo info){
    if(info.actfinish == 0 && getOrderType(info.worktype) == OrderType.XJ){
      return '';
    } else  {
      return info.lead ?? info.changeby??'';
    }
  }

  Widget _getCell(OrderShortInfo info, int index){

    String str = '';
    switch (getOrderType(info.worktype)) {
      case OrderType.XJ:
        str = '巡检';
        break;
      case OrderType.CM:
        str='报修';
        break;
      default:
        str = '保养';
        break;
    }

    return new Column (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: Style.separateHeight,
            color: getColor(info),
          ),
          new SimpleButton(
              onTap: () async {
                final result  = await Navigator.push(context, new MaterialPageRoute(
                    builder: (_) => new TaskDetailPage(info:  info,),
                    settings: RouteSettings(name: TaskDetailPage.path)
                ));
                if(result != null) {
                  removeAt(index);
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
                        Text('$str工单 : ${info.wonum}',style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(getLeadName(info), style: TextStyle(fontWeight: FontWeight.w700))
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('标题: ${info.description}', style: TextStyle(color: getOrderTextColor(info), fontWeight: FontWeight.w700),),
//                                Text('位置: ${info.locationDescription}'),
//                                Text('资产:${info.assetnum??''}'),
                            Text('设备: ${info.assetDescription}'),
                                widget.type == OrderType.ALL ?
//                                Text('完成时间: ${Func.getFullTimeString(info.actfinish)}')
                                Text('上报时间: ${Func.getFullTimeString(info.reportDate)}'):
                                Text('更新时间: ${Func.getFullTimeString(info.reportDate)}')
                          ],
                        ))
                      ],
                    ),

                  ),
                ],
              )
          ),
//          Divider(height: 1.0,),

        ]
    );
  }

  List<OrderShortInfo> filter(){
    List<OrderShortInfo> list = widget.helper.datas;
    if(_query.isEmpty) {
      list = widget.helper.datas.where((i) => i.wonum.contains(_query?.toUpperCase()) || (i.assetnum??'').contains(_query?.toUpperCase())).toList();
    }
    return _timeDescend ? list.reversed.toList() : list;
  }

  List<OrderShortInfo> getList(){
    List<OrderShortInfo> list = filter();
    return list;
  }

  void removeAt(int index) {
    if(widget.helper.datas == null) return;

    widget.helper.datas.removeAt(index);
  }


  List<_OrderStatusSelect> _getStatusList(){
    switch(_option.type.key){
      case OrderType.CM:
        return _orderCMStatusList;
      case OrderType.PM:
        return _orderPMStatusList;
      case OrderType.XJ:
        // return _orderStatusList;
        return _orderXJStatusList;
      default:
        return _orderALLStatusList;
    }
  }

  Widget _getOptionView(){
    if(!_expend){
      return  Container();
    } else {
      return Container(
          padding: EdgeInsets.all(4.0),
          child: Wrap(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('内容过滤: ', style: const TextStyle(color: Colors.black87)),
                    Expanded( child: new TextField(
                      controller: _searchQuery,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                        hintText: '输入工单号/资产编号进行查询',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                    ))
                  ],
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SimpleButton(
                      onTap: (){
                        setState(() {
                          _option.isMe = !_option.isMe;
                          if(!_option.isMe){
                            _option.type = _orderTypeList[0];
                            _option.status = _orderStatusList[0];
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('所有工单'),
                          Icon(_option.isMe ? Icons.radio_button_unchecked :Icons.radio_button_checked, size: 16.0,),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.0,),

                    Text('工单类型:'),
                    SizedBox(width: 2.0,),
                    new PopupMenuButton<_OrderTypeSelect>(
                      child: Row(
                        children: <Widget>[
                          Text('${_option.type.value}'),
                          Align(child: const Icon(Icons.arrow_drop_down))
                        ],
                      ),                      
                      itemBuilder: (BuildContext context) {
                        return _orderTypeList.map((_OrderTypeSelect status) {
                          if (status.key == OrderType.XJ) {
                            return new PopupMenuItem<_OrderTypeSelect>(
                              value: status,
                              child: new PopupMenuButton<_OrderTypeSelect>(
                                child: Row(
                                  children: <Widget>[
                                    Text(status.value),
                                    Align(child: const Icon(Icons.arrow_right))
                                  ],
                                ),
                                itemBuilder: (BuildContext context) {
                                  return _orderXJTypeList.map((_OrderTypeSelect xjStatus) {
                                    return new PopupMenuItem<_OrderTypeSelect>(
                                      value: xjStatus,
                                      child: new Text(xjStatus.value),
                                    );
                                  }).toList();
                                },
                                onSelected: (_OrderTypeSelect xjValue) {
                                  setState(() {
                                    _option.type = xjValue;
                                    _option.status = _orderStatusList[0];
                                  });
                                },
                              )
                            );
                          } else {
                            return new PopupMenuItem<_OrderTypeSelect>(
                              value: status,
                              child: new Text(status.value),
                            );
                          }
                        }
                      ).toList();
                    },
                      onSelected: (_OrderTypeSelect value) {
                        setState(() {
                          _option.type = value;
                          _option.status = _orderStatusList[0];
                        });
                      },
                    )

                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('工单状态:'),
                    SizedBox(width: 2.0,),
                    new PopupMenuButton<_OrderStatusSelect>(
                      child: Row(
                        children: <Widget>[
                          Text('${_option.status.value}'),
                          Align(child: const Icon(Icons.arrow_drop_down))
                        ],
                      ),
                      itemBuilder: (BuildContext context) {
                        return _getStatusList().map((_OrderStatusSelect status) {
                          return new PopupMenuItem<_OrderStatusSelect>(
                            value: status,
                            child: new Text(status.value),
                          );
                        }).toList();
                      },
                      onSelected: (_OrderStatusSelect value) {
//                                print('status = ${value.value}');
                        setState(() {
                          _option.status = value;
                        });
                      },
                    )

                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('上报时间: '),
                    new SizedBox(width: 10.0,),
                    new InkWell(
                        onTap:  () {
                          DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                              _option.startTime * 1000);
                          Func.selectDate(context, time, (DateTime date) {
                            setState(() {
                               int start = (new DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/ 1000).toInt();
                               print("startTime --> :${start}");
                              _option.startTime = start;
                            });
                          });
                        },
                        child: Row(
                            children: <Widget>[
                              new Text('${Func.getYearMonthDay(_option.startTime * 1000)}'),
                              Icon(Icons.arrow_drop_down)]
                        )
                    ),
                    Text('到'),
                    new SizedBox(width: 10.0,),
                    new InkWell(
                        onTap:  () {
                          DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                              _option.endTime * 1000);
                          Func.selectDate(context, time, (DateTime date) {
                            setState(() {
                              _option.endTime = (new DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/ 1000).toInt();

                            });
                          });
                        },
                        child: Row(
                            children: <Widget>[
                              new Text('${Func.getYearMonthDay(_option.endTime * 1000)}'),
                              Icon(Icons.arrow_drop_down)]
                        )
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SimpleButton(
                        onTap: (){
                          setState(() {
                            widget.helper.clear();
                            _handleRefresh();
                            _query = '';
                            widget.helper.inital = true;

                            setState(() {
                              _expend = false;
                            });
                          });
                        },
                        elevation: 2.0,

                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                        color: Colors.blueAccent,
                        child: Row(
                          children: <Widget>[
                            Text('确定', style: TextStyle(color: Colors.white),),
                          ],
                        ))
                  ],
                ),
              ],
              spacing: 12.0,
              runSpacing: 8.0,
              runAlignment: WrapAlignment.center

          ));
    }
  }

  Widget _getFilterOptionView(){
    return  new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SimpleButton(
            onTap: (){
              setState(() {
                _expend = !_expend;
              });
            },
            child: 
            widget.helper.datas.length > 0 ? 
            Container(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Material(color: Colors.transparent,
                    elevation: 2.0,
                    child: new Container(
                      height: 20.0,
                      padding: EdgeInsets.all(2.0),
                      decoration: new BoxDecoration(color: const Color(0xFFFF232D), borderRadius: new BorderRadius.circular(5.0)),
                      child: Center( child: Text('${widget.helper.datas.length}', style: new TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center,)),
                    ),
                  ),
                  Text('筛选', style: TextStyle(color: Style.primaryColor, fontSize: 18.0),),
                  Icon(_expend ? Icons.expand_less : Icons.expand_more, color: Style.primaryColor,)
                ],
              ),
            )
            : Container(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('筛选', style: TextStyle(color: Style.primaryColor, fontSize: 18.0),),
                  Icon(_expend ? Icons.expand_less : Icons.expand_more, color: Style.primaryColor,)
                ],
              ),
            )
        ),
        _getOptionView()
      ],

    );
  }

  Widget _getSortOptionView(){
    return Container(
      height: 40,
      padding: EdgeInsets.all(4.0),
      child: Wrap(
        children: <Widget>[
          Text('按时间排序:'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SimpleButton(
                onTap: (){
                  setState(() {
                    _timeDescend = false;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('升序'),
                    Icon(_timeDescend ? Icons.radio_button_unchecked :Icons.radio_button_checked, size: 16.0,),
                  ],
                ),
              ),
              SimpleButton(
                onTap: (){
                  setState(() {
                    _timeDescend = true;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text('降序'),
                    Icon(_timeDescend ? Icons.radio_button_checked :Icons.radio_button_unchecked, size: 16.0,),
                  ],
                ),
              )
            ],
          ),
        ],
        spacing: 12.0,
        runSpacing: 8.0,
        runAlignment: WrapAlignment.center
      )
    );
  }

  @override
  Widget build(BuildContext context) {
//    print('${widget.type} ... build, ${widget.helper.itemCount()}');
    
    List<OrderShortInfo> list = filter().toList();
    _scrollController = widget.helper.createController();
    _scrollController.addListener((){
      if(_scrollController.offset > context.size.height){
        globalListeners.boolChanges(ChangeBool_Scroll, true);
      } else {
        globalListeners.boolChanges(ChangeBool_Scroll, false);
      }
    });

    Widget view = Scrollbar(
      child: new ListView.builder(
        physics: _query.isEmpty ? const AlwaysScrollableScrollPhysics() : new ClampingScrollPhysics(),
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index){
          return Container(
            color:  Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Card(
              child:_getCell(list[index], index)
            )
          );
        }
      )
    );

    if(widget.type == OrderType.ALL){
      view = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card( child: _getFilterOptionView()),
          Card( child: _getSortOptionView()),
          Expanded(child:view),
        ],
      );
    }

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
        child: GestureDetector(
            onTap: (){
              Func.closeKeyboard(context);
            },
            child: new Stack(children: children))
    );
  }

  @override
  void dispose() {
    super.dispose();
    globalListeners.removeListener(hashCode);
    _searchQuery?.dispose();
  }
}

class FilterOption {
  bool isMe = true;
  _OrderTypeSelect type = _orderTypeList[0];
  int startTime = new DateTime.now().millisecondsSinceEpoch ~/ 1000 - 365*24*60*60;
  _OrderStatusSelect status = _orderStatusList[0];
  int endTime = new DateTime.now().millisecondsSinceEpoch ~/ 1000 +24*60*60;
}
