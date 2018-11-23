import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'package:meta/meta.dart';

import 'package:flutter/material.dart';
import 'package:samex_app/components/simple_button.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/utils/func.dart';

import 'package:image_picker/image_picker.dart';

import 'package:cached_network_image/cached_network_image.dart';

//import 'package:flutter_native_image/flutter_native_image.dart';

class PictureList extends StatefulWidget {

  final bool canAdd;
  final List<String> images;
  final int count;

  final String customStr;

  PictureList({Key key, this.canAdd = true,  this.images, this.count = 3, this.customStr}):super(key:key);

  @override
  PictureListState createState() => new PictureListState();
}

class PictureListState extends State<PictureList> {

  List<ImageData> _images = new List();

  List<ImageData> _resources = new List();

  Future _getImage(ImageSource value) async {
    File image = await ImagePicker.pickImage(source: value, maxHeight: 1280.0, maxWidth: 1280.0);

//    if(Platform.isIOS){
//      image = await FlutterNativeImage.compressImage(image.path,
//          quality: 98, percentage: 100);
//    }

    if(image != null){
      setState(() {
        ImageData data = new ImageData(
          path: image.path, 
          time: Func.getYYYYMMDDHHMMSSString(), 
          userName: '${Cache.instance.userName}-${Cache.instance.userDisplayName}'
        );
        _images.add(data);
//        getModel(context).step.images.add(data.toString());
      });
    }
  }

  List<ImageData> getImages() {
    return _images??[];
  }

  Widget _largeImage(Widget child,  int index){

//    print('largeimage : ${this._resources.toString()}');

    return new GestureDetector(
      onTap: (){
        Navigator.push(context, new MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return new Scaffold(
                appBar: new AppBar(
                    title: new Text('图片预览')
                ),

                body: new DefaultTabController(
                  length: _resources.length,
                  initialIndex: index,
                  child: Container(child:_PageSelector(icons: this._resources), color: Colors.black,),
                ),
              );
            }
        ));
      },
      child: widget.canAdd ? Stack(
        children: <Widget>[
          child,
          Positioned( right: 0.0,child:SimpleButton(
            elevation: 8.0,
            color: Colors.redAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
            onTap: (){

              if(widget.images != null && widget.images != null && widget.images.length > index){
                widget.images.removeAt(index);
              } else if(_images.length > 0){
                int preIndex = 0;
                if(widget.images != null ){
                  preIndex = widget.images.length;
                }

                _images.removeAt(index - preIndex);
              }

              setState(() {

              });
            },
            child:Icon(Icons.delete, size: 20.0, color: Colors.white,) ,
          ))
        ],
      ) : child,
    );
  }

  Widget _getImageList(){

    double width = min(120.0, MediaQuery.of(context).size.width / 4);

    List<Widget> children = <Widget>[];

    int count = 0;

    _resources.clear();

//    print('show picture list: ${widget.step.toString()}');

    if(widget.images != null){
      for(int i = 0, len = widget.images.length; i < len; i++){
        String id = widget.images[i];
        try {
          if(id.startsWith('/')) continue;

          ImageData data = new ImageData.fromString(id);

          children.add(_largeImage(

              Container(
                  height: width,
                  width: width,
                  child:new CachedNetworkImage(
                      imageUrl: getModel(context).api.getImageUrl(data.path),
                      placeholder: Center( child:new CircularProgressIndicator()),
                      errorWidget: new Icon(Icons.error, color: Colors.red,)))

              , count));

          data.path = getApi(context).getImageUrl(data.path);

          _resources.add(data);
          children.add(SizedBox(width: Style.separateHeight / 2,));
          count++;
        } catch (e){

          print(e);
        }
      }
    }


    for(int i = 0, len = _images.length; i < len; i++){
      children.add(_largeImage(new Image.file(File(_images[i].path), width: width,), count));

      children.add(SizedBox(width: Style.separateHeight/2,));
      _resources.add(_images[i]);
      count++;
    }

    bool canAdd = widget.canAdd ?? true;


    if(count < widget.count && canAdd){
      children.add(SizedBox(width: Style.separateHeight/2,));
      children.add(SimpleButton(
        onTap: (){

          showDialog<ImageSource>(
            context: context,
            builder: (BuildContext context) => new SimpleDialog(
                children: <Widget>[
                  new SimpleDialogOption(
                      child: Text('拍摄'),
                      onPressed: () { Navigator.pop(context, ImageSource.camera); }
                  ),
                  new SimpleDialogOption(
                      child: Text('从相册中选择'),
                      onPressed: () { Navigator.pop(context, ImageSource.gallery); }
                  ),
                ]
            ),
          ).then<void>((ImageSource value) { // The value passed to Navigator.pop() or null.
              _getImage(value);
          });

        },
        padding: EdgeInsets.all(10.0),
        child: Icon(Icons.add, size: width/2, color: Colors.grey,),
        shape: new Border.all(color: Colors.grey),
      ));
    }

    return Container(
        height: width,
        child: Row(
          children: children,
        ));
  }

  @override
  Widget build(BuildContext context) {

    if(widget.images != null && widget.images.length > 0){
      return _getImageList();
    } else {

      if(widget.canAdd){
        return  _getImageList();
      } else {
        return new Center(child: Text('未发现上传照片'));
      }

    }

  }
}

class ImageData {
  String path;
  String time;
  String userName;
  String customStr;

  ImageData({@required this.path, @required this.time, @required this.userName, this.customStr});

  @override
  String toString() {
    return '$path,$time,$userName';
  }

  ImageData.fromString([String data = '']) {
    if(data.contains(',')){
      List<String> list = data.split(',');
      path = list[0];
      time = list[1];
      if(list.length > 2) {
        userName = list[2];
      }
      if(list.length > 3) {
        customStr = list[3];
      }
    } else {
      print('图片格式有误:$data');
    }
  }
}

class _PageSelector extends StatelessWidget {
  const _PageSelector({ this.icons });

  final List<ImageData> icons;

  Align getCustomText(String str) {
    return Align(
      child: Text(str??'', style: TextStyle(color: Colors.red, fontSize: 18.0),),
      alignment: Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Colors.white;
    return new SafeArea(
      top: false,
      bottom: false,
      child: new Stack(
        children: <Widget>[
          new IconTheme(
            data: new IconThemeData(
              size: 128.0,
              color: color,
            ),
            child: new TabBarView(
                children: icons.map((ImageData icon) {
                  return new Stack(
                    children: <Widget>[
                      SizedBox.expand(child: new GridPhotoViewer(path: icon.path)),
                      Column(
                        children: <Widget>[
                          Align(
                            child: Text(icon.userName??"", style: TextStyle(color: Colors.red, fontSize: 18.0),),
                            alignment: Alignment.topCenter,
                          ),
                          Align(
                            child: Text(icon.time??"", style: TextStyle(color: Colors.red, fontSize: 18.0),),
                            alignment: Alignment.topCenter,
                          ),
                          getCustomText(icon.customStr)
                        ],
                      )
                    ],
                  );
                }).toList()
            ),
          ),
          Positioned(
              bottom: 20.0,
              left: 0.0,
              right: 0.0,
              child: new Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: new Row(

                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new TabPageSelector(controller: controller, color: Colors.black, selectedColor: Colors.white,),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center
                  )
              )),
        ],
      ),
    );
  }
}

const double _kMinFlingVelocity = 800.0;

class GridPhotoViewer extends StatefulWidget {
  const GridPhotoViewer({ Key key, @required this.path }) : super(key: key);

  final String path;

  @override
  _GridPhotoViewerState createState() => new _GridPhotoViewerState();
}

class _GridPhotoViewerState extends State<GridPhotoViewer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = new Offset(size.width, size.height) * (1.0 - _scale);
    return new Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity)
      return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = new Tween<Offset>(
        begin: _offset,
        end: _clampOffset(_offset + direction * distance)
    ).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      onDoubleTap: (){
        Navigator.pop(context);
      },
      child: new ClipRect(
        child: new Transform(
          transform: new Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: widget.path.startsWith('http') ? new CachedNetworkImage(
            imageUrl: widget.path,
            placeholder: Center( child: new CircularProgressIndicator()),
            errorWidget: new Icon(Icons.error),
          )
              : new Image.file(new File(widget.path), fit: BoxFit.cover,) ,
        ),
      ),
    );
  }
}
