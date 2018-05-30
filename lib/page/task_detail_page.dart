import 'dart:async';
import 'package:flutter/material.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/order_detail.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/components/recent_history.dart';
import 'package:samex_app/components/step_list.dart';
import 'package:samex_app/components/people_material_list.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/page/attachment_page.dart';

import 'package:after_layout/after_layout.dart';


class TaskDetailPage extends StatefulWidget {

  static const String path = '/TaskDetailPage';

  @override
  _TaskDetailPageState createState() => new _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> with AfterLayoutMixin<TaskDetailPage> {

  OrderShortInfo _info;
  OrderType _type;
  static OrderDetailData _data;

  int _tabIndex = 0;

  bool _expend = false;

  bool _show = false;

  GlobalKey<StepListState> _stepKey = new GlobalKey<StepListState>();

  @override
  void initState() {
    super.initState();
    _data = null;
  }


  Future _getOrderDetail() async{
    try{
      final response = await getApi(context).orderDetail(_info.wonum, _data?.changedate);
      OrderDetailResult result = new OrderDetailResult.fromJson(response);
      if(result.code != 0){
        Func.showMessage(result.message);
      } else {
        OrderDetailData data = result.response;
        if(data != null){
          setState(() {
            _data = data;
            getModel(context).orderDetailData = data;
          });
        }
      }
    } catch(e){
      print(e);
      Func.showMessage('网络出现异常: 获取工单详情失败');
    }

    setState(() {
      _show = false;
    });
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

  Widget _getHeader2(){
    List<Widget> children = <Widget>[];

    switch(_tabIndex){
      case 0:
        String str = (_type == OrderType.PM) ? '保养' :(_type == OrderType.CM ? '维修' : '巡检');
        children.add(Text('$str历史'));
        break;
      case 1:
        children.add(Text('任务列表'));
        if(_type != OrderType.XJ){
          children.add(new RaisedButton.icon(onPressed: (){}, icon: Icon(Icons.add), label: Text('新增任务')));
        }
        break;
      case 2:
        children.add(Text('人员列表'));
        children.add(new RaisedButton.icon(onPressed: (){}, icon: Icon(Icons.add), label: Text('新增人员')));
        break;
      case 3:
        children.add(Text('物料列表'));
        children.add(new RaisedButton.icon(onPressed: (){}, icon: Icon(Icons.add), label: Text('新增物料')));
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  Widget _getBody2(){

    Widget widget = Container();
    switch (_tabIndex){
      case 0:
        widget = RecentHistory(data: _data,);
        break;
      case 1:
        widget = StepList(key: _stepKey, data: _data,);
        break;
      case 2:
      case 3:
        widget = PeopleAndMaterialList(isPeople: _tabIndex == 2,);
        break;
    }


    return  new Container(
      color: Colors.white,
      child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Padding(
              padding: Style.pagePadding2,
              child: _getHeader2(),
            ),
            Divider(height: 1.0,),
            new Padding(
              padding: Style.pagePadding2,
              child: widget,
            ),
          ]),
    );
  }

  List<Widget> _getList(){
    List<Widget> list = <Widget>[];
    list.addAll(<Widget>[
      Text('工单编号: ${_info.wonum}'),
      Text('工单类型: ${getWorkTypeString()}'),
      Text('标题名称: ${_info.description}'),
//      Text('描述详细: '),
    ]);

    if(_expend){
      list.addAll(<Widget>[
        Text('位置编号: ${_info.location??''}'),
        Text('位置描述: ${_info.locationDescription??''}'),
        Text('资产编号: ${_info.assetnum??''}'),
        Text('资产描述: ${_info.assetDescription??''}'),
        Text('工单状态: ${_info.status}'),
        Text('汇报人员: ${_data?.reportedby ??''}'),
        Text('上报时间: ${Func.getFullTimeString( _data?.reportdate)}'),
      ]);

      if(_info != null && _info.actfinish > 0 && !getModel(context).isTask){
        list.add(Text('完成时间: ${Func.getFullTimeString( _info?.actfinish)}'));
      }
      if(_type != OrderType.XJ){
        list.addAll(<Widget>[
          Text('优先等级: ${_data?.wopriority ?? ''}'),
          Text('主管人员: ${_data?.supervisor??''}'),
          Text('负责人员: ${_data?.lead ?? ''}'),
          Text('联系电话: ${_data?.phone ?? ''}'),
        ]);
      }


//      list.add(Text('站点编号: ${_data?.lead ?? ''}'));

    }

    list.add(SizedBox(height: Style.separateHeight,));

    return list;

  }

  Widget  _getHeader(){
    return new Container(
      color: Colors.white,
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(
              padding: Style.pagePadding2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('基本信息'),
                  SimpleButton(
                    onTap: (){
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (_) => new AttachmentPage(wonum: _info.wonum, data: getModel(context).stepsList)));
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.attach_file, color: Style.primaryColor, size: 16.0,),
                        Text('查看附件', style: Style.textStyleSelect,)
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(height: 1.0,),
            new Padding(
              padding: Style.pagePadding2,
              child: new Stack(
                children: <Widget>[
                  Column(
                    children: _getList(),
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      child: SimpleButton(
                          onTap: (){
                            setState(() {
                              _expend = !_expend;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(_expend ? '收缩':'展开', style: Style.textStyleSelect,),
                              Icon(_expend ? Icons.expand_less : Icons.expand_more, color: Style.primaryColor,)
                            ],
                          )
                      ))
                ],
              ),
            ),
          ]),

    );
  }


  Widget _getBody() {
    return new Container(
        color: Style.backgroundColor,
        child: new SingleChildScrollView(
          key: ValueKey(_tabIndex),
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _getHeader(),
              SizedBox(height: Style.separateHeight,),
              _data == null ? Func.centerLoading(): _getBody2(),
            ],
          ),
        ));
  }



  void _selectMenu(OrderPostStyle style) async {
    switch(style){
      case OrderPostStyle.Post:

        if(_type == OrderType.XJ) {

          setState(() {
            _show = true;
          });

          try {
            Map response = await getModel(context).api.postXJ(_data?.wonum ?? '');
            OrderDetailResult  result = new OrderDetailResult.fromJson(response);
            if(result.code != 0) {
              Func.showMessage(result.message);
            } else {
              Func.showMessage('提交成功');

              getModel(context).user.orders = await getApi(context).orderCount();

              if(mounted){
                Navigator.popUntil(context, ModalRoute.withName(TaskDetailPage.path));
                Navigator.pop(context, true);
              }
              return;
            }
          } catch (e) {
            print(e);

            Func.showMessage('网络异常提交工单出错');
          }
          if(mounted) {
            setState(() {
              _show = false;
            });
          }
        } else {
          Func.showMessage('提交工单功能暂只支持巡检工单');
        }

        break;
      case OrderPostStyle.Redirect:
        Func.showMessage('该功能还未支持');
        break;
      case OrderPostStyle.Refresh:
        setState(() {
          _show = true;
        });

        _getOrderDetail();

        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    return
      LoadingView(
          show: _show,
          confirm: true,
          child: new Scaffold(
            appBar: new AppBar(
              title: Text(_info?.wonum ?? '',),
              actions: getModel(context).isTask ?  <Widget>[
                new PopupMenuButton<OrderPostStyle>(
                  onSelected: _selectMenu,
                  itemBuilder: (BuildContext context) => <PopupMenuItem<OrderPostStyle>>[
                    const PopupMenuItem<OrderPostStyle>(
                      value: OrderPostStyle.Post,
                      child: const Text('提交工作流'),
                    ),
                    const PopupMenuItem<OrderPostStyle>(
                      value: OrderPostStyle.Redirect,
                      child: const Text('转移工作流'),
                    ),
                    const PopupMenuItem<OrderPostStyle>(
                      value: OrderPostStyle.Refresh,
                      child: const Text('刷新工作流'),
                    ),
                  ],
                ),
              ] : null,
            ),
            body: _info== null? Text(''): _getBody(),
            floatingActionButton: _tabIndex == 1 ? new FloatingActionButton(
                child: Tooltip(child: new Image.asset(ImageAssets.scan, height: 20.0,), message: '扫码', preferBelow: false,),
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  String result = await Func.scan();

                  if(result.isNotEmpty){
                    _stepKey.currentState?.gotoStep(result);
                  }

                }) : null,
            bottomNavigationBar: new BottomNavigationBar(
              items: _getBottomBar(),
              currentIndex: _tabIndex,
              onTap: (index) {
                setState((){
                  _tabIndex = index;
                });
              },
            ),
          )
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

  @override
  void reassemble() {
    super.reassemble();
  }

}

enum OrderPostStyle {
  Post,
  Redirect,
  Refresh

}
