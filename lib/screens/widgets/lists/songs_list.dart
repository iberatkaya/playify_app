import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/utilities/utils.dart';

import '../item_tile.dart';

class SongsList extends StatefulWidget {
  final List<Artist> artists;
  const SongsList({
    @required this.artists,
  });
  @override
  _SongsListState createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.artists.length; i++) {
      for (var j = 0; j < widget.artists[i].albums.length; j++) {
        for (var k = 0; k < widget.artists[i].albums[j].songs.length; k++) {
          songs.add(copySong(widget.artists[i].albums[j].songs[k]));
        }
      }
    }
    setState(() {
      songs.sort((a, b) =>
          a.title[0].toUpperCase().compareTo(b.title[0].toUpperCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: songs.length,
        padding: EdgeInsets.symmetric(vertical: 6),
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext listContext, int index) {
          var iconArt = widget.artists
              .firstWhere((element) => element.name == songs[index].artistName)
              .albums
              .firstWhere((element) => element.title == songs[index].albumTitle)
              .coverArt;
          return ItemTile(
              title: songs[index].title,
              icon: iconArt != null ? Image.memory(iconArt) : null,
              brightness: MediaQuery.of(context).platformBrightness,
              subtitle: songs[index].artistName,
              iosSongID: songs[index].iOSSongID,
              fn: () async {
                try {
                  var playify = Playify();
                  await playify.playItem(songID: songs[index].iOSSongID);
                  updateRecentSongs(songs[index]);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } catch (e) {
                  print(e);
                }
              });
        });
  }
}
