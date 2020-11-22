import 'package:flutter/material.dart';

enum HomeContent {
  read,
  favorites,
  downloaded,
  export,
}


extension HomeContentProps on HomeContent {
  ColorSwatch get color {
    switch (this) {
      case HomeContent.read:
        return Colors.greenAccent;
      case HomeContent.favorites:
        return Colors.pinkAccent;
      case HomeContent.downloaded:
        return Colors.orange;
      case HomeContent.export:
        return Colors.blue;
    }
    throw "Unknown color for $this";
  }

  String get i18nKey {
    switch (this) {
      case HomeContent.read:
        return "home.menu.read";
      case HomeContent.favorites:
        return "home.menu.favorites";
      case HomeContent.downloaded:
        return "home.menu.downloaded";
      case HomeContent.export:
        return "home.menu.export";
    }
    throw "Unknown i18n key for $this";
  }
}
