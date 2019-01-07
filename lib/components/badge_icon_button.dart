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
    
    double badgeH = widget.badgeHeight + 4;
    Widget child = Material(
      type: MaterialType.canvas,
      elevation: 2.0,
      borderRadius: BorderRadius.all(Radius.circular(badgeH * 0.5)),
      color: widget.badgeColor,
      child: Container(
        height: badgeH,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5.5),
        child: Text(
          widget.itemCount > widget.badgeMax ? "${widget.badgeMax}+" : widget.itemCount.toString(),
          style: TextStyle(
            fontSize: 13.0,
            color: widget.badgeTextColor,
            fontWeight: FontWeight.bold,
          )
        ),
      )
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
                child: child,
              ) : child,
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