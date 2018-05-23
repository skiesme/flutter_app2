import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/components/simple_button.dart';

import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/utils/style.dart';

import 'package:image_picker/image_picker.dart';


class PictureList extends StatefulWidget {

  final int index;
  final bool canAdd;

  PictureList({@required this.index, this.canAdd = true});

  @override
  _PictureListState createState() => new _PictureListState();
}

class _PictureListState extends State<PictureList> {

  OrderStep _step;

  List<File> _images = new List();

  List<String> _resources = new List();

  Future _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    if(image != null){
      setState(() {
        _images.add(image);
      });
    }
  }

  Widget _largeImage(Widget child,  int index){

    if(!getModel(context).isTask) return child;
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
                  child: Container(child:_PageSelector(icons: _resources,), color: Colors.black,),
                ),
//                body: new SizedBox.expand(
//                  child:  new PageView.builder(
//                      controller: new PageController(initialPage: index),
//                      itemCount: _resources.length,
//                      itemBuilder: (_, index){
//                        return new GridPhotoViewer(path: _resources[index]);
//                      }),
//                ),
              );
            }
        ));
      },
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          child,
          Positioned( right: 0.0,child:SimpleButton(
            elevation: 8.0,
            color: Colors.redAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
            onTap: (){
              if(_step != null && _step.images != null && _step.images.length > index){
                _step.images.removeAt(index);
              } else {
                int preIndex = 0;
                if(_step != null && _step.images != null){
                  preIndex = _step.images.length;
                }

                _images.removeAt(index - preIndex);

                setState(() {

                });
              }
            },
            child:Icon(Icons.delete, size: 20.0, color: Colors.white,) ,
          ))
        ],
      ),
    );
  }

  Widget _getImageList(){

    double width = min(120.0, MediaQuery.of(context).size.width / 4);

    List<Widget> children = <Widget>[];

    int count = 0;

    _resources.clear();

    if(_step.images != null){
      for(int i = 0, len = _step.images.length; i < len; i++){
        String id = _step.images[i];
        children.add( _largeImage(
            new Image(image: NetworkImage(getApi(context).getImageUrl(id), headers: {
              'Authorization': Cache.instance.token
            }), width: width,), count));

        _resources.add(id);
        children.add(SizedBox(width: Style.separateHeight/2,));
        count++;
      }
    }


    for(int i = 0, len = _images.length; i < len; i++){
      children.add(_largeImage(new Image.file(_images[i], width: width,), count));

      children.add(SizedBox(width: Style.separateHeight/2,));
      _resources.add(_images[i].path);
      count++;
    }

    bool canAdd = widget.canAdd ?? true;


    if(count < 3 && canAdd){
      children.add(SizedBox(width: Style.separateHeight/2,));
      children.add(SimpleButton(
        onTap: (){
          print('add .. $width');
          _getImage();
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

    if(getModel(context).stepsList.length > widget.index){
      _step =  getModel(context).stepsList[widget.index];
    }

    if(_step?.images != null && _step.images.length > 0){
      return _getImageList();
    } else {

      bool canAdd = widget.canAdd ?? true;
      if(canAdd){
        return  _getImageList();
      } else {
        return new Center(child: Text('未发现上传照片'));
      }

    }

  }
}


class _PageSelector extends StatelessWidget {
  const _PageSelector({ this.icons });

  final List<String> icons;

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller.animateTo((controller.index + delta).clamp(0, icons.length - 1));
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
                children: icons.map((String icon) {
                  return new Container(
                    child: new GridPhotoViewer(path: icon),
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
          child: widget.path.startsWith('http') ? Image(
              image: NetworkImage(widget.path, headers: {
                'Authorization': Cache.instance.token
              }))
              : new Image.file(new File(widget.path)) ,
        ),
      ),
    );
  }
}
