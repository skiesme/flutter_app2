import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final Widget child;
  final bool show;
  LoadingView({this.child, this.show = false});

  @override
  Widget build(BuildContext context) {

    List<Widget> children = new List<Widget>();
    children.add(this.child);
    if(show){
      children.add(new Container(
        color: const Color(0x00000000),
        child: new Center(
          child: new Container(
                width: 120.0,
                height: 120.0,
                child: new RaisedButton(
                  onPressed: null,
                  disabledColor: Colors.black54,
                  disabledElevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all( Radius.circular(10.0))),
                  padding: new EdgeInsets.all(10.0),
                  color: Colors.black54,
                  highlightColor: Colors.black54,
                  child:new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new CircularProgressIndicator(),
                    new SizedBox(height: 12.0,),
                    Text('请稍后', style: TextStyle(color: Colors.white),)
                  ],
                ),
              )),
        ),
      ));
    }

    return new Stack( children: children);
  }
}
