import 'package:flutter/material.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/assets.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';

class HDOrderItem extends StatefulWidget {
  final OrderShortInfo info;
  final bool isAll;
  final GestureTapCallback onTap;

  HDOrderItem({@required this.info, this.isAll, this.onTap});

  @override
  _HDOrderItemState createState() => new _HDOrderItemState();
}

class _HDOrderItemState extends State<HDOrderItem> {
  static const double _padding = 16.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /** Colors */
  Color getColor() {
    switch (getOrderType(widget.info.worktype)) {
      case OrderType.XJ:
        if (widget.info.actfinish == 0) {
          return Colors.blue.shade900;
        } else {
          return Colors.green;
        }
        break;
      case OrderType.CM:
        if (widget.info.status.contains('待批准')) {
          return Colors.red.shade900;
        } else if (widget.info.status.contains('已批准')) {
          return Colors.cyan;
        } else if (widget.info.status.contains('待验收')) {
          return Colors.orange.shade600;
        } else if (widget.info.status.contains('重做')) {
          return Colors.red.shade400;
        } else {
          return Colors.green;
        }
        break;
      case OrderType.PM:
        if (widget.info.status.contains('进行中')) {
          return Colors.blue.shade900;
        } else if (widget.info.status.contains('待验收')) {
          return Colors.orange.shade600;
        } else if (widget.info.status.contains('重做')) {
          return Colors.red.shade400;
        } else {
          return Colors.green;
        }
        break;
      default:
        return Colors.deepOrangeAccent;
    }
  }

  String getLeadName() {
    if (widget.info.actfinish == 0 &&
        getOrderType(widget.info.worktype) == OrderType.XJ) {
      return '';
    } else {
      String name = widget.info.lead ?? widget.info.changeby ?? '';
      if (name.contains('Admin')) {
        name = '';
      }
      return name;
    }
  }

  Color getOrderTextColor() {
    switch (getOrderType(widget.info.worktype)) {
      case OrderType.XJ:
        return Colors.pink.shade600;
      case OrderType.CM:
        return Colors.deepPurpleAccent;
      default:
        return Colors.orange.shade600;
    }
  }

  Widget buildSeparateView() {
    return Container(
      height: Style.separateHeight,
      color: getColor(),
    );
  }

  Widget buildTitleView() {
    String str = '';
    switch (getOrderType(widget.info.worktype)) {
      case OrderType.XJ:
        str = '巡检';
        break;
      case OrderType.CM:
        str = '报修';
        break;
      default:
        str = '保养';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: _padding, vertical: _padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('$str工单 : ${widget.info.wonum}',
              style: TextStyle(fontWeight: FontWeight.w700)),
          Text(getLeadName(), style: TextStyle(fontWeight: FontWeight.w700))
        ],
      ),
    );
  }

  Widget buildSyncStatus() {
    List<Widget> children = new List();
    String worktype = widget.info.worktype;
    bool finished = (widget.info.actfinish == 0);
    List<OrderStep> steps = widget.info.steps;
    String status = widget.info.status;

    switch (getOrderType(worktype)) {
      case OrderType.XJ:
        String image =
            finished ? ImageAssets.order_ing : ImageAssets.order_done;
        if (widget.info.status.contains('进行中')) {
          bool isDid = false;
          if (steps != null && steps.length > 0) {
            for (var item in steps) {
              String status = item.status ?? '';
              if (status.length > 0) {
                isDid = true;
                break;
              }
            }
          }
          image = isDid ? ImageAssets.order_ing_red : ImageAssets.order_ing;
        }
        children.addAll(<Widget>[
          new CircleAvatar(
            child: new Padding(
                padding: EdgeInsets.all(8.0),
                child: new Image.asset(
                  image,
                  height: 40.0,
                )),
            backgroundColor: getColor(),
          ),
          Text(
            status,
            style: TextStyle(color: getColor()),
          )
        ]);
        break;
      case OrderType.CM:
        String image = '';

        if (status.contains('待批准')) {
          image = ImageAssets.order_pending_approved;
        } else if (status.contains('已批准')) {
          image = ImageAssets.order_approved;
        } else if (status.contains('待验收')) {
          image = ImageAssets.order_pending_accept;
        } else {
          image = ImageAssets.order_done;
        }

        children.add(
          new CircleAvatar(
            child: new Padding(
                padding: EdgeInsets.all(8.0),
                child: new Image.asset(
                  image,
                  height: 40.0,
                )),
            backgroundColor: getColor(),
          ),
        );
        children.add(Text(
            status.length > 3 ? status.substring(status.length - 3) : status,
            style: TextStyle(color: getColor())));
        break;
      default:
        String image = '';
        if (status.contains('进行中')) {
          bool isDid = false;
          if (steps != null && steps.length > 0) {
            for (var item in steps) {
              String status = item.status ?? '';
              if (status.length > 0) {
                isDid = true;
                break;
              }
            }
          }
          image = isDid ? ImageAssets.order_ing_red : ImageAssets.order_ing;
        } else if (status.contains('待验收')) {
          image = ImageAssets.order_pending_accept;
        } else {
          image = ImageAssets.order_done;
        }

        children.add(
          new CircleAvatar(
            child: new Padding(
                padding: EdgeInsets.all(8.0),
                child: new Image.asset(
                  image,
                  height: 40.0,
                )),
            backgroundColor: getColor(),
          ),
        );
        children.add(Text(
            status.length > 3 ? status.substring(status.length - 3) : status,
            style: TextStyle(color: getColor())));
        break;
    }

    return Container(
        padding: new EdgeInsets.only(right: _padding),
        decoration: new BoxDecoration(
            border: new Border(
                right: new BorderSide(
                    width: 0.5, color: Theme.of(context).dividerColor))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ));
  }

  Widget builfInfoView() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: _padding, vertical: _padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildSyncStatus(),
          SizedBox(width: _padding),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '标题: ${widget.info.description}',
                style: TextStyle(
                    color: getOrderTextColor(), fontWeight: FontWeight.w700),
              ),
              Text('设备: ${widget.info.assetDescription}'),
              widget.isAll
                  ? Text(
                      '上报时间: ${Func.getFullTimeString(widget.info.reportDate)}')
                  : Text(
                      '更新时间: ${Func.getFullTimeString(widget.info.reportDate)}')
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap();
        },
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildSeparateView(),
                buildTitleView(),
                Divider(
                  height: 1.0,
                ),
                builfInfoView()
              ],
            ))));
  }
}
