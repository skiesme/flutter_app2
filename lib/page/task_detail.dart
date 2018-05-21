import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/order_detail.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';

import 'package:after_layout/after_layout.dart';

const double _padding = 16.0;

class TaskDetailPage extends StatefulWidget {

  @override
  _TaskDetailPageState createState() => new _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> with AfterLayoutMixin<TaskDetailPage> {

  OrderShortInfo _info;
  OrderType _type;
  OrderDetialData _data;

  int _tabIndex = 0;

  bool _expend = false;

  @override
  void initState() {
    super.initState();
  }

  void _getOrderDetail() async{
    try{
      String response = await getApi(context).orderDetail(_info.wonum, _data?.changedate);
      OrderDetailResult result = new OrderDetailResult.fromJson(Func.decode(response));
      if(result.code != 0){
        Func.showMessage(result.message);
      } else {
        OrderDetialData data = result.response;
        if(data != null){
          setState(() {
            _data = data;
          });
        }
      }
    } catch(e){
      print(e);
      Func.showMessage('网络出现异常: 获取工单详情失败');
    }
  }

  String getWorkTypeString(){
    switch (_type){
      case OrderType.CM:
        return '报修单';
      case OrderType.XJ:
        return '巡检单';
      case OrderType.PM:
        return '保养单';
      default:
        return '';
    }
  }

  List<BottomNavigationBarItem> _getBottomBar(){
    List<BottomNavigationBarItem> list = <BottomNavigationBarItem>[];
    int index = 0;
    list.add(new BottomNavigationBarItem(
        icon: new Image.asset(ImageAssets.task_detail_detail, color:  index == _tabIndex ? Style.primaryColor : Colors.grey, height: 24.0,),
        title: Text('详细', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));

    list.add(new BottomNavigationBarItem(
        icon: new Image.asset(ImageAssets.task_detail_task, color:  index == _tabIndex ? Style.primaryColor : Colors.grey,height: 24.0),
        title: Text('任务', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));

    if(_type != OrderType.XJ){
      list.add(new BottomNavigationBarItem(
          icon: new Image.asset(ImageAssets.task_detail_person, color:  index == _tabIndex ? Style.primaryColor : Colors.grey,height: 24.0),
          title: Text('人员', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));

      list.add(new BottomNavigationBarItem(
          icon: new Image.asset(ImageAssets.task_detail_material, color:  index == _tabIndex ? Style.primaryColor : Colors.grey,height: 24.0),
          title: Text('物料', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));
    }

    return list;
  }

  Widget _getBody2(){
//    if(!widget.isTask) return new OrderList(helper: _pageHelpers[3], type: OrderType.ALL,);
//    switch(_tabIndex){
//      case 0:
//        return new OrderList(helper: _pageHelpers[0], type: OrderType.CM,);
//      case 1:
//        return new OrderList(helper: _pageHelpers[1], type: OrderType.XJ,);
//      default:
//        return new OrderList(helper: _pageHelpers[2], type: OrderType.PM,);
//    }

    return  new Container(
      color: Colors.white,
      child: Text('列表....') ,
    );
  }

  List<Widget> _getList(){
    List<Widget> list = <Widget>[];
    list.addAll(<Widget>[
      Text('工单编号: ${_info.wonum}'),
      Text('工单类型: ${getWorkTypeString()}'),
      Text('标题名称: ${_info.description}'),
      Text('描述详细: '),
    ]);

    if(_expend){
      list.addAll(<Widget>[
        Text('位置编号: ${_info.location}'),
        Text('位置描述: ${_info.locationDescription}'),
        Text('资产编号: ${_info.assetnum}'),
        Text('资产描述: ${_info.locationDescription}'),
        Text('工单状态: ${_info.status}'),
        Text('优先等级: ${_data?.wopriority ?? ''}'),
        Text('汇报人员: ${_data?.reportedby ??''}'),
        Text('上报时间: ${Func.getFullTimeString( _data?.reportdate)}'),
      ]);
      if(_type != OrderType.XJ){
        list.addAll(<Widget>[
          Text('主管人员: ${_data?.supervisor??''}'),
          Text('负责人员: ${_data?.lead ?? ''}'),
          Text('联系电话: ${_data?.phone ?? ''}'),
        ]);
      }

//      list.add(Text('站点编号: ${_data?.lead ?? ''}'));

    }

    return list;

  }

  Widget  _getHeader(){
    return new Container(
      color: Colors.white,
//      constraints: new BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2) ,
      padding: EdgeInsets.all(_padding),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('基本信息'),
                new InkWell(
                  onTap: (){},
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.attach_file, color: Style.primaryColor,),
                      Text('查看附件', style: Style.textStyleSelect,)
                    ],
                  ),
                )
              ],
            ),
            Divider(),
            new Stack(
              children: <Widget>[
                Column(
                  children: _getList(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            setState(() {
                              _expend = !_expend;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Text(_expend ? '收缩':'展开', style: Style.textStyleSelect,),
                              Icon(_expend ? Icons.expand_less : Icons.expand_more, color: Style.primaryColor,)
                            ],
                          ),)
                      ],
                    ))
              ],
            ),
          ]),

    );
  }


  Widget _getBody() {
    return new Container(
      color: const Color(0xFFF0F0F0),
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _getHeader(),
          new SizedBox(height: 6.0,),
          _getBody2(),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: Text(_info?.wonum ?? '',),
      ),
      body: _info== null? Text(''): _getBody(),
      bottomNavigationBar: new BottomNavigationBar(
        items: _getBottomBar(),
        currentIndex: _tabIndex,
        onTap: (index) {
          setState((){
            _tabIndex = index;
          });
        },
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {


    setState(() {
      _info = getModel(context).order;
      _type = getOrderType(_info.worktype);
      _getOrderDetail();
    });

  }
}
