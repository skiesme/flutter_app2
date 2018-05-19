import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/utils/api.dart';

SamexApi getApi(BuildContext context){
  return RootModelWidget.of(context).model.api;
}

void setToken(BuildContext context, String token){
  RootModelWidget.of(context).model.token = token;
}

class RootModel {
  RootModel({this.userName, this.token}) : this.api = new SamexApi();

  String userName;
  String token;

  final SamexApi api;
}

class RootModelWidget extends InheritedWidget {

  final RootModel model;
  RootModelWidget({
    Key key,
    @required Widget child,
    @required this.model
  }) :
        assert(child != null),
        assert(model != null),
        super(key: key, child: child);

  static RootModelWidget of(BuildContext context){
    return context.inheritFromWidgetOfExactType(RootModelWidget);
  }

  @override
  bool updateShouldNotify(RootModelWidget oldWidget) {
    return oldWidget.model.token != model.token;
  }

}