import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:samex_app/page/login_page.dart';


class Func {
  static bool  validatePhone(String value) {
    final RegExp phoneExp = new RegExp(r'^((1[3-8][0-9])+\d{8})$');
    return phoneExp.hasMatch(value??'');
  }

  static void closeKeyboard(BuildContext context){
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  static Map<String, dynamic> decode(String data){
    return json.decode(data);
  }

  static Widget loadingWidget(BuildContext context) =>  new Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: new Center(
        child: new CircularProgressIndicator(),
      )
  );

  static Widget logoutWidget(BuildContext context, String msg, [Widget button]) =>  new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(msg),
          new SizedBox(height: 10.0),
          button??new RaisedButton(
              child: new Text('退出登录'),
              onPressed: (){
                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_) => new LoginPage()));
              })
        ],
      )
  );

  static Widget centerLoading() => new Center(
              child:  new Container(
                    padding: EdgeInsets.all(16.0),
                    child:new CircularProgressIndicator()
                ),
  );

  static  FormFieldValidator<String>  validateNull(String msg){
    return (String value) {
      if(value.isEmpty){
        return msg;
      }

      return null;
    };
  }

  static void showMessage(String value, {ToastGravity gravity = ToastGravity.CENTER}) {
    if(value == null ) return;

    Fluttertoast.showToast(
        msg: value,
        toastLength: Toast.LENGTH_SHORT,
        gravity: gravity,
        timeInSecForIos: 1
    );
  }

  static String getHourMin(int mill){
    if(mill == 0) mill = new DateTime.now().millisecondsSinceEpoch;
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(mill);
    var formatter = new DateFormat('HH:mm');
    return formatter.format(time);
  }


  /// 标准的unix时间戳 需要扩大1000倍
  static String getYearMonthDay(int mill){
//    print('getYearMonthDay=$mill');
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(mill);
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(time);
  }

  static String getFullTimeString(int mill){
    if(mill == null || mill < 0) return '';
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(mill*1000);
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(time);
  }

  static String getYYYYMMDDHHMMSSString([ DateTime time ]){
    if(time == null){
      time = DateTime.now();
    }
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(time);

  }

  static String mapToString(Map map){
    return json.encode(map);
  }

  static Future<Null> selectDate(BuildContext context, DateTime selectedDate, ValueChanged<DateTime> selectDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(1990, 8),
        lastDate: new DateTime(2201)
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  static Future<Null> selectTime(BuildContext context, TimeOfDay time, ValueChanged<TimeOfDay> selectDate) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime:  time
    );
    if (picked != null && picked != time)
      selectDate(picked);
  }

  static Widget getWhiteTheme(Widget child){
    return new Theme(data: new ThemeData(
      primaryColor: Colors.white,
      hintColor: Colors.white,
      accentColor: Colors.white,
    ), child: child);
  }

  static Widget getCircleAvatar(double height, Color backGroundColor, String image ){
    return new CircleAvatar(
      backgroundColor: backGroundColor,
      child: new Image.asset(image, height: height, width: height,),
    );
  }

  static Future<String> scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print('barcode = $barcode');
      return barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Func.showMessage('相机权限被拒绝');
      } else {
        Func.showMessage('未知错误:  $e');
      }
    } on FormatException{
      ///取消
    } catch (e) {
      Func.showMessage('未知错误:  $e');
    }

    return '';
  }

}