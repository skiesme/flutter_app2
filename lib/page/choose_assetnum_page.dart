import 'package:flutter/material.dart';
import 'package:samex_app/components/samex_back_button.dart';
import 'package:samex_app/data/samex_instance.dart';
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

  ChooseAssetPage(
      {this.location, this.chooseLocation = false, this.needReturn = true});

  @override
  _ChooseAssetPageState createState() => _ChooseAssetPageState();
}

class _ChooseAssetPageState extends State<ChooseAssetPage> {
  static const double ICON_SIZE = 16.0;

  TextEditingController _scroller;
  TextEditingController _scroller2;

  bool _loading = true;
  bool _request = false;

  bool _stateNormalChecked = true; // 正常
  bool _stateDisableChecked = false; // 停用/废弃
  bool _stateOthersChecked = false; // 其他

  @override
  void initState() {
    super.initState();

    _scroller = new TextEditingController(text: '');
    _scroller.addListener(() {
      setState(() {});
    });

    _scroller2 = new TextEditingController(text: '');
    _scroller2.addListener(() {
      setState(() {});
    });

    if (widget.chooseLocation) {
      _scroller.text = widget.location ?? '';
    } else {
      _scroller2.text = widget.location ?? '';
    }
  }

  String _getTitle() {
    if (!widget.needReturn) {
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
        leading: const SamexBackButton(),
        title: Text(_getTitle()),
        centerTitle: true,
        actions: _appBarActions(),
      ),
      floatingActionButton: _scanBtn(),
      body: _body(),
    );
  }

  /// AppBarActions
  List<Widget> _appBarActions() {
    IconButton noActionBtn = IconButton(
      icon: Text('无'),
      onPressed: () {
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
        });

    List<Widget> btns = new List();
    if (widget.needReturn) {
      btns.add(noActionBtn);
    }
    btns.add(refreshBtn);

    return btns;
  }

  /// Scan Btn
  FloatingActionButton _scanBtn() {
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
    );
  }

  /// Body
  Widget _body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _filterWidget(),
        Expanded(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _getContent(),
        )
      ],
    );
  }

  Widget _filterWidget() {
    return Card(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Wrap(
          children: <Widget>[
            Divider(height: 1),
            _assetsFilterWidget(),
            Divider(height: 1),
            _locationFilterWidget(),
            Divider(height: 1),
            _statusFilterWidget()
          ],
          spacing: 12.0,
          runSpacing: 8.0,
          runAlignment: WrapAlignment.center,
        ),
      ),
    );
  }

  // FilterWidget
  Widget _assetsFilterWidget() {
    Widget clearBtn = IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        _scroller.clear();
      },
    );

    return Container(
      height: 20,
      child: TextField(
        controller: _scroller,
        decoration: InputDecoration(
            prefixIcon: Align(
              child: Text('资       产:'),
              widthFactor: 1.1,
            ),
            hintText: "请输入${widget.chooseLocation ? '位置' : '资产'}编号/描述进行过滤",
            contentPadding: EdgeInsets.symmetric(vertical: 0.0),
            border: InputBorder.none,
            suffixIcon: _scroller.text.isNotEmpty ? clearBtn : null),
      ),
    );
  }

  Widget _locationFilterWidget() {
    Widget clearBtn = IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        _scroller2.clear();
      },
    );
    return widget.chooseLocation
        ? Container()
        : Container(
            height: 20,
            child: TextField(
              controller: _scroller2,
              decoration: InputDecoration(
                  prefixIcon: Align(
                    child: Text('位       置:'),
                    widthFactor: 1.1,
                  ),
                  hintText: "请输入位置编号/描述进行过滤",
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                  border: InputBorder.none,
                  suffixIcon: _scroller2.text.isNotEmpty ? clearBtn : null),
            ),
          );
  }

  Widget _statusFilterWidget() {
    Color acolor = Style.primaryColor;
    Checkbox normal = Checkbox(
      value: _stateNormalChecked,
      activeColor: acolor,
      onChanged: (bool value) {
        setState(() {
          _stateNormalChecked = value;
        });
      },
    );
    Checkbox disable = Checkbox(
      value: _stateDisableChecked,
      activeColor: acolor,
      onChanged: (bool value) {
        setState(() {
          _stateDisableChecked = value;
        });
      },
    );
    Checkbox others = Checkbox(
      value: _stateOthersChecked,
      activeColor: acolor,
      onChanged: (bool value) {
        setState(() {
          _stateOthersChecked = value;
        });
      },
    );
    Widget runState() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("正常"),
          normal,
          Text("停用"),
          disable,
          Text("其他"),
          others
        ],
      );
    }

    return Container(
      height: 25,
      child: Row(
        children: <Widget>[
          Text("资产状态:"),
          runState(),
        ],
      ),
    );
  }

  /// Old
  List<DescriptionData> _filters(List<DescriptionData> data) {
    if (data == null) return null;

    return data.where((DescriptionData f) {
      bool canUsed = true;

      // 资产过滤
      String assFilterStr = _scroller.text;
      if (assFilterStr.length > 0) {
        assFilterStr = assFilterStr.toLowerCase();

        bool assetFilter = f.assetnum.contains(assFilterStr);
        assetFilter =
            assetFilter || (f.description ?? '').contains(assFilterStr);
        canUsed &= assetFilter;
      }

      // 位置过滤
      String locFilterStr = _scroller2.text;
      if (locFilterStr.length > 0) {
        locFilterStr = locFilterStr.toLowerCase();
        bool locationFilter = (f.location ?? '').contains(locFilterStr);
        locationFilter = locationFilter ||
            (f.locationDescription ?? '').contains(locFilterStr);
        canUsed &= locationFilter;
      }

      // 状态过滤
      String status = f.status ?? '';
      if (status == '停用' || status == 'DECOMMISSIONED') {
        canUsed &= _stateDisableChecked;
      } else if (status == 'OPERATING') {
        canUsed &= _stateNormalChecked;
      } else {
        canUsed &= _stateOthersChecked;
      }

      return canUsed;
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

    Widget _listItem(int index) {
      DescriptionData asset = data[index];
      String title = '${asset.description ?? ''}';
      String desStr =
          widget.chooseLocation ? '${asset.location}' : '${asset.assetnum}';

      String locationStr = widget.chooseLocation
          ? ''
          : '位置:${asset.location ?? ''}\n${asset.locationDescription ?? ''}';

      Color avatarColor = Style.assetStatusColor(asset.status);

      return SimpleButton(
        child: ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}',
                style: TextStyle(
                    fontSize: index > 10000 ? 12.0 : 14.0,
                    color: Colors.white)),
            backgroundColor: avatarColor,
          ),
          title: Text(title),
          subtitle: Text(desStr),
          trailing: Text(
            locationStr,
            textAlign: TextAlign.right,
          ),
        ),
        onTap: () {
          if (widget.needReturn) {
            Navigator.pop(context, asset);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AssetNumDetailPage(asset: asset.assetnum)));
          }
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, int index) {
        return Container(
            child: Column(
          children: <Widget>[_listItem(index), Divider(height: 1.0)],
        ));
      },
    );
  }

  String get cacheKey =>
      '__${Cache.instance.site}_${widget.chooseLocation ? '_locations' : '_assets'}';

  void _getAsset({String asset = '', int count = 50000, bool queryOne}) async {
    if (_request) return;
    setState(() {
      _loading = true;
    });
    try {
      _request = true;

      if (!widget.chooseLocation) {
        Map response = await getApi().getAssets(
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
        Map response = await getApi().getLocations(
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
