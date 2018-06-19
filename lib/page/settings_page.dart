import 'package:flutter/material.dart';

import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/data/root_model.dart';

class GalleryTextScaleValue {
  const GalleryTextScaleValue(this.scale, this.label);

  final double scale;
  final String label;

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType)
      return false;
    final GalleryTextScaleValue typedOther = other;
    return scale == typedOther.scale && label == typedOther.label;
  }

  @override
  int get hashCode => hashValues(scale, label);

  @override
  String toString() {
    return '$runtimeType($label)';
  }

}

const List<GalleryTextScaleValue> kAllGalleryTextScaleValues = const <GalleryTextScaleValue>[
  const GalleryTextScaleValue(null, '系统默认'),
  const GalleryTextScaleValue(0.8, '小'),
  const GalleryTextScaleValue(1.0, '正常'),
  const GalleryTextScaleValue(1.3, '大'),
//  const GalleryTextScaleValue(2.0, '超大'),
];

class SettingsPage extends StatefulWidget {

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {


    GalleryTextScaleValue textScaleFactor = GalleryTextScaleValue(null, '系统默认');
    double _scale = Cache.instance.textScaleFactor;
    if(_scale != null){
      for(int i = 1; i < kAllGalleryTextScaleValues.length ; i++){
        if((kAllGalleryTextScaleValues[i].scale * 10).toInt() == (_scale*10).toInt()){
          textScaleFactor = kAllGalleryTextScaleValues[i];
          break;
        }
      }
    }

    print('_scale=$_scale, ${textScaleFactor.scale??0} - ${textScaleFactor.label}');

    return new Scaffold(
      appBar: new AppBar(
        title: Text('设置'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('字体大小'),
                      new Text(
                        '${textScaleFactor.label}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
                new PopupMenuButton<GalleryTextScaleValue>(
                  padding: const EdgeInsetsDirectional.only(end: 16.0),
                  icon: const Icon(Icons.arrow_drop_down),
                  itemBuilder: (BuildContext context) {
                    return kAllGalleryTextScaleValues.map((GalleryTextScaleValue scaleValue) {
                      return new PopupMenuItem<GalleryTextScaleValue>(
                        value: scaleValue,
                        child: new Text(scaleValue.label),
                      );
                    }).toList();
                  },
                  onSelected: (GalleryTextScaleValue scaleValue) {
                    Cache.instance.setDoubleValue(KEY_FONT_SIZE, scaleValue.scale);
                    getModel(context).onTextScaleChanged(scaleValue.scale);
                    setState(() {

                    });
                  },
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
