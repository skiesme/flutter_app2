import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/components/order_list.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/order_list.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => new _TaskPageState();
}


List<PageHelper<OrderShortInfo> > _pageHelpers = new List();

class _TaskPageState extends State<TaskPage> with SingleTickerProviderStateMixin {

  static TextStyle _textStyleNormal = TextStyle(color: Colors.grey);
  static TextStyle _textStyleSelect = TextStyle(color: Style.primaryColor);

  int _tabIndex = 1;
  TabController _controller;
  TextEditingController _searchQuery;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this, initialIndex: _tabIndex);
    _searchQuery = new TextEditingController();

    _pageHelpers.add(new PageHelper());
    _pageHelpers.add(new PageHelper());
    _pageHelpers.add(new PageHelper());
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
//      _updateSearchQuery(null);
    });
  }

  List<BottomNavigationBarItem> _getBottomBar(){
    List<BottomNavigationBarItem> list = <BottomNavigationBarItem>[];
    int index = 0;
    list.add(new BottomNavigationBarItem(
        icon: new Image.asset(ImageAssets.task_cm, color:  index == _tabIndex ? Style.primaryColor : Colors.grey, height: 24.0,),
        title: Text('报修', style: index++ == _tabIndex ? _textStyleSelect : _textStyleNormal ,)));

    list.add(new BottomNavigationBarItem(
        icon: new Image.asset(ImageAssets.task_xj, color:  index == _tabIndex ? Style.primaryColor : Colors.grey,height: 24.0),
        title: Text('巡检', style: index++ == _tabIndex ? _textStyleSelect : _textStyleNormal ,)));

    list.add(new BottomNavigationBarItem(
        icon: new Image.asset(ImageAssets.task_pm, color:  index == _tabIndex ? Style.primaryColor : Colors.grey,height: 24.0),
        title: Text('保养', style: index++ == _tabIndex ? _textStyleSelect : _textStyleNormal ,)));

    return list;
  }

  Widget _getBody(){
    switch(_tabIndex){
      case 0:
        return new OrderList(helper: _pageHelpers[0], type: OrderType.CM,);
      case 1:
        return new OrderList(helper: _pageHelpers[1], type: OrderType.XJ,);
      default:
        return new OrderList(helper: _pageHelpers[2], type: OrderType.PM,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('任务箱'),
      ),
      body: _getBody(),
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
}
