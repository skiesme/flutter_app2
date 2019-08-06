import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:samex_app/components/load_more.dart';
import 'package:samex_app/components/orders/hd_order_item.dart';
import 'package:samex_app/components/orders/hd_order_option.dart';
import 'package:samex_app/data/badge_bloc.dart';
import 'package:samex_app/data/bloc_provider.dart';
import 'package:samex_app/data/samex_instance.dart';
import 'package:samex_app/helper/event_bus_helper.dart';
import 'package:samex_app/helper/page_helper.dart';
import 'package:samex_app/model/order_list.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/page/task_detail_page.dart';
import 'package:samex_app/utils/func.dart';

/** HDOrderOptions */
class HDOrders extends StatefulWidget {
  final PageHelper<OrderShortInfo> helper;
  final OrderType type;

  HDOrders({Key key, @required this.helper, this.type = OrderType.ALL})
      : super(key: key);

  @override
  HDOrdersState createState() => HDOrdersState();
}

class HDOrdersState extends State<HDOrders> with AfterLayoutMixin<HDOrders> {
  static const force_scroller_head = 'force_scroller_head';

  bool _showOptionView = false;

  HDOrderOptions _orderOptions;
  HDOrderOptionsResult _queryInfo;
  bool _canLoadMore = true;
  List<OrderShortInfo> _filterDatas = new List();
  OrderType _selectedtType;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    setup();

    eventBus.on<HDTaskEvent>().listen((event) {
      if (mounted) {
        if (event.type == HDTaskEventType.refresh) {
          _handleLoadNewDatas();
        } else if (event.type == HDTaskEventType.query) {
          String query = event.value;
          print('query: $query');
          // _orderOptions.
          if (mounted) {
            setState(() {
              _queryInfo.query = query;
              _handleLoadDatas();
            });
          }
        } else if (event.type == HDTaskEventType.scrollHeader) {
          if (_scrollController != null) {
            _scrollController.animateTo(1.0,
                duration: Duration(milliseconds: 400),
                curve: Curves.decelerate);
          }
        }
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        _queryInfo = _orderOptions.def;

        if (_orderOptions != null && _orderOptions.def != null) {
          _selectedtType = _orderOptions.def.type;
        }
      });
    }

    if (_scrollController.initialScrollOffset > 0) {
      Future.delayed(new Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.initialScrollOffset + 0.1);
      });
    }

    Future.delayed(Duration.zero, () => _handleLoadDatas());
  }

  @override
  Widget build(BuildContext context) {
    bool isUp = _queryInfo != null ? _queryInfo.isUp : true;
    List<OrderShortInfo> list =
        isUp ? _filterDatas.reversed.toList() : _filterDatas;

    Widget listView = ListView.builder(
        physics: _query().isEmpty
            ? const AlwaysScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          if (list.length > index) {
            return HDOrderItem(
              info: list[index],
              isAll: widget.type == OrderType.ALL,
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TaskDetailPage(
                                  wonum: list[index].wonum,
                                ),
                            settings: RouteSettings(name: TaskDetailPage.path)))
                    .then((value) {
                  if (null == value || false == value) {
                    return;
                  }

                  _handleLoadNewDatas();
                });
              },
            );
          }
          return null;
        });

    _orderOptions = HDOrderOptions(
      showView: _showOptionView,
      type: _selectedtType,
      badgeCount: _filterDatas.length,
      onSureBtnClicked: (res) => optionSureClickedHandle(res),
      onTimeSortChanged: (isUp) => optionTimeSortChangedHandle(isUp),
    );

    Widget view = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _orderOptions,
        Expanded(child: listView),
      ],
    );

    Widget refreshView = RefreshIndicator(
        onRefresh: _handleLoadNewDatas,
        child: LoadMore(
            scrollNotification: widget.helper.handle,
            child: view,
            onLoadMore: () async {
              _handleLoadDatas(1);
            }));

    List<Widget> children = <Widget>[_query().isEmpty ? refreshView : view];

    if (list.length == 0) {
      children.add(new Center(
          child: widget.helper.inital
              ? CircularProgressIndicator()
              : Text('没发现任务')));
    }

    return new Container(
        color: const Color(0xFFF0F0F0),
        child: GestureDetector(
            onTap: () {
              Func.closeKeyboard(context);
            },
            child: Stack(children: children)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setup() {
    _selectedtType = widget.type;
    _showOptionView = widget.type == OrderType.ALL;

    widget.helper.clear();
    if (mounted) {
      setState(() {
        _filterDatas = filter();
      });
    }

    widget.helper.inital = true;

    _scrollController = widget.helper.createController();
    _scrollController.addListener(() {
      bool showTopBtn = _scrollController.offset > context.size.height;
      eventBus.fire(new HDTaskEvent(
          type: HDTaskEventType.showFloatTopBtn, value: showTopBtn));
    });
  }

  void optionSureClickedHandle(HDOrderOptionsResult res) {
    setState(() {
      _queryInfo = res;
      _selectedtType = _orderOptions.type;
    });
    _handleLoadNewDatas();
  }

  void optionTimeSortChangedHandle(bool isTimeUp) {
    setState(() {
      _queryInfo.isUp = isTimeUp;
    });
  }

  Future<Null> _handleLoadNewDatas() async {
    widget.helper.clear();
    _handleLoadDatas();
    widget.helper.inital = true;
  }

  /** 网络请求 */
  Future<Null> _handleLoadDatas([int older = 0]) async {
    try {
      Func.closeKeyboard(context);

      if (!_canLoadMore) {
//        print('已经在loadMore了...');
        return;
      }
      int time = 0;
      int startTime = 0;

      if (_showOptionView) {
        time = _queryInfo.endTime;
        startTime = _queryInfo.startTime;

        if (older == 0 && widget.helper.itemCount() > 0) {
          var data = widget.helper.datas[0];
          startTime = data.reportDate;
        }
        if (older == 1 && widget.helper.itemCount() > 0) {
          var data = widget.helper.datas[widget.helper.itemCount() - 1];
          time = data.reportDate;
        }
      } else {
        if (older == 0 && widget.helper.itemCount() > 0) {
          var data = widget.helper.datas[0];
          startTime = data.reportDate;
        }
        if (older == 1 && widget.helper.itemCount() > 0) {
          var data = widget.helper.datas[widget.helper.itemCount() - 1];
          time = data.reportDate;
        }
      }

      _canLoadMore = false;

      // debugPrint('hd-> query:${_queryInfo.query}, worktype:${_queryInfo.workType}, older:${older}, time:${time}, startTime:${startTime}');

      int isAll = _queryInfo.isAll ? 0 : 1;
      String status = _showOptionView ? _queryInfo.status : 'active';
      Map response = await getApi(context).orderList(
          type: _queryInfo.workType,
          status: status,
          time: time,
          query: _query(),
          all: isAll,
          start: startTime,
          older: older,
          task: _queryInfo.task,
          count: _queryInfo.count);
      OrderListResult result = new OrderListResult.fromJson(response);

      _canLoadMore = true;
      // debugPrint('order List: ${result.toJson()}');
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        List<OrderShortInfo> info = result.response ?? [];
        if (info.length > 0) {
          if (older == 0) {
            widget.helper.datas.insertAll(0, info);
          } else {
            widget.helper.addData(info);
          }

          // 加载步骤
          for (var item in info) {
            if (item.steps == null) {
              String wonum = item.wonum;
              String site = wonum.replaceAll(new RegExp('\\d+'), '');
              loadSteps(wonum, site);
            }
          }
        }

        try {
          final BadgeBloc bloc = BlocProvider.of<BadgeBloc>(context);
          if (widget.type != OrderType.ALL) {
            bloc.badgeChange
                .add(new BadgeInEvent(widget.helper.itemCount(), widget.type));
          }
        } catch (e) {
          // debugPrint('badgeChange   error: $e');
        }
      }
      if (mounted) {
        setState(() {
          _filterDatas = filter();
        });
      }
    } catch (e) {
      // debugPrint('获取工单列表失败，$e');
      Func.showMessage('网络出现异常, 获取工单列表失败');
    }
    if (widget.helper.inital) widget.helper.inital = false;
  }

  void loadSteps(String wonum, String site) async {
    try {
      Map response =
          await getApi(context).steps(sopnum: '', wonum: wonum, site: site);
      StepsResult result = new StepsResult.fromJson(response);
      if (result.code == 0) {
        if (mounted) {
          setState(() {
            List<OrderShortInfo> infos = widget.helper.datas.toList();
            OrderShortInfo info =
                infos.where((e) => e.wonum == wonum).toList().first;
            info.steps = result.response.steps;
          });
        }
      }
    } catch (e) {
      debugPrint('获取步骤信息失败，$e');
    }
  }

  List<OrderShortInfo> filter() {
    List<OrderShortInfo> list = widget.helper.datas;
    if (_query().isNotEmpty) {
      list = widget.helper.datas
          .where((i) =>
              i.wonum.contains(_query()?.toUpperCase()) ||
              (i.assetnum ?? '').contains(_query()?.toUpperCase()))
          .toList();
    }
    return list;
  }

  String _query() {
    return _queryInfo != null ? _queryInfo.query ?? '' : '';
  }
}
