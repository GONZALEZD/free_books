import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/page/home/tablet/tablet_content_state.dart';
import 'package:free_books/widget/tutorial_builder.dart';

class CupertinoHomePage extends StatefulWidget {
  @override
  _CupertinoHomePageState createState() => _CupertinoHomePageState();
}

class _CupertinoHomePageState extends TabletContentState<CupertinoHomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: _buildMenuButton(context),
          middle: Text(I18n.of(context).value("home.title")),
          trailing: _buildExportButton(),
        ),
        child: super.build(context),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Tutorial.create(
        context: context,
        key: Tutorial.homeSettings,
        target: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => UnderneathDrawerLayout.of(context).toggle(),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return Material(
      type: MaterialType.transparency,
      child: IconButton(
        icon: Icon(CupertinoIcons.share_solid),
        onPressed: () => print("Shared icon pressed"),
      ),
    );
  }
}
