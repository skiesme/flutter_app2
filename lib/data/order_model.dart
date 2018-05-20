import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/model/order_list.dart';


class OrderModel {
  OrderModel({this.order});

  OrderShortInfo order;



}

class OrderModelWidget extends InheritedWidget{

  final OrderModel model;

  OrderModelWidget({
    Key key,
    @required this.model,
    @required Widget child,
  }): assert(child != null),
        assert(model != null),
        super(key: key, child: child);

  static OrderModelWidget of(BuildContext context){
    return context.inheritFromWidgetOfExactType(OrderModelWidget);
  }

  @override
  bool updateShouldNotify(OrderModelWidget oldWidget) {
    return model != oldWidget.model;
  }

}