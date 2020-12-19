import 'package:playify_app/classes/action.dart';
import 'package:playify_app/classes/recent_played_song.dart';

enum RecentPlayedSongsAction { setRecentPlayedSongs }

Action setRecentPlayedSongsAction(List<RecentPlayedSong> recentPlayedSong) {
  return Action(
      type: RecentPlayedSongsAction.setRecentPlayedSongs,
      payload: recentPlayedSong);
}
