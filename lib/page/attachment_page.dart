import 'dart:async';

import 'package:flutter/material.dart';

import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:after_layout/after_layout.dart';
import 'package:samex_app/model/cm_attachments.dart';

class AttachmentPage extends StatefulWidget {
  final OrderDetailData detailData;
  final List<OrderStep> steps;

  AttachmentPage({@required this.detailData, this.steps});

  @override
  _AttachmentPageState createState() => new _AttachmentPageState();
}

class _AttachmentPageState extends State<AttachmentPage>
    with AfterLayoutMixin<AttachmentPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _getLoading([String info = '没有附件信息']) {
    List<OrderStep> data =
        getMemoryCache<List<OrderStep>>(cacheKey, expired: false);

    if (data == null) {
      return Center(child: Text(info));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  List<OrderStep> _filter(List<OrderStep> data) {
    if (data == null) return null;
    // return data.where((i) => (i.images != null && i.images.length > 0)).toList();
    return data;
  }

  Widget _getAttachmentsWidget() {
    List<OrderStep> data =
        getMemoryCache<List<OrderStep>>(cacheKey, expired: false);
    data = _filter(data);

    return data == null || data.length == 0
        ? _getLoading('未发现步骤附件')
        : RefreshIndicator(
            onRefresh: _getSteps,
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, int index) {
                  print('index:${index}');
                  OrderStep step = data[index];
                  return new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: Style.pagePadding,
                        child: Text('步骤: ${step.stepno ~/ 10}'),
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      Padding(
                        padding: Style.pagePadding2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('备注: '),
                            Expanded(
                                child: Text(
                                    '${step.description ?? ''}\n${step.remark ?? ''}'))
                          ],
                        ),
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      Padding(
                        padding: Style.pagePadding2,
                        child: Row(
                          children: <Widget>[
                            Text('照片: '),
                            PictureList(
                              images: step.images,
                              canAdd: false,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: Style.padding / 2,
                        color: Style.backgroundColor,
                      )
                    ],
                  );
                }));
  }

  Widget _getCMAttachmentsWidget() {
    List<String> data = new List();
    data = getMemoryCache<List<String>>(cacheKey2, expired: false);

    if (data == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (data.length == 0) return Center(child: Text(''));

    return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: Style.pagePadding2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('描述: '),
                Expanded(child: Text(widget.detailData.description))
              ],
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Padding(
            padding: Style.pagePadding2,
            child: Row(
              children: <Widget>[
                Text('照片: '),
                PictureList(
                  images: data,
                  canAdd: false,
                )
              ],
            ),
          ),
          Container(
            height: Style.padding / 2,
            color: Style.backgroundColor,
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (!isCM()) {
      getMemoryCache(cacheKey, callback: () {
        _getSteps();
      });

      child = _getAttachmentsWidget();
    } else {
      getMemoryCache(cacheKey2, callback: () {
        _getCMAttachments();
      });
      child = _getCMAttachmentsWidget();
    }

    return new Scaffold(
        appBar: new AppBar(
          title: Text('附件'),
          centerTitle: true,
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (isCM()) {
                    _getCMAttachments();
                  }
                  _getSteps();
                })
          ],
        ),
        body: child);
  }

  Future<Null> _getSteps() async {
    if (widget.detailData.wonum != null) {
      try {
        Map response = await getApi().steps(
            sopnum: '',
            wonum: widget.detailData.wonum,
            site: Cache.instance.site);
        StepsResult result = new StepsResult.fromJson(response);

        if (result.code != 0) {
          Func.showMessage(result.message);
        } else {
          if (mounted) {
            setState(() {
              setMemoryCache(cacheKey, result.response.steps);
            });
          }
        }
      } catch (e) {
        print(e);
        Func.showMessage('出现异常: 获取步骤列表失败');
      }
    }
  }

  Future<Null> _getCMAttachments() async {
    if (widget.detailData.wonum != null) {
      try {
        Map response =
            await getApi().getCMAttachments(widget.detailData.ownerid);
        CMAttachmentsResult result = new CMAttachmentsResult.fromJson(response);

        print(result.toJson().toString());

        if (result.code != 0) {
          Func.showMessage(result.message);
        } else {
          if (mounted) {
            setState(() {
              setMemoryCache(cacheKey2, result.response);
            });
          }
        }
      } catch (e) {
        print(e);
        Func.showMessage('出现异常: 获取维修工单附件失败');
      }
    }
  }

  get cacheKey {
    var key = widget.detailData.wonum ?? '';

    if (!isCM()) {
      if (key.isEmpty) return '';

      return 'stepsList_$key';
    } else {
      return 'cm_attachments+$key';
    }
  }

  get cacheKey2 {
    var key = '2_' + widget.detailData.wonum ?? '';

    if (!isCM()) {
      if (key.isEmpty) return '';

      return 'stepsList_$key';
    } else {
      return 'cm_attachments+$key';
    }
  }

  bool isCM() {
    return getOrderType(widget.detailData.worktype) != OrderType.CM ||
        getOrderType(widget.detailData.worktype) != OrderType.BG;
  }

  @override
  void afterFirstLayout(BuildContext context) {}
}
