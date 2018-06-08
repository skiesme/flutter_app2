import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/page/step_page.dart';

import 'package:after_layout/after_layout.dart';

class StepList extends StatefulWidget {

  StepList({Key key, @required this.data}) : super(key:key);
  final OrderDetailData data;

  @override
  StepListState createState() => new StepListState();
}

class StepListState extends State<StepList> with AfterLayoutMixin<StepList> {


  bool _first = true;

  Future<Null> gotoStep(String asset) async {
    List<OrderStep> list = getMemoryCache<List<OrderStep> >(cacheKey, expired: false);


    if(list !=null && widget.data != null){
      for(int i = 0, len = list.length; i< len; i++){
        if(asset == list[i].assetnum ){
          final result = await Navigator.push(context, new MaterialPageRoute(
              builder: (_) => new StepPage(index: i, data: list[i], isTask: widget.data.actfinish != 0,),
              settings: new RouteSettings(name: StepPage.path)
          ));
          if(result != null) {
            _getSteps();
          }
          break;
        }

        if(i == (len - 1)){
          Func.showMessage('资产: $asset, 未发现');
        }
      }
    }


  }

  void _getSteps() async {
    OrderDetailData data = widget.data;
    if(data != null){
      try{
        Map response = await getApi(context).steps(sopnum: '', wonum: data.wonum, site: data.site);
        StepsResult result = new StepsResult.fromJson(response);

        if(result.code != 0){
          Func.showMessage(result.message);
        } else {
          if(mounted) {
            setState(() {
              setMemoryCache<List<OrderStep>>(cacheKey, result.response.steps);
            });
          }
        }

      } catch (e){
        print (e);
        Func.showMessage('网络出现异常: 获取步骤列表失败');
      }
    }
  }

  get cacheKey {
    var key = widget.data?.wonum ??'';
    if(key.isEmpty) return '';
    return 'stepsList_$key';
  }

  @override
  Widget build(BuildContext context) {
    List<OrderStep> list = getMemoryCache<List<OrderStep> >(cacheKey, callback: (){
      _getSteps();
    });
    if(list == null){
      if(_first) {
        return Center(child: CircularProgressIndicator());
      } else {
        return Center(child: Text('没有发现步骤'));
      }

    }

    List<Widget> children = <Widget>[];
    for(int i = 0, len = list.length; i < len; i++){
      OrderStep f = list[i];
      List<Widget> children2 = <Widget>[];

      children2.add(Text('任务${i+1}: ${f.description??''}', style: TextStyle(color: f.status == null?  Style.primaryColor : Colors.grey),));
      children2.add(Text('资产: ${f.assetnum??''}-${f.assetDescription??''}'));
      children2.add(Text('时间: ${Func.getFullTimeString(f.statusdate)}'));
      children2.add(Text('状态: ${f.status??'未处理'}'));
      children2.add(Divider(height: 1.0,));

      children.add(
          SimpleButton(
            padding: new EdgeInsets.only(top: 6.0),
            onDoubleTap: (){
              gotoStep(f.assetnum);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children2,
            ),));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

  }

  @override
  void afterFirstLayout(BuildContext context) {
    _first = false;
  }
}

