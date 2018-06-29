import 'dart:math';

import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/simple_button.dart';

class MaterialPage extends StatefulWidget {
  @override
  _MaterialPageState createState() => _MaterialPageState();
}

class _MaterialPageState extends State<MaterialPage> {
  bool _show = false;


  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
    new TextEditingController(text:  '');
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void setMountState(VoidCallback func) {
    if (mounted) {
      setState(func);
    }
  }



  void _post() async {
    Func.closeKeyboard(context);

    if (_controller.text.isEmpty) {
      Func.showMessage('请填写工单描述');
      return;
    }

    setState(() {
      _show = true;
    });

    try {

    } catch (e) {
      print(e);
    }

  }

  Widget _getMenus({
    String preText,
    Widget content,
    EdgeInsets padding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return new Container(
      padding: padding ?? EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Text(preText),
          SizedBox(
            width: Style.separateHeight,
          ),
          Expanded(child: content)
        ],
      ),
      decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border(
              bottom: Divider.createBorderSide(context, width: 1.0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          title: Text('新增维修工单'),
        ),
        body: new GestureDetector(
            onTap: () {
              Func.closeKeyboard(context);
            },
            child: LoadingView(
              show: _show,
              child: Container(
                  color: Style.backgroundColor,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: <Widget>[
                      new Positioned(left: 0.0, top: 0.0, bottom: max(80.0, MediaQuery.of(context).viewInsets.bottom), right: 0.0, child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _getMenus(preText: '类型:', content: Text('维修单')),
                            _getMenus(
                                preText: '描述:',
                                content: TextField(
                                  controller: _controller,
                                  maxLines: 3,
                                  decoration: new InputDecoration.collapsed(
                                    hintText: '请输入工单描述',
                                  ),
                                ),
                                crossAxisAlignment: CrossAxisAlignment.start),
                            _getMenus(
                                preText: '资产:',
                                padding: EdgeInsets.only(left: 8.0),
                                content: SimpleButton(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                                    onTap: () async {

                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                           '请选择资产',
                                        ),
                                        Icon(
                                          Icons.navigate_next,
                                          color: Colors.black87,
                                        ),
                                      ],
                                    ))),
                            _getMenus(
                                preText: '描述:',
                                content: Text('资产描述',)),
                            _getMenus(
                                preText: '位置:',
                                padding: EdgeInsets.only(left: 8.0),
                                content: SimpleButton(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                                    onTap: () async {

                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          '请选择位置',
                                        ),
                                        Icon(
                                          Icons.navigate_next,
                                          color: Colors.black87,
                                        ),
                                      ],
                                    ))),
                            _getMenus(
                                preText: '描述:',
                                content: Text(
                                     '位置描述',)),
                            _getMenus(
                                preText: '上报人:',
                                content: Text(Cache.instance.userDisplayName)),
                          ],
                        ),
                      )),
                      Positioned(left: 0.0, bottom: 0.0, right: 0.0, child:Material(
                        elevation: 6.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(horizontal: 40.0),
                              onPressed: () {
                                  _post();
                              },
                              child: Text(
                                '提交',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              ),
                              color: Style.primaryColor,
                            ),
                          ),
                        ),
                      ))
                    ],
                  )),
            )));
  }
}
