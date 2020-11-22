import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/page/home/tablet/tablet_content_state.dart';
import 'package:free_books/widget/tutorial_builder.dart';

class AndroidHomePage extends StatefulWidget {
  @override
  _AndroidHomePageState createState() => _AndroidHomePageState();
}

class _AndroidHomePageState extends TabletContentState<AndroidHomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).value("home.title")),
          leading: _buildMenuButton(context),
          actions: [_buildExportButton()],
        ),
        body: super.build(context),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Tutorial.create(
      context: context,
      key: Tutorial.homeSettings,
      target: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => UnderneathDrawerLayout.of(context).toggle(),
      ),
    );
  }

  Widget _buildExportButton() {
    return IconButton(
      icon: Icon(Icons.share),
      onPressed: () => print("Shared icon pressed"),
    );
  }
}
