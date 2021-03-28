import 'dart:typed_data';

import 'package:flutter/material.dart';

class RecentPlayedSong {
  String iosSongId;
  String artistName;
  String albumName;
  Uint8List? coverArt;
  String songName;

  RecentPlayedSong({
    required this.artistName,
    required this.albumName,
    required this.coverArt,
    required this.iosSongId,
    required this.songName,
  });
}
