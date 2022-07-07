import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/utilities/extensions.dart';
import 'package:playify_app/utilities/utils.dart';

import '../../widgets/item_tile.dart';

class SongsList extends StatefulWidget {
  final List<Song> songs;
  const SongsList({
    required this.songs,
  });
  @override
  _SongsListState createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    songs = widget.songs.map((i) => i.copy()).toList();
    setState(() {
      songs.sort((a, b) =>
          a.title[0].toUpperCase().compareTo(b.title[0].toUpperCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: StoreConnector<AppState, List<Artist>>(
          converter: (appstate) => appstate.state.artists,
          builder: (context, artists) {
            return ListView.separated(
                itemCount: songs.length,
                padding: EdgeInsets.symmetric(vertical: 6),
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (BuildContext listContext, int index) {
                  final iconArt = getCoverArtFromSong(artists, songs[index]);

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
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } catch (e) {
                          print(e);
                        }
                      });
                });
          }),
    );
  }
}
