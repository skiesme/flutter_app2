import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:samex_app/components/orders/hd_orders.dart';
import 'package:samex_app/components/samex_back_button.dart';
import 'package:samex_app/helper/event_bus_helper.dart';

import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/badge_icon_button.dart';
import 'package:samex_app/data/badge_bloc.dart';
import 'package:samex_app/data/bloc_provider.dart';

class TaskPage extends StatefulWidget {
  final bool isTask;

  TaskPage({this.isTask = true});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<TaskPage> {
  int _tabIndex = 1;
  TabController _controller;
  TextEditingController _searchQuery;
  PageController _pageController;
  double _currentPage = 1.0;

  bool _isSearching = false;
  bool _showFloatActionButton = false;

  // 工单箱
  final HDOrders woPage = HDOrders(type: OrderType.ALL);

  final HDOrders cmPage = HDOrders(type: OrderType.CM);
  final HDOrders xjPage = HDOrders(type: OrderType.XJ);
  final HDOrders pmPage = HDOrders(type: OrderType.PM);

  @override
  void initState() {
    super.initState();

    _controller =
        TabController(length: 3, vsync: this, initialIndex: _tabIndex);
    _searchQuery = TextEditingController();

    _setupIndex();

    eventBus.on<HDTaskEvent>().listen((event) {
      if (event.type == HDTaskEventType.showFloatTopBtn) {
        bool show = event.value;
        if (show == _showFloatActionButton) return;
        if (mounted) {
          setState(() {
            _showFloatActionButton = show;
          });
        }
      }
    });
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

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

  void _setupIndex() {
    _tabIndex = 1;

    String title = Cache.instance.userTitle;
    if (title != null && title.contains('部长')) {
      _tabIndex = 0;
    }

    _pageController = PageController(initialPage: _tabIndex);
  }

  List<BottomNavigationBarItem> _getBottomBar(Map<OrderType, int> badges) {
    if (badges == null) badges = Map();
    List<BottomNavigationBarItem> list = <BottomNavigationBarItem>[];
    int index = 0;
    double imH = 24.0;

    list.add(BottomNavigationBarItem(
        icon: BadgeIconButton(
            itemCount: badges[OrderType.CM] ?? 0,
            icon: Image.asset(ImageAssets.task_cm,
                color: index == _tabIndex ? Style.primaryColor : Colors.grey,
                height: imH)),
        title: Text(
          '报修',
          style: index++ == _tabIndex
              ? Style.textStyleSelect
              : Style.textStyleNormal,
        )));

    list.add(BottomNavigationBarItem(
        icon: BadgeIconButton(
            itemCount: badges[OrderType.XJ] ?? 0,
            icon: Image.asset(ImageAssets.task_xj,
                color: index == _tabIndex ? Style.primaryColor : Colors.grey,
                height: imH)),
        title: Text(
          '巡检',
          style: index++ == _tabIndex
              ? Style.textStyleSelect
              : Style.textStyleNormal,
        )));

    list.add(BottomNavigationBarItem(
        icon: BadgeIconButton(
            itemCount: badges[OrderType.PM] ?? 0,
            icon: Image.asset(ImageAssets.task_pm,
                color: index == _tabIndex ? Style.primaryColor : Colors.grey,
                height: imH)),
        title: Text(
          '保养',
          style: index++ == _tabIndex
              ? Style.textStyleSelect
              : Style.textStyleNormal,
        )));

    return list;
  }

  Widget _getBody() {
    double width = MediaQuery.of(context).size.width;

    if (!widget.isTask) {
      return woPage;
    } else {
      return LayoutBuilder(
          builder: (context, constraints) => NotificationListener(
              onNotification: (ScrollNotification note) {
                setState(() {
                  _currentPage = _pageController.page;
                  _tabIndex = _currentPage.floor();
                });
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
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
                        child: cmPage,
                      ),
                      Container(width: width, child: xjPage),
                      Container(
                        width: width,
                        child: pmPage,
                      ),
                    ],
                  ),
                ),
              )));
    }
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
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

    return widget.isTask
        ? <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: '工单搜索',
              onPressed: _startSearch,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '强制刷新',
              onPressed: () {
                eventBus.fire(HDTaskEvent(type: HDTaskEventType.refresh));
              },
            ),
          ]
        : <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '强制刷新',
              onPressed: () {
                eventBus.fire(HDTaskEvent(type: HDTaskEventType.refresh));
              },
            ),
          ];
  }

  Widget _buildSearchField() {
    var textField = TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: '输入工单号/资产编号进行查询',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onEditingComplete: () {
        _updateSearchQuery(_searchQuery.text ?? '');
      },
    );
    return textField;
  }

  void _updateSearchQuery(String Query) {
    eventBus.fire(HDTaskEvent(type: HDTaskEventType.query, value: Query));
  }

  BottomNavigationBar getBottomBar(Map<OrderType, int> badges) {
    return BottomNavigationBar(
      items: _getBottomBar(badges),
      currentIndex: _tabIndex,
      onTap: (index) {
        setState(() {
          _tabIndex = index;
          _pageController.jumpToPage(index);
        });
      },
    );
  }

  Widget _buildAppBarLeading() {
    if (SamexInstance.isModule || _isSearching) {
      return const SamexBackButton();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final BadgeBloc bloc = BlocProvider.of<BadgeBloc>(context);

    return Scaffold(
      appBar: AppBar(
        leading: _buildAppBarLeading(),
        title: _isSearching
            ? _buildSearchField()
            : (widget.isTask ? Text('任务箱') : Text('工单箱')),
        centerTitle: true,
        actions: _buildActions(),
      ),
      body: _getBody(),
      bottomNavigationBar: widget.isTask
          ? StreamBuilder<Map<OrderType, int>>(
              stream: bloc.outBadges,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return getBottomBar(snapshot.data);
                } else {
                  return getBottomBar(null);
                }
              },
            )
          : null,
      floatingActionButton: _showFloatActionButton
          ? FloatingActionButton(
              onPressed: () {
                eventBus.fire(HDTaskEvent(type: HDTaskEventType.scrollHeader));
              },
              child: Icon(Icons.navigation),
            )
          : null,
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
  }

  @override
  void afterFirstLayout(BuildContext context) {}
}
