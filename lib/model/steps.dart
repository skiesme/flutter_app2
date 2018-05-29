import 'dart:io' as Io;
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:image/image.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';



typedef void OnResultListener(List<UploadFileInfo> result);

class Calculator {
  Calculator({ @required this.onResultListener, this.data })
      : assert(onResultListener != null);

  final OnResultListener onResultListener;
  final List<String> data;

  void run() {

    List<UploadFileInfo> list = [];

    for(int i= 0, len = data.length; i < len; i++) {
      String f = data[i];
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if(path.startsWith('/')){

          List<int> bytes =  new Io.File(path).readAsBytesSync();

          Image image = decodeImage(bytes);

          String cachePath = dirname(path)+ '${i+1}.png';

          Io.File file = new Io.File(cachePath);
          if(file.existsSync()){
            file.deleteSync();
          }

          // Save the thumbnail as a PNG.
          new Io.File(cachePath).writeAsBytesSync(encodeJpg(image, quality: 80));


          list.add(new UploadFileInfo(new Io.File(cachePath), basename(cachePath), contentType: Io.ContentType.BINARY));
        }
      } catch(e){
        print(e);
      }
    }


    onResultListener(list);

  }


}

class DecodeMessage {
  DecodeMessage(this.data, this.sendPort);
  List<String> data;
  SendPort sendPort;
}

enum CalculationState {
  idle,
  loading,
  calculating
}

class CalculationManager {
  CalculationManager({ @required this.onResultListener, @required this.images})
      : assert(onResultListener != null),
        _receivePort = new ReceivePort() {
    _receivePort.listen(_handleMessage);
  }

  CalculationState _state = CalculationState.idle;
  CalculationState get state => _state;
  bool get isRunning => _state != CalculationState.idle;

  final OnResultListener onResultListener;
  List<String> images;

  // Start the background computation.
  //
  // Does nothing if the computation is already running.
  void start() {
    if (!isRunning) {
      _state = CalculationState.loading;
      _runCalculation();
    }
  }

  // Stop the background computation.
  //
  // Kills the isolate immediately, if spawned. Does nothing if the
  // computation is not running.
  void stop() {
    if (isRunning) {
      _state = CalculationState.idle;
      if (_isolate != null) {
        _isolate.kill(priority: Isolate.immediate);
        _isolate = null;
      }
    }
  }

  final ReceivePort _receivePort;
  Isolate _isolate;

  void _runCalculation() {
    // Load the JSON string. Note that this is done in the main isolate; at the
    // moment, spawned isolates do not have access to Mojo services, including
    // the root bundle (see https://github.com/flutter/flutter/issues/3294).
    // However, the loading process is asynchronous, so the UI will not block
    // while the file is loaded.

      if (isRunning) {

        final DecodeMessage message = new DecodeMessage(this.images, _receivePort.sendPort);
        // Spawn an isolate to JSON-parse the file contents. The JSON parsing
        // is synchronous, so if done in the main isolate, the UI would block.
        Isolate.spawn(_calculate, message).then<Null>((Isolate isolate) {
          if (!isRunning) {
            isolate.kill(priority: Isolate.immediate);
          } else {
            _state = CalculationState.calculating;
            _isolate = isolate;
          }
        });
      }
  }

  void _handleMessage(dynamic message) {
    onResultListener(message);

  }

  // Main entry point for the spawned isolate.
  //
  // This entry point must be static, and its (single) argument must match
  // the message passed in Isolate.spawn above. Typically, some part of the
  // message will contain a SendPort so that the spawned isolate can
  // communicate back to the main isolate.
  //
  // Static and global variables are initialized anew in the spawned isolate,
  // in a separate memory space.
  static void _calculate(DecodeMessage message) {
    print('44444');

    final SendPort sender = message.sendPort;
    final Calculator calculator = new Calculator(
        onResultListener: sender.send,
        data: message.data
    );
    calculator.run();
  }
}


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
    images = json['images']?.cast<String>() ?? [];
  }

  static Future<String> _getThumbPath(String thumbnail ) async {
//    var documentsDirectory = await getExternalStorageDirectory();
    var documentsDirectory = await getApplicationDocumentsDirectory();

    var path = join(documentsDirectory.path, thumbnail);

    // make sure the folder exists
    if (!await new Io.Directory(dirname(path)).exists()) {
      try {
        await new Io.Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        if (!await new Io.Directory(dirname(path)).exists()) {
          print(e);
        }
      }
    }
    return path;
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
        } else {
          continue;
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

  List<String> getUploadImages() {
    List<String> list = [];
    if(images == null) return  list;

    images.forEach( (String f)  {
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if(path.startsWith('/')){
          list.add(f);
        }
      } catch(e){
      }
    });

    return list;
  }

  Future<List<UploadFileInfo>> getUploadImage() async {
    List<UploadFileInfo> list = [];
    if(images == null) return list;

    int i = 0;
    await Future.forEach(images, (String f) async {
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if(path.startsWith('/')){

          List<int> bytes = await new Future.delayed(Duration.zero, (){
            return new Io.File(path).readAsBytes();
          });

          Image image = await new Future.delayed(Duration.zero, (){
            return  decodeImage(bytes);
          });

          String cachePath = await _getThumbPath('${i++}.png');

          Io.File file = new Io.File(cachePath);
          if(await file.exists()){
            await file.delete();
          }

          // Save the thumbnail as a PNG.
          await  new Io.File(cachePath).writeAsBytes(encodeJpg(image, quality: 80));

          list.add(new UploadFileInfo(new Io.File(cachePath), basename(cachePath), contentType: Io.ContentType.BINARY));
        }
      } catch(e){
      }
    });


    return list;
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['stepno'] = this.stepno.toString();
    data['description'] = this.description;
    data['wonum'] = this.wonum;
    data['assetnum'] = this.assetnum;
    data['asset_description'] = this.assetDescription;
    data['status'] = this.status;
//    data['statusdate'] = this.statusdate.toString();
    data['remark'] = this.remark;
    data['executor'] = this.executor;
    String images = _getImages();
    if(images.contains(',')){
      data['images'] = _getImages();
    }
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