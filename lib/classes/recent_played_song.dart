import 'package:flutter/material.dart';

class RecentPlayedSong {
  String iosSongId;
  String artistName;
  String albumName;
  List<int> coverArt;
  String songName;

  RecentPlayedSong({
    @required this.artistName,
    @required this.albumName,
    @required this.coverArt,
    @required this.iosSongId,
    @required this.songName,
  });
}
