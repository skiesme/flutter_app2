import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/model/people.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/simple_button.dart';

class PeoplePage extends StatefulWidget {

  final RegExp req;
  final bool trade;
  PeoplePage({this.req, this.trade = false});

  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {

  TextEditingController _scroller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _scroller = new  TextEditingController(text: '');
    _scroller.addListener((){
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final list = getMemoryCache(cacheKey, callback: (){
      _getUsers();
    });

    if(list != null) _loading = false;

    return new Scaffold(
      appBar: new AppBar(
        title: Text('人员选择'),
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.refresh),
              tooltip: '数据刷新',
              onPressed: (){
                if(!_loading){
                  _getUsers();
                }
              })
        ],
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color:Style.backgroundColor,
            padding: const EdgeInsets.all(20.0),
            child: new TextField(
              controller: _scroller,
              decoration: new InputDecoration(
                  hintText: "仅支持用户拼音搜索",
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(8.0),
                  hintStyle: TextStyle(fontSize: 16.0),
                  border: new OutlineInputBorder(),
                  suffixIcon: _scroller.text.isNotEmpty ? new IconButton(icon: Icon(Icons.clear), onPressed: (){
                    _scroller.clear();
                  }): null
              ),
            ),
          ),
          Expanded(child: _loading ? Center(child: CircularProgressIndicator(),) : _getContent(),)

        ],
      ),
    );
  }

  List<PeopleData> _filters(List<PeopleData> data){
    if(data == null) return null;

    return data.where((PeopleData f) {
      if(widget.req != null) {
        bool req = widget.req.hasMatch(f.department);
//        print('req = ${widget.req}, f.department=${f.department}, result=$req');
        if(!req) return false;
      }

      if(widget.trade){
        if(f.trade == null || f.trade.isEmpty){
          return false;
        }
      }

      if(_scroller.text.length > 0){
        return  f.hrid.contains(_scroller.text.toUpperCase());
      }

      return  true;

    }).toList();

  }

  Widget _getContent(){
    List<PeopleData> data = getMemoryCache(cacheKey, expired: false);

    data = _filters(data);

    if(data == null || data.length == 0){
      return Center(child: Text('没有可选择的人员'),);
    }

    return new ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, int index){
        PeopleData people = data[index];
        return new Container(
            child: new Column(
              children: <Widget>[
                SimpleButton(

                  child:ListTile(

                    title: Text(people.displayname),
                    subtitle: Text(people.title),
                    trailing: Text(people.department),
                  ),
                  onTap: (){
                    Navigator.pop(context, people);
                  },
                ),

                Divider(height: 1.0,)
              ],
            )
        );
      },

    );
  }

  String get cacheKey => '__${Cache.instance.site}_peolple';

  void _getUsers() async {
    setState(() {
      _loading = true;
    });
    try{
      Map response = await getModel(context).api.userAll();
      PeopleResult result = new PeopleResult.fromJson(response);
      if(result.code != 0) {
        Func.showMessage(result.message);
      } else {
        setMemoryCache<List<PeopleData>>(cacheKey, result.response);
      }

    } catch (e){
      setMemoryCache<List<PeopleData>>(cacheKey, getMemoryCache(cacheKey)??[]);

      Func.showMessage('网络异常, 请求人员接口失败');
    }

    if(mounted){
      setState(() {
        _loading = false;
      });
    }
  }
}
