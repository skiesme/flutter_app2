import 'dart:math';
import 'package:flutter/material.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/model/order_new.dart';
import 'package:dio/dio.dart';

import 'package:samex_app/model/description.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/page/choose_assetnum_page.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:samex_app/model/cm_history.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/page/task_detail_page.dart';

class OrderNewPage extends StatefulWidget {
  final OrderPostData data;

  OrderNewPage({this.data});

  @override
  _OrderNewPageState createState() => _OrderNewPageState();
}

class OrderPostData {
  String worktype = 'CM';
  String description;
  String assetnum;
  String location;
  String reportedby;
  String assetDescription;
  String locationDescription;
  List<String> images;

  OrderPostData({this.images, this.description, this.assetnum, this.assetDescription, this.location, this.locationDescription});
}

class _OrderNewPageState extends State<OrderNewPage> {
  bool _show = false;

  OrderPostData _data;
  GlobalKey<PictureListState> _key = new GlobalKey<PictureListState>();
  CalculationManager _manager;

  TextEditingController _controller;
  TextEditingController _controller2;


  String _tips;

  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _data = widget.data ?? new OrderPostData();
    _controller = new TextEditingController(text: '');
    _controller2 = new TextEditingController(text: Cache.instance.userPhone ?? '');

    _manager?.stop();
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

  List<String> getUploadImages(List<ImageData> images) {
    List<String> list = [];
    if (images == null) return list;

    images.forEach((ImageData f) {
      try {
        print('add, ${f.toString()}');
        if (f.path.startsWith('/')) {
          list.add(f.path);
        }
      } catch (e) {}
    });

    return list;
  }

  void _getHistory() async {

    Func.closeKeyboard(context);

    if (_controller.text.isEmpty) {
      Func.showMessage('请填写工单描述');
      return;
    }

    if (!Func.validatePhone(_controller2.text)) {
      Func.showMessage('请填写联系电话');
      return;
    }


    setState(() {
      _show = true;
    });

    try {
      Map response = await getApi(context).historyCM(_data.assetnum, location:_data.location);
      CMHistoryResult result = new CMHistoryResult.fromJson(response);

      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        List<CMHistoryData> data = result.response;
        if(data.length > 0){
          showDialog(
              context: context,
              builder: (BuildContext context) =>
              new AlertDialog(
//                titlePadding : const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
//                contentPadding : const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
                title: Text('最近的报修记录', style: TextStyle(fontSize: 16.0),),
                content: SingleChildScrollView(child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: data.map(
                          (CMHistoryData f) =>
                          SimpleButton(
                            padding: EdgeInsets.all(0.0),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                              title: Text(f.assetDescription??'', style: TextStyle(fontSize: 16.0)),
                              subtitle: Text('${f.description}'),
                              trailing: Text('${f.status}\n${Func.getYearMonthDay(f.actfinish*1000)}', textAlign: TextAlign.right,),
                            ),
                            onTap: (){
                              OrderShortInfo info = new OrderShortInfo(wonum: f.wonum, worktype: "CM");
                              Navigator.push(context, new MaterialPageRoute(
                                  builder: (_) => new TaskDetailPage(info: info)));

                            },
                          )).toList(),
                )),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },

                  ),
                  new FlatButton(
                    child: new Text('继续'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _post();
                    },)
                ],
              )
          );

        } else {
          _post();
          return;
        }
      }

    } catch (e){
      print (e);
      Func.showMessage('网络出现异常: 获取最近报修工单失败');
    }

    if(mounted){
      setState(() {
        _show = false;
      });
    }

  }


  void _post() async {
    Func.closeKeyboard(context);

    if (_controller.text.isEmpty) {
      Func.showMessage('请填写工单描述');
      return;
    }

    if (!Func.validatePhone(_controller2.text)) {
      Func.showMessage('请填写联系电话');
      return;
    }

    setState(() {
      _show = true;
    });

    try {
      List<String> origin = new List();
      origin.addAll(_data.images ?? []);

      String images = '';
      for (int i = 0, len = _data.images?.length ?? 0; i < len; i++) {

        String image = _data.images[i];

        if(image.contains('_')){
          images += image.split('_')[0];
        } else {
          images += _data.images[i];
        }
        if (i != len - 1) {
          images += ',';
        }
      }

      List<UploadFileInfo> list = new List();

      List<String> uploadImages =
      getUploadImages(_key.currentState.getImages());

      var post = () async {
        try {
          _manager?.stop();
          Map response = await getApi(context).postOrder(
              worktype: _data.worktype,
              assetnum: _data.assetnum,
              location: _data.location,
              description: _controller.text,
              phone: _controller2.text,
              reportedby: Cache.instance.userName,
              images: images,
              files: list,
              onProgress: (send, total){
                int percent = ((send / total) * 100).toInt();
                print('received: percent= $percent');
                setMountState(() {
                  if(percent == 100) {
                    _progress = 0;
                    _tips = '后台处理中...';

                  } else {
                    _progress = percent;
                    _tips = '上传中...($percent\%)';

                  }
                });

              }
          );
          OrderNewResult result = new OrderNewResult.fromJson(response);
          if (result.code != 0) {
            Func.showMessage(result.message);
          } else {
            Func.showMessage('新建成功');
            Navigator.pop(context, true);
            return;
          }
        } catch (e) {
          _data.images?.clear();
          _data.images?.addAll(origin);
          print(e);
          Func.showMessage('出现异常, 新建工单失败');
        }

        if (mounted) {
          setState(() {
            _show = false;
            _progress = 0;
          });
        }
      };

      if (uploadImages.length > 0) {
        _manager = new CalculationManager(
            images: uploadImages,
            onProgressListener: (int step) {
              setMountState(() {
                _tips = '图片$step处理中';
              });
            },
            onResultListener: (List<UploadFileInfo> files) {
              print('onResultListener ....len=${files.length}, ');
              list = files;

              setMountState(() {
                _tips = '上传中';
              });
              post();
            });

        _manager?.start();
      } else {
        post();
      }
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
              tips: _tips,
              progress: _progress,
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
                                      final DescriptionData result =
                                      await Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (_) =>
                                              new ChooseAssetPage(
                                                location:
                                                _data.location,
                                              )));

                                      if (result != null) {
                                        setState(() {
                                          _data.assetnum = result.assetnum;
                                          _data.assetDescription =
                                              result.description;
                                          _data.location = result.location;
                                          _data.locationDescription =
                                              result.locationDescription;
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          _data.assetnum ?? '请选择资产',
                                          style: TextStyle(
                                              color: _data.assetnum == null
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
                                content: Text(
                                    _data.assetDescription ?? '资产描述',
                                    style: TextStyle(
                                        color: _data.assetnum == null
                                            ? Colors.grey
                                            : Colors.black))),
                            _getMenus(
                                preText: '位置:',
                                padding: EdgeInsets.only(left: 8.0),
                                content: SimpleButton(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                                    onTap: () async {
                                      final DescriptionData result =
                                      await Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (_) =>
                                              new ChooseAssetPage(
                                                chooseLocation: true,
                                              )));

                                      if (result != null) {
                                        setState(() {
                                          _data.location = result.location;
                                          _data.locationDescription =
                                              result.description;
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          _data.location ?? '请选择位置',
                                          style: TextStyle(
                                              color: _data.location == null
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
                                content: Text(
                                    _data.locationDescription ?? '位置描述',
                                    style: TextStyle(
                                        color: _data.location == null
                                            ? Colors.grey
                                            : Colors.black))),
                            _getMenus(
                                preText: '照片:',
                                content: PictureList(
                                  canAdd: true,
                                  images: _data.images,
                                  key: _key,
                                )),

                            _getMenus(
                                preText: '联系电话:',
                                content: TextField(
                                  controller: _controller2,
                                  decoration: new InputDecoration.collapsed(
                                    hintText: '请输入电话号码',
                                  ),
                                ),
                                crossAxisAlignment: CrossAxisAlignment.start),
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
                                if(_data.assetnum != null && _data.assetnum.isNotEmpty){
                                  _getHistory();
                                } else {
                                  _post();
                                }
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
