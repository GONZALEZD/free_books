import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesNotifier = PreferencesNotifier();

class PreferencesNotifier extends ChangeNotifier {

  Future<void> reload() async {
    await (await SharedPreferences.getInstance()).reload();
    notifyListeners();
  }
}

class PreferencesListener extends InheritedNotifier {
  PreferencesListener({Widget child, VoidCallback onUpdate}):super(child: child, notifier: preferencesNotifier){
    _callback = onUpdate;
    preferencesNotifier.removeListener(PreferencesListener._update);
    preferencesNotifier.addListener(PreferencesListener._update);
  }
  static VoidCallback _callback;
  static void _update() {
    _callback?.call();
  }

  @override
  bool updateShouldNotify(InheritedNotifier oldWidget) {
    return true;
  }
}