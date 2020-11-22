import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/common/app/flavors.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/flavor/child/child_theme.dart' as child;
import 'package:free_books/widget/tutorial_popup_builder.dart';

class Application {
  final ThemeData light;
  final ThemeData dark;

  final Color unselectedTab;
  final Color selectedTab;
  final Color fullPageAccentColor;

  Application._(
      {this.light, this.dark, this.unselectedTab, this.selectedTab, this.fullPageAccentColor});

  static Application _instance;

  static Application get() => _instance;

  static void setup({Flavor flavor}) {
    TutorialManager.setTutorialBuilder(TutorialBuilder());

    Application data;
    switch (flavor) {
      case Flavor.ADULT:
        data = _adultSetup();
        break;
      case Flavor.CHILD:
        data = _childSetup();
        break;
    }

    _instance = data;
  }

  static Application _adultSetup() {
    I18n.init(_supportedLocales());
    final appTheme = AppTheme.fromColors(
      primary: Color(0xFF9D00FF),
      primaryDark: Color(0xFF540088),
      accent: Color(0xFF9D00FF),
    );
    return Application._(
      light: appTheme.light,
      dark: appTheme.dark,
      unselectedTab: Colors.grey.shade400,
      fullPageAccentColor: Colors.greenAccent.shade400,
    );
  }

  static Application _childSetup() {
    I18n.init(_supportedLocales(), suffix: ".child");
    final appTheme = AppTheme.fromColors(
      primary: Colors.amber,
      primaryDark: Colors.deepOrange.shade700,
      accent: Colors.deepOrange,
    );
    ThemeData themeData = child.customiseTheme(appTheme.light);
    return Application._(
      light: themeData,
      dark: themeData,
      unselectedTab: Colors.amber.shade200,
      selectedTab: Colors.orange.shade900,
      fullPageAccentColor: Colors.amber,
    );
  }

  static List<Locale> _supportedLocales() {
    return [Locale("en"), Locale("fr")];
  }
}
