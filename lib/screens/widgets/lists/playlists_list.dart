import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

class PlaylistsList extends StatelessWidget {
  final List<Playlist> playlists;
  const PlaylistsList({
    this.playlists,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: playlists.length,
      padding: EdgeInsets.symmetric(vertical: 6),
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (BuildContext listContext, int index) {
        return ListTile(title: Text(playlists[index].title));
      },
    );
  }
}
