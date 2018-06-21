import 'package:flutter/material.dart';

import 'package:samex_app/model/material.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/components/simple_button.dart';


class MaterialPage extends StatefulWidget {
  @override
  _MaterialPageState createState() => _MaterialPageState();
}

class _MaterialPageState extends State<MaterialPage> {
  TextEditingController _scroller;
  bool _loading = true;
  bool _request = false;

  @override
  void initState() {
    super.initState();

    _scroller = new TextEditingController(text: '');
    _scroller.addListener(() {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    final list = getMemoryCache(cacheKey, callback: () {
      _getMaterials();
    });

    if (list != null) _loading = false;

    return new Scaffold(
      appBar: new AppBar(
        title: Text('库存查询'),
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.refresh),
              tooltip: '数据刷新',
              onPressed: () {
                if (!_loading) {
                  _getMaterials();
                }
              })
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          child: Tooltip(
            child: new Image.asset(
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
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Style.backgroundColor,
            padding: const EdgeInsets.all(20.0),
            child: new TextField(
              controller: _scroller,
              decoration: new InputDecoration(
                  hintText: "请输入物料编号/名称进行过滤",
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
          ),
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

  List<MaterialData> _filters(List<MaterialData> data) {
    if (data == null) return null;

    return data.where((MaterialData f) {

      if (_scroller.text.length > 0) {
        if ((f.itemnum??'').contains(_scroller.text.toUpperCase())) {
          return true;
        }

        if ((f.description??'').contains(_scroller.text.toUpperCase())) {
          return true;
        }

        return false;
      }

      return true;
    }).toList();
  }

  Widget _getContent() {
    List<MaterialData> data = getMemoryCache(cacheKey, expired: false);

    data = _filters(data);

    if (data == null || data.length == 0) {
      return Center(
        child: Text('没有可选择的资产'),
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
                  onTap:(){},
                  padding: EdgeInsets.all(8.0),
                  child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('${index+1}: ${info.description}', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                        SizedBox(height: 8.0,),
                        Wrap(
                            children: <Widget>[
                              Text('编号:${info.itemnum}'),
                              Text('类别:${info.in26 ??'无'}'),
                              Text('规格:${info.in27??'无'}'),
                              Text('余量: ${info.curbal} ${info.orderunit}'),
                              Text('位置:${info.locationdescription??''}'),
                              Text('上次盘点:${Func.getFullTimeString(info.physcntdate)}')
                            ],
                            spacing: 16.0,
                            runSpacing: 8.0,
//                    alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.center

                        )
                      ],
                      )
                ),
                Divider(
                  height: 1.0,
                )
              ],
            ));
      },
    );
  }

  String get cacheKey =>
      '__${Cache.instance.site}_materials';

  void _getMaterials({String asset = '', int count = 50000, bool queryOne}) async {
    if (_request) return;
    setState(() {
      _loading = true;
    });
    try {
      _request = true;
      Map response = await getModel(context).api.getMaterials();
      MaterialResult result = new MaterialResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        setMemoryCache<List<MaterialData>>(cacheKey, result.response);
      }

    } catch (e) {
      print(e);
      setMemoryCache<List<MaterialData>>(
          cacheKey, getMemoryCache(cacheKey) ?? []);

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
