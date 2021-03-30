import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/screens/list/list.dart';
import 'package:playify_app/screens/widgets/item_tile.dart';

class PlaylistsList extends StatelessWidget {
  final List<Playlist> playlists;
  const PlaylistsList({
    required this.playlists,
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
        return ItemTile(
          title: playlists[index].title,
          hasLeadingIcon: false,
          fn: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ListScreen(
                      listType: MusicListType.playlist,
                      playlist: playlists[index],
                    )));
          },
        );
      },
    );
  }
}
