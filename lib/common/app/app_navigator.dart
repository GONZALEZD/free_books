import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_books/page/home/layout_home_page.dart';
import 'package:free_books/page/reader/reader_page.dart';
import 'package:free_books/page/search/search_page.dart';
import 'package:free_books/page/setting/android_settings_page.dart';

class AppNavigator {
  static const String root = "/";
  static const String settings = "/settings";
  static const String search = "/search";
  static const String reader = "/reader";

  static Map<String, WidgetBuilder> get _routes {
    return {
      // root: (context) => EpubExamplePage(),
      // root: (context) => testPurpose.DownloadTestPage(),
      root: (context) => HomePage(),
      settings: (context) => AndroidSettingsPage(),
      search: (context) => SearchPage(),
      reader: (context) => ReaderPage(),
    };
  }

  static RouteFactory routeFactory(TargetPlatform platform) {
    if (platform == TargetPlatform.iOS) {
      return (settings) {
        return CupertinoPageRoute(
          builder: AppNavigator._routes[settings.name],
          settings: settings,
          maintainState: settings.name == AppNavigator.reader,
        );
      };
    } else {
      return (settings) {
        return MaterialPageRoute(
          builder: AppNavigator._routes[settings.name],
          settings: settings,
          maintainState: settings.name == AppNavigator.reader,
        );
      };
    }
  }
}
