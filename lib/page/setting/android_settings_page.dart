import 'package:flutter/material.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/service/book_provider.dart';
import 'package:free_books/page/setting/settings_list.dart';
import 'package:free_books/common/service/preferences_notifier.dart';

class AndroidSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.value("settings.title")),
        leading: BackButton(onPressed: () => provokeHomeUpdate(context)),
      ),
      body: AppSettingsList(display: SettingsDisplay.android),
    );
  }

  void provokeHomeUpdate(context) async {
    preferencesNotifier.reload();
    Navigator.of(context).pop();
  }
}
