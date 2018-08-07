import 'package:flutter/material.dart';
import 'package:samex_app/model/assetnum_detail.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/recent_history.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:samex_app/page/upload_assetnum_page.dart';

class AssetNumDetailPage extends StatefulWidget {

  final String asset;

  AssetNumDetailPage({@required this.asset});


  @override
  _AssetDetailPageState createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetNumDetailPage> {

  bool _error = false;

  String get cacheKey => '${widget.asset}_detail';


  void _getAssetDetail() async {
    try {
        Map response = await getModel(context).api.getAssetDetail(widget.asset);
        AssetNumDetailResult result = new AssetNumDetailResult.fromJson(response);
        if (result.code != 0) {
          Func.showMessage(result.message);
        } else {
          setMemoryCache(cacheKey, result.response);
          if(mounted){
            setState(() {

            });
          }
        }

    } catch (e) {
      print(e);
      _error = true;

      Func.showMessage('网络异常, 请求资产详情接口失败');
    }
  }


  Widget _getDetail(){

    AssetNumDetail data = getMemoryCache<AssetNumDetail>(cacheKey, callback: (){
      _getAssetDetail();
    });

    if(data == null){
      if(_error) return Center(child: Text('没有发现该资产对应的数据'),);
      return Center(child: CircularProgressIndicator(),);
    }

    List<Widget> children = new List();

    children.add(Padding(padding: Style.pagePadding2, child: Text('基本信息', style: TextStyle(fontWeight: FontWeight.w700),),));
    children.add(Divider(height: 1.0,));
    children.add(Padding(padding: Style.pagePadding4, child: Text('资产编号: ${data.assetnum}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('资产描述: ${data.description}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('所在位置: ${data.location}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('位置描述: ${data.locationDescription}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('修改人员: ${data.changeby}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('资产类型: ${data.assettype}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('功能类别: ${data.funclass}'),));
    if(data.specific.isNotEmpty){
      children.add(Padding(padding: Style.pagePadding4, child: Text('规格型号: ${data.specific}'),));
    }
    children.add(Padding(padding: Style.pagePadding4, child: Text('资产状态: ${data.status}'),));

    children.add(Padding(padding: Style.pagePadding4, child: Text('运行状况: ${data.serialnum}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('重要等级: ${data.assetlev}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('上级资产编号: ${data.parent}'),));
    children.add(Padding(padding: Style.pagePadding4, child: Text('最后修订时间: ${Func.getFullTimeString(data.changedate)}'),));
    children.add(new SizedBox(height: Style.separateHeight));

    children.add(Padding(padding: Style.pagePadding2, child: Text('相关图片', style: TextStyle(fontWeight: FontWeight.w700)),));
    children.add(Divider(height: 1.0,));
    children.add(Padding(padding: Style.pagePadding4, child:PictureList(canAdd: false, images: data.pic??[],)));

    children.add(new SizedBox(height: Style.separateHeight));

    children.add(Padding(padding: Style.pagePadding2, child: Text('资产相关工单记录', style: TextStyle(fontWeight: FontWeight.w700)),));
    children.add(Divider(height: 1.0,));
    children.add(new RecentHistory(data: new OrderDetailData(
      assetnum: widget.asset,
      worktype: 'CM'
    )));

    return Container(
      child: SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    AssetNumDetail data = getMemoryCache<AssetNumDetail>(cacheKey, expired: false);
    return new Scaffold(
      appBar: AppBar(
        title: Text('${widget.asset} 详情'),
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.refresh), onPressed: (){
            _error = false;
            _getAssetDetail();
          })
        ],
      ),

      body: _getDetail(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (data == null || !Cache.instance.userDisplayName.contains("管理员") ) ?  null : new FloatingActionButton(
          child: Tooltip(
            child: new Icon(Icons.edit),
            message: '修改',
            preferBelow: false,
          ),
//          backgroundColor: Colors.redAccent,
          onPressed: () async {
            final result = await Navigator.push(context, new MaterialPageRoute(builder: (_){
              return new UploadAssetPage(asset: data);
            }));

            if(result != null) {
              _error = false;
              _getAssetDetail();
            }
          }),
    );
  }
}
