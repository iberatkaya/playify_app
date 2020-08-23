import 'package:playify_app/redux/store.dart';

Map<String, dynamic> getTopSongsByPlayTime(AppState appstate) {
  List<Map<String, dynamic>> songs = [];

  /// To sum all of songs play time according to their titles
  for (var i = 0; i < appstate.artists.length; i++) {
    for (var j = 0; j < appstate.artists[i].albums.length; j++) {
      for (var k = 0; k < appstate.artists[i].albums[j].songs.length; k++) {
        songs.add({
          "title": appstate.artists[i].albums[j].songs[k].title,
          "artist": appstate.artists[i].name,
          "album": appstate.artists[i].albums[j].title,
          "totalSeconds":
              appstate.artists[i].albums[j].songs[k].playCount.toDouble()
        });
      }
    }
  }

  /// Compare total played seconds for each songs, then sort by total seconds
  songs.sort((a, b) => b["totalSeconds"].compareTo(a["totalSeconds"]));

  Map<String, double> songObj =
      new Map(); //This is a album map for adjusting number of songs will shown according to user preferences.
  double otherSong = 0;
  double topSong = 0;

  /// Start from first to end, add as a top songs or others.
  for (int i = 0; i < songs.length; i++) {
    if (appstate.settings.statisticNumberSong > i) {
      songObj.putIfAbsent(songs[i]["title"] + " - " + songs[i]["artist"],
          () => songs[i]["totalSeconds"]);
      topSong += songs[i]["totalSeconds"];
    } else
      otherSong += songs[i]["totalSeconds"];
  }

  /// add other map to Song object
  if (songs.length > appstate.settings.statisticNumberSong) {
    songObj.putIfAbsent("Other", () => otherSong);
  }
  return songObj;
}
