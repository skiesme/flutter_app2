import 'dart:io' as Io;
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:image/image.dart';

import 'package:path/path.dart';

typedef void OnResultListener(List<MultipartFile> result);
typedef void OnProgressListener(int step);

class Calculator {
  Calculator(
      {@required this.onResultListener,
      @required this.onProgressListener,
      @required this.data})
      : assert(onResultListener != null);

  final OnResultListener onResultListener;
  final OnProgressListener onProgressListener;
  final List<String> data;

  void run() {
    List<MultipartFile> list = [];

    for (int i = 0, len = data.length; i < len; i++) {
      String f = data[i];
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if (path.startsWith('/')) {
          if (!Io.Platform.isIOS) {
            onProgressListener(i + 1);
            List<int> bytes = new Io.File(path).readAsBytesSync();

            Image image = decodeImage(bytes);

            String cachePath = dirname(path) + '${i + 1}.jpg';

            Io.File file = new Io.File(cachePath);
            if (file.existsSync()) {
              file.deleteSync();
            }

            // Save the thumbnail as a PNG.
            Io.File(cachePath).writeAsBytesSync(encodeJpg(image, quality: 80));
            list.add(MultipartFile.fromFileSync(cachePath,
                filename: basename(cachePath)));
          } else {
            list.add(
                MultipartFile.fromFileSync(path, filename: basename(path)));
          }
        }
      } catch (e) {
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

enum CalculationState { idle, loading, calculating }

class CalculationManager {
  CalculationManager(
      {@required this.onResultListener,
      @required this.onProgressListener,
      @required this.images})
      : assert(onResultListener != null),
        _receivePort = new ReceivePort() {
    _receivePort.listen(_handleMessage);
  }

  CalculationState _state = CalculationState.idle;
  CalculationState get state => _state;
  bool get isRunning => _state != CalculationState.idle;

  final OnResultListener onResultListener;
  final OnProgressListener onProgressListener;
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
      final DecodeMessage message =
          new DecodeMessage(this.images, _receivePort.sendPort);
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
    if (message is List<MultipartFile>) {
      onResultListener(message);
    } else if (message is int) {
      onProgressListener(message);
    }
  }

  static void _calculate(DecodeMessage message) {
    final SendPort sender = message.sendPort;
    final Calculator calculator = new Calculator(
        onResultListener: sender.send,
        onProgressListener: (int step) {
          sender.send(step);
        },
        data: message.data);
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
  List<String> images;
  List<OrderStep> steps;

  StepsData({this.changedate, this.steps});

  StepsData.fromJson(Map<String, dynamic> json) {
    changedate = json['changedate'];
    images = json['images']?.cast<String>() ?? [];
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
      this.status = '',
      this.statusdate = 0,
      this.remark = '',
      this.executor = '',
      this.images});

  OrderStep.fromJson(Map<String, dynamic> json) {
    stepno = json['stepno'];
    description = json['description'];
    wonum = json['wonum'];
    assetnum = json['assetnum'];
    assetnum = assetnum == "null" ? "" : assetnum;

    assetDescription = json['asset_description'];
    assetDescription = assetDescription == "null" ? "" : assetDescription;

    status = json['status'];
    statusdate = json['statusdate'];
    remark = json['remark'];
    executor = json['exectuor'];
    images = json['images']?.cast<String>() ?? [];
  }

  String _getImages() {
    String list = '';

    if (images == null) return list;

    for (int i = 0, len = images.length; i < len; i++) {
      String f = images[i];
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        } else {
          continue;
        }
        if (path.startsWith('/')) {
        } else {
          if (list.length > 0) {
            list += '##';
          }
          list += f;
        }
      } catch (e) {}
    }

    return list;
  }

  List<String> getUploadImages() {
    List<String> list = [];
    if (images == null) return list;

    images.forEach((String f) {
      try {
        String path = f;
        if (f.contains(',')) {
          path = f.split(',')[0];
        }
        if (path.startsWith('/')) {
          list.add(f);
        }
      } catch (e) {}
    });

    return list;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    if (images.contains(',')) {
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
