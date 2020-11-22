import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/page/home/phone/android_phone_page.dart';
import 'package:free_books/page/home/phone/cupertino_phone_page.dart';
import 'package:free_books/page/setting/underneath_settings_page.dart';
import 'package:free_books/page/setting/settings_list.dart';
import 'package:free_books/page/home/tablet/cupertino_home_page.dart' as tabletCupertino;
import 'package:free_books/page/home/tablet/android_home_page.dart' as tabletAndroid;


class HomePage extends StatelessWidget {
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.shortestSide > 600;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isTablet = this._isTablet(context);
    if (isTablet) {
      return isIOS ? _buildTabletIOS(context) : _buildTabletAndroid(context);
    } else {
      return isIOS ? _buildPhoneIOS(context) : AndroidPhoneHomePage();
    }
  }

  Widget _buildTabletIOS(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = 400.0;
    return UnderneathDrawerLayout(
      openedPageWidth: width - drawerWidth,
      openedPageHeightMargin: 0.0,
      openedPageBorderRadius: 0.0,
      drawerBuilder: (context) => UnderneathSettingsPage(paddingRight: width - drawerWidth),
      pageBuilder: (context) => tabletCupertino.CupertinoHomePage(),
    );
  }

  Widget _buildTabletAndroid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = 400.0;
    return UnderneathDrawerLayout(
      openedPageWidth: width - drawerWidth,
      openedPageHeightMargin: 0.0,
      openedPageBorderRadius: 0.0,
      drawerBuilder: (context) => UnderneathSettingsPage(paddingRight: width - drawerWidth),
      pageBuilder: (context) => tabletAndroid.AndroidHomePage(),
    );
  }

  Widget _buildPhoneIOS(BuildContext context) {
    return UnderneathDrawerLayout(
      openedPageWidth: 80.0,
      drawerBuilder: (context) => UnderneathSettingsPage(paddingRight: 80.0),
      pageBuilder: (context) => CupertinoPhoneHomePage(),
    );
  }
}
