import 'package:flutter/material.dart';
import 'package:samex_app/model/assetnum_detail.dart';

import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/picture_list.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:dio/dio.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/model/order_new.dart';


class UploadAssetPage extends StatefulWidget {
  final AssetNumDetail asset;

  UploadAssetPage({@required this.asset});

  @override
  _UploadAssetPageState createState() => _UploadAssetPageState();
}

class _UploadAssetPageState extends State<UploadAssetPage> {
  bool _show = false;
  String _tips;

  GlobalKey<PictureListState> _key = new GlobalKey<PictureListState>();

  CalculationManager _manager;

  void setMountState(VoidCallback func) {
    if (mounted) {
      setState(func);
    }
  }


  List<String> getUploadImages(List<ImageData> images) {
    List<String> list = [];
    if (images == null) return list;

    images.forEach((ImageData f) {
      try {
        print('add, ${f.toString()}');
        if (f.path.startsWith('/')) {
          list.add(f.path);
        }
      } catch (e) {}
    });

    return list;
  }

  void _post() async {

    setState(() {
      _show = true;
    });

    try {
      List<String> origin = new List();
      origin.addAll(widget.asset.pic ?? []);

      List<ImageData> data = _key.currentState.getImages();

      List<MultipartFile> list = new List();

      List<String> uploadImages = getUploadImages(data);

      if(uploadImages.length == 0) {
        Func.showMessage('未发现修改');
        setMountState(() {
          _show = false;
        });

        return;
      }

      var post = () async {
        try {
          _manager?.stop();
          Map response = await getApi().postAsset(
              widget.asset.assetnum,
              list);
          OrderNewResult result = new OrderNewResult.fromJson(response);
          if (result.code != 0) {
            Func.showMessage(result.message);
          } else {
            Func.showMessage('新建成功');
            Navigator.pop(context, true);
            return;
          }
        } catch (e) {
          print(e);
          Func.showMessage('出现异常, 提交失败');
        }

        if (mounted) {
          setState(() {
            _show = false;
          });
        }
      };

      _manager = new CalculationManager(
          images: uploadImages,
          onProgressListener: (int step) {
            setMountState(() {
              _tips = '图片$step处理中';
            });
          },
          onResultListener: (List<MultipartFile> files) {
            print('onResultListener ....len=${files.length}, ');
            list = files;

            setMountState(() {
              _tips = '上传中';
            });
            post();
          });

      _manager?.start();

    } catch (e) {
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return new LoadingView(
        show: _show,
        tips: _tips,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text('资产 ${widget.asset.assetnum} 图片管理'),
            centerTitle: true,
          ),

          body: Container(
            padding: const EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('描述: '+widget.asset.description ?? ''),
                SizedBox(height: 20.0,),
                Row(
                  children: <Widget>[
                    Text('图片: '),
                    PictureList(
                      key: _key,
                      count: 2,
                      canAdd: true,
                      images: widget.asset.pic??[],
                    )
                  ],
                ),
                SizedBox(height: 40.0,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SimpleButton(
                        onTap: (){
                          _post();
                        },
                        elevation: 2.0,

                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(4.0)),
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                        color: Colors.blueAccent,
                        child: Row(
                          children: <Widget>[
                            Text('提交', style: TextStyle(color: Colors.white, fontSize: 18.0),),
                          ],
                        ))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
