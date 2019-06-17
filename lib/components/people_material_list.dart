import 'package:flutter/material.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/model/work_time.dart';
import 'package:samex_app/model/order_material.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/page/work_time_page.dart';
import 'package:samex_app/page/material_new_page.dart';

class PeopleAndMaterialList extends StatefulWidget {

  final bool isPeople;

  final bool read;

  final OrderDetailData data;

  PeopleAndMaterialList({this.isPeople, Key key, @required this.data, @required this.read}) : super(key:key);

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
          Map response = await getApi(context).getOrderMaterial(data.wonum);
          OrderMaterialResult result = new OrderMaterialResult.fromJson(response);

          if(result.code != 0){
            Func.showMessage(result.message);
          } else {
            setMemoryCache<List<OrderMaterialData>>(cacheKey, result.response);
          }

        }


      } catch (e){
        print (e);
        setMemoryCache(cacheKey, getMemoryCache(cacheKey)??[]);

        Func.showMessage('网络出现异常: 获取数据失败');
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
                return new WorkTimePage(data: p , read: widget.read);
              }));

              if(result != null) {
                getData();
              }
        })

      ],
    );
  }

  TableRow _buildMaterialRow(OrderMaterialData p) {
    return new TableRow(
      children: <Widget> [
        _centeredText(p.description),
        _centeredText(p.location),
        _centeredText('${p.itemqty}'),
        new SimpleButton(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            shape: new CircleBorder(side: BorderSide.none),
            child: Icon(Icons.edit, size: 16.0,),
            onTap: () async {
              final result = await Navigator.push(context, new MaterialPageRoute(builder: (_){
                return new MaterialPage(data: p , read: widget.read);
              }));

              if(result != null) {
                getData();
              }
            })

      ],
    );
  }

  Widget getPeoples(){
    List<WorkTimeData> list;
    try{
      list = getMemoryCache(cacheKey, expired: false)??[];
    } catch (e){
      list = new List();
    }

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

    List<OrderMaterialData> list;
    try{
      list = getMemoryCache(cacheKey, expired: false)??[];
    } catch (e){
      list = new List();
    }


    List<TableRow> children =<TableRow>[
      new TableRow(
          decoration: new BoxDecoration(color: Colors.blue.shade300),
          children: <Widget> [
            _centeredText('物料'),
            _centeredText('仓库'),
            _centeredText('数量'),
            _centeredText('操作'),

          ]
      )
    ];

    children.addAll(list.map((f) => _buildMaterialRow(f)).toList());


    return Container(
        padding: Style.pagePadding,
        child: new Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: children,

        )
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
