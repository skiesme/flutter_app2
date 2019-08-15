import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/model/work_time.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/page/people_page.dart';
import 'package:samex_app/model/people.dart';

class WorkTimePage extends StatefulWidget {
  final WorkTimeData data;
  final bool read;

  final bool isNew;

  WorkTimePage({@required this.data, @required this.read, this.isNew = false});

  @override
  _WorkTimePageState createState() => _WorkTimePageState();
}

class _WorkTimePageState extends State<WorkTimePage> {
  bool _show = false;
  WorkTimeData _data;

  dynamic _people;

  TextEditingController _controller;

  Widget _getMenus({
    String preText,
    Widget content,
    EdgeInsets padding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }){
    return new Container(
      padding: padding??EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Text(preText),
          SizedBox(width: Style.separateHeight,),
          Expanded(child: content)
        ],
      ),
      decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border(
              bottom: Divider.createBorderSide(context, width: 1.0)
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _data = widget.data;

    if(_data.hrid != null){
      _people = new PeopleData(
          hrid: _data.hrid,
          displayname: _data.displayname,
          trade: _data.trade
      );
    }

    _controller = new TextEditingController(text: '${_data.actualhrs??''}');

    int now = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _data.starttime = _data.starttime?? now;
    _data.startdate = _data.startdate ?? now;

    DateTime time1 = new DateTime.fromMillisecondsSinceEpoch(_data.startdate * 1000);
    DateTime time2 = new DateTime.fromMillisecondsSinceEpoch(_data.starttime * 1000);

    _data.startdate = (new DateTime(time1.year, time1.month, time1.day, time2.hour, time2.minute, 0).millisecondsSinceEpoch ~/ 1000).toInt();
    _data.finishtime = _data.finishtime ?? now;
    _data.finishdate = _data.finishdate ?? now;

    time1 = new DateTime.fromMillisecondsSinceEpoch(_data.finishdate * 1000);
    time2 = new DateTime.fromMillisecondsSinceEpoch(_data.finishtime * 1000);

    _data.finishdate = (new DateTime(time1.year, time1.month, time1.day, time2.hour, time2.minute, 0).millisecondsSinceEpoch ~/ 1000).toInt();

  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void delete() async {
    setState(() {
      _show = true;
    });

    try{
      Map response = await getApi().delWorkTime(widget.data.hrtransid);
      WorkTimeResult result = new WorkTimeResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        Func.showMessage('删除成功');
        Navigator.pop(context, true);
        return;
      }

    } catch (e) {
      print(e);
      Func.showMessage('出现异常, 删除失败');
    }

    if(mounted){
      setState(() {
        _show = false;
      });

    }
  }

  Future<bool> _post(PeopleData people) async {
    _data.hrid = people.hrid;
    _data.displayname = people.displayname;
    _data.trade = people.trade;
    _data.starttime = _data.startdate;
    _data.finishtime = _data.finishdate;

    _data.regularhrs = (_data.finishdate - _data.startdate) / (60*60);

    _data.actualhrs = double.parse(_controller.text);

    try{
      Map response = await getApi().postWorkTime(_data);
      WorkTimeResult result = new WorkTimeResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
        return false;
      } else {
        if(_people is List){
          return true;
        }
        Func.showMessage('提交成功');
        return true;
      }

    } catch (e) {
      print(e);
      Func.showMessage('出现异常, 新建工时失败');
      return false;
    }

  }

  void postStep() async{
    Func.closeKeyboard(context);

    if(_people == null) {
      Func.showMessage('请选择人员');
      return;
    }

    if(_controller.text == null || _controller.text.length == 0){
      Func.showMessage('请填写工时');
      return;
    }

    if(_data.finishdate < _data.startdate ){
      Func.showMessage('结束时间不能早于开始时间');
      return;
    }

    int now = new DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if(_data.finishdate > now ){
      Func.showMessage('结束时间不能是将来');
      return;
    }

    setState(() {
      _show = true;
    });

    if(_people is List){
      List<PeopleData> data = _people;

      for(int i = 0, len = data.length; i < len ; i++){
        bool ok = await _post(data[i]);
        if(!ok){
          Navigator.pop(context, true);
          return;
        }
      }

      Navigator.pop(context, true);

    } else {
      bool ok =  await _post(_people);

      if(ok){
        Navigator.pop(context, true);
      }

    }

    if(mounted){
      setState(() {
        _show = false;
      });

    }
  }

  void  _changeDate(){
    String real = _controller.text;
    if(_data.finishdate > _data.startdate){
      _data.regularhrs = (_data.finishdate - _data.startdate)  / (60*60);
    } else {
      _data.regularhrs = 0.0;
    }

    real = _data.regularhrs.toString();
//    if(real.isNotEmpty){
      _controller.text = num.parse(real).toStringAsFixed(2);
//    }
  }

  String getPeopleName(){
    if(_people == null){
      return '请选择人员';
    }
    if(_people is List){

      String names = '';
      List<PeopleData> data = _people;

      for(int i = 0, len = data.length; i < len ; i++){
        names += '${data[i].displayname} ';
      }

      return names;

    } else {
      return _people?.displayname ;
    }
  }

  @override
  Widget build(BuildContext context) {
    String real = _controller.text;
    if(_data.finishdate > _data.startdate){
    } else {
      _data.regularhrs = 0.0;
    }

    String regular = _data.regularhrs.toStringAsFixed(2);


    if(MediaQuery.of(context).padding.bottom == 0){
      if(real.isNotEmpty){
        Future.delayed(new Duration(milliseconds: 17), (){
          if(_controller.text.length != num.parse(real).toStringAsFixed(2).toString().length ){
            _controller.text = num.parse(real).toStringAsFixed(2);
            Func.closeKeyboard(context);
          }
        });

      }
    }

    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          title: Text(_controller.text.isEmpty ? '新增人员工时':'工时填写'),
          centerTitle: true,
          actions: widget.read || widget.data.hrtransid == 0 ? null : <Widget>[
            new  IconButton(
              icon: Icon(Icons.delete),
              tooltip: '删除工时',
              onPressed: (){
                showDialog(
                    context: context,
                    builder: ( (_) => new AlertDialog(
                      title: Text('警告'),
                      content: Text('确认删除该员工工时'),
                      actions: <Widget>[
                        new FlatButton(
                          onPressed: (){
                            Navigator.of(context).pop(false);
                          },
                          child: Text('取消'),
                        ),
                        new FlatButton(
                          onPressed: (){
                            Navigator.of(context).pop(false);
                            delete();
                          },
                          child: Text('删除', style: TextStyle(color: Colors.redAccent),),
                        )
                      ],
                    ))
                );
              },
            )
          ],
        ),

        body: new GestureDetector(
          onTap: (){
            Func.closeKeyboard(context);
          },
          child:  LoadingView(
            show: _show,
            child: Container(
              color: Style.backgroundColor,
              height: MediaQuery.of(context).size.height,

              child: Stack(
                children: <Widget>[
                  new Positioned(left: 0.0, top: 0.0, bottom: max(80.0, MediaQuery.of(context).viewInsets.bottom), right: 0.0, child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _getMenus(preText: '工单:', content: Text(_data.refwo)),

                        _getMenus(preText: '人员:',
                            padding: EdgeInsets.only(left: 8.0),
                            content: SimpleButton(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                onTap: widget.read ? null : () async {
                                  dynamic result = await Navigator.push(context,
                                      new MaterialPageRoute(
                                          builder:(_)=> new PeoplePage( trade: true, multiple: widget.isNew,))
                                  );

                                  if(result != null) {
                                    setState(() {
                                      _people = result;
                                    });
                                  }

                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child:Text(getPeopleName(), style: TextStyle(color: _people == null ? Colors.grey: Colors.black),)),
                                    Icon(Icons.navigate_next, color: Colors.black87,),
                                  ],
                                ))),

                        widget.isNew ? Container() :  _getMenus(preText: '技能:', content:  Text(_people?.trade ?? '', style: TextStyle(color: _people == null ? Colors.grey: Colors.black))),


                        new Container(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text('开始时间: '),
                              new SizedBox(width: 20.0,),
                              new InkWell(
                                  onTap: widget.read ? null : () {
                                    DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                                        _data.startdate * 1000);
                                    Func.selectDate(context, time, (DateTime date) {
                                      setState(() {
                                        _data.startdate = (new DateTime(date.year, date.month, date.day, time.hour, time.minute).millisecondsSinceEpoch ~/ 1000).toInt();
                                        _changeDate();
                                      });
                                    });
                                  },
                                  child: Row(
                                      children: <Widget>[
                                        new Text('${Func.getYearMonthDay(_data.startdate * 1000)}'),
                                        Icon(Icons.arrow_drop_down)]
                                  )
                              ),
                              new SizedBox(width: 20.0,),
                              new InkWell(
                                  onTap: widget.read ? null : () {
                                    DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                                        _data.startdate * 1000);
                                    Func.selectTime(context, TimeOfDay.fromDateTime(time), (TimeOfDay date) {
                                      setState(() {
                                        _data.startdate =  (new DateTime(time.year, time.month, time.day, date.hour, date.minute).millisecondsSinceEpoch ~/ 1000).toInt();
                                        _changeDate();
                                      });
                                    });
                                  },
                                  child:Row(
                                      children: <Widget>[ new Text('${Func.getHourMin(_data.startdate * 1000)}'),
                                      Icon(Icons.arrow_drop_down)
                                      ])
                              ),
                            ],
                          ),

                          decoration: new BoxDecoration(
                              color: Colors.white,
                              border: new Border(
                                  bottom: Divider.createBorderSide(context, width: 1.0)
                              )),
                        ),

                        new Container(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text('结束时间: '),
                              new SizedBox(width: 20.0,),
                              new InkWell(
                                  onTap: widget.read ? null : () {
                                    DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                                        _data.finishdate * 1000);
                                    Func.selectDate(context, time, (DateTime date) {
                                      setState(() {
                                        _data.finishdate = (new DateTime(date.year, date.month, date.day, time.hour, time.minute).millisecondsSinceEpoch ~/ 1000).toInt();
                                        _changeDate();
                                      });
                                    });
                                  },
                                  child: Row(
                                      children: <Widget>[
                                        new Text('${Func.getYearMonthDay(_data.finishdate * 1000)}'),
                                        Icon(Icons.arrow_drop_down)]
                                  )
                              ),
                              new SizedBox(width: 20.0,),
                              new InkWell(
                                  onTap: widget.read ? null : () {
                                    DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                                        _data.finishdate * 1000);
                                    Func.selectTime(context, TimeOfDay.fromDateTime(time), (TimeOfDay date) {
                                      setState(() {
                                        _data.finishdate =  (new DateTime(time.year, time.month, time.day, date.hour, date.minute).millisecondsSinceEpoch ~/ 1000).toInt();
                                        _changeDate();
                                      });
                                    });
                                  },
                                  child:Row(
                                      children: <Widget>[ new Text('${Func.getHourMin(_data.finishdate * 1000)}'),
                                      Icon(Icons.arrow_drop_down)
                                      ])
                              ),
                            ],
                          ),

                          decoration: new BoxDecoration(
                              color: Colors.white,
                              border: new Border(
                                  bottom: Divider.createBorderSide(context, width: 1.0)
                              )),
                        ),
                        _getMenus(preText: '参考工时:', content: Text(regular)),
                        _getMenus(preText: '实际工时:', content: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          enabled: !widget.read,
                          decoration: new InputDecoration.collapsed(
                            hintText: '请输入实际工时',
                          ),
                        ),
                            crossAxisAlignment: CrossAxisAlignment.start
                        ),

                      ],
                    ),
                  ),
                  ),
                  widget.read ? Container() :  Positioned(left: 0.0, bottom: 0.0, right: 0.0, child:
                  Material(
                    elevation: 6.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: RaisedButton(
                          padding:EdgeInsets.symmetric(horizontal: 40.0),
                          onPressed: (){
                            postStep();
                          },
                          child: Text('提交', style: TextStyle( color: Colors.white, fontSize: 18.0),),
                          color: Style.primaryColor,
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        )
    );
  }
}
