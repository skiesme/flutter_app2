import 'package:flutter/material.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/steps.dart';

import 'package:after_layout/after_layout.dart';

class StepList extends StatefulWidget {
  @override
  _StepListState createState() => new _StepListState();
}

class _StepListState extends State<StepList> with AfterLayoutMixin<StepList> {

  OrderDetailData _data;

  void _getSteps() async {
    _data = getModel(context).orderDetailData;
    if(_data != null){
      try{
        String response = await getApi(context).steps(sopnum: _data.sopnum, wonum: _data.wonum, site: _data.site);
        StepsResult result = new StepsResult.fromJson(Func.decode(response));

        if(result.code != 0){
          Func.showMessage(result.message);
        } else {
          setState(() {
            getModel(context).stepsList.clear();
            getModel(context).stepsList.addAll(result.response.steps);
          });
        }


      } catch (e){
        print (e);
        Func.showMessage('网络出现异常: 获取步骤列表失败');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    List<OrderStep> list = getModel(context).stepsList;
    if(list.length == 0){
      _getSteps();
      return Center(child: CircularProgressIndicator());
    } else {
      List<Widget> children = <Widget>[];
      for(int i = 0, len = list.length; i < len; i++){
        OrderStep f = list[i];
        List<Widget> children2 = <Widget>[];

        children2.add(Text('任务$i: ${f.description}', style: TextStyle(color: f.status == null?  Style.primaryColor : Colors.grey),));
        children2.add(Text('资产: ${f.location}-${f.locationDescription}'));
        children2.add(Text('时间: ${Func.getFullTimeString(f.statusdate)}'));
        children2.add(Text('状态: ${f.status??'未处理'}'));
        children2.add(Divider(height: 1.0,));

        children.add(
            SimpleButton(
              padding: new EdgeInsets.only(top: 6.0),
              onTap: (){},
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
  }

  @override
  void afterFirstLayout(BuildContext context) {
//    List<OrderStep> list = getModel(context).stepsList;
//    if(list.length == 0){
//      _getSteps();
//    }
  }
}
