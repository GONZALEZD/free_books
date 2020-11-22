import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/application.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/page/setting/settings_list.dart';

class UnderneathSettingsPage extends StatelessWidget {
  final double paddingRight;

  UnderneathSettingsPage({this.paddingRight});

  @override
  Widget build(BuildContext context) {
    return FullColoredPage(
      color: Theme.of(context).primaryColorDark,
      accentColor: Application.get().fullPageAccentColor,
      textColor: Colors.white,
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          heroTag: "unused_hero_tag",
          border: Border.all(style: BorderStyle.none),
          brightness: Brightness.dark,
          middle: Text(I18n.of(context).value("settings.title")),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: paddingRight),
                child: AppSettingsList(display: SettingsDisplay.cupertino),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                I18n.of(context).value("copyright"),
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
