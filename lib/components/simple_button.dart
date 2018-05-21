import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class SimpleButton extends StatelessWidget {

  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double elevation;

  SimpleButton({@required this.child, this.onTap, this.padding, this.elevation});

  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: elevation??0.0,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding?? EdgeInsets.all(1.0),
          child: child,
        ),
      ),
    );
  }
}
