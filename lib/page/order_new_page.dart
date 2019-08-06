import 'dart:math';
import 'package:flutter/material.dart';
import 'package:samex_app/components/samex_back_button.dart';

import 'package:samex_app/data/samex_instance.dart';
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

/** 报修工单 - 故障 分类 */
final List<_StatusSelect> _woprofList = <_StatusSelect>[
  _StatusSelect(0, '机械'),
  _StatusSelect(1, '电气'),
  _StatusSelect(2, '仪表'),
  _StatusSelect(3, '自控'),
  _StatusSelect(4, '其他'),
];

/** 故障等级 */
final List<_StatusSelect> _faultlevList = <_StatusSelect>[
  _StatusSelect(0, 'AA'),
  _StatusSelect(1, 'A'),
  _StatusSelect(2, 'B'),
  _StatusSelect(3, 'C'),
];

final List<_StatusSelect> _woTypeList = <_StatusSelect>[
  _StatusSelect(0, '维修工单'),
  _StatusSelect(1, '办公工单'),
];

class _StatusSelect {
  int key;
  String value;
  _StatusSelect(this.key, this.value);
}

class _OrderNewFormItem {
  String title;
  String value;
  _OrderNewFormItem(this.title, this.value);
}

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

  OrderPostData(
      {this.images,
      this.description,
      this.assetnum,
      this.assetDescription,
      this.location,
      this.locationDescription});
}

class _OrderNewPageState extends State<OrderNewPage> {
  bool _show = false;

  OrderPostData _data;
  GlobalKey<PictureListState> _key = new GlobalKey<PictureListState>();
  CalculationManager _manager;

  TextEditingController _controller;
  TextEditingController _controller2;

  String _woprof = ''; // 故障分类
  String _faultlev = ''; // 故障等级

  String _woType = '维修工单'; // 工单类型

  String _tips;

  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _data = widget.data ?? new OrderPostData();
    _controller = new TextEditingController(text: _data.description);
    _controller2 =
        new TextEditingController(text: Cache.instance.userPhone ?? '');

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
      Map response = await getApi(context)
          .historyCM(_data.assetnum, location: _data.location);
      CMHistoryResult result = new CMHistoryResult.fromJson(response);

      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        List<CMHistoryData> data = result.response;
        if (data.length > 0) {
          showDialog(
              context: context,
              builder: (BuildContext context) => new AlertDialog(
                    title: Text(
                      '最近的报修记录',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    content: SingleChildScrollView(
                        child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: data
                          .map((CMHistoryData f) => SimpleButton(
                                padding: EdgeInsets.all(0.0),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 0.0),
                                  title: Text(f.assetDescription ?? '',
                                      style: TextStyle(fontSize: 16.0)),
                                  subtitle: Text('${f.description}'),
                                  trailing: Text(
                                    '${f.status}\n${Func.getYearMonthDay(f.actfinish * 1000)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                onTap: () {
                                  OrderShortInfo info = new OrderShortInfo(
                                      wonum: f.wonum, worktype: "CM");
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (_) => new TaskDetailPage(
                                              wonum: info.wonum)));
                                },
                              ))
                          .toList(),
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
                        },
                      )
                    ],
                  ));
        } else {
          _post();
          return;
        }
      }
    } catch (e) {
      print(e);
      Func.showMessage('网络出现异常: 获取最近报修工单失败');
    }

    if (mounted) {
      setState(() {
        _show = false;
      });
    }
  }

  void _post() async {
    Func.closeKeyboard(context);
    setState(() {
      _show = true;
    });

    try {
      List<String> origin = new List();
      origin.addAll(_data.images ?? []);
      String images = '';
      for (int i = 0, len = _data.images?.length ?? 0; i < len; i++) {
        String image = _data.images[i];
        if (image.contains('_')) {
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
              woprof: _woprof,
              faultlev: _faultlev,
              reportedby: Cache.instance.userName,
              images: images,
              files: list,
              onProgress: (send, total) {
                int percent = ((send / total) * 100).toInt();
                // debugPrint('order new progress: percent= $percent');
                setMountState(() {
                  if (percent == 100) {
                    _progress = 0;
                    _tips = '后台处理中...';
                  } else {
                    _progress = percent;
                    _tips = '上传中...($percent\%)';
                  }
                });
              });
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
          leading: const SamexBackButton(),
          title: Text('新增维修工单'),
          centerTitle: true,
        ),
        body: new GestureDetector(
            onTap: () {
              Func.closeKeyboard(context);
            },
            child: _loadingView()));
  }

  Widget _loadingView() {
    return LoadingView(
      show: _show,
      tips: _tips,
      progress: _progress,
      child: Container(
          color: Style.backgroundColor,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[_formView(), _actionView()],
          )),
    );
  }

  Widget typeItem() {
    if (Cache.instance.site != 'GM') {
      return _getMenus(preText: '工单类型:', content: Text('维修单'));
    }
    return _getMenus(
        preText: '工单类型:',
        padding: EdgeInsets.only(left: 8.0),
        content: SimpleButton(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(
              _woType.length > 0 ? _woType : '请选择工单类型',
              style: TextStyle(
                  color: _woType.length > 0 ? Colors.black : Colors.grey),
            ),
            new Expanded(
                child: new PopupMenuButton<_StatusSelect>(
              tooltip: '请选择工单类型',
              child: Align(
                child: const Icon(Icons.arrow_drop_down),
                alignment: Alignment.centerRight,
                heightFactor: 1.5,
              ),
              itemBuilder: (BuildContext context) {
                return _woTypeList.map((_StatusSelect status) {
                  return new PopupMenuItem<_StatusSelect>(
                    value: status,
                    child: new Text(status.value),
                  );
                }).toList();
              },
              onSelected: (_StatusSelect value) {
                setState(() {
                  _woType = value.value;
                  _data.worktype = (value.key == 1) ? 'CM' : 'BG';
                });
              },
            ))
          ],
        )));
  }

  Widget typeDesItem() {
    return _getMenus(
        preText: '描述:',
        content: TextField(
          controller: _controller,
          maxLines: 3,
          decoration: new InputDecoration.collapsed(
            hintText: '请输入工单描述',
          ),
        ),
        crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget assetsItem() {
    return _getMenus(
        preText: '资产:',
        padding: EdgeInsets.only(left: 8.0),
        content: SimpleButton(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            onTap: () async {
              final DescriptionData result = await Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (_) => new ChooseAssetPage(
                            location: _data.location,
                          )));

              if (result != null) {
                setState(() {
                  _data.assetnum = result.assetnum;
                  _data.assetDescription = result.description;
                  _data.location = result.location;
                  _data.locationDescription = result.locationDescription;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _data.assetnum ?? '请选择资产',
                  style: TextStyle(
                      color:
                          _data.assetnum == null ? Colors.grey : Colors.black),
                ),
                Icon(
                  Icons.navigate_next,
                  color: Colors.black87,
                ),
              ],
            )));
  }

  Widget assetsDesItem() {
    return _getMenus(
        preText: '描述:',
        content: Text(_data.assetDescription ?? '资产描述',
            style: TextStyle(
                color: _data.assetnum == null ? Colors.grey : Colors.black)));
  }

  Widget locationItem() {
    return _getMenus(
        preText: '位置:',
        padding: EdgeInsets.only(left: 8.0),
        content: SimpleButton(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            onTap: () async {
              final DescriptionData result = await Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (_) => new ChooseAssetPage(
                            chooseLocation: true,
                          )));

              if (result != null) {
                setState(() {
                  _data.location = result.location;
                  _data.locationDescription = result.description;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _data.location ?? '请选择位置',
                  style: TextStyle(
                      color:
                          _data.location == null ? Colors.grey : Colors.black),
                ),
                Icon(
                  Icons.navigate_next,
                  color: Colors.black87,
                ),
              ],
            )));
  }

  Widget locationDesItem() {
    return _getMenus(
        preText: '描述:',
        content: Text(_data.locationDescription ?? '位置描述',
            style: TextStyle(
                color: _data.location == null ? Colors.grey : Colors.black)));
  }

  Widget woprofItem() {
    return _getMenus(
        preText: '故障分类:',
        padding: EdgeInsets.only(left: 8.0),
        content: SimpleButton(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(
              _woprof.length > 0 ? _woprof : '请选择故障分类',
              style: TextStyle(
                  color: _woprof.length > 0 ? Colors.black : Colors.grey),
            ),
            new Expanded(
                child: new PopupMenuButton<_StatusSelect>(
              tooltip: '请选择故障分类',
              child: Align(
                child: const Icon(Icons.arrow_drop_down),
                alignment: Alignment.centerRight,
                heightFactor: 1.5,
              ),
              itemBuilder: (BuildContext context) {
                return _woprofList.map((_StatusSelect status) {
                  return new PopupMenuItem<_StatusSelect>(
                    value: status,
                    child: new Text(status.value),
                  );
                }).toList();
              },
              onSelected: (_StatusSelect value) {
                setState(() {
                  _woprof = value.value;
                });
              },
            ))
          ],
        )));
  }

  Widget faultlevItem() {
    return _getMenus(
        preText: '故障等级:',
        padding: EdgeInsets.only(left: 8.0),
        content: SimpleButton(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(
              _faultlev.length > 0 ? _faultlev : '请选择故障等级',
              style: TextStyle(
                  color: _faultlev.length > 0 ? Colors.black : Colors.grey),
            ),
            new Expanded(
                child: new PopupMenuButton<_StatusSelect>(
              tooltip: '请选择故障等级',
              child: Align(
                child: const Icon(Icons.arrow_drop_down),
                alignment: Alignment.centerRight,
                heightFactor: 1.5,
              ),
              itemBuilder: (BuildContext context) {
                return _faultlevList.map((_StatusSelect status) {
                  return new PopupMenuItem<_StatusSelect>(
                    value: status,
                    child: new Text(status.value),
                  );
                }).toList();
              },
              onSelected: (_StatusSelect value) {
                setState(() {
                  _faultlev = value.value;
                });
              },
            ))
          ],
        )));
  }

  Widget photoItem() {
    return _getMenus(
        preText: '照片:',
        content: PictureList(
          canAdd: true,
          images: _data.images,
          key: _key,
        ));
  }

  Widget editUserItem() {
    return _getMenus(
        preText: '上报人:', content: Text(Cache.instance.userDisplayName));
  }

  Widget userPhoneItem() {
    return _getMenus(
        preText: '联系电话:',
        content: TextField(
          controller: _controller2,
          decoration: new InputDecoration.collapsed(
            hintText: '请输入电话号码',
          ),
        ),
        crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget _formView() {
    return Positioned(
        left: 0.0,
        top: 0.0,
        bottom: max(80.0, MediaQuery.of(context).viewInsets.bottom),
        right: 0.0,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              typeItem(),
              typeDesItem(),
              assetsItem(),
              assetsDesItem(),
              locationItem(),
              locationDesItem(),
              woprofItem(),
              faultlevItem(),
              photoItem(),
              editUserItem(),
              userPhoneItem(),
            ],
          ),
        ));
  }

  Widget _actionView() {
    void showConfirmDialog(BuildContext ctx) {
      double btnFontSize = 16.0;
      Widget diaSure() {
        return FlatButton(
          onPressed: () {
            Navigator.pop(ctx);
            _post();
          },
          child: Text('确定',
              style:
                  TextStyle(color: Colors.blueAccent, fontSize: btnFontSize)),
        );
      }

      Widget diaCancle() {
        return FlatButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: Text('取消',
              style: TextStyle(color: Colors.redAccent, fontSize: btnFontSize)),
        );
      }

      TextSpan itemcell(_OrderNewFormItem item) {
        bool isFirst = item.title == '类型';
        String wrap = isFirst ? '' : '\n';
        return TextSpan(text: '${wrap}${item.title}： ', children: <TextSpan>[
          TextSpan(text: item.value, style: TextStyle(color: Colors.black45))
        ]);
      }

      showDialog(
          context: ctx,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, state) {
                return AlertDialog(
                  title: Text('确认提交？', textAlign: TextAlign.center),
                  content: RichText(
                      text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    children: _confirmDatas().map((_OrderNewFormItem item) {
                      return itemcell(item);
                    }).toList(),
                  )),
                  actions: <Widget>[diaCancle(), diaSure()],
                );
              },
            );
          });
    }

    Widget commitBtn() {
      return RaisedButton(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        onPressed: () {
          if (_data.assetnum != null && _data.assetnum.isNotEmpty) {
            _getHistory();
          } else {
            if (_controller.text.isEmpty) {
              Func.showMessage('请填写工单描述');
              return;
            }
            if (!Func.validatePhone(_controller2.text)) {
              Func.showMessage('请填写联系电话');
              return;
            }
            if (_woprof.length == 0) {
              Func.showMessage('请设置故障分类');
              return;
            }
            if (_faultlev.length == 0) {
              Func.showMessage('请设置故障等级');
              return;
            }

            showConfirmDialog(context);
          }
        },
        child:
            Text('提交', style: TextStyle(color: Colors.white, fontSize: 18.0)),
        color: Style.primaryColor,
      );
    }

    return Positioned(
        left: 0.0,
        bottom: 0.0,
        right: 0.0,
        child: Material(
          elevation: 6.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: commitBtn(),
            ),
          ),
        ));
  }

  List<_OrderNewFormItem> _confirmDatas() {
    List<_OrderNewFormItem> datas = new List();
    datas.add(_OrderNewFormItem('类型', '维修单'));
    datas.add(_OrderNewFormItem('描述', _data.description));
    datas.add(_OrderNewFormItem('资产', _data.assetnum));
    datas.add(_OrderNewFormItem('描述', _data.assetDescription));
    datas.add(_OrderNewFormItem('位置', _data.location));
    datas.add(_OrderNewFormItem('描述', _data.locationDescription));
    datas.add(_OrderNewFormItem('故障分类', _woprof));
    datas.add(_OrderNewFormItem('故障等级', _faultlev));
//    datas.add(_OrderNewFormItem('照片', ''));
    datas.add(_OrderNewFormItem('上报人', Cache.instance.userDisplayName));
    datas.add(_OrderNewFormItem('联系电话', _controller2.text));
    return datas;
  }
}
