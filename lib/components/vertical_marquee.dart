import 'dart:async';

import 'package:flutter/material.dart';
import 'package:samex_app/utils/style.dart';

class Marquee extends StatefulWidget {
  final List<String> textList;
  final double fontSize;
  final Color textColor;
  final Duration scrollDuration;
  final Duration stopDuration;
  final bool tapToNext;
  final MarqueeController controller;

  const Marquee({
    Key key,
    this.textList = const [],
    this.fontSize = 14.0,
    this.textColor = Colors.black,
    this.scrollDuration = const Duration(seconds: 1),
    this.stopDuration = const Duration(seconds: 3),
    this.tapToNext = false,
    this.controller,
  }) : super(key: key);

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  double percent = 0.0;
  int current = 0;

  List<String> get textList => widget.textList;

  Timer stopTimer;

  AnimationController animationConroller;

  MarqueeController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    animationConroller = AnimationController(vsync: this);
    stopTimer = Timer.periodic(widget.stopDuration + widget.scrollDuration, (timer) {
      next();
    });
  }

  @override
  void dispose() {
    animationConroller.dispose();
    stopTimer.cancel();
    super.dispose();
  }

  void next() {
    var listener = () {
      var value = animationConroller.value;
      setState(() {
        percent = value;
        _refreshControllerValue();
      });
    };

    animationConroller.addListener(listener);
    animationConroller.animateTo(1.0, duration: widget.scrollDuration * (1 - percent)).then((t) {
      animationConroller.removeListener(listener);
      animationConroller.value = 0.0;
      setState(() {
        percent = 0.0;
        current = nextPosition;
        _refreshControllerValue();
      });
    });
  }

  void _refreshControllerValue() {
    controller?.position = current;
    if (percent > 0.5) {
      controller?.position = nextPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (textList == null || textList.isEmpty) {
      return Container();
    }

    if (textList.length == 1) {
      return Text(
        textList[0],
        style: TextStyle(
          fontSize: widget.fontSize,
          // color: widget.textColor,
          color: Style.getStatusStyle(textList[0]).color,
        ),
        textAlign: TextAlign.left,
      );
    }

    Widget _widget = ClipRect(
      child: CustomPaint(
        child: Container(),
        painter: _MarqueePainter(
          widget.textList,
          fontSize: widget.fontSize,
          textColor: widget.textColor,
          verticalSpace: 0.0,
          percent: percent,
          current: current,
        ),
      ),
    );

    if (widget.tapToNext) {
      _widget = GestureDetector(
        onTap: next,
        child: _widget,
      );
    }

    return _widget;
  }

  int get nextPosition {
    var next = current + 1;
    if (next >= textList.length) {
      next = 0;
    }
    return next;
  }
}

class _MarqueePainter extends CustomPainter {
  List<String> textList;
  double verticalSpace;
  double fontSize;
  Color textColor;

  int current = 0;

  double percent = 0.0;

  _MarqueePainter(
    this.textList, {
    this.fontSize,
    this.textColor,
    this.verticalSpace,
    this.percent = 0.0,
    this.current,
  });

  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.left);

  @override
  void paint(Canvas canvas, Size size) {
    _paintCurrent(size, canvas);
    _paintNext(size, canvas);
  }

  void _paintCurrent(Size size, Canvas canvas) {
    String text = textList[current];
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        // color: textColor,
        color: Style.getStatusStyle(text).color,
      ),
    );
    textPainter.textAlign = TextAlign.left;
    textPainter.maxLines = 1;
    textPainter.ellipsis = "...";

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, _getTextOffset(textPainter, size));
  }

  _paintNext(Size size, Canvas canvas) {
    String text = textList[nextPosition];
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        // color: textColor,
        color: Style.getStatusStyle(text).color,
      ),
    );
    textPainter.textAlign = TextAlign.left;
    textPainter.maxLines = 1;
    textPainter.ellipsis = "...";

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, _getTextOffset(textPainter, size, isNext: true));
  }

  Offset _getTextOffset(TextPainter textPainter, Size size, {bool isNext = false}) {
    var width = textPainter.width;
    if (width >= size.width) {
      width = size.width;
    }
    var height = textPainter.height;
    var dx = 1.0;
    var dy = size.height / 2 - height / 2 - size.height * percent;
    if (isNext) {
      dy = dy + size.height;
    }
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  int get nextPosition {
    var next = current + 1;
    if (next >= textList.length) {
      next = 0;
    }
    return next;
  }
}

class MarqueeController {
  int position;
}