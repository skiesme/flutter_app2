import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/components/order_list.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/data/order_model.dart';
import 'package:samex_app/data/root_model.dart';

class TaskPage extends StatefulWidget {

  final bool isTask;

  TaskPage({this.isTask = true});

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

    if(_pageHelpers.length == 0){
      _pageHelpers.add(new PageHelper());
      _pageHelpers.add(new PageHelper());
      _pageHelpers.add(new PageHelper());
      _pageHelpers.add(new PageHelper());
    }

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
    if(!widget.isTask) return new OrderList(helper: _pageHelpers[3], type: OrderType.ALL,);
    switch(_tabIndex){
      case 0:
        return new OrderList(helper: _pageHelpers[0], type: OrderType.CM,);
      case 1:
        return new OrderList(helper: _pageHelpers[1], type: OrderType.XJ,);
      default:
        return new OrderList(helper: _pageHelpers[2], type: OrderType.PM,);
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

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  Widget _buildSearchField() {
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: '输入工单号',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: _updateSearchQuery,
    );
  }

  void _updateSearchQuery(String newQuery) {
//    print('_updateSearchQuery $newQuery');
    getModel(context).queryChanges(newQuery);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : (widget.isTask ? Text('任务箱') : Text('工单箱')),
        actions: _buildActions(),
      ),
      body: OrderModelWidget(
        model: new OrderModel(),
        child: _getBody(),
      ),
      bottomNavigationBar: widget.isTask ? new BottomNavigationBar(
        items: _getBottomBar(),
        currentIndex: _tabIndex,
        onTap: (index) {
          setState((){
            _tabIndex = index;
          });
        },
      ) : null,
    );
  }

  @override
  void dispose() {
    super.dispose();

    _controller?.dispose();
    _searchQuery?.dispose();
  }
}
