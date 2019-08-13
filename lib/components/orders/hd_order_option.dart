import 'package:flutter/material.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';

/** OrderItem - 订单类型 选项 */
final List<OrderItem> _orderTypeItmes = <OrderItem>[
  OrderItem(OrderType.ALL, '全部', null),
  OrderItem(OrderType.CM, '报修', null),
  OrderItem(OrderType.XJ, '巡检', _orderXJTypeSubItems),
  OrderItem(OrderType.PM, '保养', null),
];

final List<OrderItem> _orderXJTypeSubItems = <OrderItem>[
  OrderItem(OrderType.XJ, '全部巡检', null),
  OrderItem(OrderType.XJ1, '一级巡检', null),
  OrderItem(OrderType.XJ2, '二级巡检', null),
  OrderItem(OrderType.XJ3, '三级巡检', null),
  OrderItem(OrderType.XJ4, '四级巡检', null),
];

class OrderItem {
  OrderType type;
  String title;
  List<OrderItem> subItems;
  OrderItem(this.type, this.title, this.subItems);
}

/** HDOrderOptionsResult */
final List<_OrderStatusItem> _orderStatusList = <_OrderStatusItem>[
  _OrderStatusItem('', '全部'),
  _OrderStatusItem('active', '进行中'),
  _OrderStatusItem('inactive', '已完成'),
];

final List<_OrderStatusItem> _orderCMStatusList = <_OrderStatusItem>[
  _OrderStatusItem('', '全部'),
  _OrderStatusItem('待批准', '待批准'),
  _OrderStatusItem('已批准', '已批准'),
  _OrderStatusItem('待验收', '待验收'),
  _OrderStatusItem('inactive', '已完成'),
];

final List<_OrderStatusItem> _orderPMStatusList = <_OrderStatusItem>[
  _OrderStatusItem('', '全部'),
  _OrderStatusItem('进行中', '进行中'),
  _OrderStatusItem('待验收', '待验收'),
  _OrderStatusItem('inactive', '已完成'),
];

final List<_OrderStatusItem> _orderALLStatusList = <_OrderStatusItem>[
  _OrderStatusItem('', '全部'),
  _OrderStatusItem('进行中', '进行中'),
  _OrderStatusItem('待批准', '待批准'),
  _OrderStatusItem('已批准', '已批准'),
  _OrderStatusItem('待验收', '待验收'),
  _OrderStatusItem('inactive', '已完成'),
];

class _OrderStatusItem {
  String key;
  String value;

  _OrderStatusItem(this.key, this.value);
}

/** HDOrderOptionsResult */
class HDOrderOptionsResult {
  OrderType type;
  String query;
  bool isAll; // 所有工单
  int startTime;
  int endTime;
  bool isUp; // 是否为升序

  String workType; // 工单类型
  String status; // 选择的状态
  int task;
  int count;

  HDOrderOptionsResult(
      {this.type,
      this.query,
      this.isAll,
      this.startTime,
      this.endTime,
      this.isUp,
      this.workType,
      this.status,
      this.task,
      this.count});
}

/** HDOrderOptions */
const option_cache_key = 'filter_option_key';

class HDOrderOptions extends StatefulWidget {
  bool showView = false;
  OrderType type;
  int badgeCount = 0;
  HDOrderOptionsResult def;

  final onSureBtnClicked;
  final onTimeSortChanged;

  HDOrderOptions(
      {Key key,
      this.showView,
      this.type,
      this.badgeCount,
      this.def,
      this.onSureBtnClicked,
      this.onTimeSortChanged})
      : super(key: key);

  @override
  HDOrderOptionsState createState() => HDOrderOptionsState();

  void cached(HDOrderOptionsResult res) {
    def = res;
    setMemoryCache<HDOrderOptionsResult>(option_cache_key, res);
  }
}

class HDOrderOptionsState extends State<HDOrderOptions> {
  bool _isAll = true;
  int _startTime =
      new DateTime.now().millisecondsSinceEpoch ~/ 1000 - 365 * 24 * 60 * 60;
  int _endTime =
      new DateTime.now().millisecondsSinceEpoch ~/ 1000 + 24 * 60 * 60;
  bool _isUp = false;

  bool _expend = false;
  TextEditingController _searchQuery = new TextEditingController(text: '');
  _OrderStatusItem _selectedStatus;
  static const double padding = 3.0;
  static const double ICON_SIZE = 16.0;
  static const itemPadding =
      const EdgeInsets.symmetric(horizontal: padding, vertical: padding);

  @override
  void initState() {
    super.initState();
    _setupDatas();

    _checkAll();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = widget.showView
        ? <Widget>[
            Card(child: _filterOptionView()),
            Card(child: _sortOptionView())
          ]
        : new List();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchQuery?.dispose();
  }

  void _setupDatas() {
    _selectedStatus = _statusList(widget.type)[0];

    widget.def = widget.showView
        ? getMemoryCache<HDOrderOptionsResult>(option_cache_key, expired: false)
        : null;
    if (widget.def == null) {
      widget.def = HDOrderOptionsResult(
          type: widget.type,
          query: _searchQuery?.text,
          isAll: _isAll,
          startTime: _startTime,
          endTime: _endTime,
          isUp: _isUp,
          workType: _workType(),
          status: _statusKey(),
          task: _task(),
          count: _count());
    } else {
      setState(() {
        widget.type = widget.def.type;
        _selectedStatus = _status(widget.def.status);
        _searchQuery.text = widget.def.query;
        _isAll = widget.def.isAll;
        _startTime = widget.def.startTime;
        _endTime = widget.def.endTime;
        _isUp = widget.def.isUp;
      });
    }
  }

  String _workType() {
    switch (widget.type) {
      case OrderType.PM:
        return 'PM';
      case OrderType.CM:
        return 'CM';
      case OrderType.XJ:
        return 'XJ';
      case OrderType.XJ1:
        return 'XJM';
      case OrderType.XJ2:
        return 'XJ2';
      case OrderType.XJ3:
        return 'XJ3';
      case OrderType.XJ4:
        return 'XJ4';
      default:
        return '';
    }
  }

  String _statusKey() {
    return _selectedStatus.key;
  }

  _OrderStatusItem _status(String key) {
    return _statusList(widget.type).where((e) => e.key == key).toList().first;
  }

  int _task() {
    return widget.type == OrderType.ALL ? 0 : 1;
  }

  int _count() {
    return widget.type == OrderType.ALL ? 20 : 100;
  }

  String _typeName(OrderType type) {
    switch (type) {
      case OrderType.PM:
        return '保养';
      case OrderType.CM:
        return '报修';
      case OrderType.XJ:
        return '巡检';
      case OrderType.XJ1:
        return '一级巡检';
      case OrderType.XJ2:
        return '二级巡检';
      case OrderType.XJ3:
        return '三级巡检';
      case OrderType.XJ4:
        return '四级巡检';
      default:
        return '全部';
    }
  }

  void _checkAll() {
    OrderType type = _orderTypeItmes[0].type;
    _OrderStatusItem status = _orderStatusList[0];
    bool isAll = widget.type == type && _selectedStatus.key == status.key;
    setState(() {
      _isAll = isAll;
    });
  }

  List<_OrderStatusItem> _statusList(OrderType type) {
    if (type == OrderType.CM) {
      return _orderCMStatusList;
    } else if (type == OrderType.PM) {
      return _orderPMStatusList;
    } else if (type == OrderType.XJ ||
        type == OrderType.XJ1 ||
        type == OrderType.XJ2 ||
        type == OrderType.XJ3 ||
        type == OrderType.XJ4) {
      return _orderStatusList;
    } else {
      return _orderALLStatusList;
    }
  }

  String _statusName(_OrderStatusItem item) {
    List<_OrderStatusItem> list = _statusList(widget.type);
    String name = _selectedStatus.value;
    for (int i = 0; i < list.length; i++) {
      if (item.key == list[i].key) {
        name = item.value;
      }
    }
    return name;
  }

  /** FilterOptionView */
  Widget _titleView() {
    bool showBadge = widget.badgeCount > 0;

    Widget badge() {
      String badgeStr = showBadge ? widget.badgeCount.toString() : '';
      return Material(
        color: Colors.transparent,
        elevation: 2.0,
        child: Container(
            height: 22.0,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5.0),
            decoration: BoxDecoration(
                color: const Color(0xFFFF232D),
                borderRadius: BorderRadius.circular(5.0)),
            child: Center(
                child: Text(
              '${badgeStr}',
              style: TextStyle(color: Colors.white, fontSize: 14.0),
              textAlign: TextAlign.center,
            ))),
      );
    }

    return Container(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          showBadge ? badge() : Center(),
          Text(
            '筛选',
            style: TextStyle(color: Style.primaryColor, fontSize: 18.0),
          ),
          Icon(
            _expend ? Icons.expand_less : Icons.expand_more,
            color: Style.primaryColor,
          )
        ],
      ),
    );
  }

  Widget _queryItem() {
    return Padding(
      padding: itemPadding,
      child: Row(
        children: <Widget>[
          Text('内容过滤: ', style: const TextStyle(color: Colors.black87)),
          Expanded(
              child: TextField(
            controller: _searchQuery,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0.0),
              hintText: '输入工单号/资产编号进行查询',
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.black87, fontSize: 16.0),
          ))
        ],
      ),
    );
  }

  Widget _orderItem() {
    Widget allBtn() {
      return SimpleButton(
        onTap: () {
          setState(() {
            _isAll = !_isAll;
            if (_isAll) {
              widget.type = OrderType.ALL;
              _selectedStatus = _statusList(OrderType.ALL)[0];
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('所有工单'),
            Icon(
              _isAll
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: ICON_SIZE,
            ),
          ],
        ),
      );
    }

    void showChooseTypeDialog(BuildContext ctx) {
      bool isXJExpanded() {
        if (widget.type == OrderType.XJ ||
            widget.type == OrderType.XJ1 ||
            widget.type == OrderType.XJ2 ||
            widget.type == OrderType.XJ3 ||
            widget.type == OrderType.XJ4) {
          return true;
        }
        return false;
      }

      Widget itemcell(StateSetter state, OrderItem item) {
        bool hasSub = item.subItems != null;
        bool isSelected = (item.type == widget.type);

        if (hasSub) {
          return ExpansionTile(
            title: new Text(item.title),
            trailing: isSelected
                ? const Icon(
                    Icons.check,
                    size: ICON_SIZE,
                  )
                : null,
            initiallyExpanded: isXJExpanded(),
            children: item.subItems.map((OrderItem item) {
              return itemcell(state, item);
            }).toList(),
          );
        } else {
          return ListTile(
            title: new Text(item.title),
            selected: isSelected,
            trailing: isSelected
                ? const Icon(
                    Icons.check,
                    size: ICON_SIZE,
                  )
                : null,
            onTap: () {
              state(() {
                setState(() {
                  widget.type = item.type;
                  _selectedStatus = _statusList(item.type)[0];
                  _checkAll();
                });
              });
            },
          );
        }
      }

      showDialog(
          context: ctx,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, state) {
                return SimpleDialog(
                  contentPadding: const EdgeInsets.all(5.0),
                  children: _orderTypeItmes.map((OrderItem item) {
                    return itemcell(state, item);
                  }).toList(),
                );
              },
            );
          });
    }

    Widget orderType() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('工单类型:'),
          SimpleButton(
            onTap: () {
              showChooseTypeDialog(context);
            },
            child: Row(
              children: <Widget>[
                Text('${_typeName(widget.type)}'),
                Align(
                    child: const Icon(
                  Icons.arrow_drop_down,
                  size: ICON_SIZE,
                ))
              ],
            ),
          )
        ],
      );
    }

    void showChooseStatusDialog(BuildContext ctx) {
      Widget itemcell(StateSetter state, _OrderStatusItem item) {
        bool isSelected = (item.key == _selectedStatus.key);
        return ListTile(
          title: new Text(item.value),
          selected: isSelected,
          trailing: isSelected
              ? const Icon(
                  Icons.check,
                  size: ICON_SIZE,
                )
              : null,
          onTap: () {
            state(() {
              setState(() {
                _selectedStatus = item;
                _checkAll();
              });
            });
          },
        );
      }

      showDialog(
          context: ctx,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, state) {
                return SimpleDialog(
                  contentPadding: const EdgeInsets.all(5.0),
                  children:
                      _statusList(widget.type).map((_OrderStatusItem item) {
                    return itemcell(state, item);
                  }).toList(),
                );
              },
            );
          });
    }

    Widget orderStatus() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('工单状态:'),
          SimpleButton(
            onTap: () {
              showChooseStatusDialog(context);
            },
            child: Row(
              children: <Widget>[
                Text('${_statusName(_selectedStatus)}'),
                Align(child: const Icon(Icons.arrow_drop_down, size: ICON_SIZE))
              ],
            ),
          )
        ],
      );
    }

    return Padding(
      padding: itemPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[allBtn(), orderType(), orderStatus()],
      ),
    );
  }

  Widget _timeItem() {
    Widget startTime() {
      return InkWell(
        onTap: () {
          DateTime time =
              new DateTime.fromMillisecondsSinceEpoch(_startTime * 1000);
          Func.selectDate(context, time, (DateTime date) {
            setState(() {
              int start = (new DateTime(date.year, date.month, date.day)
                          .millisecondsSinceEpoch ~/
                      1000)
                  .toInt();
              print("startTime --> :${start}");
              _startTime = start;
            });
          });
        },
        child: Row(
          children: <Widget>[
            new Text('${Func.getYearMonthDay(_startTime * 1000)}'),
            Icon(
              Icons.arrow_drop_down,
              size: ICON_SIZE,
            )
          ],
        ),
      );
    }

    Widget endTime() {
      return InkWell(
        onTap: () {
          DateTime time =
              new DateTime.fromMillisecondsSinceEpoch(_endTime * 1000);
          Func.selectDate(context, time, (DateTime date) {
            setState(() {
              _endTime = (new DateTime(date.year, date.month, date.day)
                          .millisecondsSinceEpoch ~/
                      1000)
                  .toInt();
            });
          });
        },
        child: Row(
          children: <Widget>[
            new Text('${Func.getYearMonthDay(_endTime * 1000)}'),
            Icon(
              Icons.arrow_drop_down,
              size: ICON_SIZE,
            )
          ],
        ),
      );
    }

    return Padding(
      padding: itemPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('上报时间'),
          SizedBox(width: 1),
          startTime(),
          Text('到'),
          endTime()
        ],
      ),
    );
  }

  Widget _sureBtn() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      SimpleButton(
          onTap: () {
            setState(() {
              _expend = false;
            });

            if (widget.onSureBtnClicked != null) {
              // option -> model
              HDOrderOptionsResult res = new HDOrderOptionsResult(
                  type: widget.type,
                  query: _searchQuery?.text,
                  isAll: _isAll,
                  startTime: _startTime,
                  endTime: _endTime,
                  isUp: _isUp,
                  workType: _workType(),
                  status: _statusKey(),
                  task: _task(),
                  count: _count());
              widget.cached(res);
              widget.onSureBtnClicked(res);
            }
          },
          elevation: 2.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(4.0)),
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 24.0),
          color: Colors.blueAccent,
          child: Text(
            '确定',
            style: TextStyle(color: Colors.white),
          ))
    ]);
  }

  Widget _getOptionView() {
    if (!_expend) {
      return Container();
    } else {
      return Container(
          padding: EdgeInsets.all(4.0),
          child: Wrap(
              children: <Widget>[
                Divider(height: 1),
                _queryItem(),
                Divider(height: 1),
                _orderItem(),
                Divider(height: 1),
                _timeItem(),
                Divider(height: 1),
                _sureBtn()
              ],
              spacing: 12.0,
              runSpacing: 8.0,
              runAlignment: WrapAlignment.center));
    }
  }

  Widget _filterOptionView() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
            onTap: () {
              setState(() {
                _expend = !_expend;
              });
            },
            child: _titleView()),
        _getOptionView()
      ],
    );
  }

  Widget _sortOptionView() {
    Widget timeUp() {
      return SimpleButton(
        onTap: () {
          setState(() {
            _isUp = true;
          });

          if (widget.onTimeSortChanged != null) {
            widget.onTimeSortChanged(_isUp);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('升序'),
            Icon(
              _isUp ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: ICON_SIZE,
            ),
          ],
        ),
      );
    }

    Widget timeDown() {
      return SimpleButton(
        onTap: () {
          setState(() {
            _isUp = false;
          });
          if (widget.onTimeSortChanged != null) {
            widget.onTimeSortChanged(_isUp);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 10.0,
            ),
            Text('降序'),
            Icon(
              _isUp ? Icons.radio_button_unchecked : Icons.radio_button_checked,
              size: ICON_SIZE,
            ),
          ],
        ),
      );
    }

    return Container(
        height: 40,
        padding: EdgeInsets.all(4.0),
        child: Wrap(children: <Widget>[
          Text('按时间排序:'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[timeUp(), timeDown()],
          ),
        ], spacing: 12.0, runSpacing: 8.0, runAlignment: WrapAlignment.center));
  }
}
