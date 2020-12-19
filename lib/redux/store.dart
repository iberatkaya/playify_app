import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recent_played_song.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/reducer.dart';
import 'package:redux/redux.dart';

final store = Store<AppState>(reducer,
    initialState: AppState(
        artists: [],
        playlists: [],
        settings: Settings(),
        recentPlayedSongs: [],
        currentSong: null));

class AppState {
  List<Artist> artists;
  List<Playlist> playlists;
  Settings settings;
  Song currentSong;
  List<RecentPlayedSong> recentPlayedSongs;
  AppState(
      {@required this.artists,
      @required this.playlists,
      @required this.settings,
      @required this.recentPlayedSongs,
      @required this.currentSong});

  static copy(AppState appstate) {
    return AppState(
        artists: [...appstate.artists],
        playlists: [...appstate.playlists],
        currentSong: appstate.currentSong,
        settings: appstate.settings,
        recentPlayedSongs: [...appstate.recentPlayedSongs]);
  }
}
