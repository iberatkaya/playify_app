import 'package:playify/playify.dart';
import 'package:playify_app/classes/action.dart';

enum MusicAction { setMusicLibrary }

Action setMusicLibraryAction(List<Artist> artists, List<Playlist> playlist) {
  return Action(
      type: MusicAction.setMusicLibrary, payload: [artists, playlist]);
}
