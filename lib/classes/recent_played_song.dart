import 'dart:typed_data';

class RecentPlayedSong {
  String songID;
  String artistName;
  String albumName;
  Uint8List? coverArt;
  String songName;

  RecentPlayedSong({
    required this.artistName,
    required this.albumName,
    required this.coverArt,
    required this.songID,
    required this.songName,
  });
}
