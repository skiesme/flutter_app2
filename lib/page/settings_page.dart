import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:samex_app/components/samex_back_button.dart';
import 'package:samex_app/model/site.dart';
import 'package:samex_app/model/user.dart';

import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';

import 'login_page.dart';

class GalleryTextScaleValue {
  const GalleryTextScaleValue(this.scale, this.label);

  final double scale;
  final String label;

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final GalleryTextScaleValue typedOther = other;
    return scale == typedOther.scale && label == typedOther.label;
  }

  @override
  int get hashCode => hashValues(scale, label);

  @override
  String toString() {
    return '$runtimeType($label)';
  }
}

const List<GalleryTextScaleValue> kAllGalleryTextScaleValues =
    const <GalleryTextScaleValue>[
  const GalleryTextScaleValue(null, '系统默认'),
  const GalleryTextScaleValue(0.8, '小'),
  const GalleryTextScaleValue(1.0, '正常'),
  const GalleryTextScaleValue(1.3, '大'),
//  const GalleryTextScaleValue(2.0, '超大'),
];

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AfterLayoutMixin<SettingsPage> {
  List<Site> _siteList = new List();
  String _defSite = Cache.instance.site;
  Site _selectedSite;
  GalleryTextScaleValue _textScaleFactor = GalleryTextScaleValue(null, '系统默认');

  String get cacheKey => '__Cache.instance.site_list';
  @override
  void initState() {
    super.initState();
    _siteList = getMemoryCache<List<Site>>(cacheKey, expired: false);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (_siteList == null || _siteList.length == 0) {
      loadSiteDatas();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_defSite == null && _siteList != null && _siteList.length > 0) {
      _defSite = _siteList.first.description;
    }

    double _scale = Cache.instance.textScaleFactor;
    if (_scale != null) {
      for (int i = 1; i < kAllGalleryTextScaleValues.length; i++) {
        if ((kAllGalleryTextScaleValues[i].scale * 10).toInt() ==
            (_scale * 10).toInt()) {
          _textScaleFactor = kAllGalleryTextScaleValues[i];
          break;
        }
      }
    }

    print(
        '_scale=$_scale, ${_textScaleFactor.scale ?? 0} - ${_textScaleFactor.label}');

    return new Scaffold(
        appBar: new AppBar(
          leading: SamexBackButton(),
          title: Text('设置'),
          centerTitle: true,
        ),
        body: new Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[_buildBody(), _buildVersion()],
        )));
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _sitesSelectItem(),
        Divider(height: 1),
      ],
    );
  }

  void loadSiteDatas() async {
    try {
      final response = await getApi(context).getSites();
      SiteResult res = new SiteResult.fromJson(response);
      if (res.code != 0) {
        Func.showMessage(res.message);
      } else {
        setMemoryCache<List<Site>>(cacheKey, res.response);
        setState(() {
          _siteList = res.response;

          if (_defSite == null && _siteList != null && _siteList.length > 0) {
            _defSite = _siteList.first.description;
          }
        });
      }
    } catch (e) {
      setMemoryCache<List<Site>>(cacheKey, getMemoryCache(cacheKey) ?? []);
      print(e);
    }
  }

  Widget _sitesSelectItem() {
    if (_siteList == null) {
      return ListTile();
    }
    String title = '';
    String siteID = Cache.instance.site;
    if (siteID != null) {
      for (Site item in _siteList) {
        if (item.siteid == siteID) {
          title = item.description;
          break;
        }
      }
    }

    void showChooseDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, state) {
                return SimpleDialog(
                  contentPadding: const EdgeInsets.all(10.0),
                  title: new Text('选择水厂',
                      style: new TextStyle(fontSize: 18.0, color: Colors.black),
                      textAlign: TextAlign.center),
                  children: _siteList.map((Site site) {
                    return new ListTile(
                      trailing: site.description == title
                          ? const Icon(Icons.check)
                          : null,
                      title: new Text(site.description),
                      onTap: () {
                        setState(() {
                          _selectedSite = site;
                        });

                        Navigator.pop(context);
                        showLogOutDialog(context);
                      },
                    );
                  }).toList(),
                );
              },
            );
          });
    }

    return ListTile(
        trailing: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text('${title}', style: TextStyle(fontSize: 12.0)),
              Icon(Icons.arrow_drop_down)
            ]),
        title: const Text('用户水厂'),
        enabled: true,
        onTap: () {
          _selectedSite;

          showChooseDialog(context);
        });
  }

  Widget _buildVersion() {
    return Column(
      children: <Widget>[
        Text(
          'SAMEX',
          style: TextStyle(fontSize: 17.0),
        ),
        Text(
          'Version 1.1.1905270915',
          style: TextStyle(fontSize: 11.0),
        ),
        Text('')
      ],
    );
  }

  void showLogOutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, state) {
              return AlertDialog(
                title: Text('提示'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('确定切换水厂后，您需要进行重新登录。'),
                      Text('是否将水厂切换至 "${_selectedSite.description}"？'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('取消', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('确定'),
                    onPressed: () {
                      // 切换水厂 重新登录
                      updateUserSite(_selectedSite.siteid);
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  void updateUserSite(String site) async {
    try {
      final response = await getApi(context).changeSite(site);
      UserResult res = new UserResult.fromJson(response);
      if (res.code != 0) {
        Func.showMessage(res.message);
      } else {
        Navigator.pop(context);
        
        setToken(context, null);
        clearMemoryCache();

        Navigator.pushReplacement(
            context, new MaterialPageRoute(builder: (_) => new LoginPage()));
      }
    } catch (e) {
      print(e);
    }
  }
}
