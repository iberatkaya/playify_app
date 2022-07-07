import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/utilities/extensions.dart';
import 'package:playify_app/utilities/utils.dart';

import '../../widgets/item_tile.dart';

class AllSongsList extends StatefulWidget {
  final List<Artist> artists;
  const AllSongsList({
    required this.artists,
  });
  @override
  _AllSongsListState createState() => _AllSongsListState();
}

class _AllSongsListState extends State<AllSongsList> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.artists.length; i++) {
      for (var j = 0; j < widget.artists[i].albums.length; j++) {
        for (var k = 0; k < widget.artists[i].albums[j].songs.length; k++) {
          songs.add(widget.artists[i].albums[j].songs[k].copy());
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
          final iconArt = getCoverArtFromSong(widget.artists, songs[index]);

          return ItemTile(
              title: songs[index].title,
              icon: iconArt != null ? Image.memory(iconArt) : null,
              subtitle: songs[index].artistName,
              songID: songs[index].songID,
              fn: () async {
                try {
                  var playify = Playify();
                  await playify.setQueue(
                    songIDs: songs.map((e) => e.songID).toList(),
                    startPlaying: true,
                    startID: songs[index].songID,
                  );
                  updateRecentSongs(songs[index]);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } catch (e) {
                  print(e);
                }
              });
        });
  }
}
