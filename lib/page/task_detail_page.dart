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
import 'package:samex_app/page/order_post_page.dart';
import 'package:samex_app/page/step_new_page.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/model/work_time.dart';
import 'package:samex_app/page/work_time_page.dart';
import 'package:samex_app/utils/cache.dart';

class TaskDetailPage extends StatefulWidget {

  static const String path = '/TaskDetailPage';

  final OrderShortInfo info;
  TaskDetailPage({this.info});

  @override
  _TaskDetailPageState createState() => new _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> with AfterLayoutMixin<TaskDetailPage> {

  OrderShortInfo _info;
  OrderType _type;
  OrderDetailData _data;

  int _tabIndex = 0;

  bool _expend = false;

  bool _show = false;

  GlobalKey<StepListState> _stepKey = new GlobalKey<StepListState>();
  GlobalKey<PeopleAndMaterialListState> _peopleAndMaterialKey = new GlobalKey<PeopleAndMaterialListState>();

  @override
  void initState() {
    super.initState();
    _data = getMemoryCache(cacheKey, expired: false);
  }


  Future _getOrderDetail({bool force = false}) async{
    try{
      final response = await getApi(context).orderDetail(_info.wonum, force ? 0: _data?.changedate);
      OrderDetailResult result = new OrderDetailResult.fromJson(response);
      if(result.code != 0){
        Func.showMessage(result.message);
      } else {
        OrderDetailData data = result.response;
        if(data != null){

          setMemoryCache<OrderDetailData>(cacheKey, data);
          setState(() {
            _data = data;
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

    final newButton = (String name, VoidCallback cb) {
      return SimpleButton(
        onTap: cb,
        elevation: 4.0,
        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
        padding: EdgeInsets.all(6.0),
        color: Style.primaryColor,
        child: Row(
          children: <Widget>[
            Icon(Icons.add, color: Colors.white,size: 16.0,),
            Text(name, style: TextStyle(color: Colors.white),)
          ],
        ),
      );
    };

    switch(_tabIndex){
      case 0:
        String str = (_type == OrderType.PM) ? '保养' :(_type == OrderType.CM ? '维修' : '巡检');
        if(_type == OrderType.CM && _data.actfinish != 0){
          str = '$str记录';
        } else {
          str = '$str历史';
        }
        children.add(Text(str));
        break;
      case 1:
        children.add(Text('任务列表'));
        if(_type == OrderType.CM && _data.actfinish == 0){
          children.add(newButton('新增任务', () async {
            if(_stepKey.currentState == null) return;
            final result = await Navigator.push(context, new MaterialPageRoute(builder: (_){
              return new StepNewPage(step: new OrderStep(
                stepno: (_stepKey.currentState.steps + 1) * 10,
                assetnum: _data.assetnum,
                assetDescription: _data.assetDescription,
                executor: Cache.instance.userDisplayName,
                wonum: _data.wonum
              ), read: _data.actfinish != 0,);
            }));

            if(result != null) {
              _stepKey.currentState.getSteps();
            }

          }));
        }
        break;
      case 2:
        children.add(Text('人员工时列表'));
        if(_data.actfinish == 0){
          children.add(newButton('新增人员工时', () async {
            final result = await Navigator.push(context, new MaterialPageRoute(builder: (_){
              return new WorkTimePage(data: new WorkTimeData(
                  refwo: _data.wonum
              ), read: _data.actfinish != 0,);
            }));

            if(result != null) {
              _peopleAndMaterialKey.currentState?.getData();
            }
          }));
        }

        break;
      case 3:
        children.add(Text('物料列表'));
        if(_data.actfinish == 0){
          children.add(newButton('新增物料', (){

          }));
        }

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
        widget = new RecentHistory(data: _data,);
        break;
      case 1:
        widget = new StepList(key: _stepKey, data: _data,);
        break;
      case 2:
      case 3:
        widget = new PeopleAndMaterialList(isPeople: _tabIndex == 2, data: _data, key: _peopleAndMaterialKey,);
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
            widget,
          ]),
    );
  }

  List<Widget> _getList(){
    List<Widget> list = <Widget>[];
    list.addAll(<Widget>[
      Text('工单编号: ${_info.wonum}'),
      Text('工单类型: ${getWorkTypeString()}'),
      Text('标题名称: ${_data?.description??''}'),
      Text('工单状态: ${_data?.status??''}'),
//      Text('描述详细: '),
    ]);

    if(_expend){
      list.addAll(<Widget>[
        Text('位置编号: ${_data?.location??''}'),
        Text('位置描述: ${_data?.locationDescription??''}'),
        Text('资产编号: ${_data?.assetnum??''}'),
        Text('资产描述: ${_data?.assetDescription??''}'),
        Text('汇报人员: ${_data?.reportedby ??''}'),
        Text('上报时间: ${Func.getFullTimeString( _data?.reportdate)}'),
      ]);

      if(_data != null && _data.actfinish > 0){
        list.add(Text('完成时间: ${Func.getFullTimeString( _data?.actfinish)}'));
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
                          builder: (_) => new AttachmentPage(order: _info, data: [])));
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


  void _selectMenu(String style) async {
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

        return;
      case OrderPostStyle.Redirect:
        Func.showMessage('该功能还未支持');
        return;
      case OrderPostStyle.Refresh:
        clearMemoryCacheWithKeys(_info.wonum);
        setState(() {
          _show = true;
        });

        _getOrderDetail(force: true);
        return;
    }

    _data.actions?.forEach((Actions f) async {
      if(f.actionid == style){

        final result = await Navigator.push(context,
            new MaterialPageRoute(builder:(_) =>  new OrderPostPage(id: _data.ownerid, action: f, wonum: _data.wonum)));

        if(result != null) {
          clearMemoryCacheWithKeys(_data.wonum);
          if(getModel(context).user.orders > 0){
            getModel(context).user.orders -= 1;
          }
          Navigator.pop(context, 'done');

        }
      }
    });
  }

  List<PopupMenuItem<String>> getPopupMenuButton(){
    List<PopupMenuItem<String>> list = new List();
    switch(getOrderType(widget.info.worktype)){
      case OrderType.XJ:
        list.addAll(
            <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: OrderPostStyle.Post,
                child: const Text('提交工作流'),
              ),
              const PopupMenuItem<String>(
                value: OrderPostStyle.Redirect,
                child: const Text('转移工作流'),
              )]
        );
        break;
      case OrderType.CM:
      case OrderType.PM:

        _data?.actions?.forEach((Actions f){
          list.add(PopupMenuItem<String>(
            value: f.actionid,
            child: Text(f.instruction),
          ));
        });

        break;
      default:
        break;
    }
    list.add(PopupMenuItem<String>(
      value: OrderPostStyle.Refresh,
      child: const Text('刷新工作流'),
    ));
    return list;
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
              actions: widget.info.actfinish == 0 ?  <Widget>[
                new PopupMenuButton<String>(
                  onSelected: _selectMenu,
                  itemBuilder: (BuildContext context) => getPopupMenuButton(),
                ),
              ] : null,
            ),
            body: _info== null? Text(''): _getBody(),
            floatingActionButton: _tabIndex == 1 && getOrderType(_info?.worktype) != OrderType.CM ? new FloatingActionButton(
                child: Tooltip(child: new Image.asset(ImageAssets.scan, height: 20.0,), message: '扫码', preferBelow: false,),
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  String result = await Func.scan();

                  if(result != null && result.isNotEmpty && result.length > 0){
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

  String get cacheKey {
    return 'task_detail_${widget.info.wonum}';
  }

  @override
  void afterFirstLayout(BuildContext context) {

    setState(() {
      _info = widget.info;
      _type = getOrderType(_info.worktype);
      _getOrderDetail();
    });

  }

  @override
  void reassemble() {
    super.reassemble();
  }

}

class OrderPostStyle {
  static const String Post = '__POST';
  static const String Redirect = '__REDIECT';
  static const String Refresh ='__REFRESH';
}
