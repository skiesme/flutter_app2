import 'package:flutter/material.dart';
import 'package:samex_app/components/center_popup_menu.dart';
import 'package:samex_app/model/site.dart';

import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/login.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/page/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _controller;
  TextEditingController _controller2;
  bool _obscureText = true;
  bool _showLoading = false;
  GlobalKey<PopupMenuButtonState<Site>> _key = new GlobalKey();
  List<Site> _siteList = new List();
  Site _defSite;

  String get cacheKey => '__Cache.instance.site_list';
  void loadSiteDatas() async {
    try {
      final response = await getApi(context).getSites();
      SiteResult res = new SiteResult.fromJson(response);
      if (res.code != 0) {
        if(res.code == 20000) {
          _controller.clear();
        }
        _controller2.clear();
        Func.showMessage(res.message);
      } else {
        setMemoryCache<List<Site>>(cacheKey, res.response);
        setState(() {
          _siteList = res.response;

          if(_defSite == null && _siteList != null && _siteList.length > 0) {
            _defSite = _siteList.first;
          }
        });
      }
    } catch (e) {
      setMemoryCache<List<Site>>(cacheKey, getMemoryCache(cacheKey)??[]);
      print(e);
    }
  }

  void _submit() async {
    Func.closeKeyboard(context);
    if(_controller.text.isEmpty){
      Func.showMessage('请输入用户');
      return;
    }

    if(_controller2.text.isEmpty){
      Func.showMessage('请输入密码');
      return;
    }

    setState(() {
      _showLoading = true;
    });

    try {
      final response = await getApi(context).login(
          _controller.text, _controller2.text, _defSite != null ? _defSite.siteid : '');
      LoginResult result = new LoginResult.fromJson(response);
      if(result.code != 0){
        if(result.code == 20000) {
          _controller.clear();
        }
        _controller2.clear();
        Func.showMessage(result.message);
      } else {
        getModel(context).user = null;
        Cache.instance.setStringValue(KEY_USER_NAME, _controller.text);
        Cache.instance.setStringValue(KEY_TOKEN, result.response.accessToken);

        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_) => new MainPage() ));

      }
    } catch (e){
      print(e);
      Func.showMessage('网络出现异常!');
    }

    setState(() {
      _showLoading = false;
    });
  }

  Widget _buildLoginForm() {
    return new Center(
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('深水光明系统登录', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center, ),
          new SizedBox(height: 5.0),
          new Container(
            height:20,
            alignment: AlignmentDirectional.topCenter,
            child: new MyPopupMenuButton<Site>(
              key:_key,
              child: new Row(
                children: <Widget>[
                new Text(
                  _defSite != null ? _defSite.description : '',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              itemBuilder: (BuildContext context) {
                return _siteList.map((Site site) {
                  return new PopupMenuItem<Site>(
                    value: site,
                    child: new Text(site.description??''),
                    );
                  }).toList();
                },
                onSelected: (Site value) {
                  print('status = ${value}');
                  setState(() {
                    _defSite = value;
                  });
                },
              )
          ),
          new SizedBox(height: 40.0),
          TextField(
            controller: _controller,
            cursorColor: Colors.white,
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
            decoration: new InputDecoration(
              prefixIcon: new Padding(
                  padding: new EdgeInsets.all(12.0),
                  child : new Image.asset(
                    ImageAssets.login_user,
                    height: 22.0,
                  )),
              hintText: '用户名',
              hintStyle: TextStyle(color: Colors.white.withAlpha(125)),
              border: const UnderlineInputBorder(),
            ),
          ),
          new SizedBox(height: 10.0),
          TextField(
            controller: _controller2,
            obscureText: _obscureText,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
            decoration: new InputDecoration(
              prefixIcon: new Padding(
                  padding: new EdgeInsets.all(12.0),
                  child : new Image.asset(
                    ImageAssets.login_password,
                    height: 22.0,
                  )),
              hintText: '密码',
              hintStyle: TextStyle(color: Colors.white.withAlpha(125)),
              border: const UnderlineInputBorder(),
              suffixIcon: new GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child:  new Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white,),
              ),
            ),
          ),
          new SizedBox(height: 30.0),

          new OutlineButton(
              shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all( Radius.circular(20.0))),
              borderSide: new BorderSide(color: Colors.white.withAlpha(125)),
              padding: new EdgeInsets.all(10.0),
              color: const Color.fromARGB(255, 96, 167, 232),
              highlightColor: const Color.fromARGB(255, 96, 167, 232),
              textColor: Colors.white,
              child: SizedBox(
                  width: double.infinity,
                  child: Center(child:Text('登录', style: new TextStyle(fontSize: 18.0),))),
              onPressed: _submit
          ),
          new SizedBox(height: 120.0),


        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text:  Cache.instance.userName??'');
    _controller2 = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _siteList = getMemoryCache(cacheKey, callback: (){
      loadSiteDatas();
    });
    
    if(_defSite == null && _siteList != null && _siteList.length > 0) {
      _defSite = _siteList.first;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new LoadingView(
        show: _showLoading,
        child: new GestureDetector(child: new Container(
          decoration: new BoxDecoration(image: new DecorationImage(image: new AssetImage(ImageAssets.login_background), fit: BoxFit.cover)),
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: new Theme(
            data: new ThemeData(
              primaryColor: Colors.white,
              accentColor: Colors.white,
              hintColor: Colors.white,
            ),
            child:_buildLoginForm(),
          )),
        onTap: (){
          Func.closeKeyboard(context);
        },
      ),
    ));
  }
}
