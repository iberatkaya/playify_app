import 'package:playify/playify.dart';
import 'package:playify_app/redux/store.dart';

Album mostListenedAlbum(List<Artist> artists) {
  /// To sum all of songs of the album play count
  List<Album> albums = [];
  for (var i = 0; i < artists.length; i++) {
    for (var j = 0; j < artists[i].albums.length; j++) {
      albums.add(artists[i].albums[j]);
    }
  }

  /// Compare total played count for each album, then sort by total play count
  albums.sort((a, b) => b.songs
      .map((e) => e.playCount)
      .reduce((value, element) => value += element)
      .compareTo(a.songs.map((e) => e.playCount).reduce((value, element) => value += element)));
  if (albums.length == 0) {
    return null;
  }
  return albums[0];
}
