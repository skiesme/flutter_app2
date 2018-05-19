import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/settings_page.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/page/task_page.dart';
import 'package:after_layout/after_layout.dart';

var _textStyle = new TextStyle(color: Colors.white, fontSize: 16.0);

class MainPage extends StatefulWidget{
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> with AfterLayoutMixin<MainPage>  {


  void openSettings(){
    Navigator.push(context, new MaterialPageRoute(builder: (_) => new SettingsPage()));
  }

  List<Widget> buildSliverList(){
    UserInfo _user = getUserInfo(context);

    List<Widget> list = new List<Widget>();

    list.add(
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
                          width: 24.0,
                          decoration: new BoxDecoration(color: const Color(0xFFFF232D), borderRadius: new BorderRadius.circular(5.0)),
                          padding: EdgeInsets.all(2.0),
                          child: Text('${_user?.orders??0}', style: _textStyle, textAlign: TextAlign.center,),
                        ),
                      ),
                      Text('项任务未处理', style: _textStyle,),
                      Icon(Icons.navigate_next, color: Colors.white,)
                    ],
                  ))

            ],
          ),
        )
    );
    return list;
  }

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      body: new RefreshIndicator(
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
    );
  }

  Future<Null> _handlerRefresh() async {
    try {
      String response = await getApi(context).user();
      UserResult result = new UserResult.fromJson(Func.decode(response));
      if(result.code != 0) {
        Func.showMessage(result.message);
      } else {
        UserInfo info = result.response;

        setState(() {
          setUserInfo(context, info);
        });
      }
    } catch (e){
      print(e);
    }


  }

  @override
  void afterFirstLayout(BuildContext context) {
    _handlerRefresh();
  }
}
