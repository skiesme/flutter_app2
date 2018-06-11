import 'dart:async';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final Widget child;
  final bool show;
  final String tips;
  final bool confirm;
  LoadingView({this.child, this.show = false, this.tips, this.confirm = false});

  WillPopCallback _onWillPop(BuildContext context) {
    if(show == false || !confirm) return null;
    return (){
      return Future.value(false);
//       showDialog(
//        context: context,
//        builder:(BuildContext context)=> new AlertDialog(
//          title: new Text('警告'),
//          content: new Text('强行取消提交容易出现异常, 请谨慎操作'),
//          actions: <Widget>[
//            new FlatButton(
//              onPressed: () {
//                Navigator.of(context).pop(false);
//                Navigator.of(context).pop(false);
//              },
//              child: new Text('退出'),
//            ),
//            new FlatButton(
//              onPressed: () => Navigator.of(context).pop(true),
//              child: new Text('我点错了', style: TextStyle(color: Colors.redAccent),),
//            ),
//          ],
//        ),
//      ) ?? false;
    };

  }

  @override
  Widget build(BuildContext context) {

    List<Widget> children = new List<Widget>();
    children.add(this.child);
    if(show){
      children.add(Container(
        color: Colors.black87.withOpacity(0.4),
        child: new Center(
          child: new SizedBox(
                height: 100.0,
                child: new RaisedButton(
                  onPressed: null,
                  disabledColor: Colors.black87.withOpacity(0.6),
                  disabledElevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all( Radius.circular(10.0))),
                  padding: new EdgeInsets.all(8.0),
                  color: Colors.black87,
                  highlightColor: Colors.black87,
                  child:new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new CircularProgressIndicator(),
                    new SizedBox(height: 8.0,),
                    Text(tips??'请稍后...', style: TextStyle(color: Colors.white),)
                  ],
                ),
              )),
        ),
      ));
    }

    return new WillPopScope(
        onWillPop: _onWillPop(context),
        child: new Stack( children: children)
    )
    ;
  }
}
