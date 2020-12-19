import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

import '../../list.dart';
import '../item_tile.dart';

class ArtistsList extends StatefulWidget {
  final List<Artist> artists;

  const ArtistsList({@required this.artists});
  @override
  _ArtistsListState createState() => _ArtistsListState();
}

class _ArtistsListState extends State<ArtistsList> {
  List<Artist> sortedArtists;
  @override
  void initState() {
    super.initState();
    sortedArtists = [...widget.artists];
    setState(() {
      sortedArtists.sort(
          (a, b) => a.name[0].toUpperCase().compareTo(b.name[0].toUpperCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 6),
        itemCount: sortedArtists.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext listContext, int index) {
          return ItemTile(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
            title: sortedArtists[index].name,
            brightness: MediaQuery.of(context).platformBrightness,
            subtitle: sortedArtists[index].albums.length.toString() +
                ((sortedArtists[index].albums.length == 1)
                    ? " Album"
                    : " Albums"),
            icon: sortedArtists[index].albums[0].coverArt != null
                ? Image.memory(sortedArtists[index].albums[0].coverArt)
                : null,
            fn: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ListScreen(
                  listType: MusicListType.artist,
                  artist: sortedArtists[index],
                ),
              ),
            ),
          );
        });
  }
}
