import 'dart:typed_data';

import 'package:playify/playify.dart';

extension SongX on Song {
  Map<String, dynamic> toJson() => {
        "albumTitle": albumTitle,
        "artistName": artistName,
        "discNumber": discNumber,
        "duration": duration,
        "iOSSongID": iOSSongID,
        "isExplicit": isExplicit,
        "playCount": playCount,
        "title": title,
        "trackNumber": trackNumber,
        "genre": genre,
        "releaseDate": releaseDate.toIso8601String()
      };

  static Song mapToSong(Map<String, dynamic> song) => Song(
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

  Song copy() => Song(
        albumTitle: albumTitle,
        artistName: artistName,
        discNumber: discNumber,
        duration: duration,
        genre: genre,
        iOSSongID: iOSSongID,
        isExplicit: isExplicit,
        playCount: playCount,
        releaseDate: releaseDate,
        title: title,
        trackNumber: trackNumber,
      );
}

extension AlbumX on Album {
  Map<String, dynamic> toJson() => {
        "albumTrackCount": albumTrackCount,
        "artistName": artistName,
        "discCount": discCount,
        "songs": songs.map((element) => element.toJson()).toList(),
        "title": title,
        "coverArt": coverArt,
      };

  static Album mapToAlbum(Map<String, dynamic> album) => Album(
        albumTrackCount: album["albumTrackCount"],
        artistName: album["artistName"],
        discCount: album["discCount"],
        songs: List<Song>.from(
            album["songs"].map((i) => SongX.mapToSong(i)).toList()),
        title: album["title"],
        coverArt: album["coverArt"] != null
            ? Uint8List.fromList(List<int>.from(album["coverArt"]))
            : null,
      );

  Album copy() => Album(
        albumTrackCount: albumTrackCount,
        artistName: artistName,
        coverArt: coverArt != null ? Uint8List.fromList([...coverArt!]) : null,
        discCount: discCount,
        songs: songs.map((i) => i.copy()).toList(),
        title: title,
      );
}

extension ArtistX on Artist {
  Map<String, dynamic> toJson() => {
        "name": name,
        "albums": albums.map((e) => e.toJson()).toList(),
      };

  static Artist mapToArist(Map<String, dynamic> artist) => Artist(
        name: artist["name"],
        albums: List<Album>.from(
            artist["albums"].map((e) => AlbumX.mapToAlbum(e)).toList()),
      );

  Artist copy() =>
      Artist(albums: albums.map((i) => i.copy()).toList(), name: name);
}

extension PlaylistX on Playlist {
  Map<String, dynamic> toJson() => {
        "title": title,
        "playlistID": playlistID,
        "songs": songs.map((i) => i.toJson()).toList(),
      };

  static Playlist mapToPlaylist(Map<String, dynamic> map) => Playlist(
      songs: List<Song>.from(map["songs"].map((i) => SongX.mapToSong(i))),
      playlistID: map["playlistID"],
      title: map["title"]);
}

extension ShuffleX on Shuffle {
  String getValue() {
    if (this == Shuffle.songs) {
      return "Songs";
    } else if (this == Shuffle.off) {
      return "Off";
    }
    return "";
  }
}

extension RepeatX on Repeat {
  String getValue() {
    if (this == Repeat.all) {
      return "All";
    } else if (this == Repeat.one) {
      return "Song";
    } else if (this == Repeat.none) {
      return "Off";
    }
    return "";
  }
}
