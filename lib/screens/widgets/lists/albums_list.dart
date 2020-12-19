import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/utilities/utils.dart';

import '../../list.dart';
import '../grid_item_tile.dart';

class AlbumsList extends StatefulWidget {
  final List<Artist> artists;

  const AlbumsList({@required this.artists});
  @override
  _AlbumsListState createState() => _AlbumsListState();
}

class _AlbumsListState extends State<AlbumsList> {
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.artists.length; i++) {
      for (var j = 0; j < widget.artists[i].albums.length; j++) {
        var albumExists = false;
        for (var k = 0; k < albums.length; k++) {
          if (widget.artists[i].albums[j].title == albums[k].title &&
              albums[k].albumTrackCount ==
                  widget.artists[i].albums[j].albumTrackCount) {
            widget.artists[i].albums[j].songs.forEach((element) {
              albums[k].songs.add(copySong(element));
            });
            albumExists = true;
          }
        }
        if (!albumExists) albums.add(copyAlbum(widget.artists[i].albums[j]));
      }
    }
    setState(() {
      albums.sort((a, b) =>
          a.title[0].toUpperCase().compareTo(b.title[0].toUpperCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: albums.length,
        padding: EdgeInsets.symmetric(vertical: 6),
        itemBuilder: (BuildContext listContext, int index) {
          return GridItemTile(
            title: albums[index].title,
            subtitle:
                albums[index].songs[0].releaseDate.millisecondsSinceEpoch == 0
                    ? null
                    : albums[index].songs[0].releaseDate.year.toString(),
            padding: EdgeInsets.only(bottom: 12),
            icon: albums[index].coverArt != null
                ? Image.memory(albums[index].coverArt)
                : null,
            brightness: MediaQuery.of(context).platformBrightness,
            fn: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ListScreen(
                  listType: MusicListType.album,
                  album: albums[index],
                ),
              ),
            ),
          );
        });
  }
}
