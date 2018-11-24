import 'dart:async';
import 'package:flutter/material.dart';
import 'package:samex_app/model/description.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/order_detail.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_new.dart';
import 'package:samex_app/page/choose_assetnum_page.dart';
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
import 'package:samex_app/page/material_new_page.dart';
import 'package:samex_app/model/order_material.dart';
import 'package:samex_app/model/cm_attachments.dart';
import 'package:samex_app/components/badge_icon_button.dart';

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

  int _attachments = 0;

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
        String str = (_type == OrderType.XJ) ? '巡检': '维修保养';
        if(_type != OrderType.XJ ){
          if(_data.actfinish == 0){
            str = '$str历史';
          } else {
            str = '工单状态记录';
          }
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
              ), read: _data.actfinish != 0,
              isNew: true,);
            }));

            if(result != null) {
              _peopleAndMaterialKey.currentState?.getData();
            }
          }));
        }

        break;
      case 3:
        children.add(Text('物料计划'));
        if(_data.actfinish == 0){
          children.add(newButton('物料登记', () async {
            final result = await Navigator.push(context, new MaterialPageRoute(builder: (_){
              return new MaterialPage(data: new OrderMaterialData(
                  wonum: _data.wonum
              ), read: _data.actfinish != 0,);
            }));

            if(result != null) {
              _peopleAndMaterialKey.currentState?.getData();
            }
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
        widget = new PeopleAndMaterialList(read: _data.actfinish > 0, isPeople: _tabIndex == 2, data: _data, key: _peopleAndMaterialKey,);
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

  Color getColor(String status){
    String type = getWorkTypeString();
    if(type.contains('报修')){ 
      if(status.contains('待批准')){
        return Colors.red.shade900;
      } else if(status.contains('已批准')){
        return Colors.cyan;
      } else if(status.contains('待验收')){
        return Colors.orange.shade600;
      } else if(status.contains('重做')){
        return Colors.red.shade400;
      } else {
        return Colors.green;
      }
    } else if(type.contains('巡检')){ 
      if(status.contains('进行中')){
        return Colors.blue.shade900;
      } else {
        return Colors.green;
      }
    } else if(type.contains('保养')){ 
      if(status.contains('进行中')){
        return Colors.blue.shade900;
      } else if(status.contains('待验收')){
        return Colors.orange.shade600;
      } else if(status.contains('重做')){
        return Colors.red.shade400;
      } else {
        return Colors.green;
      }
    }
    return Colors.deepOrangeAccent;
  }

  List<Widget> _getList(){
    List<Widget> list = <Widget>[];
    String status = _data?.status??'';
    list.addAll(<Widget>[
      Text('工单编号: ${_info.wonum}'),
      Text('工单类型: ${getWorkTypeString()}'),
      Text('标题名称: ${_data?.description??''}'),
      Row(children: <Widget>[
        Text('工单状态: '),
        Text('${status}', style: TextStyle(color: getColor(status)),),
      ]),
    ]);

    if(_expend){
      list.addAll(<Widget>[
        Text('位置编号: ${_data?.location??''}'),
        Text('位置描述: ${_data?.locationDescription??''}'),
        Text('资产编号: ${_data?.assetnum??''}'),
        Text('资产描述: ${_data?.assetDescription??''}'),
      ]);
      if (_type != OrderType.XJ) {
        list.add(Text('汇报人员: ${_data?.reportedby ??''}'));
      }
      list.add(Text('上报时间: ${Func.getFullTimeString( _data?.reportdate)}'));

      if(_data != null && _data.actfinish > 0){
        list.add(Text('完成时间: ${Func.getFullTimeString( _data?.actfinish)}'));
      }
      if(_type != OrderType.XJ){
        list.addAll(<Widget>[
          Text('联系电话: ${_data?.phone ?? ''}'),
//          Text('优先等级: ${_data?.wopriority ?? ''}'),
          Text('主管人员: ${_data?.supervisor??''}'),
          Text('负责人员: ${_data?.lead ?? ''}'),
        ]);
      }

      if(_data.faultlev.isNotEmpty){
        list.add(Text('故障等级: ${_data.faultlev}'));
      }
      if(_data.woprof.isNotEmpty){
        list.add(Text('报修工单分类: ${_data.woprof}'));
      }

//      list.add(Text('站点编号: ${_data?.lead ?? ''}'));

    }

    list.add(SizedBox(height: Style.separateHeight,));

    return list;
  }

  void _getAttachments() async {

    try{


      var images = new List();

      if(getOrderType(_info.worktype) != OrderType.XJ){

        Map response = await getApi(context).steps(sopnum: '', wonum: _info.wonum, site: Cache.instance.site);
        StepsResult result2 = new StepsResult.fromJson(response);
        
        if(result2.code == 0){
          images.addAll(result2.response.images);
        }
      } else  {
        Map response = await getApi(context).steps(sopnum: '', wonum: _info.wonum, site: Cache.instance.site);
        StepsResult result = new StepsResult.fromJson(response);
        if(result.code == 0){
          List <OrderStep> setps =  result.response.steps;
          for (OrderStep item in setps) {
            images.addAll(item.images);
          }
          setMemoryCache<List<OrderStep>>(cacheStepsKey, setps);
        }
      }

      if(mounted){
        setState(() {
          _attachments = images.length;
        });
      }

      setMemoryCache(cacheKey2, images.length);


    } catch (e){
      print (e);
    }
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
                  _attachments > 0 ? BadgeIconButton(itemCount: _attachments, animation: false, icon: SimpleButton(
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
                  )) : Container()
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

  List<Widget> getRightActions() {
    
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
          if(_data.status.contains('待验收') && f.instruction.contains('指派工单责任人')){
            return;
          }
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

    _attachments = getMemoryCache(cacheKey2, callback: (){
      _getAttachments();
    })??0;

    Widget _getMenus({
      String preText,
      Widget content,
      EdgeInsets padding,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,

    }){
      return new Container(
        padding: padding??EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          children: <Widget>[
            Text(preText),
            SizedBox(width: Style.separateHeight,),
            Expanded(child: content)
          ],
        ),
        decoration: new BoxDecoration(
            color: Colors.white,
            border: new Border(
                bottom: Divider.createBorderSide(context, width: 1.0)
            )),
      );
    }

  // Post
  void _post() async {

    setState(() {
      _show = true;
    });
    
    try {
      // Map response = await getApi(context).postOrder(
      //     worktype: _data.worktype,
      //     assetnum: _data.assetnum,
      //     location: _data.location,
      //     description: _data.description,
          
      //     onProgress: (send, total){
      //       int percent = ((send / total) * 100).toInt();
      //       print('received: percent= $percent');
      //     }
      // );
      // OrderNewResult result = new OrderNewResult.fromJson(response);
      // if (result.code != 0) {
      //   Func.showMessage(result.message);
      // } else {
      //   Func.showMessage('修改成功');
      //   return;
      // }
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        _show = false;
      });
    }
  }

    List<Widget> getBarActions() {
      if (widget.info.actfinish == 0) {
        // 判断是否为 待批准 报修单
        List<Widget> actions = new List<Widget>();
        // if(getOrderType(_info?.worktype) == OrderType.CM && _info.status.contains("等待批准")) {
        //   actions.add(
        //     new IconButton(
        //       icon: Icon(Icons.edit),
        //       tooltip: '编辑',
        //       onPressed: (){
        //         showDialog(
        //           context: context,
        //           builder: (context) {
        //               String label = 'test';
        //               return StatefulBuilder(
        //                   builder: (context, state) {
        //                       print('label = $label');
        //                       return SimpleDialog(
        //                         title: Text('信息编辑', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
        //                         children: <Widget>[
        //                           _getMenus(preText: '工单编号:', content:  Text(_data.wonum ?? '', style: TextStyle(color: _data.wonum == null ? Colors.grey: Colors.black))),
        //                           _getMenus(
        //                             preText: '位置:',
        //                             padding: EdgeInsets.only(left: 8.0),
        //                             content: SimpleButton(
        //                                 padding: EdgeInsets.symmetric(vertical: 8.0),
        //                                 onTap: () async {
        //                                   final DescriptionData result = await Navigator.push( context,
        //                                   new MaterialPageRoute( builder: (context) =>
        //                                     new ChooseAssetPage(
        //                                       chooseLocation: true,
        //                                   )));

        //                                   if (result != null) {
        //                                     state(() {
        //                                       _data.location = result.location;
        //                                       _data.locationDescription = result.locationDescription;
        //                                     });
        //                                   }
        //                                 },
        //                                 child: Row(
        //                                   mainAxisAlignment:
        //                                   MainAxisAlignment.spaceBetween,
        //                                   children: <Widget>[
        //                                     Text(
        //                                       _data.location ?? '请选择位置',
        //                                       style: TextStyle(
        //                                           color: _data.location == null
        //                                               ? Colors.grey
        //                                               : Colors.black),
        //                                     ),
        //                                     Icon(
        //                                       Icons.navigate_next,
        //                                       color: Colors.black87,
        //                                     ),
        //                                   ],
        //                                 )
        //                               )
        //                             ),
        //                           _getMenus(
        //                             preText: '资产:',
        //                             padding: EdgeInsets.only(left: 8.0),
        //                             content: SimpleButton(
        //                                 padding:
        //                                 EdgeInsets.symmetric(vertical: 8.0),
        //                                 onTap: () async {
        //                                   final DescriptionData result =
        //                                   await Navigator.push( context,
        //                                   new MaterialPageRoute(
        //                                       builder: (context) =>
        //                                       new ChooseAssetPage(
        //                                         location: _data.location,
        //                                       )));

        //                                   if (result != null) {
        //                                     state(() {
        //                                       _data.assetnum = result.assetnum;
        //                                       _data.assetDescription = result.description;
        //                                       _data.location = result.location;
        //                                       _data.locationDescription = result.locationDescription;
        //                                     });
        //                                   }
        //                                 },
        //                                 child: Row(
        //                                   mainAxisAlignment:
        //                                   MainAxisAlignment.spaceBetween,
        //                                   children: <Widget>[
        //                                     Text(
        //                                       _data.assetnum ?? '请选择资产',
        //                                       style: TextStyle(
        //                                           color: _data.assetnum == null
        //                                               ? Colors.grey
        //                                               : Colors.black),
        //                                     ),
        //                                     Icon(
        //                                       Icons.navigate_next,
        //                                       color: Colors.black87,
        //                                     ),
        //                                   ],
        //                                 )
        //                               )
        //                             ),
        //                             SimpleButton(
        //                               onTap: (){
        //                                 _post();
        //                               },
        //                               elevation: 2.0,
        //                               shape: new RoundedRectangleBorder(
        //                               borderRadius: new BorderRadius.circular(4.0)),
        //                               padding: EdgeInsets.all(4),
        //                               color: Colors.blueAccent,
        //                               child: Row(
        //                                 children: <Widget>[
        //                                   Text('提交', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        //                                 ],
        //                               )
        //                             )
        //                 ],
        //               );
        //             },
        //           );
        //         }
        //       );
        //     }),
        //   );
        // }

        // refresh work_flow
        actions.add(
          new PopupMenuButton<String>(
            onSelected: _selectMenu,
            itemBuilder: (BuildContext context) => getPopupMenuButton(),
          ),
        );
        return actions.toList();
      }
      return null;
    }


    return
      LoadingView(
          show: _show,
          confirm: true,
          child: new Scaffold(
            appBar: new AppBar(
              title: Text(_info?.wonum ?? '',),
              actions: getBarActions(),
            ),
            body: _info== null? Text(''): _getBody(),
            floatingActionButton: _tabIndex == 1 && getOrderType(_info?.worktype) != OrderType.CM  && _info.actfinish == 0 ? new FloatingActionButton(
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
  String get cacheStepsKey {
    return 'stepsList_${widget.info.wonum}';
  }

  String get cacheKey2 {
    return 'task_detail_${widget.info.wonum}_attachments_2';
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
