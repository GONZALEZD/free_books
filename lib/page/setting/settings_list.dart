import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/common/app/setting_keys.dart';
import 'package:free_books/common/service/preferences_notifier.dart';
import 'package:free_books/widget/tutorial_builder.dart';

enum SettingsDisplay {
  cupertino,
  android,
}

class AppSettingsList extends StatelessWidget {
  final SettingsWidgetFactory _factory;

  AppSettingsList({SettingsDisplay display}) : _factory = _factoryOf(display);

  static SettingsWidgetFactory _factoryOf(SettingsDisplay display) {
    switch (display) {
      case SettingsDisplay.cupertino:
        return _MyCupertinoSettingsFactory();
      case SettingsDisplay.android:
        return _MyAndroidSettingsFactory();
    }

    throw "Unable to retrieve a settings factory for display $display";
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return Material(
      type: MaterialType.transparency,
      child: SettingsList(
        settingsFactory: _factory,
        pageTitle: i18n.value("settings.title"),
        settings: [
          TitleSetting(title: i18n.value("settings.search")),
          ToggleSwitchSetting(
            title: i18n.value("settings.search.save.queries"),
            defaultValue: true,
            identifier: kSaveQueries,
          ),
          // ToggleSwitchSetting(
          //   title: i18n.value("settings.search.save.details"),
          //   defaultValue: true,
          //   identifier: kSaveQueryResults,
          //   description: i18n.value("settings.search.save.details.description"),
          // ),
          // ParagraphSetting(
          //   availability: SettingAvailability.ios,
          //   text: i18n.value("settings.search.save.details.description"),
          // ),
          TitleSetting(
              title: i18n.value("settings.reader.background_color"),
              availability: SettingAvailability.ios),
          ChoicesSetting(
            title: i18n.value("settings.reader.background_color"),
            labeledValues: {
              i18n.value("settings.reader.background_color.white"): Colors.grey.shade50.value,
              i18n.value("settings.reader.background_color.beige"): Colors.amber.shade50.value,
              i18n.value("settings.reader.background_color.black"): Colors.grey.shade800.value,
              i18n.value("settings.reader.background_color.auto"): -1,
            },
            defaultValue: -1,
            createRoute: false,
            identifier: kReaderBackgroundColor,
            description: i18n.value("settings.reader.background_color.description"),
          ),
          ParagraphSetting(
            availability: SettingAvailability.ios,
            text: i18n.value("settings.reader.background_color.description"),
          ),
          TitleSetting(
              title: i18n.value("settings.tutorial"),
              availability: SettingAvailability.ios),
          ButtonSetting(
            title: i18n.value("settings.tutorial.reset"),
            onTap: () {
              TutorialManager.instance.reset(Tutorial.all);
              },
          ),
        ],
      ),
    );
  }
}

class ButtonSetting extends SettingData {
  final VoidCallback onTap;

  ButtonSetting({String title, this.onTap, SettingAvailability availability, IconData buttonIcon,})
      : super(title: title, isInteractive: true, availability: availability, icon: buttonIcon,);
}

class _MyCupertinoSettingsFactory extends CupertinoSettingsFactory with ButtonSettingFactoryMixin{
  @override
  Color getBackgroundColor({BuildContext context}) {
    return Colors.white10;
  }

  @override
  Icon buildCheckmark({BuildContext context}) {
    return Icon(CupertinoIcons.check_mark, color: Colors.white);
  }

  @override
  Widget buildDividerBetween(BuildContext context, SettingData after, SettingData before) {
    return SizedBox(height: 4.0);
  }
}

class _MyAndroidSettingsFactory extends AndroidSettingsFactory with ButtonSettingFactoryMixin {

}

mixin ButtonSettingFactoryMixin on SettingsWidgetFactory {
  @override
  Widget buildUnknownSetting(SettingsFactoryContext factoryContext, SettingData setting) {
    if (setting is ButtonSetting) {
      return Container(
        height: 40.0,
        alignment: Alignment.center,
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(width: 1.0, color: Colors.white38, style: BorderStyle.solid),
          ),
          color: Theme.of(factoryContext.context).colorScheme.primary,
          textColor: Colors.white,
          child: Text(setting.title),
          onPressed: setting.onTap,
        ),
      );
    }
    return Container();
  }
}