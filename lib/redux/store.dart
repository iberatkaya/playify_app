import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/redux/reducer.dart';
import 'package:redux/redux.dart';

final store = Store<AppState>(reducer, initialState: AppState(artists: []));

class AppState {
  List<Artist> artists;
  AppState({@required this.artists});
  static copy(AppState appstate) {
    return AppState(artists: [...appstate.artists]);
  }
}
