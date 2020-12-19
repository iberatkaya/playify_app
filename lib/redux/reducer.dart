import 'package:playify_app/redux/store.dart';

import 'actions/current_song/action.dart';
import 'actions/music/action.dart';
import 'actions/recent_played_songs/action.dart';
import 'actions/settings/action.dart';

AppState reducer(AppState state, dynamic action) {
  if (action.type == MusicAction.setMusicLibrary) {
    AppState newstate = AppState.copy(state);
    newstate.artists = action.payload[0];
    newstate.playlists = action.payload[1];
    return newstate;
  } else if (action.type == SettingsAction.setSettings) {
    AppState newstate = AppState.copy(state);
    newstate.settings = action.payload;
    return newstate;
  } else if (action.type == RecentPlayedSongsAction.setRecentPlayedSongs) {
    AppState newstate = AppState.copy(state);
    newstate.recentPlayedSongs = action.payload;
    return newstate;
  } else if (action.type == CurrentSongAction.setCurrentSong) {
    AppState newstate = AppState.copy(state);
    newstate.currentSong = action.payload;
    return newstate;
  }
  return state;
}
