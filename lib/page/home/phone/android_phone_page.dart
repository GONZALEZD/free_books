import 'package:flutter/material.dart';
import 'package:flutter_tools/widget/drawer/basic_drawer.dart';
import 'package:free_books/common/app/app_navigator.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/common/service/preferences_notifier.dart';
import 'package:free_books/page/home/phone/content_definition.dart';
import 'package:free_books/page/home/phone/phone_content_state.dart';
import 'package:free_books/widget/tutorial_builder.dart';
import 'package:provider/provider.dart';

class AndroidPhoneHomePage extends StatefulWidget {
  @override
  _AndroidPhoneHomePageState createState() => _AndroidPhoneHomePageState();
}

class _AndroidPhoneHomePageState extends PhoneHomeContentState<AndroidPhoneHomePage> {
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
        leading: buildMenuButton(),
      ),
      drawer: __buildAndroidDrawer(context),
      body: buildContent(verticalMargin: 16),
      floatingActionButton: _buildFAB(context),
    );
    return PreferencesListener(
      child: scaffold,
      onUpdate: () => setState(() {}),
    );
  }


  Widget buildMenuButton() {
    return Builder(
      builder: (context) {
        final menu = Tutorial.create(
          context: context,
          key: Tutorial.homeDrawerMenu,
          target: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              final scaffold = Scaffold.of(context);
              scaffold.openDrawer();
            },
          ),
        );

        final hasDownloads =
            context.select<BookProvider, bool>((provider) => provider.downloaded.isNotEmpty);
        if (hasDownloads) {
          return Tutorial.create(
            context: context,
            key: Tutorial.homeDrawerDownloadedBook,
            target: menu,
          );
        }
        return menu;
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Tutorial.create(
      key: Tutorial.homeSearch,
      context: context,
      target: FloatingActionButton(
        onPressed: this.goToSearch,
        child: Icon(Icons.search, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget __buildAndroidDrawer(BuildContext context) {
    final Color titleColor = Color.lerp(Theme.of(context).colorScheme.primary, Colors.white, 0.3);
    final i18n = I18n.of(context);
    var dataset = [
      {"content": HomeContent.read, "icon": Icons.book},
      {"content": HomeContent.favorites, "icon": Icons.favorite},
      {"content": HomeContent.downloaded, "icon": Icons.download_sharp},
      {"content": HomeContent.export, "icon": Icons.upload_sharp},
    ];
    var separatorBuilder = () {
      return DrawerSeparatorItem(thickness: 2.0, padding: EdgeInsets.symmetric(horizontal: 16.0));
    };
    return BasicDrawer(
      items: [
        DrawerSeparatorItem.space(kToolbarHeight),
        DrawerTextItem(textColor: titleColor, title: i18n.value("home.menu.books")),
        separatorBuilder(),
        ...dataset.map((data) {
          HomeContent content = data["content"] as HomeContent;
          final action = DrawerActionItem(
            icon: Icon(data["icon"]),
            label: i18n.value(content.i18nKey),
            action: (context) {
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.of(context).maybePop();
              }
              this.selection = content;
            },
          );
          if (this.selection == content) {
            return ColoredBox(color: titleColor.withOpacity(0.2), child: action);
          } else {
            return action;
          }
        }).toList(),
        separatorBuilder(),
        DrawerActionItem.route(
          icon: Icon(Icons.settings),
          label: i18n.value("home.menu.settings"),
          route: AppNavigator.settings,
        ),
      ],
      footer: Text(I18n.of(context).value("copyright")),
    );
  }

  void goToSearch() {
    Navigator.of(context).pushNamed(AppNavigator.search);
  }
}
