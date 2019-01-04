import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:samex_app/components/load_more.dart';
import 'package:samex_app/components/orders/hd_order_option.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/data/badge_bloc.dart';
import 'package:samex_app/data/bloc_provider.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/page/task_detail_page.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';


/** HDOrderOptions */
class HDOrders extends StatefulWidget {

  HDOrdersState state;
  final PageHelper<OrderShortInfo> helper;
  final OrderType type;

  HDOrders({Key key, @required this.helper, this.type = OrderType.ALL}) :super(key:key);

  @override
  State<StatefulWidget> createState() {
    state = new HDOrdersState();
    return state;
  }
}

class HDOrdersState extends State<HDOrders> with AfterLayoutMixin<HDOrders> {
  static const double _padding = 16.0;
  static const force_scroller_head = 'force_scroller_head';

  HDOrderOptions _orderOptions;
  HDOrderOptionsResult _queryInfo;
  bool _canLoadMore = true;
  List<OrderShortInfo> _filterDatas = new List();
  OrderType _selectedtType;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    setup();
    _selectedtType = widget.type;

    _scrollController = widget.helper.createController();
    _scrollController.addListener((){
      if(_scrollController.offset > context.size.height){
        globalListeners.boolChanges(ChangeBool_Scroll, true);
      } else {
        globalListeners.boolChanges(ChangeBool_Scroll, false);
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      _queryInfo = _orderOptions.def;

      if(_orderOptions != null && _orderOptions.def != null) {
        _selectedtType = _orderOptions.def.type;
      }
    });

    if(_scrollController.initialScrollOffset > 0){
      Future.delayed(new Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.initialScrollOffset + 0.1);
      });
    }

    globalListeners.addListener(hashCode, (String query){
      if(query == force_scroller_head){
        if(_scrollController != null) {
          _scrollController.animateTo(1.0,  duration: Duration(milliseconds: 400),  curve: Curves.decelerate);
        }
        return;
      }
    });

    Future.delayed(Duration.zero,() =>_handleLoadDatas());
  }

  @override
  Widget build(BuildContext context) {

    bool isUp = _queryInfo != null ? _queryInfo.isUp : true;
    List<OrderShortInfo> list = isUp ? _filterDatas.reversed.toList() : _filterDatas;

    Widget listView = Scrollbar(
      child: new ListView.builder(
        physics: _query().isEmpty ? const AlwaysScrollableScrollPhysics() : new ClampingScrollPhysics(),
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index){
          return Container(
            color:  Colors.transparent,
            child: _cellView(list[index])
          );
        }
      )
    );

    Widget view = listView;

    _orderOptions = HDOrderOptions(
      type: _selectedtType,
      badgeCount: _filterDatas.length,
      onSureBtnClicked: (res) => optionSureClickedHandle(res),
      onTimeSortChanged: (isUp) => optionTimeSortChangedHandle(isUp),
    );

    if(widget.type == OrderType.ALL){
      view = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _orderOptions,
          Expanded(child:view),
        ],
      );
    }

    Widget refreshView = RefreshIndicator(
        onRefresh: _handleLoadNewDatas,
        child: LoadMore(
            scrollNotification: widget.helper.handle,
            child: view,
            onLoadMore: () async{
              _handleLoadDatas(1);
            }
        )
    );

    List<Widget> children = <Widget>[
      _query().isEmpty ? refreshView : view
    ];

    if(list.length == 0){
      children.add(
        new Center(
          child: (widget.helper.inital && _query().isEmpty) ? CircularProgressIndicator() : Text('没发现任务')
        )
      );
    }

    return new Container(
      color: const Color(0xFFF0F0F0),
      child: GestureDetector(
        onTap: (){
          Func.closeKeyboard(context);
        },
        child: Stack(children: children)
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    globalListeners.removeListener(hashCode);
  }

  void setup() {
    widget.helper.clear();
    setState(() {
      _filterDatas = filter();
    });
  }

  void optionSureClickedHandle(HDOrderOptionsResult res) {
    print("option query:${res.query}, isAll:${res.isAll}, startTime:${res.startTime}, endTime:${res.endTime}, isUp:${res.isUp}");
    setState(() {
      _queryInfo = res;
      _selectedtType = _orderOptions.type;
    });
    _handleLoadNewDatas();
  }
  void optionTimeSortChangedHandle(bool isTimeUp) {
    String res = isTimeUp ? 'Yes' : 'No';
    print("current is tiem up? ${res}!");
    setState(() {
      _queryInfo.isUp = isTimeUp;
    });
  }

  Future<Null> _handleLoadNewDatas() async {
    widget.helper.clear();
    _handleLoadDatas();
    widget.helper.inital = true;
  }

  /** 网络请求 */
  Future<Null> _handleLoadDatas([int older = 0]) async {
    try{

      Func.closeKeyboard(context);

      if(!_canLoadMore){
//        print('已经在loadMore了...');
        return;
      }

      int time = _queryInfo.endTime;
      int startTime = _queryInfo.startTime;

      if(older == 0 && widget.helper.itemCount() > 0) {
        var data = widget.helper.datas[0];
        startTime = data.reportDate;
      }
      if(older == 1 && widget.helper.itemCount() > 0){
        var data = widget.helper.datas[widget.helper.itemCount() - 1];
        time = data.reportDate;
      }

      _canLoadMore = false;

      print('hd-> query:${_queryInfo}, older:${older}, time:${time}, startTime:${startTime}');

      Map response = await getApi(context).orderList(
          type:_queryInfo.workType,
          status: _queryInfo.status,
          time: time,
          query: _query(),
          all: _queryInfo.isAll ? 0 : 1,
          start: startTime,
          older: older,
          task: _queryInfo.task,
          count: _queryInfo.count);
      OrderListResult result = new OrderListResult.fromJson(response);

      _canLoadMore = true;

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

      setState(() {
        _filterDatas = filter();
      });
    } catch(e){
      print(e);
      Func.showMessage('网络出现异常, 获取工单列表失败');
    }
    if(widget.helper.inital) widget.helper.inital = false;
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

  List<OrderShortInfo> filter(){
    List<OrderShortInfo> list = widget.helper.datas;
    if(_query().isEmpty) {
      list = widget.helper.datas.where((i) => i.wonum.contains(_query()?.toUpperCase()) || (i.assetnum??'').contains(_query()?.toUpperCase())).toList();
    }
    return list;
  }

  String _query() {
    return _queryInfo != null ? _queryInfo.query??'' : '';
  }

  /** Info */
  String getLeadName(OrderShortInfo info){
    if(info.actfinish == 0 && getOrderType(info.worktype) == OrderType.XJ){
      return '';
    } else  {
      String name = info.lead ?? info.changeby??'';
      if (name.contains('Admin')) {
        name = '';
      }
      return name;
    }
  }

  /** Colors */
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
  }


  /** Custom Views */
  Widget _cellView(OrderShortInfo info) {
    return Container(
      color:  Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _separateView(info),
            _cellInfoView(info),
          ],
        )
      )
    );
  }

  Widget _separateView(OrderShortInfo info) {
    return Container(
      height: Style.separateHeight,
      color: getColor(info),
    );
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
          new CircleAvatar(child:new Padding(padding: EdgeInsets.all(8.0), child:  new Image.asset( image , height: 40.0,)), backgroundColor: getColor(info),),
          Text(info.status, style: TextStyle(color: getColor(info)),)
        ]);
      break;
    case OrderType.CM:
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
      )
    );
  }

  Widget _cellInfoView(OrderShortInfo info) {
    Widget titleView() {
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padding, vertical: _padding/2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('$str工单 : ${info.wonum}',style: TextStyle(fontWeight: FontWeight.w700)),
            Text(getLeadName(info), style: TextStyle(fontWeight: FontWeight.w700))
          ],
        ),
      );
    }

    Widget infoView() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padding, vertical: _padding/2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _getSyncStatus(info),
            SizedBox(width: _padding),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('标题: ${info.description}', style: TextStyle(color: getOrderTextColor(info), fontWeight: FontWeight.w700),),
                Text('设备: ${info.assetDescription}'),
                widget.type == OrderType.ALL ? Text('上报时间: ${Func.getFullTimeString(info.reportDate)}'): Text('更新时间: ${Func.getFullTimeString(info.reportDate)}')
              ],
            ))
          ],
        ),
      );
    }

    return SimpleButton(
      onTap: () async {
        Navigator.push(context, new MaterialPageRoute(
          builder: (_) => new TaskDetailPage(info:  info,),
          settings: RouteSettings(name: TaskDetailPage.path)
        ));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          titleView(),
          Divider(height: 1.0,),
          infoView()
        ],
      ),
    );
  }
}