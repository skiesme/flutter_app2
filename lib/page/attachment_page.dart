import 'dart:async';

import 'package:flutter/material.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:after_layout/after_layout.dart';


class AttachmentPage extends StatefulWidget {

  final String wonum;

  final List<OrderStep> data;

  AttachmentPage({@required this.wonum, this.data});

  @override
  _AttachmentPageState createState() => new _AttachmentPageState();
}

class _AttachmentPageState extends State<AttachmentPage> with AfterLayoutMixin<AttachmentPage> {

  List<OrderStep> _data;

  @override
  void initState() {
    super.initState();

    _data = widget.data??[];
    if(_data.length == 0) {
      _data = getMemoryCache<List<OrderStep>>(cacheKey);
    }

  }

  Widget _getLoading() {
    if(_data == null){
      return Center(child: CircularProgressIndicator());
    } else  {
      return Center(child: Text('没有附件信息'));
    }
  }

  List<OrderStep> _filter() {
    if(_data == null) return null;
    return _data.where((i) => (i.images != null && i.images.length > 0)).toList();
  }

  @override
  Widget build(BuildContext context) {

    List<OrderStep> data = _filter();

    return new Scaffold(
      appBar: new AppBar(
        title: Text('附件'),
      ),

      body: data == null || data.length == 0 ? _getLoading() : RefreshIndicator(
          onRefresh:_getSteps,
          child:ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, int index) {
                OrderStep step = data[index];
                return new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[

                    Padding(padding: Style.pagePadding,
                      child: Text('步骤: ${step.stepno ~/ 10}') ,),
                    Divider(height: 1.0,),

                    Padding(padding: Style.pagePadding2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('备注: '),
                          Expanded(child:Text(step.description))
                        ],
                      ) ,),
                    Divider(height: 1.0,),

                    Padding(padding: Style.pagePadding2,
                      child: Row(
                        children: <Widget>[
                          Text('照片: '),
                          PictureList(images: step.images, canAdd: false,)
                        ],
                      ) ,),

                    Container(height: Style.padding/2, color: Style.backgroundColor,)
                  ],
                );
              })),

    );
  }


  Future<Null> _getSteps() async {
    if(widget.wonum != null){
      try{
        Map response = await getApi(context).steps(sopnum: '', wonum: widget.wonum, site: Cache.instance.site);
        StepsResult result = new StepsResult.fromJson(response);

        if(result.code != 0){
          Func.showMessage(result.message);
        } else {
          setState(() {
            _data = result.response.steps;

            setMemoryCache(cacheKey, _data);
          });
        }

      } catch (e){
        print (e);
        Func.showMessage('网络出现异常: 获取步骤列表失败');
      }
    }

  }

  get cacheKey {
    var key = widget.wonum ??'';
    if(key.isEmpty) return '';
    return 'stepsList_$key';
  }

  @override
  void afterFirstLayout(BuildContext context) {

    if(_data == null){
      _getSteps();
    }

  }

}
