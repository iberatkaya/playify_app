import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recentPlayedSong.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/list.dart';
import 'package:playify_app/utilities/utils.dart';

class RecentMusicContainer extends StatelessWidget {
  final RecentPlayedSong songInfo;

  const RecentMusicContainer({Key key, @required this.songInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = songInfo.coverArt;
    final albumTitle = songInfo.albumName;
    final artistName = songInfo.artistName;
    final songName = songInfo.songName;

    return StoreProvider(
      store: store,
      child: StoreConnector<AppState, List<Artist>>(
          converter: (appstate) => appstate.state.artists,
          builder: (storeContext, artists) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ListScreen(
                        listType: MusicListType.album,
                        album: artists
                            .where((element) => element.name == artistName)
                            .toList()[0]
                            .albums
                            .where((element) => element.title == albumTitle)
                            .toList()[0],
                      ))),
              child: Column(
                children: [
                  Expanded(
                    flex: 12,
                    child: image != null
                        ? Image.memory(
                            image,
                            fit: BoxFit.contain,
                          )
                        : Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  themeModeColor(MediaQuery.of(context).platformBrightness, Colors.black12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              albumTitle.substring(0, 2).toUpperCase(),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      songName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
