import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:samex_app/components/orders/hd_order_option.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/utils/func.dart';


/** HDOrderOptions */
class HDOrders extends StatefulWidget {

  HDOrdersState state;
  final PageHelper<OrderShortInfo> helper;
  final OrderType type;

  HDOrders({Key key, @required this.helper, this.type = OrderType.ALL}) :super(key:key);

  @override
  State<StatefulWidget> createState() {
    state = new HDOrdersState();
    return state;
  }
}

class HDOrdersState extends State<HDOrders> {
  HDOrderOptions orderOptions;

  @override
  void initState() {
    super.initState();

    orderOptions = new HDOrderOptions(
      type: widget.type,
      badgeCount: 10,
      onSureBtnClicked: (res) => optionSureClickedHandle(res),
      onTimeSortChanged: (isUp) => optionTimeSortChangedHandle(isUp),
    );
  }

  @override
  Widget build(BuildContext context) {
    // orderOptions.badgeCount = Random().nextInt(100);
    
    return new Container(
        color: const Color(0xFFF0F0F0),
        child: GestureDetector(
            onTap: (){
              Func.closeKeyboard(context);
            },
            child: new Stack(children: <Widget>[
              orderOptions
            ],))
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void optionSureClickedHandle(HDOrderOptionsResult res) {
    print("option query:${res.query}, isAll:${res.isAll}, startTime:${res.startTime}, endTime:${res.endTime}, isUp:${res.isUp}");
  }
  void optionTimeSortChangedHandle(bool isTimeUp) {
    String res = isTimeUp ? 'Yes' : 'No';
    print("current is tiem up? ${res}!");
  }

}