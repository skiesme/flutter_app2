import 'package:flutter/material.dart';

class PeopleAndMaterialList extends StatefulWidget {

  final bool isPeople;

  PeopleAndMaterialList({this.isPeople, Key key}) : super(key:key);

  @override
  _PeopleAndMaterialListState createState() => new _PeopleAndMaterialListState();
}

class _PeopleAndMaterialListState extends State<PeopleAndMaterialList> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.isPeople ? '人员' : '物料');
  }
}
