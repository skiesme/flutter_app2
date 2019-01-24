import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:samex_app/utils/cache.dart';

import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/home_page.dart';
import 'package:samex_app/data/root_model.dart';

import 'package:samex_app/utils/style.dart';

import 'package:samex_app/data/bloc_provider.dart';
import 'package:samex_app/data/badge_bloc.dart';

void main() async {
  await Cache.getInstance();
  runApp(new App());
}

class App extends StatelessWidget {

  final GlobalKey<_MyAppState> _key = new GlobalKey<_MyAppState>();

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider<BadgeBloc>(
          bloc: BadgeBloc(),
          child: new RootModelWidget(
              model: new RootModel(
                  token: Cache.instance.token,
                  onTextScaleChanged: (double textScale){
                    _key.currentState.setTextScale(textScale);
                  }),
              child: MyApp(key: _key,)));
  }
}


class MyApp extends StatefulWidget {

  MyApp({Key key}) : super(key:key);

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void setTextScale(double textScale){
    setState(() {
    });
  }

  Widget _getHomePage() {
    String token = Cache.instance.token ?? '';

    if (token.length > 0) {
      return new MainPage();
    } else {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    return new MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('zh', 'ZH'), // Chinese
          // ... other locales the app supports
        ],
        theme: new ThemeData(
          primaryColor: Style.primaryColor,
          textTheme: theme.textTheme.copyWith(
            body1: theme.textTheme.body1.copyWith(
                fontSize: 14.0
            ),
            title: theme.textTheme.title.copyWith(
                fontSize: 18.0
            ),
          ),

          primaryTextTheme: theme.primaryTextTheme.copyWith(
            body1: theme.primaryTextTheme.body1.copyWith(
                fontSize: 14.0
            ),
            title: theme.primaryTextTheme.title.copyWith(
                fontSize: 18.0
            ),
          ),
          fontFamily: 'Miui',
        ),
        builder: (BuildContext context, Widget child) {
          return new Directionality(
            textDirection: TextDirection.ltr,
            child: _applyTextScaleFactor(child),
          );
        },
        home: _getHomePage()
    )
    ;
  }
}



