import 'package:playify_app/redux/store.dart';

Map<String, double> getTopArtistByPlayTime(AppState appstate) {

  List<Map<String, dynamic>> myartists = [];
  for (var i = 0; i < appstate.artists.length; i++) {
    /// To sum all of songs of the artist play time
    myartists.add({
      "artist": appstate.artists[i].name,
      "totalSeconds": appstate.artists[i].albums
          .map((e) => e.songs)
          .map((e) => e
              .map((e) => e.playCount)
              .reduce((value, element) => value += element)
              .toDouble())
          .reduce((value, element) => value += element)
    });
  }

  /// Compare total played seconds for each artist, then sort by total seconds
  myartists.sort(
      (a, b) => b["totalSeconds"].compareTo(a["totalSeconds"].toDouble()));
  Map<String, double> myartistsObj =
      new Map(); //This is a artist map for adjusting number of artist will shown according to user preferences.
  double otherArtist =
      0; // when not shown in my artist map primarily, it is shown in otherArtist group
  double topArtist = 0;

  /// Start from first to end, add as a top artist or others.
  for (int i = 0; i < myartists.length; i++) {
    /// appstate.settings => from user statics number
    if (appstate.settings.statisticNumberArtist > i) {
      myartistsObj.putIfAbsent(
          myartists[i]["artist"], () => myartists[i]["totalSeconds"]);
      topArtist += myartists[i]["totalSeconds"];
    }

    /// the artists are in others.
    else
      otherArtist += myartists[i]["totalSeconds"];
  }

  /// put Other Map to myArtistObject
  if (myartists.length > appstate.settings.statisticNumberArtist) {
    myartistsObj.putIfAbsent("Other", () => otherArtist);
  }
  return myartistsObj;
}
