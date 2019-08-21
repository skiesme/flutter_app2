import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:samex_app/components/samex_back_button.dart';

import 'package:samex_app/model/material.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/components/center_popup_menu.dart';

class ChooseMaterialPage extends StatefulWidget {
  final bool needReturn;

  ChooseMaterialPage({this.needReturn = false});

  @override
  _ChooseMaterialPageState createState() => _ChooseMaterialPageState();
}

class _ChooseMaterialPageState extends State<ChooseMaterialPage>
    with AfterLayoutMixin<ChooseMaterialPage> {
  TextEditingController _scroller = new TextEditingController(text: '');
  bool _loading = true;
  bool _request = false;

  GlobalKey<PopupMenuButtonState<_StatusSelect>> _key = new GlobalKey();
  String get cacheKey => '__${Cache.instance.site}_materials';

  _StatusSelect _location = new _StatusSelect(key: '', value: '');
  List<_StatusSelect> _statusList = new List();

  @override
  void initState() {
    super.initState();

    _setupStorages();
  }

  // 初始化 仓库列表
  void _setupStorages() {
    _statusList.clear();

    locationSite.forEach((String key, String value) {
      print('$key - $value');
      _statusList.add(new _StatusSelect(key: key, value: value));
    });

    _setupDefStorage();
  }

  // 初始化 默认仓库, 根据用户的站点，进行水厂匹配
  void _setupDefStorage() {
    _location = _StatusSelect(key: '', value: '');

    _StatusSelect defSelect(String key) {
      if (_statusList.length > 0 && key.length > 0) {
        List<_StatusSelect> kList = _statusList.where((_StatusSelect f) {
          return f.key == key;
        }).toList();
        if (kList.length > 0) {
          return kList.first;
        }
      }
      return _location;
    }

    String site = Cache.instance.site;
    // TODO: 这部分代码不应该写死在这里，需要从服务器将用户的默认仓库对应至User信息中。
    if (site == 'GM') {
      // 维修仓库
      _location = defSelect('WXCK');
    } else if (site == 'JZT') {
      // 甲子塘中心仓库
      _location = defSelect('JZTCK');
    } else if (site == 'SC') {
      // 上村维修仓库
      _location = defSelect('SCWXC');
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    getMemoryCache(cacheKey, callback: () {
      _getMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = getMemoryCache(cacheKey);

    if (list != null) _loading = false;

    return Scaffold(
      appBar: AppBar(
        leading: const SamexBackButton(),
        title: Text('库存查询'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              tooltip: '数据刷新',
              onPressed: () {
                if (!_loading) {
                  _getMaterials();
                }
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Tooltip(
            child: Image.asset(
              ImageAssets.scan,
              height: 20.0,
            ),
            message: '扫码',
            preferBelow: false,
          ),
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            String result = await Func.scan();

            if (result != null && result.isNotEmpty && result.length > 0) {
              _scroller.text = result;
            }
          }),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              color: Style.backgroundColor,
              padding: const EdgeInsets.all(10.0),
              child: Column(children: <Widget>[
                Card(
                  child: SimpleButton(
                    onTap: () {
                      _key.currentState?.showButtonMenu();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            height: 40,
                            child: MyPopupMenuButton<_StatusSelect>(
                              key: _key,
                              child: Row(
                                children: <Widget>[
                                  Text('当前仓库:  '),
                                  Text(
                                    locationSite[_location.key] ?? '',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Align(
                                    child: const Icon(Icons.arrow_drop_down),
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                              itemBuilder: (BuildContext context) {
                                return _statusList.map((_StatusSelect status) {
                                  return PopupMenuItem<_StatusSelect>(
                                    value: status,
                                    child: Text(status.value),
                                  );
                                }).toList();
                              },
                              onSelected: (_StatusSelect value) {
                                setState(() {
                                  _location = value;
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                new TextField(
                  controller: _scroller,
                  decoration: new InputDecoration(
                      hintText: "请输入物料编号/名称/规格进行过滤",
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(8.0),
                      hintStyle: TextStyle(fontSize: 16.0),
                      border: new OutlineInputBorder(),
                      suffixIcon: _scroller.text.isNotEmpty
                          ? new IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _scroller.clear();
                              })
                          : null),
                ),
              ])),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _getContent(),
          )
        ],
      ),
    );
  }

  List<MaterialData> _filters() {
    List<MaterialData> data = getMemoryCache(cacheKey, expired: false);
    if (data == null) return null;

    return data.where((MaterialData f) {
      if (!(f.location ?? '').contains(_location.key)) {
        return false;
      }

      if (_scroller.text.length > 0) {
        if ((f.itemnum ?? '').contains(_scroller.text.toUpperCase())) {
          return true;
        }

        if ((f.description ?? '').contains(_scroller.text.toUpperCase())) {
          return true;
        }

        if ((f.in27 ?? '').contains(_scroller.text.toUpperCase())) {
          return true;
        }

        return false;
      }

      return true;
    }).toList();
  }

  Widget _getContent() {
    List<MaterialData> data = _filters();

    if (data == null || data.length == 0) {
      return Center(
        child: Text('没有可选择的资源'),
      );
    }

    return new ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, int index) {
        MaterialData info = data[index];
        return new Container(
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SimpleButton(
                onTap: () {
                  if (widget.needReturn) {
                    Navigator.pop(context, info);
                  }
                },
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${index + 1}: ${info.description}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                        Text('站点:${info.site ?? ''}',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Wrap(
                        children: <Widget>[
                          Text('编号:${info.itemnum}'),
                          Text('类别:${info.in26 ?? '无'}'),
                          Text('规格:${info.in27 ?? '无'}'),
                          Text('成本:${info.avgcost ?? '无'}'),
                          Text('余量: ${info.curbal} ${info.orderunit}'),
                          Text('位置:${info.locationdescription ?? ''}'),
                          Text(
                              '上次盘点:${Func.getFullTimeString(info.physcntdate)}')
                        ],
                        spacing: 16.0,
                        runSpacing: 8.0,
                        runAlignment: WrapAlignment.center)
                  ],
                )),
            Divider(
              height: 1.0,
            )
          ],
        ));
      },
    );
  }

  void _getMaterials(
      {String asset = '', int count = 50000, bool queryOne}) async {
    if (_request) return;
    setState(() {
      _loading = true;
    });
    try {
      locationSite.clear();
      _request = true;
      Map response = await getApi().getMaterials();
      MaterialResult result = new MaterialResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        setState(() {
          _setupStorages();

          setMemoryCache<List<MaterialData>>(cacheKey, result.response);
        });
      }
    } catch (e) {
      setState(() {
        setMemoryCache<List<MaterialData>>(
            cacheKey, getMemoryCache(cacheKey) ?? []);
      });

      Func.showMessage('网络异常, 请求物料接口失败');
    }

    _request = false;
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}

class _StatusSelect {
  String key;
  String value;

  _StatusSelect({this.key, this.value});
}
