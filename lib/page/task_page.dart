import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:samex_app/components/orders/hd_orders.dart';
import 'package:samex_app/components/orders/order_list.dart';

import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/badge_icon_button.dart';
import 'package:samex_app/data/badge_bloc.dart';
import 'package:samex_app/data/bloc_provider.dart';

class TaskPage extends StatefulWidget {

  final bool isTask;

  TaskPage({this.isTask = true});

  @override
  _TaskPageState createState() => new _TaskPageState();
}

List<PageHelper<OrderShortInfo> > taskPageHelpers = new List();
List<HDOrders> taskOrderLists = new List();

class _TaskPageState extends State<TaskPage> with SingleTickerProviderStateMixin, AfterLayoutMixin<TaskPage> {

  int _tabIndex = 1;
  TabController _controller;
  TextEditingController _searchQuery;
  PageController _pageController;
  double _currentPage = 1.0;

  bool _isSearching = false;
  bool _showFloatActionButton = false;

  @override
  void initState() {
    super.initState();

    _controller = new TabController(length: 3, vsync: this, initialIndex: _tabIndex);
    _searchQuery = new TextEditingController();

    // 创建页面
    if(taskPageHelpers.length == 0){
      taskPageHelpers.add(new PageHelper());
      taskPageHelpers.add(new PageHelper());
      taskPageHelpers.add(new PageHelper());
      taskPageHelpers.add(new PageHelper());
    }
    
    _setupIndex();

    _creatOrderLists();
  }

  void _startSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQuery.clear();
      _updateSearchQuery('');
    });
  }

  void _creatOrderLists() {
    taskOrderLists = new List();
    if(!widget.isTask) {
      taskOrderLists.add(new HDOrders(helper: taskPageHelpers[3], type: OrderType.ALL));
    } else {
      taskOrderLists.add(new HDOrders(helper: taskPageHelpers[0], type: OrderType.CM, key: ValueKey(0)));
      taskOrderLists.add(new HDOrders(helper: taskPageHelpers[1], type: OrderType.XJ, key: ValueKey(1)));
      taskOrderLists.add(new HDOrders(helper: taskPageHelpers[2], type: OrderType.PM, key: ValueKey(2)));
    }
  }

  void _setupIndex() {
      _tabIndex = 1;

      String title = Cache.instance.userTitle;
      if(title != null && title.contains('部长')){
        _tabIndex = 0;
      }   

      _pageController = new PageController(initialPage: _tabIndex);
  }

  List<BottomNavigationBarItem> _getBottomBar(Map<OrderType, int> badges){

    if(badges == null) badges = Map();
    List<BottomNavigationBarItem> list = <BottomNavigationBarItem>[];
    int index = 0;
    double imH = 24.0;

    list.add(new BottomNavigationBarItem(
        icon: BadgeIconButton(
          itemCount: 9, 
          // itemCount: badges[OrderType.CM]??0, 
          icon:  new Image.asset(ImageAssets.task_cm, 
          color:  index == _tabIndex ? Style.primaryColor : Colors.grey,
          height: imH)
        ),
        title: Text('报修', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));

    list.add(new BottomNavigationBarItem(
        icon: BadgeIconButton(
          itemCount: 20, 
          // itemCount: badges[OrderType.XJ]??0, 
          icon: new Image.asset(ImageAssets.task_xj, 
          color:  index == _tabIndex ? Style.primaryColor : Colors.grey,
          height: imH)
        ),
        title: Text('巡检', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));

    list.add(new BottomNavigationBarItem(
        icon: BadgeIconButton(
          itemCount: 120, 
          // itemCount: badges[OrderType.PM]??0, 
          icon: new Image.asset(ImageAssets.task_pm, 
          color:  index == _tabIndex ? Style.primaryColor : Colors.grey,
          height: imH)
        ),
        title: Text('保养', style: index++ == _tabIndex ? Style.textStyleSelect : Style.textStyleNormal ,)));

    return list;
  }

  Widget _getBody(){

    Widget show = taskOrderLists[0];
    double width = MediaQuery.of(context).size.width;

    if(!widget.isTask) {
      return show;
    } else {

      return new LayoutBuilder(builder: (context, constraints) => new NotificationListener(
      onNotification: (ScrollNotification note) {
        setState(() {
          _currentPage = _pageController.page;
          _tabIndex = _currentPage.floor();
        });
      },
      child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            physics: const PageScrollPhysics(parent: const BouncingScrollPhysics()),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: width,
                    child: taskOrderLists[0],
                  ),
                  Container(
                    width: width,
                    child: taskOrderLists[1],
                  ),
                  Container(
                    width: width,
                    child: taskOrderLists[2],
                  ),
                ],
              ),
            ),
          )
    ));
    }
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              // Stop searching.
              Navigator.pop(context);
              return;
            }

            _clearSearchQuery();
          },
        ),
      ];
    }

    return widget.isTask ? <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        tooltip: '工单搜索',
        onPressed: _startSearch,
      ),
      new IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: '强制刷新',
        onPressed: (){
          globalListeners.queryChanges(force_refresh);
        },
      ),
    ] : <Widget>[
      new IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: '强制刷新',
        onPressed: (){
          globalListeners.queryChanges(force_refresh);
        },
      ),
    ];
  }

  Widget _buildSearchField() {
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: '输入工单号/资产编号进行查询',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: _updateSearchQuery,
    );
  }

  void _updateSearchQuery(String newQuery) {
//    print('_updateSearchQuery $newQuery');
    globalListeners.queryChanges(newQuery??'');
  }
  
  BottomNavigationBar getBottomBar(Map<OrderType, int> badges){
    return  new BottomNavigationBar(
      items: _getBottomBar(badges),
      currentIndex: _tabIndex,
      onTap: (index) {
        setState((){
          if(_isSearching){
            _updateSearchQuery(_searchQuery.text);
          }
          _tabIndex = index;
          
          _pageController.jumpToPage(index);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BadgeBloc bloc = BlocProvider.of<BadgeBloc>(context);

    return new Scaffold(
      appBar: new AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : (widget.isTask ? Text('任务箱') : Text('工单箱')),
        actions: _buildActions(),
      ),
      body: _getBody(),
      bottomNavigationBar: widget.isTask ? StreamBuilder<Map<OrderType, int> >(
        stream: bloc.outBadges, 
        builder: (context, snapshot){
          if(snapshot.hasData){
            return getBottomBar(snapshot.data);
          } else {
            return getBottomBar(null);
          }
      },) : null,
      floatingActionButton: _showFloatActionButton ?new FloatingActionButton(

          onPressed: (){
            globalListeners.queryChanges(force_scroller_head);
          },
        child: Icon(Icons.navigation),
      ) : null,
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _searchQuery?.dispose();

    globalListeners.removeBoolListener(ChangeBool_Scroll);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    globalListeners.addBoolListener(ChangeBool_Scroll,hashCode, (bool show){
      if(show == _showFloatActionButton) return;
      setState(() {
        _showFloatActionButton = show;
      });
    });
  }
}


