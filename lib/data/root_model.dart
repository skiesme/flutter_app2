import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:samex_app/utils/api.dart';
import 'package:samex_app/model/user.dart';

SamexApi getApi(BuildContext context){
  return RootModelWidget.of(context).model.api;
}

void setToken(BuildContext context, String token){
  RootModelWidget.of(context).model.token = token;
}

UserInfo getUserInfo(BuildContext context) {
  return RootModelWidget.of(context).model.user;
}

void setUserInfo(BuildContext context, UserInfo info){
  RootModelWidget.of(context).model.user = info;
}

RootModel getModel(BuildContext context){
  return RootModelWidget.of(context).model;
}

typedef  QueryListener(String value);

class RootModel {
  RootModel({this.userName, this.token}) : this.api = new SamexApi();

  String userName;
  String token;

  UserInfo user;

  final SamexApi api;

  Map<int, QueryListener> _listeners = new Map();

  void addListener(int key, QueryListener listener){
      _listeners[key] = listener;
  }

  void queryChanges(String query){
//    print('queryChanges... $query, ${_listeners.length}');
    try{
      _listeners.map((int key, QueryListener value) => value(query));
    } catch(e){

    }
  }

  void clearListeners(){
    _listeners.clear();
  }

  void removeListener(int key){
    _listeners.remove(key);
  }
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