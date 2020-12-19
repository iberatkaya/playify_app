import 'package:playify/playify.dart';
import 'package:playify_app/classes/action.dart';

enum CurrentSongAction { setCurrentSong }

Action setCurrentSongAction(Song song) {
  return Action(type: CurrentSongAction.setCurrentSong, payload: song);
}
