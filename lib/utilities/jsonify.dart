import 'dart:typed_data';

import 'package:playify/playify.dart';

Map<String, dynamic> songToMap(Song song) => {
      "albumTitle": song.albumTitle,
      "artistName": song.artistName,
      "discNumber": song.discNumber,
      "duration": song.duration,
      "iOSSongID": song.iOSSongID,
      "isExplicit": song.isExplicit,
      "playCount": song.playCount,
      "title": song.title,
      "trackNumber": song.trackNumber,
      "genre": song.genre,
      "releaseDate": song.releaseDate.toIso8601String()
    };

Map<String, dynamic> albumToMap(Album album) => {
      "albumTrackCount": album.albumTrackCount,
      "artistName": album.artistName,
      "discCount": album.discCount,
      "songs": album.songs.map((element) => songToMap(element)).toList(),
      "title": album.title,
      "coverArt": album.coverArt,
    };

Map<String, dynamic> artistToMap(Artist artist) => {
      "name": artist.name,
      "albums": artist.albums.map((e) => albumToMap(e)).toList(),
    };

Map<String, dynamic> playlistToMap(Playlist playlist) => {
      "title": playlist.title,
      "songIDs": playlist.songIDs.toList(),
    };

Playlist mapToPlaylist(Map<String, dynamic> map) =>
    Playlist(songIDs: List<String>.from(map["songIDs"]), title: map["title"]);

Song mapToSong(Map<String, dynamic> song) => Song(
      albumTitle: song["albumTitle"],
      artistName: song["artistName"],
      discNumber: song["discNumber"],
      duration: song["duration"],
      iOSSongID: song["iOSSongID"],
      isExplicit: song["isExplicit"],
      playCount: song["playCount"],
      title: song["title"],
      trackNumber: song["trackNumber"],
      genre: song["genre"],
      releaseDate: DateTime.parse(song["releaseDate"]),
    );

Album mapToAlbum(Map<String, dynamic> album) => Album(
      albumTrackCount: album["albumTrackCount"],
      artistName: album["artistName"],
      discCount: album["discCount"],
      songs: List<Song>.from(album["songs"].map((i) => mapToSong(i)).toList()),
      title: album["title"],
      coverArt: album["coverArt"] != null
          ? Uint8List.fromList(List<int>.from(album["coverArt"]))
          : null,
    );

Artist mapToArist(Map<String, dynamic> artist) => Artist(
      name: artist["name"],
      albums:
          List<Album>.from(artist["albums"].map((e) => mapToAlbum(e)).toList()),
    );
