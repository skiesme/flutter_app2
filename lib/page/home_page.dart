import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:samex_app/components/samex_back_button.dart';
import 'package:samex_app/helper/event_bus_helper.dart';
import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/settings_page.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/page/task_page.dart';
import 'package:samex_app/page/order_new_page.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/page/choose_assetnum_page.dart';
import 'package:samex_app/page/choose_material_page.dart';
import 'package:samex_app/utils/alarm.dart';
import 'package:samex_app/model/update.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:open_file/open_file.dart';

var _textStyle = new TextStyle(color: Colors.white, fontSize: 16.0);

void printHello() {
  final DateTime now = new DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
}

class _Menu {
  final String image;
  final String title;

  _Menu({this.image, this.title});
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> with AfterLayoutMixin<MainPage> {
  List<_Menu> _menus = <_Menu>[];

  bool _show = false;
  String _tips;
  int _progress = 0;

  void setMountState(VoidCallback func) {
    if (mounted) {
      setState(func);
    }
  }

  GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  void openSettings() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (_) => new SettingsPage()));
  }

  void _gotoPage(String menu) {
    if (ImageAssets.home_order == menu) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (_) => new TaskPage(
                    isTask: false,
                  )));
    } else if (ImageAssets.home_assets == menu) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (_) => new ChooseAssetPage(
                    needReturn: false,
                  )));
    } else if (ImageAssets.home_material == menu) {
      Navigator.push(context,
          new MaterialPageRoute(builder: (_) => new ChooseMaterialPage()));
    }
  }

  Widget getMenu(_Menu menu) {
    return new Container(
        height: 100.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: new RaisedButton(
          onPressed: () {
            _gotoPage(menu.image);
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(menu.image, height: 60.0),
              new SizedBox(
                height: 9.0,
                width: double.infinity,
              ),
              Text(menu.title, style: TextStyle(fontSize: 16.0))
            ],
          ),
        ));
  }

  List<TableRow> getTable() {
    List<TableRow> list = <TableRow>[];
    for (int i = 0, len = _menus.length; i < len; i += 1) {
      list.add(new TableRow(children: <Widget>[
        getMenu(_menus[i]),
//            getMenu(_menus[i+1]),
      ]));
    }

    return list;
  }

  List<Widget> buildSliverList() {
    UserInfo _user = getUserInfo(context);

    List<Widget> list = new List<Widget>();

    list.add(new Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: 200.0,
        padding: new EdgeInsets.only(bottom: 40.0),
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage(ImageAssets.home_background),
                fit: BoxFit.cover)),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 64.0,
              padding: new EdgeInsets.all(2.0),
              decoration: new BoxDecoration(
//                    image: new DecorationImage(image: new AssetImage(ImageAssets.login_user)),
                  color: Colors.blue,
                  shape: BoxShape.circle),
              child: Icon(
                Icons.person,
                size: 60.0,
                color: Colors.white,
              ),
            ),
            new SizedBox(
              height: 5.0,
            ),
            Text(
              Cache.instance.userDisplayName,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            new SizedBox(
              height: 10.0,
            ),
            new InkWell(
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (_) => new TaskPage()));
                },
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Image.asset(
                      ImageAssets.home_message,
                      width: 18.0,
                    ),
                    Text(
                      '您尚有',
                      style: _textStyle,
                    ),
                    Material(
                      color: Colors.transparent,
                      elevation: 2.0,
                      child: new Container(
                        height: 24.0,
                        padding: EdgeInsets.fromLTRB(2.0, 1.0, 2.0, 2.0),
                        decoration: new BoxDecoration(
                            color: const Color(0xFFFF232D),
                            borderRadius: new BorderRadius.circular(5.0)),
                        child: Center(
                            child: Text(
                          '${_user?.orders ?? 0}',
                          style: _textStyle,
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Text(
                      '项任务未处理',
                      style: _textStyle,
                    ),
                    Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    )
                  ],
                )),
          ],
        ),
      ),
      new Container(
        margin: new EdgeInsets.only(top: 170.0),
        width: MediaQuery.of(context).size.width,
        child: new Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: getTable(),
        ),
      )
    ]));
    return list;
  }

  @override
  void initState() {
    super.initState();

    _eventBusObserver();

    _menus.add(new _Menu(image: ImageAssets.home_order, title: '工单箱'));
    _menus.add(new _Menu(image: ImageAssets.home_assets, title: '资产扫描'));
    _menus.add(new _Menu(image: ImageAssets.home_material, title: '库存查询'));
//    _menus.add(new _Menu(image: ImageAssets.home_history, title: '历史记录'));
//    _menus.add(new _Menu(image: ImageAssets.home_notification, title: '通知公告'));
//    _menus.add(new _Menu(image: ImageAssets.home_meter, title: '仪表抄表'));
  }

  void _eventBusObserver() {
    eventBus.on<HDTaskEvent>().listen((event) {
      if (event.type == HDTaskEventType.refresh) {
        _handlerRefresh();
      }
    });
  }

  void _checkUpdate() async {
    try {
      final response = await getApi().checkUpdate();
      UpdateResult result = UpdateResult.fromJson(response);
      if (result.code == 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                title: new Text('发现新版本!'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: new Text('取消'),
                  ),
                  new FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop(true);

                      try {
                        OpenFile.open(await getApi().download(
                            result.response.url, (int received, int total) {
                          int percent = ((received / total) * 100).toInt();

                          setMountState(() {
                            if (percent == 100) {
                              _progress = 0;
                              _tips = '';
                              _show = false;
                            } else {
                              _progress = percent;
                              _tips = '更新包下载中...($percent\%)';
                              _show = true;
                            }
                          });
                        }));
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: new Text('下载'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print('检查更新失败: $e');
    }
  }

  Widget _buildHeaderLeft() {
    if (SamexInstance.isModule) {
      return SamexBackButton();
    } else {
      return Image.asset(ImageAssets.logo, width: 24, height: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return new Future.value(false);
        },
        child: new LoadingView(
            show: _show,
            tips: _tips,
            progress: _show ? _progress : 0,
            confirm: true,
            child: new Scaffold(
              body: new RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: _handlerRefresh,
                  child: new CustomScrollView(
                      physics: new AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverAppBar(
                          leading: _buildHeaderLeft(),
                          pinned: true,
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(Icons.add),
                                tooltip: '新增工单',
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (_) => new OrderNewPage()));
                                }),
                            IconButton(
                                icon: Icon(Icons.settings),
                                tooltip: '设置',
                                onPressed: openSettings),
                          ],
                        ),
                        SliverList(
                          delegate:
                              new SliverChildListDelegate(buildSliverList()),
                        )
                      ])),
              floatingActionButton: new FloatingActionButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => new AlertDialog(
                          content: new Text('确定退出登录?'),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: new Text(
                                '取消',
                              ),
                            ),
                            new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                                setToken(context, null);

                                // 清除缓存
                                clearMemoryCache();

                                Navigator.pushReplacement(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (_) => new LoginPage()));
                              },
                              child: new Text(
                                '退出',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                backgroundColor: Colors.transparent,
                child: Image.asset(ImageAssets.logout),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            )));
  }

  Future<Null> _handlerRefresh() async {
    UserInfo info = await getApi().user();
    if (Platform.isAndroid) {
      _checkUpdate();
    }

    if (info != null && mounted) {
      setState(() {
        setUserInfo(context, info);
        Alarm.start(
            token: SamexInstance.singleton.token,
            workers: info.orders,
            url: getCountUrl());
      });
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _refreshKey.currentState.show();
    print('toke: ${SamexInstance.singleton.token}');
  }

  @override
  void dispose() {
    super.dispose();
    clearMemoryCache();
    Alarm.stop();
  }

  @override
  void reassemble() {
    super.reassemble();

    new Future.delayed(new Duration(milliseconds: 100), () {
      _handlerRefresh();
    });
  }
}
