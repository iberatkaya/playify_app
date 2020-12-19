import 'package:playify_app/classes/action.dart';
import 'package:playify_app/classes/settings.dart';

enum SettingsAction { setSettings }

Action setSettingsAction(Settings settings) {
  return Action(type: SettingsAction.setSettings, payload: settings);
}
