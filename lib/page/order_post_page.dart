import 'dart:async';
import 'package:flutter/material.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/page/people_page.dart';
import 'package:samex_app/model/people.dart';

class OrderPostPage extends StatefulWidget {

  final int id;
  final Actions action;
  final String wonum;

  const OrderPostPage({@required this.id, @required this.action, @required this.wonum});
  @override
  _OrderPostPageState createState() => _OrderPostPageState();
}

class _OrderPostPageState extends State<OrderPostPage> {

  bool _show = false;
  String _assigncode;
  PeopleData _data;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new TextEditingController();
  }

  void _submit() async {
    Func.closeKeyboard(context);
    await new Future.delayed(new Duration(milliseconds: 200), (){});

    setState(() {
      _show = true;
    });


    try {
      Map response = await getModel(context).api.submit(
        assigncode: _data?.hrid?? Cache.instance.userName,
        actionid: widget.action.actionid,
        notes:  _controller.text,
        ownerid: widget.id
      );

      UserResult result = new UserResult.fromJson(response);
      if(result.code != 0){
        Func.showMessage(result.message);

      } else {
        Navigator.pop(context, 'done');
        Func.showMessage('提交成功');
      }

    } catch (e){
      Func.showMessage('提交失败: ${e.toString()}');
    }

    if(mounted){
      setState(() {
        _show = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    _assigncode = _data?.displayname;
    return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.action.instruction ?? '提交工作流'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: '提交',
              onPressed: (){
                  _submit();
              },
            )
          ],
        ),
//        floatingActionButton: new FloatingActionButton(
//            child: Icon(Icons.done),
//            backgroundColor: Colors.redAccent,
//            tooltip: '提交',
//            onPressed: (){
//              _submit();
//            }),
        body: new GestureDetector(
          onTap: (){
            Func.closeKeyboard(context);
          },
          child:  LoadingView(
            show: _show,
            child:  Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  widget.action.instruction.contains(new RegExp(r'[责任人|指派]')) ?  ListTile(
                    title: Text('指派工单负责人'),
                    subtitle: Text(_assigncode?? '请选择人员'),
                    trailing: Icon(Icons.edit),
                    onTap: () async{
                        final  result = await Navigator.push(context,
                          new MaterialPageRoute(builder: (_)=> PeoplePage(req: new RegExp(r'维修'),) )
                        );

                        if(result != null) {
                          setState(() {
                            _data = result;
                          });
                        }
                    },
                  ) : Container(),
                  ListTile(
                    title:Text('工单编号'),
                    subtitle: Text(widget.wonum),
                  ),
                  ListTile(
                    title: Text('操作人'),
                    subtitle: Text(Cache.instance.userDisplayName),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('备注'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: new InputDecoration(
                          hintText: "输入备注",
                          contentPadding: const EdgeInsets.all(8.0),
                          hintStyle: TextStyle(fontSize: 16.0),
                          border: new OutlineInputBorder()
                      ),
                    ),
                  ),

                Expanded(child: Container(
                  color: Colors.transparent),
                )
                ],
              ),
            ),
          ),
        ));
  }
}
