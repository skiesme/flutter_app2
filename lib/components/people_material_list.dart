import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/model/work_time.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/page/work_time_page.dart';

class PeopleAndMaterialList extends StatefulWidget {

  final bool isPeople;

  final OrderDetailData data;

  PeopleAndMaterialList({this.isPeople, Key key, @required this.data}) : super(key:key);

  @override
  PeopleAndMaterialListState createState() => new PeopleAndMaterialListState();
}

class PeopleAndMaterialListState extends State<PeopleAndMaterialList>  with AfterLayoutMixin<PeopleAndMaterialList> {
  bool _first = true;


  get cacheKey {
    var key = widget.data?.wonum ??'';
    if(key.isEmpty) return '';
    return 'PeopleAndMaterial_${widget.isPeople}_$key';
  }



  void getData() async {
    OrderDetailData data = widget.data;
    if(data != null){
      try{

        if(widget.isPeople){
          Map response = await getApi(context).getWorkTime(data.wonum);
          WorkTimeResult result = new WorkTimeResult.fromJson(response);

          if(result.code != 0){
            Func.showMessage(result.message);
          } else {
            setMemoryCache<List<WorkTimeData>>(cacheKey, result.response);

          }
        } else {
        }


      } catch (e){
        print (e);
        setMemoryCache<List<WorkTimeData>>(cacheKey, getMemoryCache(cacheKey)??[]);

        Func.showMessage('网络出现异常: 获取步骤列表失败');
      }
    }

    if(mounted) {
      setState(() {
      });
    }
  }

  Widget _centeredText(String label) =>
      new Padding(
        // Match the default padding of IconButton.
        padding: const EdgeInsets.all(8.0),
        child: new Text(label, textAlign: TextAlign.center),
      );

  TableRow _buildPeopleRow(WorkTimeData p) {
    return new TableRow(
      children: <Widget> [
        _centeredText(p.displayname),
        _centeredText(p.trade),
        _centeredText(p.actualhrs.toString()),
        new SimpleButton(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          shape: new CircleBorder(side: BorderSide.none),
            child: Icon(Icons.edit, size: 16.0,),
            onTap: () async {
              final result = await Navigator.push(context, new MaterialPageRoute(builder: (_){
                return new WorkTimePage(data: p , read: widget.data.actfinish != 0);
              }));

              if(result != null) {
                getData();
              }


        })

      ],
    );
  }

  Widget getPeoples(){
    List<WorkTimeData> list = getMemoryCache(cacheKey, expired: false)??[];

    List<TableRow> children =<TableRow>[
      new TableRow(
          decoration: new BoxDecoration(color: Colors.blue.shade300),
          children: <Widget> [
            _centeredText('人员'),
            _centeredText('技能'),
            _centeredText('工时'),
            _centeredText('操作'),

          ]
      )
    ];

    children.addAll(list.map((f) => _buildPeopleRow(f)).toList());


    return Container(
        padding: Style.pagePadding,
        child: new Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: children,

        )
    );
  }

  Widget getMaterial(){
    List<WorkTimeData> list = getMemoryCache(cacheKey, expired: false)??[];
    if(list == null){
      return Center(child: Text('没有发现记录'),);
    }

    return Container(

    );
  }

  @override
  Widget build(BuildContext context) {

    final List list = getMemoryCache(cacheKey, callback: (){
      getData();
    });
    if(list == null){
      Widget child;
      if(_first) {
        child =  Center(child: CircularProgressIndicator());
      } else {
        child =  Center(child: Text('没有发现'));
      }

      return Container(
        padding: EdgeInsets.all(8.0),
        child: child,
      );
    }

    if(list.isEmpty && _first){
      getData();
    }

    if(widget.isPeople){
      return getPeoples();
    } else {
      return getMaterial();
    }
  }
  
  @override
  void afterFirstLayout(BuildContext context) {
    _first = false;
  }
}
