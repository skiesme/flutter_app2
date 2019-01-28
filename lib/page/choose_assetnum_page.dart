import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/model/description.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/page/assetnum_detail_page.dart';

// 资产选择
class ChooseAssetPage extends StatefulWidget {
  final String location;
  final bool chooseLocation;

  final bool needReturn;

  ChooseAssetPage({this.location, this.chooseLocation = false, this.needReturn = true});

  @override
  _ChooseAssetPageState createState() => _ChooseAssetPageState();
}

class _ChooseAssetPageState extends State<ChooseAssetPage> {
  TextEditingController _scroller;
  TextEditingController _scroller2;

  bool _loading = true;
  bool _request = false;

  @override
  void initState() {
    super.initState();

    _scroller = new TextEditingController(text:'');
    _scroller.addListener(() {
      setState(() {});
    });

    _scroller2 = new TextEditingController(text: '');
    _scroller2.addListener(() {
      setState(() {});
    });

    if(widget.chooseLocation) {
      _scroller.text = widget.location??'';
    } else {
      _scroller2.text = widget.location??'';
    }
  }


  String _getTitle(){
    if(!widget.needReturn){
      return '资产扫描';
    } else {
      return widget.chooseLocation ? '位置选择' : '资产选择';
    }
  }

  @override
  void dispose() {
    super.dispose();

    _scroller?.dispose();
    _scroller2?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = getMemoryCache(cacheKey, callback: () {
      _getAsset();
    });

    if (list != null) _loading = false;

    return new Scaffold(
      appBar: new AppBar(
        title: Text(_getTitle()),
        actions: _appBarActions(),
      ),
      floatingActionButton: _scanBtn(),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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

  /// AppBarActions
  List<Widget> _appBarActions() {
    IconButton noActionBtn = IconButton(
      icon: Text('无'),
      tooltip: '无数据',
      onPressed: (){
        if (!_loading) {
          String nullStr = '无';
          DescriptionData asset = new DescriptionData();
          if (widget.chooseLocation) {
            asset.location = nullStr;
            asset.locationDescription = nullStr;
          } else {
            asset.assetnum = nullStr;
            asset.description = nullStr;
            asset.location = nullStr;
            asset.locationDescription = nullStr;
          }
          Navigator.pop(context, asset);
        }
      },
    );

    IconButton refreshBtn = IconButton(
      icon: Icon(Icons.refresh),
      tooltip: '数据刷新',
      onPressed: () {
        if (!_loading) {
          _getAsset();
        }
      }
    );

    List<Widget> btns = new List();
    if (widget.needReturn) {
      btns.add(noActionBtn);
    }
    btns.add(refreshBtn);

    return btns;
  }

  /// Scan Btn
  FloatingActionButton _scanBtn () {
    return FloatingActionButton(
      child: Image.asset(
        ImageAssets.scan,
        height: 20.0,
      ),
      backgroundColor: Colors.redAccent,
      onPressed: () async {
        String result = await Func.scan();

        if (result != null && result.isNotEmpty && result.length > 0) {
          _scroller.text = result;
        }
      },
    ) ;
  }

  /// Body
  Widget _body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _assetsFilterWidget(),
        _locationFilterWidget(),
        Expanded(child: _loading
          ? Center(child: CircularProgressIndicator(),)
          : _getContent(),
        )
      ],
    );
  }

  // FilterWidget
  Widget _assetsFilterWidget() {
    Widget clearBtn = IconButton(
      icon: Icon(Icons.clear),
      onPressed: (){
        _scroller.clear();
      },
    );

    return Container(
      color: Style.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: TextField(
        controller: _scroller,
        decoration: InputDecoration(
          prefixIcon: Align(
            child: Text(widget.chooseLocation ? '位置' : '资产'),
            widthFactor: 1.1,
          ),
          hintText: "请输入${widget.chooseLocation ? '位置':'资产'}编号/描述进行过滤",
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(0.0),
          border: new OutlineInputBorder(),
          suffixIcon: _scroller.text.isEmpty ? clearBtn : null
        ),
      ),
    );
  }

  Widget _locationFilterWidget() {
    Widget clearBtn = IconButton(
      icon: Icon(Icons.clear),
      onPressed: (){
        _scroller2.clear();
      },
    );
    return widget.chooseLocation 
    ? Container() 
    : Container(
      color: Style.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: TextField(
        controller: _scroller2,
        decoration: InputDecoration(
          prefixIcon: Align(
            child: Text('位置'),
            widthFactor: 1.1,
          ),
          hintText: "请输入位置编号/描述进行过滤",
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(0.0),
          border: new OutlineInputBorder(),
          suffixIcon: _scroller2.text.isEmpty ? clearBtn : null
        ),
      ),
    );
  }


  /// Old

  List<DescriptionData> _filters(List<DescriptionData> data) {
    if (data == null) return null;

    return data.where((DescriptionData f) {

      if (_scroller.text.length > 0 || _scroller2.text.length > 0) {
        if (!widget.chooseLocation) {
          bool assetFilter = f.assetnum.contains(_scroller.text.toUpperCase());
          assetFilter = assetFilter || (f.description??'').contains(_scroller.text.toUpperCase());

          bool locationFilter = (f.location??'').contains(_scroller2.text.toUpperCase());
          locationFilter = locationFilter || (f.locationDescription ??'').contains(_scroller2.text.toUpperCase());

          if ( assetFilter && locationFilter) {
            return true;
          } else {
            return false;
          }
        }

        if ((f.location??'').contains(_scroller.text.toUpperCase()) 
        || (f.description ??'').contains(_scroller.text.toUpperCase())) {
          return true;
        }

        return false;
      }

      return true;
    }).toList();
  }

  Widget _getContent() {
    List<DescriptionData> data = getMemoryCache(cacheKey, expired: false);

    data = _filters(data);

    if (data == null || data.length == 0) {
      return Center(
        child: Text('没有可选择的${widget.chooseLocation ? '位置' : '资产'}'),
      );
    }

    Color _avatarColor(DescriptionData asset) {
      // TODO : Change to asset status change Colors
      String title = widget.chooseLocation ? '${asset.location}' : '${asset.assetnum}';
      Color avatarColor = Colors.blue.shade600;
      if (title.contains('001')) {
        avatarColor = Colors.red.shade400;
      } else if (title.contains('002')) {
        avatarColor = Colors.grey.shade400;
      }
      return avatarColor;
    }

    Widget _listItem(int index) {
      DescriptionData asset = data[index];
      String title = widget.chooseLocation ? '${asset.location}' : '${asset.assetnum}';
      String desStr = '描述:${asset.description??''}';
      String locationStr = widget.chooseLocation ? '' : '位置:${asset.location??''}\n${asset.locationDescription??''}';
      Color avatarColor = _avatarColor(asset);

      return SimpleButton(
        child: ListTile(
          leading: CircleAvatar(
            child: Text('${index+1}', style: TextStyle(fontSize: index > 10000 ? 12.0 : 14.0, color: Colors.white)),
            backgroundColor: avatarColor,
          ),
          title: Text(title),
          subtitle: Text(desStr),
          trailing: Text(locationStr, textAlign: TextAlign.right,),
        ),
        onTap: (){
          if(widget.needReturn){
            Navigator.pop(context, asset);
          } else {
            Navigator.push(context, new MaterialPageRoute(builder: (_) => new AssetNumDetailPage(asset: asset.assetnum)));
          }
        },
      );
    }

    return new ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, int index) {
        return new Container(
          child: new Column(
            children: <Widget>[
              _listItem(index),
              Divider(height: 1.0)
            ],
          )
        );
      },
    );
  }

  String get cacheKey =>
      '__${Cache.instance.site}_${widget.chooseLocation ? '_locations': '_assets'}';

  void _getAsset({String asset = '', int count = 50000, bool queryOne}) async {
    if (_request) return;
    setState(() {
      _loading = true;
    });
    try {
      _request = true;

      if (!widget.chooseLocation) {
        Map response = await getModel(context).api.getAssets(
              location: widget.location,
              count: count,
              queryOne: queryOne,
              asset: asset,
            );
        DescriptionResult result = new DescriptionResult.fromJson(response);
        if (result.code != 0) {
          Func.showMessage(result.message);
        } else {
          setMemoryCache<List<DescriptionData>>(cacheKey, result.response);
        }
      } else {
        Map response = await getModel(context).api.getLocations(
              location: widget.location,
              count: count,
              queryOne: queryOne,
            );
        DescriptionResult result = new DescriptionResult.fromJson(response);
        if (result.code != 0) {
          Func.showMessage(result.message);
        } else {
          setMemoryCache<List<DescriptionData>>(cacheKey, result.response);
        }
      }
    } catch (e) {
      print(e);
      setMemoryCache<List<DescriptionData>>(
          cacheKey, getMemoryCache(cacheKey) ?? []);

      Func.showMessage('网络异常, 请求${widget.chooseLocation ? '位置' : '资产'}接口失败');
    }

    _request = false;
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}
