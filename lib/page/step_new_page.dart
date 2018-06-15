import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/page/choose_assetnum_page.dart';
import 'package:samex_app/model/description.dart';
import 'package:samex_app/model/steps.dart';

class StepNewPage extends StatefulWidget {

  final OrderStep step;
  final bool read;

  StepNewPage({@required this.step, @required this.read = false});

  @override
  _StepNewPageState createState() => _StepNewPageState();
}

class _StepNewPageState extends State<StepNewPage> {

  bool _show = false;
  OrderStep _step;

  TextEditingController _controller;
  TextEditingController _controller2;

  Widget _getMenus({
    String preText,
    Widget content,
    EdgeInsets padding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,

  }){
    return new Container(
      padding: padding??EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Text(preText),
          SizedBox(width: Style.separateHeight,),
          Expanded(child: content)
        ],
      ),
      decoration: new BoxDecoration(
        color: Colors.white,
          border: new Border(
          bottom: Divider.createBorderSide(context, width: 1.0)
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    _step = widget.step;

    _controller = new TextEditingController(text: _step.description??'');
    _controller2 = new TextEditingController(text: _step.remark??'');
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller2?.dispose();

  }

  void postStep() async{
    Func.closeKeyboard(context);
//    print('postStep : ${_controller.text}');

    if(_controller.text == null || _controller.text.length == 0){

      Func.showMessage('请填写任务描述再提交');
      return;
    }

    setState(() {
      _show = true;
    });

    _step.remark = _controller2.text;
    _step.description = _controller.text;

    try{
      Map response = await getApi(context).postStep(
          _step, []);
      StepsResult result = new StepsResult.fromJson(response);
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        Func.showMessage('提交成功');
        Navigator.pop(context, true);
        return;
      }

    } catch (e) {
      print(e);
      Func.showMessage('出现异常, 新建任务失败');
    }

    if(mounted){
      setState(() {
        _show = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text(_controller.text.isEmpty ? '新增任务':'任务填写'),
        ),

        body: new GestureDetector(
          onTap: (){
            Func.closeKeyboard(context);
          },
          child:  LoadingView(
            show: _show,
            child: Container(
              color: Style.backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _getMenus(preText: '工单:', content: Text(_step.wonum)),
                          _getMenus(preText: '步骤:', content: Text('${_step.stepno ~/ 10}')),
                          _getMenus(preText: '描述:', content: TextField(
                            controller: _controller,
                            maxLines: 3,
                            enabled: !widget.read,
                            decoration: new InputDecoration.collapsed(
                              hintText: '请输入任务描述',
                            ),
                          ),
                              crossAxisAlignment: CrossAxisAlignment.start
                          ),

                          _getMenus(preText: '资产:',
                              padding: EdgeInsets.only(left: 8.0),
                              content: SimpleButton(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  onTap: () async {
                                    if(widget.read) return;
                                    final DescriptionData result = await Navigator.push(context,
                                      new MaterialPageRoute(
                                          builder:(_)=> new ChooseAssetPage())
                                    );

                                    if(result != null) {
                                      setState(() {
                                        _step.assetnum = result.assetnum;
                                        _step.assetDescription = result.description;
                                      });
                                    }

                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(_step.assetnum ?? '请选择资产', style: TextStyle(color: _step.assetnum == null ? Colors.grey: Colors.black),),
                                      Icon(Icons.navigate_next, color: Colors.black87,),
                                    ],
                                  ))),
                          _getMenus(preText: '描述:', content:  Text(_step.assetDescription ?? '资产描述', style: TextStyle(color: _step.assetnum == null ? Colors.grey: Colors.black))),

                          _getMenus(preText: '备注:', content: TextField(
                            controller: _controller2,
                            maxLines: 3,
                            enabled: !widget.read,
                            decoration: new InputDecoration.collapsed(
                              hintText: '请输入备注',
                            ),
                          ),
                              crossAxisAlignment: CrossAxisAlignment.start
                          ),

                          _getMenus(preText: '人员:', content:  Text(_step.executor??'')),

                        ],
                      ),
                    ),
                  ),

                  widget.read ? Container() : Material(
                    elevation: 6.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: RaisedButton(
                          padding:EdgeInsets.symmetric(horizontal: 40.0),
                          onPressed: (){
                            postStep();
                          },
                          child: Text('提交', style: TextStyle( color: Colors.white, fontSize: 18.0),),
                          color: Style.primaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
