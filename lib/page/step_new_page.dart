import 'dart:math';

import 'package:flutter/material.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/page/choose_assetnum_page.dart';
import 'package:samex_app/model/description.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:dio/dio.dart';

class StepNewPage extends StatefulWidget {
  final OrderStep step;
  final bool read;

  StepNewPage({@required this.step, this.read = false});

  @override
  _StepNewPageState createState() => _StepNewPageState();
}

class _StepNewPageState extends State<StepNewPage> {
  bool _show = false;
  OrderStep _step;

  GlobalKey<PictureListState> _key = new GlobalKey<PictureListState>();
  CalculationManager _manager;

  TextEditingController _controller;
  TextEditingController _controller2;

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
  void initState() {
    super.initState();
    _step = widget.step;

    _controller = new TextEditingController(text: _step.description ?? '');
    _controller2 = new TextEditingController(text: _step.remark ?? '');
  }

  void setMountState(VoidCallback func) {
    if (mounted) {
      setState(func);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller2?.dispose();
    _manager?.stop();
  }

  void _post() async {
    Func.closeKeyboard(context);
//    print('postStep : ${_controller.text}');

    if (_controller.text == null || _controller.text.length == 0) {
      Func.showMessage('请填写任务描述再提交');
      return;
    }

    setState(() {
      _show = true;
    });

    _step.remark = _controller2.text;
    _step.description = _controller.text;

    try {
      List<String> origin = new List();
      origin.addAll(_step.images ?? []);

      List<ImageData> list = _key.currentState.getImages();

      if (_step.images == null) {
        _step.images = new List();
      }

      for (ImageData img in list) {
        _step.images.add(img.toString());
      }

      List<String> images = _step.getUploadImages();

      print('found len=${images.length}  upload');
      List<MultipartFile> lists = new List();

      var postStep = () async {
        try {
          _manager?.stop();
          Map response = await getApi()
              .postStep(_step, lists, onProgress: (send, total) {});
          StepsResult result = new StepsResult.fromJson(response);
          if (result.code != 0) {
            Func.showMessage(result.message);
          } else {
            Func.showMessage('提交成功');
            Navigator.pop(context, true);
            return;
          }
        } catch (e) {
          widget.step.images.clear();
          widget.step.images.addAll(origin);
          print(e);
          Func.showMessage('网络出现异常, 步骤提交失败');
        }

        setMountState(() {
          _show = false;
        });
      };

      if (images.length > 0) {
        _manager = new CalculationManager(
            images: images,
            onProgressListener: (int step) {},
            onResultListener: (List<MultipartFile> files) {
              print('onResultListener ....len=${files.length}');
              lists = files;
              postStep();
            });

        _manager?.start();
      } else {
        postStep();
      }
    } catch (e) {
      print(e);
      Func.showMessage('出现异常, 新建任务失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          title: Text(_controller.text.isEmpty ? '新增任务' : '任务填写'),
          centerTitle: true,
        ),
        body: new GestureDetector(
          onTap: () {
            Func.closeKeyboard(context);
          },
          child: LoadingView(
            show: _show,
            child: Container(
              color: Style.backgroundColor,
              child: Stack(
                children: <Widget>[
                  new Positioned(
                    left: 0.0,
                    top: 0.0,
                    bottom: max(80.0, MediaQuery.of(context).viewInsets.bottom),
                    right: 0.0,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _getMenus(preText: '工单:', content: Text(_step.wonum)),
                          _getMenus(
                              preText: '步骤:',
                              content: Text('${_step.stepno ~/ 10}')),
                          _getMenus(
                              preText: '描述:',
                              content: TextField(
                                controller: _controller,
                                maxLines: 3,
                                enabled: !widget.read,
                                decoration: new InputDecoration.collapsed(
                                  hintText: '请输入任务描述',
                                ),
                              ),
                              crossAxisAlignment: CrossAxisAlignment.start),
                          _getMenus(
                              preText: '资产:',
                              padding: EdgeInsets.only(left: 8.0),
                              content: SimpleButton(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  onTap: () async {
                                    if (widget.read) return;
                                    final DescriptionData result =
                                        await Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (_) =>
                                                    new ChooseAssetPage()));

                                    if (result != null) {
                                      setState(() {
                                        _step.assetnum = result.assetnum;
                                        _step.assetDescription =
                                            result.description;
                                      });
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        _step.assetnum ?? '请选择资产',
                                        style: TextStyle(
                                            color: _step.assetnum == null
                                                ? Colors.grey
                                                : Colors.black),
                                      ),
                                      Icon(
                                        Icons.navigate_next,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ))),
                          _getMenus(
                              preText: '描述:',
                              content: Text(_step.assetDescription ?? '资产描述',
                                  style: TextStyle(
                                      color: _step.assetnum == null
                                          ? Colors.grey
                                          : Colors.black))),
                          _getMenus(
                              preText: '备注:',
                              content: TextField(
                                controller: _controller2,
                                maxLines: 3,
                                enabled: !widget.read,
                                decoration: new InputDecoration.collapsed(
                                  hintText: '请输入备注',
                                ),
                              ),
                              crossAxisAlignment: CrossAxisAlignment.start),
                          _getMenus(
                              preText: '照片:',
                              content: Row(
                                children: <Widget>[
                                  new PictureList(
                                      canAdd: !widget.read,
                                      images: widget.step.images,
                                      key: _key,
                                      customStr: '')
                                ],
                              )),
                          _getMenus(
                              preText: '人员:',
                              content: Text(_step.executor ?? '')),
                        ],
                      ),
                    ),
                  ),
                  widget.read
                      ? Container()
                      : Positioned(
                          left: 0.0,
                          bottom: 0.0,
                          right: 0.0,
                          child: Material(
                            elevation: 6.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: RaisedButton(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.0),
                                  onPressed: () {
                                    // add dialog
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext bctx) {
                                          return AlertDialog(
                                            title: Text('确认提交'),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text('是否确认提交任务单？'),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('取消'),
                                                onPressed: () {
                                                  Navigator.of(bctx).pop();
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('确定'),
                                                onPressed: () {
                                                  _post();
                                                  Navigator.of(bctx).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        });
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
              ),
            ),
          ),
        ));
  }
}
