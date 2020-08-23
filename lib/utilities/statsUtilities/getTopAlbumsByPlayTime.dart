import 'package:playify_app/redux/store.dart';

Map<String, double> getTopAlbumsByPlayTime(AppState appstate) {
  /// To sum all of songs of the album play time
  List<Map<String, dynamic>> albums = [];
  for (var i = 0; i < appstate.artists.length; i++) {
    for (var j = 0; j < appstate.artists[i].albums.length; j++) {
      albums.add({
        "title": appstate.artists[i].albums[j].title,
        "artist": appstate.artists[i].name,
        "totalSeconds": appstate.artists[i].albums[j].songs
            .map((e) => e.playCount)
            .reduce((value, element) => value += element)
            .toDouble()
      });
    }
  }

  /// Compare total played seconds for each album, then sort by total seconds
  albums.sort(
      (a, b) => b["totalSeconds"].compareTo(a["totalSeconds"].toDouble()));

  Map<String, double> albumObj =
      new Map(); //This is a album map for adjusting number of album will shown according to user preferences.
  double otherAlbum =
      0; // when not shown in my album map primarily, it is shown in otherAlbum group
  double topAlbum = 0;

  /// Start from first to end, add as a top album or others.
  for (int i = 0; i < albums.length; i++) {
    /// appstate.settings => from user statics number
    if (appstate.settings.statisticNumberAlbum > i) {
      albumObj.putIfAbsent(albums[i]["title"] + " - " + albums[i]["artist"],
          () => albums[i]["totalSeconds"]);
      topAlbum += albums[i]["totalSeconds"];
    }

    /// the albums are in others.
    else
      otherAlbum += albums[i]["totalSeconds"];
  }

  /// put Other Map to myAlbumObject
  if (albums.length > appstate.settings.statisticNumberAlbum) {
    albumObj.putIfAbsent("Other", () => otherAlbum);
  }
  return albumObj;
}
