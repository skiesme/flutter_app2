import 'package:flutter/material.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';

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
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.action.instruction ?? '提交工作流'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: '提交',
              onPressed: (){

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
            child:  Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListTile(
                    title: Text('流程指派'),
                    subtitle: Text(_assigncode?? '请选择人员'),
                    trailing: Icon(Icons.edit),
                    onTap: (){

                    },
                  ),
                  ListTile(
                    title:Text('工单编号'),
                    subtitle: Text(widget.wonum),
                  ),
                  ListTile(
                    title: Text('操作人'),
                    subtitle: Text(getModel(context).user?.displayname?? ''),
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

//              Container(
//                padding: EdgeInsets.all(20.0),
//                child: Center(
//                    child:RaisedButton(
//                  child: Text('提交', style: TextStyle(fontSize: 18.0),),
//                    onPressed: (){
//
//                })),
//              )

                ],
              ),
            ),
          ),
        ));
  }
}
