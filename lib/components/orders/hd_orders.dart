import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
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
  final OrderType type;

  HDOrders({Key key, this.type = OrderType.ALL}) : super(key: key);

  @override
  HDOrdersState createState() => HDOrdersState();
}

class HDOrdersState extends State<HDOrders> with AfterLayoutMixin<HDOrders> {
  static const force_scroller_head = 'force_scroller_head';

  final PageHelper<OrderShortInfo> helper = PageHelper();

  bool _showOptionView = false;

  HDOrderOptions _orderOptions;
  HDOrderOptionsResult _queryInfo;
  bool _canLoadMore = true;
  List<OrderShortInfo> _filterDatas = List();
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
      Future.delayed(Duration(milliseconds: 100), () {
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
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (_, int index) {
          OrderShortInfo info;
          if (list.length > index) {
            info = list[index];
          }

          if (null == info) {
            return null;
          }

          return HDOrderItem(
            info: info,
            isAll: widget.type == OrderType.ALL,
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                                wonum: info.wonum,
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
            scrollNotification: helper.handle,
            child: view,
            onLoadMore: () async {
              _handleLoadDatas(1);
            }));

    List<Widget> children = <Widget>[_query().isEmpty ? refreshView : view];

    if (list.length == 0) {
      children.add(Center(
          child: helper.inital ? CircularProgressIndicator() : Text('没发现任务')));
    }

    return Container(
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

    helper.clear();
    if (mounted) {
      setState(() {
        _filterDatas = filter();
      });
    }

    helper.inital = true;

    _scrollController = helper.createController();
    _scrollController.addListener(() {
      bool showTopBtn = _scrollController.offset > context.size.height;
      eventBus.fire(HDTaskEvent(
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
    helper.clear();
    _handleLoadDatas();
    helper.inital = true;
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

        if (older == 0 && helper.itemCount() > 0) {
          var data = helper.datas[0];
          startTime = data.reportDate;
        }
        if (older == 1 && helper.itemCount() > 0) {
          var data = helper.datas[helper.itemCount() - 1];
          time = data.reportDate;
        }
      } else {
        if (older == 0 && helper.itemCount() > 0) {
          var data = helper.datas[0];
          startTime = data.reportDate;
        }
        if (older == 1 && helper.itemCount() > 0) {
          var data = helper.datas[helper.itemCount() - 1];
          time = data.reportDate;
        }
      }

      _canLoadMore = false;

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
      OrderListResult result = OrderListResult.fromJson(response);

      _canLoadMore = true;
      // debugPrint('order List: ${result.toJson()}');
      if (result.code != 0) {
        Func.showMessage(result.message);
      } else {
        List<OrderShortInfo> info = result.response ?? [];
        if (info.length > 0) {
          if (older == 0) {
            helper.datas.insertAll(0, info);
          } else {
            helper.addData(info);
          }

          // 加载步骤
          for (var item in info) {
            if (item.steps == null) {
              String wonum = item.wonum;
              String site = wonum.replaceAll(RegExp('\\d+'), '');
              loadSteps(wonum, site);
            }
          }
        }

        try {
          final BadgeBloc bloc = BlocProvider.of<BadgeBloc>(context);
          if (widget.type != OrderType.ALL) {
            bloc.badgeChange.add(BadgeInEvent(helper.itemCount(), widget.type));
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
    if (helper.inital) helper.inital = false;
  }

  void loadSteps(String wonum, String site) async {
    try {
      Map response =
          await getApi(context).steps(sopnum: '', wonum: wonum, site: site);
      StepsResult result = StepsResult.fromJson(response);
      if (result.code == 0) {
        if (mounted) {
          setState(() {
            List<OrderShortInfo> infos = helper.datas.toList();
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
    List<OrderShortInfo> list = helper.datas;
    if (_query().isNotEmpty) {
      list = helper.datas
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
