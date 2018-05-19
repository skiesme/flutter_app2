import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:samex_app/utils/cache.dart';

import 'package:samex_app/page/login_page.dart';
import 'package:samex_app/page/home_page.dart';
import 'package:samex_app/data/root_model.dart';

void main() async {
  await Cache.getInstance();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  Widget _getHomePage() {
    String token = Cache.instance.token ?? '';

    if (token.length > 0) {
      return new MainPage();
    } else {
      return new LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RootModelWidget(
        model: new RootModel(userName: Cache.instance.userName, token: Cache.instance.token),
        child:
        new MaterialApp(
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
            primaryColor: Colors.blue.shade600,
          ),
          home: _getHomePage()
        )
    );
  }
}


