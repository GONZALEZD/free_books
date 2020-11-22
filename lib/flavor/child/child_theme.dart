import 'package:flutter/material.dart';

ThemeData customiseTheme(ThemeData base) {
  final cardColor = Color(0xFFFFFDF4);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: Colors.amber,
      secondary: Colors.deepOrange,
      background: Colors.amber.shade50,
      brightness: Brightness.light,
    ),
    brightness: Brightness.light,
    backgroundColor: Colors.amber.shade50,
    appBarTheme: base.appBarTheme.copyWith(
      color: Colors.amber,
      shadowColor: Colors.amber.shade800,
      brightness: Brightness.dark,
      textTheme: base.textTheme.copyWith(
        headline6: TextStyle(color: Colors.white, fontSize: 22),
        bodyText2: TextStyle(color: Colors.white),
      ),
      iconTheme: base.iconTheme.copyWith(color: Colors.white),
    ),

    bottomAppBarTheme: base.bottomAppBarTheme.copyWith(
      color: Colors.amber,
    ),
    iconTheme: base.iconTheme.copyWith(color: Colors.white),
    cardColor: cardColor,
    cardTheme: base.cardTheme.copyWith(
      color: cardColor,
    ),
    canvasColor: cardColor,
    chipTheme: base.chipTheme.copyWith(
      brightness: Brightness.dark,
      backgroundColor: Colors.amber,
      deleteIconColor: Colors.white,
      labelStyle: base.chipTheme.labelStyle.copyWith(color: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.amber.shade50,
    cupertinoOverrideTheme: base.cupertinoOverrideTheme.copyWith(
      scaffoldBackgroundColor: Colors.amber.shade200,
      primaryColor: Colors.white,
      barBackgroundColor: Colors.amber,
      brightness: Brightness.dark,
      textTheme: base.cupertinoOverrideTheme.textTheme.copyWith(
        primaryColor: Colors.white,
        navTitleTextStyle: base.cupertinoOverrideTheme.textTheme.navTitleTextStyle.copyWith(
          color: Colors.white,
        ),
      ),
    ),
    bottomAppBarColor: Colors.amber,
    dialogBackgroundColor: Colors.amber.shade100,
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: Colors.amber,
    ),
  );
}