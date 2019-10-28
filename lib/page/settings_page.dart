import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:samex_app/components/samex_back_button.dart';
import 'package:samex_app/model/site.dart';
import 'package:samex_app/model/user.dart';

import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/utils/func.dart';

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

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AfterLayoutMixin<SettingsPage> {
  List<Site> _siteList = new List();
  String _defSite = Cache.instance.site;
  Site _selectedSite;

  bool _showHostItem = false;
  List<String> _envList = ['生产', '测试'];
  String _selectedEnv = Cache.instance.inProduction ? '生产' : '测试';

  String _verStr = 'Version 1.5.1910281537';

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

    return Scaffold(
        appBar: AppBar(
          leading: SamexBackButton(),
          title: GestureDetector(
            onLongPress: () {
              setState(() {
                _showHostItem = !_showHostItem;
              });
            },
            child: Text('设置'),
          ),
          centerTitle: true,
        ),
        body: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[_buildBody(), _buildVersion()],
        )));
  }

  Widget _buildBody() {
    List<Widget> childs = [_sitesSelectItem(), Divider(height: 1)];

    if (_showHostItem) {
      childs.add(_hostSelectItem());
      childs.add(Divider(height: 1));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: childs,
    );
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
                  title: Text('选择水厂',
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                      textAlign: TextAlign.center),
                  children: _siteList.map((Site site) {
                    return ListTile(
                      trailing: site.description == title
                          ? const Icon(Icons.check)
                          : null,
                      title: Text(site.description),
                      onTap: () {
                        Navigator.pop(context);
                        String msg1 = '确定切换水厂后，您需要进行重新登录。';
                        String msg2 = '是否将水厂切换至 "${site.description ?? ''}"？';
                        final changeSite = () {
                          setState(() {
                            _selectedSite = site;
                            // 切换水厂 重新登录
                            updateUserSite(_selectedSite.siteid);
                          });
                        };
                        showLogOutDialog(context, msg1, msg2, changeSite);
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

  Widget _hostSelectItem() {
    void showEnvDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, state) {
                return SimpleDialog(
                  contentPadding: const EdgeInsets.all(10.0),
                  title: Text('选择环境',
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                      textAlign: TextAlign.center),
                  children: _envList.map((String env) {
                    return ListTile(
                      trailing: (env == _selectedEnv)
                          ? const Icon(Icons.check)
                          : null,
                      title: Text(env),
                      onTap: () {
                        Navigator.pop(context);
                        String msg1 = '确定切换APP 运行环境后，您需要进行重新登录。';
                        String msg2 = '是否将APP 运行环境切换至 "${env}"？';
                        final commit = () {
                          setState(() {
                            _selectedEnv = env;
                            setInProduction(pro: (env == '生产'));
                          });
                          gotoLogin();
                        };
                        showLogOutDialog(context, msg1, msg2, commit);
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
              Text(_selectedEnv, style: TextStyle(fontSize: 12.0)),
              Icon(Icons.arrow_drop_down)
            ]),
        title: const Text('运行环境'),
        enabled: true,
        onTap: () {
          showEnvDialog(context);
        });
  }

  void loadSiteDatas() async {
    try {
      final response = await getApi().getSites();
      SiteResult res = SiteResult.fromJson(response);
      if (res.code != 0) {
        Func.showMessage(res.message);
      } else {
        setMemoryCache<List<Site>>(cacheKey, res.response);
        setState(() {
          _siteList = res.response;
        });
      }
    } catch (e) {
      setMemoryCache<List<Site>>(cacheKey, getMemoryCache(cacheKey) ?? []);
      print(e);
    }
  }

  Widget _buildVersion() {
    return Column(
      children: <Widget>[
        Text(
          'SAMEX',
          style: TextStyle(fontSize: 17.0),
        ),
        Text(
          _verStr,
          style: TextStyle(fontSize: 11.0),
        ),
        Text('')
      ],
    );
  }

  void updateUserSite(String site) async {
    try {
      final response = await getApi().changeSite(site);
      UserResult res = UserResult.fromJson(response);
      if (res.code != 0) {
        Func.showMessage(res.message);
      } else {
        gotoLogin();
      }
    } catch (e) {
      print(e);
    }
  }

  void gotoLogin() {
    Navigator.pop(context);

    setToken(context, null);
    clearMemoryCache();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => new LoginPage()));
  }

  void showLogOutDialog(
      BuildContext context, String msg1, String msg2, onCommit) {
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
                      Text(msg1),
                      Text(msg2),
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
                      onCommit();
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}
