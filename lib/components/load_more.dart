import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const kRefreshOffset = 40.0;
const kLoadMoreOffset = 0.0;

enum _PullIndicatorMode { idle, dragReleaseRefresh, dragReleaseLoadMore, dragReleaseCancel, refreshing, loading }

typedef Future LoadMoreCallback();

class LoadMore extends StatefulWidget {
  final Widget child;
  final LoadMoreCallback onLoadMore;

  final double loadMoreOffset;

  final NotificationListenerCallback<ScrollNotification> scrollNotification;

  final bool enableLoadMore;

  final bool isFinish;

  LoadMore({
    @required this.child,
    this.onLoadMore,
    this.loadMoreOffset = kLoadMoreOffset,
    this.scrollNotification,
    this.enableLoadMore = true,
    this.isFinish = false,
  });

  @override
  _LoadMoreState createState() => new _LoadMoreState();
}

class _LoadMoreState extends State<LoadMore> with TickerProviderStateMixin {
  double _dragOffset;

  _PullIndicatorMode _mode;

  var isLoading = false;

  Animation<double> _value;
  AnimationController _positionController;

  @override
  void initState() {
    _positionController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 300));
    _value = new Tween<double>(
      // The "value" of the circular progress indicator during a drag.
      begin: 0.0,
      end: 1.0,
    ).animate(_positionController);

    super.initState();
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    if(widget.child is ListView && enableLoadMore){
//      return widget.child;
//    }

    Widget _widget = new NotificationListener(
      onNotification: _handleScrollNotification,
      child: widget.child,
    );

    return new Stack(
      children: <Widget>[
        _widget,
        new Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 30.0,
          child: new FadeTransition(
            opacity: _value,
            child: new KProgressWidget(
              text: "",
              isLoading: true,
            ),
          ),
        )
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    if (widget.scrollNotification != null && notification.depth == 0) {
      widget.scrollNotification(notification);
    }

    if (notification is ScrollStartNotification) {
      _dragOffset = 0.0;
      _mode = _PullIndicatorMode.dragReleaseCancel;
    }

    if (notification is UserScrollNotification) {}

    if (notification is ScrollUpdateNotification) {
      _dragOffset -= notification.scrollDelta;

      if (_mode == _PullIndicatorMode.dragReleaseCancel ||
          _mode == _PullIndicatorMode.dragReleaseRefresh ||
          _mode == _PullIndicatorMode.dragReleaseLoadMore) {
        if (notification.metrics.extentAfter == 0.0 && _dragOffset < -widget.loadMoreOffset) {
//          changeMode(_PullIndicatorMode.dragReleaseLoadMore);
          _handleLoadMore();
        } else if (notification.metrics.extentAfter == 0.0) {
//          changeMode(_PullIndicatorMode.dragReleaseCancel);
        }
      }
    }

    if (notification is OverscrollNotification) {}

    if (notification is ScrollEndNotification) {
//      _dragOffset = null;
//      changeMode(null);
    }
    return false;
  }

  void _handleLoadMore() {
    if (!widget.enableLoadMore || widget.isFinish) {
      print("return is state");
      return;
    }
    if (widget.onLoadMore != null && !isLoading) {
      print("_handle loadMore");
      handleResult(widget.onLoadMore());
    }
  }

  void changeMode(_PullIndicatorMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  Future handleResult(Future result) async {
    print("handleResult");
    assert(() {
      if (result == null)
        FlutterError.reportError(new FlutterErrorDetails(
          exception: new FlutterError('The onRefresh/onLoadMore callback returned null.\n'
              'The ScrollIndicator onRefresh/onLoadMore callback must return a Future.'),
          context: 'when calling onRefresh/onLoadMore',
          library: 'loadmore',
        ));
      return true;
    }());
    if (result == null) return;
    isLoading = true;
    _positionController?.forward();
    await result;
    _positionController?.reverse();
    isLoading = false;
    if (mounted && _mode == _PullIndicatorMode.refreshing) {
      changeMode(_PullIndicatorMode.idle);
    }
    if (mounted && _mode == _PullIndicatorMode.loading) {
      changeMode(_PullIndicatorMode.idle);
    }

//
//    result.whenComplete(() {
//
//    });
  }
}

class KProgressWidget extends StatelessWidget {
  final bool isLoading;
  final String text;
  final double size;

  final Color background;

  const KProgressWidget({
    Key key,
    this.isLoading = false,
    @required this.text,
    this.size = 24.0,
    this.background = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = new SizedBox(
      child: new CircularProgressIndicator(),
      width: size,
      height: size,
    );
    if (!isLoading) {
      result = new Text(
        text,
        maxLines: 1,
      );
    }
    return new Center(
      child: new ClipRRect(
        borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
        child: new Container(
          color: background,
          alignment: Alignment.bottomCenter,
          child: new Center(
            child: new Padding(
              child: result,
              padding: const EdgeInsets.all(12.0),
            ),
          ),
        ),
      ),
    );
  }
}