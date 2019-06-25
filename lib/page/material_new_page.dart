import 'dart:math';

import 'package:flutter/material.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/model/order_material.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/model/material.dart';
import 'package:samex_app/page/choose_material_page.dart';

class MaterialPage extends StatefulWidget {
  final OrderMaterialData data;
  final bool read;

  MaterialPage({@required this.data, @required this.read});

  @override
  _MaterialPageState createState() => _MaterialPageState();
}

class _MaterialPageState extends State<MaterialPage> {
  bool _show = false;

  OrderMaterialData _data;

  MaterialData _material;

  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _data = widget.data;

    if (_data.woitemid != 0) {
      _material = new MaterialData(
          description: _data.description,
          location: _data.location,
          locationdescription: _data.locationdescription,
          site: _data.storelocsite,
          itemnum: _data.itemnum);
    }

    _controller = new TextEditingController(text: '${_data.itemqty ?? ''}');
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

  void delete() async {
    setState(() {
      _show = true;
    });

    try {
      Map response =
          await getApi(context).delOrderMaterial(widget.data.woitemid);
      OrderMaterialResult result = new OrderMaterialResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        Func.showMessage('删除成功');
        Navigator.pop(context, true);
        return;
      }
    } catch (e) {
      print(e);
      Func.showMessage('出现异常, 删除失败');
    }

    if (mounted) {
      setState(() {
        _show = false;
      });
    }
  }

  void _post() async {
    Func.closeKeyboard(context);

    if (_material == null) {
      Func.showMessage('请选择物料');
      return;
    }

    if (_controller.text.isEmpty) {
      Func.showMessage('请填写物料用量');
      return;
    }

//    if(double.parse(_controller.text) > _material.curbal) {
//      Func.showMessage('库存量不足');
//      return;
//    }

    setState(() {
      _show = true;
    });

    _data.description = _material.description;
    _data.location = _material.location;
    _data.storelocsite = _material.site;
    _data.itemnum = _material.itemnum;
    _data.itemqty = double.parse(_controller.text);

    try {
      Map response = await getApi(context).postOrderMaterial(_data);
      OrderMaterialResult result = new OrderMaterialResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        Func.showMessage('提交成功');
        Navigator.pop(context, true);
        return;
      }
    } catch (e) {
      print(e);
      Func.showMessage('出现异常, 新建物料计划失败');
    }

    if (mounted) {
      setState(() {
        _show = false;
      });
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
          title: Text('新增物料计划'),
          centerTitle: true,
          actions: widget.read || widget.data.woitemid == 0
              ? null
              : <Widget>[
                  new IconButton(
                    icon: Icon(Icons.delete),
                    tooltip: '删除物料计划',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: ((_) => new AlertDialog(
                                title: Text('警告'),
                                content: Text('确认删除该物料计划'),
                                actions: <Widget>[
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('取消'),
                                  ),
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      delete();
                                    },
                                    child: Text(
                                      '删除',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  )
                                ],
                              )));
                    },
                  )
                ],
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
                      new Positioned(
                          left: 0.0,
                          top: 0.0,
                          bottom: max(
                              80.0, MediaQuery.of(context).viewInsets.bottom),
                          right: 0.0,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                _getMenus(
                                    preText: '工单编号:',
                                    content: Text('${_data.wonum}')),
                                _getMenus(
                                    preText: '物料名称:',
                                    padding: EdgeInsets.only(left: 8.0),
                                    content: SimpleButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        onTap: widget.read
                                            ? null
                                            : () async {
                                                final MaterialData result =
                                                    await Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (_) =>
                                                                new ChooseMaterialPage(
                                                                  needReturn:
                                                                      true,
                                                                )));

                                                if (result != null) {
                                                  setState(() {
                                                    _material = result;
                                                  });
                                                }
                                              },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              _material?.description ?? '请选择物料',
                                              style: TextStyle(
                                                  color: _material == null
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
                                    preText: '所在仓库:',
                                    content: Text(
                                      _material?.locationdescription ?? '',
                                    )),
                                _getMenus(
                                    preText: '仓库站点:',
                                    content: Text(
                                      _material?.site ?? '',
                                    )),
                                _getMenus(
                                    preText: '物料余量:',
                                    content: Text(
                                      '${_material?.curbal ?? ''} ${_material?.orderunit ?? ''}',
                                    )),
                                _getMenus(
                                    preText: '所需用量:',
                                    content: TextField(
                                      controller: _controller,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      enabled: !widget.read,
                                      decoration: new InputDecoration.collapsed(
                                        hintText: '请输入所需数量',
                                      ),
                                    )),
                                _getMenus(
                                    preText: '上报人员:',
                                    content: Text(_data.requestby ??
                                        Cache.instance.userDisplayName)),
                                _data.requiredate != null
                                    ? _getMenus(
                                        preText: '上报时间:',
                                        content: Text(Func.getFullTimeString(
                                            _data.requiredate)))
                                    : new Container(),
                              ],
                            ),
                          )),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.0),
                                      onPressed: () {
                                        _post();
                                      },
                                      child: Text(
                                        '提交',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0),
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
