import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/page/step_page.dart';
import 'package:samex_app/page/step_new_page.dart';

import 'package:after_layout/after_layout.dart';


class StepList extends StatefulWidget {

  final OrderDetailData data;
  final onImgChanged;
  StepList({Key key, @required this.data, this.onImgChanged}) : super(key:key);

  @override
  StepListState createState() => new StepListState();
}

class StepListState extends State<StepList> with AfterLayoutMixin<StepList> {

  bool _first = true;
  bool _request = false;

  Future<Null> gotoStep(String asset, [int index = -1]) async {
    List<OrderStep> list = getMemoryCache<List<OrderStep> >(cacheKey, expired: false);

    if(list !=null && widget.data != null){
      final goo = (int i) async {
        final result = await Navigator.push(context, new MaterialPageRoute(
            builder: (_) => new StepPage(
              index: i,
              data: list[i],
              info: widget.data,
              isTask: widget.data.actfinish == 0,
              isXJ: getOrderType(widget.data.worktype) == OrderType.XJ,
              onImgChanged: (){
                widget.onImgChanged();
              },
            ),
            settings: new RouteSettings(name: StepPage.path)
        ));
        if(result != null) {
          getSteps();
        }
      };

      if(index > 0  && index < list.length){
        goo(index);
        return;
      }

      for(int i = 0, len = list.length; i< len; i++){
        if(asset == list[i].assetnum ){
          goo(i);
          break;
        }

        if(i == (len - 1)){
          Func.showMessage('资产: $asset, 未发现');
        }
      }
    }
  }

  Future<Null> gotoStep2(int index) async {
    List<OrderStep> list = getMemoryCache<List<OrderStep> >(cacheKey, expired: false);

    OrderStep step = list[index];
    final result = await Navigator.push(context, new MaterialPageRoute(
        builder: (_)=> new StepNewPage(step: step, read: widget.data.actfinish != 0,)));
    if(result != null) {
      getSteps();
    }
  }


  void getSteps() async {
    if(_request) return;
    _request = true;
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

    _request = false;
  }

  get cacheKey {
    var key = widget.data?.wonum ??'';
    if(key.isEmpty) return '';
    return 'stepsList_$key';
  }

  int get  steps {
    final list = getMemoryCache<List<OrderStep> >(cacheKey, expired: false);
    return list == null ? 0 : list.length;
  }


  bool _isModify(OrderStep f){
    if(getOrderType(widget.data?.worktype) == OrderType.CM){
      return false;
    } else {
      return (f.status == null || f.status.isEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
//    print('orderdata ; ${widget.data.toJson()}');

    List<OrderStep> list = getMemoryCache<List<OrderStep> >(cacheKey, callback: (){
      getSteps();
    });
    if(list == null || list.isEmpty){
      if(_first && list == null) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('没有发现步骤')),
        );
      }

    }

    List<Widget> children = <Widget>[];
    for(int i = 0, len = list.length; i < len; i++){
      OrderStep f = list[i];
      List<Widget> children2 = <Widget>[];

      children2.add(Text('任务${i+1}: ${f.description??''}', style: TextStyle(color: _isModify(f) ?  Style.primaryColor : Colors.grey),));
      children2.add(Text('资产: ${f.assetnum??''}-${f.assetDescription??''}'));
      children2.add(Text('时间: ${Func.getFullTimeString(f.statusdate)}'));

      if(getOrderType(widget.data?.worktype) != OrderType.CM){
        children2.add(Text('状态: ${f.status??'未处理'}'));
      }

      children.add(
          SimpleButton(
            padding: Style.pagePadding,
            onTap: () {
              if(getOrderType(widget.data.worktype) == OrderType.CM){
                gotoStep2(i);
              }
            },
            onDoubleTap: (){
              if(getOrderType(widget.data.worktype) != OrderType.CM) {
                gotoStep(f.assetnum, i);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children2,
            ),));
      children.add(Divider(height: 1.0,));

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

