import 'package:playify_app/redux/music/action.dart';
import 'package:playify_app/redux/settings/action.dart';
import 'package:playify_app/redux/store.dart';

AppState reducer(AppState state, dynamic action) {
  if (action.type == MusicAction.setMusicLibrary) {
    AppState newstate = AppState.copy(state);
    newstate.artists = action.payload;
    return newstate;
  }
  if (action.type == SettingsAction.setSettings) {
    AppState newstate = AppState.copy(state);
    newstate.settings = action.payload;
    return newstate;
  }
  return state;
}
