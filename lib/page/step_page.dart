import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:dio/dio.dart';

final List<_StatusSelect> _statusList = <_StatusSelect>[
  _StatusSelect(0, '正常'),
  _StatusSelect(1, '异常'),
  _StatusSelect(2, '待用'),
  _StatusSelect(3, '挂牌')
];

class _StatusSelect{
  int key;
  String value;


  _StatusSelect(this.key, this.value);
}

class StepPage extends StatefulWidget {

  final int index;
  final OrderStep data;
  final bool isTask;

  static const String path = '/StepPage';

  StepPage({@required this.index, @required this.data, @required this.isTask});


  @override
  _StepPageState createState() => new _StepPageState();
}

class _StepPageState extends State<StepPage>{

  TextEditingController _controller;
  GlobalKey<PictureListState> _key = new GlobalKey<PictureListState>();
  CalculationManager _manager;
  String _status;
  bool _show = false;
  String _tips;

  void setMountState(VoidCallback func){
    if(mounted){
      setState(func);
    }
  }

  void _postStep() async {
    if(_status.isEmpty || getModel(context).step == null){
      Func.showMessage('请先配置状态再提交');
      return;
    }

    setState(() {
      _show = true;
      _tips = null;
    });

    await Future.delayed(Duration(seconds: 0));

    try{
      List<ImageData> list = _key.currentState.getImages();

      for(int i =0, len = list.length; i< len; i++){
        getModel(context).step.images.add(list[i].toString());
      }

      if(getModel(context).step != null){
        getModel(context).step.status = _status;
        double time = DateTime.now().millisecondsSinceEpoch / 1000;
        getModel(context).step.statusdate =  time.toInt();
        getModel(context).step.remark = _controller.text;
        getModel(context).step.executor = getModel(context).user.displayname;

        getModel(context).stepsList[widget.index] = getModel(context).step;
      }

      List<String> images = getModel(context).step.getUploadImages();

      print('found len=${images.length}  upload');
      List<UploadFileInfo> lists = new List();

      var postStep = () async {
        try {
          _manager?.stop();
          Map response = await getApi(context).postStep(
              getModel(context).step, lists);
          StepsResult result = new StepsResult.fromJson(response);
          if (result.code != 0) {
            Func.showMessage(result.message);
          } else {
            Func.showMessage('提交成功');
            Navigator.popUntil(context, ModalRoute.withName(StepPage.path));
            Navigator.pop(context, true);
            return;
          }
        } catch (e){
          print(e);
          Func.showMessage('网络出现异常, 步骤提交失败');
        }

        setMountState(() {
          _show = false;
        });
      };


      if(images.length > 0) {
        _manager = new CalculationManager(
            images: images,
            onProgressListener: (int step){
              setMountState(() {
                _tips = '图片$step处理中';
              });
            },
            onResultListener: (List<UploadFileInfo> files)  {
              print('onResultListener ....len=${files.length}');
              lists = files;

              setMountState(() {
                _tips = '上传中';
              });
              postStep();

            });

        _manager?.start();

      } else {
        postStep();
      }
    } catch(e) {
      print(e);
    }

  }

  Widget _getBody(){

    OrderStep data = widget.data;

    if(MediaQuery.of(context).viewInsets.bottom == 0){
      Func.closeKeyboard(context);
    }

//    print('orderstep : ${data.toString()}');
    if(data == null) {
      return Center(child: Text('步骤数据丢失...'),);
    }

    return new Container(
      color: Style.backgroundColor,
      height: MediaQuery.of(context).size.height,
      child: new Stack(
        children: <Widget>[
          new Positioned(left: 0.0, top: 0.0, bottom: max(80.0, MediaQuery.of(context).viewInsets.bottom), right: 0.0, child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(padding: Style.pagePadding2, child:Text('基本信息')),
                  Divider(height: 1.0,),
                  Padding(padding: Style.pagePadding4, child:Text('任务: ${widget.index+1 ?? ''}')),
                  Padding(padding: Style.pagePadding4, child:Text('描述: ${data.description ??''}')),
                  Padding(padding: Style.pagePadding4, child:Text('资产: ${data.assetnum ?? ''}')),
                  Padding(padding: Style.pagePadding4, child:Text('描述: ${data.assetDescription ?? ''}')),
                  Container(height: Style.separateHeight, color: Style.backgroundColor,),

                  Padding(padding: Style.pagePadding2, child:Text('操作信息')),
                  Divider(height: 1.0,),


                  Padding(padding: new EdgeInsets.symmetric(horizontal: Style.padding), child: new Row(
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text('状态: '),
                            new Text(_status, style:  _status == '异常' ? TextStyle(color: Colors.redAccent) : null,),
                          ],
                        ),

                        getModel(context).isTask ? new Expanded(
                            child:new PopupMenuButton<_StatusSelect>(
                              tooltip:'请选择巡检状态',

                              child: Align(child: const Icon(Icons.arrow_drop_down), alignment: Alignment.centerRight, heightFactor: 1.5,),
                              itemBuilder: (BuildContext context) {
                                return _statusList.map((_StatusSelect status) {
                                  return new PopupMenuItem<_StatusSelect>(
                                    value: status,
                                    child: new Text(status.value),
                                  );
                                }).toList();
                              },
                              onSelected: (_StatusSelect value) {
//                                print('status = ${value.value}');
                                setState(() {
                                  _status = value.value;
                                });
                              },
                            )) : Text(''),
                      ])),
                  Padding(padding: Style.pagePadding4, child:Divider(height: 1.0,)),
                  Padding(padding: Style.pagePadding4, child:Text('时间: ${Func.getFullTimeString(data.statusdate)}')),
                  Padding(padding: Style.pagePadding4, child:Divider(height: 1.0,)),
                  Padding(padding: Style.pagePadding2, child:Text('人员: ${(widget.isTask ? getModel(context).user?.displayname : data.executor) ?? ''}')),
                  SizedBox(height: Style.separateHeight/2,),
                  Container(height: Style.separateHeight, color: Style.backgroundColor,),


                  Padding(padding: Style.pagePadding2, child:Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('备注: '),
                      Expanded(child: widget.isTask ? TextField(
                        controller: _controller,
                        maxLines: 3,
                        enabled: widget.isTask,
                        decoration: new InputDecoration(
                          contentPadding: EdgeInsets.all(0.0),
                          hintStyle: TextStyle(fontSize: 16.0),
                          hintText: '请输入备注信息',
                        ),
                      ): Text('${data.remark ??''}'))
                    ],
                  )),

                  Padding(padding: Style.pagePadding2, child:Row(
                    children: <Widget>[
                      Text('照片: '),
                      new PictureList(index: widget.index, canAdd: widget.isTask, step: widget.data, key: _key,)
                    ],
                  )),

                ],
              ),
            ),)),
          widget.isTask ? new Positioned(left: 0.0, bottom: 20.0, right: 0.0, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('异常报修', style: TextStyle(color: Colors.white),),
                color: Colors.redAccent,
                onPressed: (){

                },
              ),
              RaisedButton(
                child: Text('提交保存', style: TextStyle(color: Colors.white),),
                color: Style.primaryColor,
                onPressed: () async{
                  _postStep();
                },
              )
            ],
          )) : Positioned(left: 0.0, bottom: 0.0, right: 0.0, child: Text('')),
        ],

      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: widget.data.remark?? '');
    _status = widget.data.status?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _manager?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return new LoadingView(
      show: _show,
      tips: _tips,
      confirm: true,
      child: new Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: new AppBar(
            title: Text('填写结果'),
          ),
          body: _getBody()),
    );
  }
}
