import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/settings_page.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/page/task_page.dart';
import 'package:after_layout/after_layout.dart';

var _textStyle = new TextStyle(color: Colors.white, fontSize: 16.0);


class _Menu {
  final String image;
  final String title;

  _Menu({
    this.image,
    this.title
  });
}

class MainPage extends StatefulWidget{
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> with AfterLayoutMixin<MainPage>  {

  List<_Menu> _menus = <_Menu>[];

  GlobalKey<RefreshIndicatorState> _refreshKey = new GlobalKey<RefreshIndicatorState>();

  void openSettings(){
    Navigator.push(context, new MaterialPageRoute(builder: (_) => new SettingsPage()));
  }

  void _gotoPage(String menu){
    if(ImageAssets.home_order == menu){
      Navigator.push(context, new MaterialPageRoute(builder: (_) => new TaskPage(isTask: false,)));
    }
  }

  Widget getMenu(_Menu menu){
    return new Container(
        height: 140.0,
        margin: new EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: new RaisedButton(
          onPressed: (){
            _gotoPage(menu.image);
          },
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(menu.image, height: 80.0),
              new SizedBox(height: 9.0,),
              Text(menu.title, style: TextStyle(fontSize: 16.0))
            ],
          ),
        ));
  }

  List<TableRow> getTable() {
    List<TableRow> list = <TableRow>[];
    for(int i = 0, len = _menus.length; i< len; i+= 2){

      list.add(new TableRow(
          children: <Widget>[
            getMenu(_menus[i]),
            getMenu(_menus[i+1]),
          ]
      ));
    }

    return list;
  }

  List<Widget> buildSliverList(){
    UserInfo _user = getUserInfo(context);

    List<Widget> list = new List<Widget>();

    list.add(
        new Stack(children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200.0,
            padding: new EdgeInsets.only(bottom: 40.0),
            decoration: new BoxDecoration(
                image: new DecorationImage(image: new AssetImage(ImageAssets.home_background), fit: BoxFit.cover)
            ),
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
                      shape: BoxShape.circle
                  ),
                  child: Icon(Icons.person, size: 60.0, color: Colors.white,),
                ),
                new SizedBox(height: 5.0,),
                Text(_user?.displayname??' ', style: TextStyle(fontSize: 22.0, color: Colors.white),),
                new SizedBox(height: 5.0,),

                new InkWell(
                    onTap: (){
                      Navigator.push(context, new MaterialPageRoute(builder: (_)=> new TaskPage()));
                    },
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Image.asset(ImageAssets.home_message, width: 18.0,),
                        Text('您尚有', style: _textStyle,),
                        Material(color: Colors.transparent,
                          elevation: 2.0,
                          child: new Container(
                            height: 20.0,
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: new BoxDecoration(color: const Color(0xFFFF232D), borderRadius: new BorderRadius.circular(5.0)),
                            child: Center( child: Text('${_user?.orders??0}', style: _textStyle, textAlign: TextAlign.center,)),
                          ),
                        ),
                        Text('项任务未处理', style: _textStyle,),
                        Icon(Icons.navigate_next, color: Colors.white,)
                      ],
                    )),

              ],
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(top: 150.0),
            width: MediaQuery.of(context).size.width,
            child: new Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: getTable(),
            ),

          )
        ])
    );
    return list;
  }

  @override
  void initState() {
    super.initState();

    _menus.add(new _Menu(image: ImageAssets.home_order, title: '工单邮箱'));
    _menus.add(new _Menu(image: ImageAssets.home_assets, title: '资产扫描'));
    _menus.add(new _Menu(image: ImageAssets.home_material, title: '库存查询'));
    _menus.add(new _Menu(image: ImageAssets.home_history, title: '历史记录'));
    _menus.add(new _Menu(image: ImageAssets.home_notification, title: '通知公告'));
    _menus.add(new _Menu(image: ImageAssets.home_meter, title: '仪表抄表'));

  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          onWillPop: (){
            return new Future.value(false);
          },
          child: new Scaffold(
            body: new RefreshIndicator(
                key: _refreshKey,
                onRefresh: _handlerRefresh,
                child: new CustomScrollView(
                    physics: new AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppBar(
                        title: const Text('深水光明移动工单系统'),
                        pinned: true,
                        actions: <Widget>[
                          IconButton(
                              icon: Icon(Icons.settings),
                              tooltip: '设置',
                              onPressed: openSettings),
                        ],
                      ),
                      SliverList(
                        delegate: new SliverChildListDelegate(buildSliverList()),
                      )

                    ])),

            floatingActionButton: new FloatingActionButton(
              onPressed: () async{
                Cache.instance.remove(KEY_TOKEN);

                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_)=> new LoginPage()));
              },
              backgroundColor: Colors.redAccent,
              child: const Icon(
                Icons.lock_open,
                semanticLabel: '注销',
              ),
            ),
          ));
  }

  Future<Null> _handlerRefresh() async {

    UserInfo info = await getApi(context).user();
    if(info != null) {
      setState(() {
        setUserInfo(context, info);
      });
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _refreshKey.currentState.show();
    print('toke: ${Cache.instance.token}');
  }


  @override
  void dispose() {
    super.dispose();
    taskPageHelpers.clear();
  }

  @override
  void reassemble() {
    super.reassemble();

    new Future.delayed(new Duration(milliseconds: 100), (){
      _handlerRefresh();
    });
  }
}
