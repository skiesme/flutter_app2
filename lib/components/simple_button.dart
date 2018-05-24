import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class SimpleButton extends StatelessWidget {

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;

  final EdgeInsets padding;
  final double elevation;
  final ShapeBorder shape;
  final Color color;

  SimpleButton({@required this.child, this.onTap, this.padding, this.elevation, this.onLongPress, this.shape, this.color, this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: elevation??0.0,
      color: color ?? Colors.transparent,
      shape: this.shape,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: Padding(
          padding: padding?? EdgeInsets.all(1.0),
          child: child,
        ),
      ),
    );
  }
}
