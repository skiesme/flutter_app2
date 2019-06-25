import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:samex_app/data/samex_instance.dart';

class SamexBackButton extends StatelessWidget {
  const SamexBackButton({Key key, this.icon, this.onPressed}) : super(key: key);

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon != null ? icon : const BackButtonIcon(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          return;
        }

        if (SamexInstance.isModule) {
          FlutterBoost.singleton.closePageForContext(context);
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
