import 'dart:convert';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recent_played_song.dart';
import 'package:playify_app/redux/actions/music/action.dart';
import 'package:playify_app/redux/actions/recent_played_songs/action.dart';
import 'package:playify_app/utilities/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../store.dart';

Future<void> updateRecentSongs(Song selectedSong) async {
  var prefs = await SharedPreferences.getInstance();
  List<String> recentlist = prefs.getStringList("recentPlayed") != null
      ? prefs.getStringList("recentPlayed")
      : [];
  if (recentlist.contains(selectedSong.iOSSongID)) {
    recentlist.remove(selectedSong.iOSSongID);
    recentlist.insert(0, selectedSong.iOSSongID);
  } else {
    recentlist.insert(0, selectedSong.iOSSongID);
    if (recentlist.length > 6) {
      recentlist.removeAt(recentlist.length - 1);
    }
  }
  List<RecentPlayedSong> recentSongs = [];
  recentlist.forEach(
    (i) => store.state.artists.forEach(
      (j) => j.albums.forEach(
        (k) => k.songs.forEach((l) => (l.iOSSongID == i)
            ? recentSongs.add(RecentPlayedSong(
                albumName: k.title,
                iosSongId: i,
                coverArt: k.coverArt,
                artistName: j.name,
                songName: l.title,
              ))
            : null),
      ),
    ),
  );
  store.dispatch(setRecentPlayedSongsAction(recentSongs));
  await prefs.setStringList(
      "recentPlayed", recentSongs.map((e) => e.iosSongId).toList());
}

Future<void> updateMusicLibrary(int desiredWidth) async {
  var playify = Playify();
  var allSongs = await playify.getAllSongs(coverArtSize: desiredWidth);
  var allPlaylists = await playify.getPlaylists();

  List<Map<String, dynamic>> artistsMap =
      allSongs.map((e) => e.toJson()).toList();
  List<Map<String, dynamic>> playlistsMap =
      allPlaylists.map((e) => e.toJson()).toList();

  var prefs = await SharedPreferences.getInstance();
  await prefs.setString("artists", json.encode(artistsMap));
  await prefs.setString("playlists", json.encode(playlistsMap));
  store.dispatch(setMusicLibraryAction(allSongs, allPlaylists));
}
