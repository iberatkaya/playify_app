import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recentPlayedSong.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/reducer.dart';
import 'package:redux/redux.dart';

final store = Store<AppState>(reducer,
    initialState: AppState(artists: [], settings: Settings(), recentPlayedSongs: []));

class AppState {
  List<Artist> artists;
  Settings settings;
  List<RecentPlayedSong> recentPlayedSongs;
  AppState({@required this.artists, @required this.settings, @required this.recentPlayedSongs});

  static copy(AppState appstate) {
    return AppState(
        artists: [...appstate.artists],
        settings: appstate.settings,
        recentPlayedSongs: [...appstate.recentPlayedSongs]);
  }
}
