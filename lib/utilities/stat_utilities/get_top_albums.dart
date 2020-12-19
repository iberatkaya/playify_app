import 'package:playify_app/redux/store.dart';

///Get the top albums by play time (determined by play count).
///[totalStatistics] overrides the value from settings.
Map<String, double> getTopAlbumsByPlayTime(AppState appstate,
    {bool showCounts = false, int totalStatistics = 0}) {
  ///To sum all of songs of the album play time
  List<Map<String, dynamic>> albums = [];
  for (var i = 0; i < appstate.artists.length; i++) {
    for (var j = 0; j < appstate.artists[i].albums.length; j++) {
      double totalClicks = appstate.artists[i].albums[j].songs
          .map((e) => e.playCount)
          .reduce((value, element) => value += element)
          .toDouble();
      if (!showCounts)
        albums.add({
          "title": appstate.artists[i].albums[j].title,
          "artist": appstate.artists[i].name,
          "totalClicks": totalClicks
        });
      else
        albums.add({
          "title": appstate.artists[i].albums[j].title +
              " (" +
              totalClicks.toInt().toString() +
              ")",
          "artist": appstate.artists[i].name,
          "totalClicks": totalClicks
        });
    }
  }

  ///Compare total played seconds for each album, then sort by total seconds
  albums
      .sort((a, b) => b["totalClicks"].compareTo(a["totalClicks"].toDouble()));

  Map<String, double> albumObj = new Map();

  ///This is a album map for adjusting number of album will shown according to user preferences.
  double otherAlbum = 0;

  ///When not shown in my album map primarily, it is shown in otherAlbum group
  double topAlbum = 0;

  ///Start from first to end, add as a top album or others.
  for (int i = 0; i < albums.length; i++) {
    ///appstate.settings => from user statics number
    if (totalStatistics == 0 && appstate.settings.statisticNumberAlbum > i) {
      albumObj.putIfAbsent(albums[i]["title"] + " - " + albums[i]["artist"],
          () => albums[i]["totalClicks"]);
      topAlbum += albums[i]["totalClicks"];
    } else if (totalStatistics != 0 && totalStatistics > i) {
      albumObj.putIfAbsent(albums[i]["title"] + " - " + albums[i]["artist"],
          () => albums[i]["totalClicks"]);
      topAlbum += albums[i]["totalClicks"];
    }

    ///The albums are in others.
    else
      otherAlbum += albums[i]["totalClicks"];
  }

  ///Put Other Map to myAlbumObject
  if (totalStatistics == 0 &&
      albums.length > appstate.settings.statisticNumberAlbum) {
    albumObj.putIfAbsent("Other", () => otherAlbum);
  } else if (totalStatistics != 0 && albums.length > totalStatistics) {
    albumObj.putIfAbsent("Other", () => otherAlbum);
  }
  return albumObj;
}
