import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:samex_app/utils/cache.dart';

import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/home_page.dart';
import 'package:samex_app/data/root_model.dart';

import 'package:samex_app/utils/style.dart';

void main() async {
  await Cache.getInstance();
  runApp(new App());
}

class App extends StatelessWidget {

  final GlobalKey<_MyAppState> _key = new GlobalKey<_MyAppState>();

  @override
  Widget build(BuildContext context) {
    return new RootModelWidget(
        model: new RootModel(
            userName: Cache.instance.userName,
            token: Cache.instance.token,
            onTextScaleChanged: (double textScale){
              _key.currentState.setTextScale(textScale);
            }),
        child: MyApp(key: _key,));
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
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          primaryColor: Style.primaryColor,
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



