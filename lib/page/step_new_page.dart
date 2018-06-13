import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/page/choose_assetnum_page.dart';
import 'package:samex_app/model/description.dart';
import 'package:samex_app/model/steps.dart';

class StepNewPage extends StatefulWidget {

  final OrderDetailData data;
  final int number;

  StepNewPage({@required this.data, @required this.number});

  @override
  _StepNewPageState createState() => _StepNewPageState();
}

class _StepNewPageState extends State<StepNewPage> {

  bool _show = false;

  TextEditingController _controller;
  String _assetNum = '';
  String _description = '';

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
    _controller = new TextEditingController();
    _assetNum = widget.data.assetnum;
    _description = widget.data.assetDescription;
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void postStep() async{
    Func.closeKeyboard(context);
    print('postStep : ${_controller.text}');

    if(_controller.text == null || _controller.text.length == 0){

      Func.showMessage('请填写任务描述再提交');
      return;
    }

    if(_assetNum.isEmpty || _description.isEmpty){
      Func.showMessage('请选择资产再提交');
      return;
    }
    OrderStep step = new OrderStep(
        stepno: widget.number * 10,
        assetnum: _assetNum,
        description: _controller.text,
        assetDescription: _description,
        wonum: widget.data.wonum
    );

    setState(() {
      _show = true;
    });

    try{
      Map response = await getApi(context).postStep(
          step, []);
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
          title: Text('新增任务'),
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
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _getMenus(preText: '工单:', content: Text(widget.data.wonum)),
                        _getMenus(preText: '步骤:', content: Text('${widget.number}')),
                        _getMenus(preText: '描述:', content: TextField(
                          controller: _controller,
                          maxLines: 3,
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
                                  final DescriptionData result = await Navigator.push(context,
                                    new MaterialPageRoute(
                                        builder:(_)=> new ChooseAssetPage())
                                  );

                                  if(result != null) {
                                    setState(() {
                                      _assetNum = result.assetnum;
                                      _description = result.description;
                                    });
                                  }

                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(_assetNum ?? '请选择资产', style: TextStyle(color: _assetNum == null ? Colors.grey: Colors.black),),
                                    Icon(Icons.navigate_next, color: Colors.black87,),
                                  ],
                                ))),
                        _getMenus(preText: '描述:', content:  Text(_description ?? '资产描述', style: TextStyle(color: _assetNum == null ? Colors.grey: Colors.black))),

                        SizedBox(height: 30.0,),

                        RaisedButton(
                          padding:EdgeInsets.symmetric(horizontal: 40.0),
                          onPressed: (){
                            postStep();
                          },
                          child: Text('提交', style: TextStyle( color: Colors.white),),
                          color: Style.primaryColor,
                        )
                      ],
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
