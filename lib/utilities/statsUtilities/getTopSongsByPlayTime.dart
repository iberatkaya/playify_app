import 'package:playify_app/redux/store.dart';

///Get the top songs by play time (determined by play count).
///@param totalStatistics overrides the value from settings.
Map<String, dynamic> getTopSongsByPlayTime(AppState appstate,
    {bool showCounts = false, int totalStatistics = 0}) {
  List<Map<String, dynamic>> songs = [];

  /// To sum all of songs play time according to their titles
  for (var i = 0; i < appstate.artists.length; i++) {
    for (var j = 0; j < appstate.artists[i].albums.length; j++) {
      for (var k = 0; k < appstate.artists[i].albums[j].songs.length; k++) {
        double totalClicks = appstate.artists[i].albums[j].songs[k].playCount.toDouble();
        if (!showCounts)
          songs.add({
            "title": appstate.artists[i].albums[j].songs[k].title,
            "artist": appstate.artists[i].name,
            "album": appstate.artists[i].albums[j].title,
            "totalClicks": totalClicks
          });
        else
          songs.add({
            "title":
                appstate.artists[i].albums[j].songs[k].title + " (" + totalClicks.toInt().toString() + ")",
            "artist": appstate.artists[i].name,
            "album": appstate.artists[i].albums[j].title,
            "totalClicks": totalClicks
          });
      }
    }
  }

  /// Compare total played seconds for each songs, then sort by total seconds
  songs.sort((a, b) => b["totalClicks"].compareTo(a["totalClicks"]));

  Map<String, double> songObj =
      new Map(); //This is a album map for adjusting number of songs will shown according to user preferences.
  double otherSong = 0;
  double topSong = 0;

  /// Start from first to end, add as a top songs or others.
  for (int i = 0; i < songs.length; i++) {
    if (totalStatistics == 0 && appstate.settings.statisticNumberSong > i) {
      songObj.putIfAbsent(songs[i]["title"] + " - " + songs[i]["artist"], () => songs[i]["totalClicks"]);
      topSong += songs[i]["totalClicks"];
    } else if (totalStatistics != 0 && totalStatistics > i)
      songObj.putIfAbsent(songs[i]["title"] + " - " + songs[i]["artist"], () => songs[i]["totalClicks"]);
    else
      otherSong += songs[i]["totalClicks"];
  }

  /// add other map to Song object
  if (totalStatistics == 0 && songs.length > appstate.settings.statisticNumberSong) {
    songObj.putIfAbsent("Other", () => otherSong);
  } else if (totalStatistics != 0 && songs.length > totalStatistics) {
    songObj.putIfAbsent("Other", () => otherSong);
  }
  return songObj;
}
