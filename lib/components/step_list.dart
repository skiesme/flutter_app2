import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/samex_instance.dart';
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
                widget.onImgChanged(widget.data);
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
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text('没有发现步骤')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildStepLists(list),
    );
  }

  List<Widget> _buildStepLists(List<OrderStep> list) {
    int index = 0;
    return list.map((OrderStep step) {
      Widget cell = _buildItemCell(index, step);
      index++;
      return cell;
    }).toList();
  }

  Widget _buildItemCell(int i, OrderStep step) {
    // debugPrint('资产: ${step.assetnum??' '}-${step.assetDescription??' '}');

    Widget info(){
      bool isCM = getOrderType(widget.data?.worktype) == OrderType.CM;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('任务${i+1}: ${step.description??''}', style: TextStyle(color: _isModify(step) ?  Style.primaryColor : Colors.grey),),
          Text('资产: ${step.assetnum??''}-${step.assetDescription??''}'),
          Text('时间: ${Func.getFullTimeString(step.statusdate)}'),
          isCM ? Container(height: 1.0,) : Text('状态: ${step.status??'未处理'}')
        ],
      );
    }

    return Column(
      children: <Widget>[
        SimpleButton(
          padding: Style.pagePadding,
          onTap: (){
            if(getOrderType(widget.data.worktype) == OrderType.CM){
              gotoStep2(i);
            }
          },
          onDoubleTap: (){
            if(getOrderType(widget.data.worktype) != OrderType.CM) {
              gotoStep(step.assetnum, i);
            }
          },
          child: info(),
        ),
        Divider(height: 1.0)
      ],
    );
  }


  @override
  void afterFirstLayout(BuildContext context) {
    _first = false;
  }
}

