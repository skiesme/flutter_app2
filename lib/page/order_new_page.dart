import 'package:flutter/material.dart';

import 'package:samex_app/model/steps.dart';

class OrderNewPage extends StatefulWidget {
  final OrderStep step;

  OrderNewPage({this.step});

  @override
  _OrderNewPageState createState() => _OrderNewPageState();
}

class _OrderNewPageState extends State<OrderNewPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('新增维修工单'),

      ),
    );
  }
}
