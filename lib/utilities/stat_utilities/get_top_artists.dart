import 'package:playify_app/redux/store.dart';

///Get the top artists by play time (determined by play count).
///[totalStatistics] overrides the value from settings.
Map<String, double> getTopArtistByPlayTime(AppState appstate,
    {bool showCounts = false, int totalStatistics = 0}) {
  List<Map<String, dynamic>> myartists = [];
  for (var i = 0; i < appstate.artists.length; i++) {
    /// To sum all of songs of the artist play time
    double totalClicks = appstate.artists[i].albums
        .map((e) => e.songs)
        .map((e) => e
            .map((e) => e.playCount)
            .reduce((value, element) => value += element)
            .toDouble())
        .reduce((value, element) => value += element);
    if (!showCounts)
      myartists.add(
          {"artist": appstate.artists[i].name, "totalClicks": totalClicks});
    else
      myartists.add({
        "artist": appstate.artists[i].name +
            " (" +
            totalClicks.toInt().toString() +
            ")",
        "totalClicks": totalClicks
      });
  }

  /// Compare total played seconds for each artist, then sort by total seconds
  myartists
      .sort((a, b) => b["totalClicks"].compareTo(a["totalClicks"].toDouble()));
  Map<String, double> myartistsObj =
      new Map(); //This is a artist map for adjusting number of artist will shown according to user preferences.
  double otherArtist =
      0; // when not shown in my artist map primarily, it is shown in otherArtist group
  double topArtist = 0;

  /// Start from first to end, add as a top artist or others.
  for (int i = 0; i < myartists.length; i++) {
    /// appstate.settings => from user statics number
    if (totalStatistics == 0 && appstate.settings.statisticNumberArtist > i) {
      myartistsObj.putIfAbsent(
          myartists[i]["artist"], () => myartists[i]["totalClicks"]);
      topArtist += myartists[i]["totalClicks"];
    } else if (totalStatistics != 0 && totalStatistics > i) {
      myartistsObj.putIfAbsent(
          myartists[i]["artist"], () => myartists[i]["totalClicks"]);
      topArtist += myartists[i]["totalClicks"];
    }

    /// the artists are in others.
    else
      otherArtist += myartists[i]["totalClicks"];
  }

  /// put Other Map to myArtistObject
  if (totalStatistics == 0 &&
      myartists.length > appstate.settings.statisticNumberArtist) {
    myartistsObj.putIfAbsent("Other", () => otherArtist);
  } else if (totalStatistics != 0 && myartists.length > totalStatistics) {
    myartistsObj.putIfAbsent("Other", () => otherArtist);
  }
  return myartistsObj;
}
