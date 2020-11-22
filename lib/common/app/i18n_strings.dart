import 'dart:ui';

import 'package:flutter/material.dart' show BuildContext, Localizations, LocalizationsDelegate;
import 'package:flutter_tools/common/app_strings.dart';

class I18n extends AppStrings {

  static String _suffix;
  
  I18n(Locale locale) : super(locale);
  
  static void init(List<Locale> supportedLocales, {String suffix}) {
    AppStrings.init(supportedLocales, delegate: I18nDelegate());
    _suffix = suffix;
  }

  @override
  String value(String key) {
    final completeKey = "$key${_suffix ??""}";
    if (this.exists(completeKey)) {
      return super.value(completeKey);
    }
    return super.value(key);
  }

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }
}

class I18nDelegate extends LocalizationsDelegate<I18n> {

  const I18nDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppStrings.supportedLocales.map((locale) => locale.languageCode).contains(locale.languageCode);

  @override
  Future<I18n> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppStrings localizations = new I18n(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(I18nDelegate old) => false;

}