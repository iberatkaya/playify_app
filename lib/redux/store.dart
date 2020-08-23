import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/reducer.dart';
import 'package:redux/redux.dart';

final store = Store<AppState>(reducer, initialState: AppState(artists: [], settings: Settings()));

class AppState {
  List<Artist> artists;
  Settings settings;
  AppState({
    @required this.artists,
    @required this.settings,
  });

  static copy(AppState appstate) {
    return AppState(artists: [...appstate.artists], settings: appstate.settings);
  }
}
