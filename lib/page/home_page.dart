import 'package:flutter/material.dart';
import 'package:samex_app/page/login_page.dart';

import 'package:samex_app/utils/cache.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('深水光明移动工单系统'),
      ),

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
}
