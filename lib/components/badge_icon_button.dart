import 'dart:io';

import 'package:flutter/material.dart';

class BadgeIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final int itemCount;
  final Color badgeColor;
  final Color badgeTextColor;
  final Widget icon;
  final bool hideZeroCount;
  final bool animation;
  final double badgeHeight;
  final int badgeMax;

  BadgeIconButton({
    Key key,
    @required this.itemCount,
    @required this.icon,
    this.onPressed,
    this.animation: true,
    this.hideZeroCount: true,
    this.badgeColor: Colors.red,
    this.badgeTextColor: Colors.white,
    this.badgeHeight: 15.0,
    this.badgeMax: 99
  })  : assert(itemCount >= 0),
        assert(badgeColor != null),
        assert(badgeTextColor != null),
        super(key: key);

  @override
  BadgeIconButtonState createState() {
    return BadgeIconButtonState();
  }
}

class BadgeIconButtonState extends State<BadgeIconButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  final Tween<Offset> _badgePositionTween = Tween(
    begin: const Offset(-0.5, 0.9),
    end: const Offset(0.0, 0.0),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.hideZeroCount && widget.itemCount == 0) {
      return widget.icon;
    }

    double badgeH = Platform.isAndroid ? widget.badgeHeight : widget.badgeHeight + 4;
    double radius = (badgeH + 4) * 0.5;
    
    String badgeStr = widget.itemCount > widget.badgeMax ? "${widget.badgeMax}+" : widget.itemCount.toString();
    Widget badgeView = Material(
      color: Colors.transparent,
      child: Container(
        height: badgeH,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4.0),
        decoration: BoxDecoration(color: const Color(0xFFFF232D), borderRadius: BorderRadius.circular(radius)),
        child: Center(child: Text('${badgeStr}', style: TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center,))
      ),
    );

    return Stack(
      overflow: Overflow.visible,
      children: [
        widget.icon,
        Positioned(
          top: -8.0,
          right: -16.0,
          child: widget.animation ? SlideTransition(
            position: _badgePositionTween.animate(_animation),
            child: badgeView,
          ) : badgeView,
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(BadgeIconButton oldWidget) {
    if (widget.itemCount != oldWidget.itemCount) {
      _animationController.reset();
      _animationController.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
    _animationController.forward();
  }
}