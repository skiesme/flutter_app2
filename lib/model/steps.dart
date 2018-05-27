import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';

class StepsResult {
  int code;
  String message;
  StepsData response;

  StepsResult({this.code, this.message, this.response});

  StepsResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new StepsData.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Message'] = this.message;
    if (this.response != null) {
      data['Response'] = this.response.toJson();
    }
    return data;
  }
}

class StepsData {
  int changedate;
  List<OrderStep> steps;

  StepsData({this.changedate, this.steps});

  StepsData.fromJson(Map<String, dynamic> json) {
    changedate = json['changedate'];
    if (json['steps'] != null) {
      steps = new List<OrderStep>();
      json['steps'].forEach((v) {
        steps.add(new OrderStep.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['changedate'] = this.changedate;
    if (this.steps != null) {
      data['steps'] = this.steps.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderStep {
  int stepno;
  String description;
  String wonum;
  String assetnum;
  String assetDescription;
  String status;
  int statusdate;
  String remark;
  String executor;
  List<String> images;

  OrderStep(
      {this.stepno,
        this.description,
        this.wonum,
        this.assetnum,
        this.assetDescription,
        this.status='',
        this.statusdate,
        this.remark,
        this.executor,
        this.images});

  OrderStep.fromJson(Map<String, dynamic> json) {
    stepno = json['stepno'];
    description = json['description'];
    wonum = json['wonum'];
    assetnum = json['assetnum'];
    assetDescription = json['asset_description'];
    status = json['status'];
    statusdate = json['statusdate'];
    remark = json['remark'];
    executor = json['exectuor'];
    images = json['images']?.cast<String>();
  }

  String _getImages(){
    String list = '';

    if(images == null) return list;

    for(int i =0, len = images.length; i < len; i++){
      String f = images[i];
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if(path.startsWith('/')){
        } else {
          if(list.length > 0){
            list += '##';
          }
          list += f;
        }
      }
      catch(e){
      }
    }

    return list;
  }

  List<UploadFileInfo> getUploadImage() {
    List<UploadFileInfo> list = [];
    if(images == null) return list;
    for(int i =0, len = images.length; i < len; i++){
      String f = images[i];
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if(path.startsWith('/')){
          list.add(new UploadFileInfo(new File(path), basename(path)));
        }
      } catch(e){
      }
    }

    return list;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stepno'] = this.stepno;
    data['description'] = this.description;
    data['wonum'] = this.wonum;
    data['assetnum'] = this.assetnum;
    data['asset_description'] = this.assetDescription;
    data['status'] = this.status;
    data['statusdate'] = this.statusdate;
    data['remark'] = this.remark;
    data['executor'] = this.executor;
    data['images'] = _getImages();
//    data['file'] = _getImages(true);
    return data;
  }

  @override
  String toString() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stepno'] = this.stepno;
    data['description'] = this.description;
    data['wonum'] = this.wonum;
    data['assetnum'] = this.assetnum;
    data['asset_description'] = this.assetDescription;
    data['status'] = this.status;
    data['statusdate'] = this.statusdate;
    data['remark'] = this.remark;
    data['exectuor'] = this.executor;
    data['images'] = this.images;
    return json.encode(data).toString();
  }
}