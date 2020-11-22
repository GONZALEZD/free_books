import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/application.dart';
import 'package:free_books/common/app/app_navigator.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/page/home/phone/content_definition.dart';
import 'package:free_books/page/home/phone/phone_content_state.dart';
import 'package:free_books/widget/tutorial_builder.dart';

class CupertinoPhoneHomePage extends StatefulWidget {
  @override
  _CupertinoPhoneHomePageState createState() => _CupertinoPhoneHomePageState();
}

class _CupertinoPhoneHomePageState extends PhoneHomeContentState<CupertinoPhoneHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        brightness: Theme.of(context).cupertinoOverrideTheme.brightness,
        middle: Text(getTitle()),
        leading: _buildMenuButton(context),
      ),
      body: buildContent(verticalMargin: 80.0),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: NotchedBottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedColor: Application.get().unselectedTab,
        selected: HomeContent.values.indexOf(this.selection),
        selectedColor: Application.get().selectedTab ?? this.selection.color,
        onTap: (index) => this.selection = HomeContent.values[index],
        items: __buildNavigationItems(),
        floatingActionButton: __buildFAB(context),
      ),
    );
  }

  Widget __buildFAB(BuildContext context) {
    return FloatingActionButton(
      child: Tutorial.create(
        context: context,
        key: Tutorial.homeSearch,
        target: Container(
          margin: const EdgeInsets.all(8.0),
          child: Icon(CupertinoIcons.search, color: Colors.white),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      onPressed: () => Navigator.of(context).pushNamed(AppNavigator.search),
    );
  }

  List<BottomNavigationBarItem> __buildNavigationItems() {
    final i18n = I18n.of(context);
    var dataset = [
      {"content": HomeContent.read, "icon": CupertinoIcons.book_fill},
      {"content": HomeContent.favorites, "icon": CupertinoIcons.heart_fill},
      {"content": HomeContent.downloaded, "icon": CupertinoIcons.archivebox_fill},
      {"content": HomeContent.export, "icon": CupertinoIcons.share_solid},
    ];
    return dataset.map((data) {
      final content = data["content"] as HomeContent;
      var color1, color2;
      if (Application.get().selectedTab != null) {
        color1 = Application.get().selectedTab;
        color2 = color1;
      } else {
        color1 = content.color[100];
        color2 = content.color[700];
      }
      return BottomNavigationBarItem(
        label: i18n.value(content.i18nKey),
        icon: Icon(data["icon"]),
        activeIcon: GradientIcon(
          data["icon"],
          LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMenuButton(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => UnderneathDrawerLayout.of(context).toggle(),
      ),
    );
  }
}
