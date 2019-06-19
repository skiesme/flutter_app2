import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:samex_app/utils/cache.dart';

import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/home_page.dart';
import 'package:samex_app/utils/localizations.dart';

import 'package:samex_app/utils/style.dart';

import 'package:samex_app/data/bloc_provider.dart';
import 'package:samex_app/data/badge_bloc.dart';

import 'data/samex_instance.dart';
import 'page/task_page.dart';

void main() async {
  await Cache.getInstance();
  runApp(new App());
}

class App extends StatelessWidget {
  final GlobalKey<_MyAppState> _key = new GlobalKey<_MyAppState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BadgeBloc>(
        bloc: BadgeBloc(),
        child: MyApp(
          key: _key,
        ));
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void setTextScale(double textScale) {
    setState(() {});
  }

  Widget _getHomePage() {
    if (SamexInstance.isModule) {
      return Container();
    } else {
      if (SamexInstance.singleton.token.length > 0) {
        return new MainPage();
      }
      return new LoginPage();
    }
  }

  Widget _applyTextScaleFactor(Widget child) {
    return new Builder(
      builder: (BuildContext context) {
        return new MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: Cache.instance.textScaleFactor,
          ),
          child: child,
        );
      },
    );
  }

  /** 对外Native 开放的 页面 */
  Widget renderHome(String pageName, Map<dynamic, dynamic> params, String _) {
    print("task params:$params");
    setToken(context, params['token']);
    return MainPage();
  }

  Widget renderTaksList(
      String pageName, Map<dynamic, dynamic> params, String _) {
    print("task params:$params");
    setToken(context, params['token']);
    return TaskPage();
  }

  Widget renderWorkOrderList(
      String pageName, Map<dynamic, dynamic> params, String _) {
    print("task params:$params");
    setToken(context, params['token']);
    return TaskPage(isTask: false);
  }

  @override
  void initState() {
    super.initState();

    // FlutterBoost.singleton.registerPageBuilders({
    //   'samex/home': (pageName, params, _) => renderHome(pageName, params, _),
    //   // 任务
    //   'samex/task/list': (pageName, params, _) =>
    //       renderTaksList(pageName, params, _),
    //   'samex/task/detail': (pageName, params, _) =>
    //       renderTaksList(pageName, params, _),
    //   // 工单
    //   'samex/workOrder/list': (pageName, params, _) =>
    //       renderWorkOrderList(pageName, params, _)
    // });
    // FlutterBoost.handleOnStartPage();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          ChineseCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('zh', 'ZH'), // Chinese
          // ... other locales the app supports
        ],
        theme: new ThemeData(
          primaryColor: Style.primaryColor,
          textTheme: theme.textTheme.copyWith(
            body1: theme.textTheme.body1.copyWith(fontSize: 14.0),
            title: theme.textTheme.title.copyWith(fontSize: 18.0),
          ),
          primaryTextTheme: theme.primaryTextTheme.copyWith(
            body1: theme.primaryTextTheme.body1.copyWith(fontSize: 14.0),
            title: theme.primaryTextTheme.title.copyWith(fontSize: 18.0),
          ),
          fontFamily: 'Miui',
        ),
        builder: (BuildContext context, Widget child) {
          return new Directionality(
            textDirection: TextDirection.ltr,
            child: _applyTextScaleFactor(child),
          );
        },
        home: _getHomePage());
  }
}
