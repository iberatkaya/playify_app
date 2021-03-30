import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recent_played_song.dart';
import 'package:playify_app/screens/widgets/grid_item_tile.dart';
import 'package:playify_app/screens/widgets/transition_background.dart';
import 'package:playify_app/constant/animation_amount.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/list/list.dart';
import 'package:playify_app/screens/settings/settings.dart';
import 'package:playify_app/utilities/most_listened/most_listened_album.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation; // Fading Animation
  late AnimationController animationController; // Fading Animation Controller

  @override
  void initState() {
    initAnimation();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ///Create an animation for the background
  void initAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 2,
      ),
    )..repeat(reverse: true);

    animation = Tween(
      begin: beginAmount,
      end: endAmount,
    ).animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fontsize = MediaQuery.of(context).textScaleFactor;

    return StoreProvider(
      store: store,
      child: StoreConnector<AppState, List<Artist>>(
          converter: (appstate) => appstate.state.artists,
          builder: (storeContext, artists) {
            var favAlbum = mostListenedAlbum(artists);
            return Stack(
              children: <Widget>[
                TransitionBackground(
                  opacity: animation,
                  color1: Colors.indigo.shade400,
                  color2: Colors.deepPurple.shade400,
                ),

                ///All Profile UI
                SafeArea(
                  child: ListView(
                    children: <Widget>[
                      ///Profile Picture Card
                      GestureDetector(
                        onTap: () {
                          if (favAlbum == null) {
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                  listType: MusicListType.album,
                                  album: favAlbum),
                            ),
                          );
                        },
                        child: Container(
                          height: height * 0.35,
                          margin: EdgeInsets.only(top: 25),
                          child: Container(
                            child: favAlbum != null && favAlbum.coverArt != null
                                ? Image.memory(favAlbum.coverArt!)
                                : CircleAvatar(
                                    child: Text(favAlbum != null
                                        ? favAlbum.title
                                            .substring(0, 2)
                                            .toUpperCase()
                                        : "Favorite Album Cover"),
                                  ),
                          ),
                        ),
                      ),

                      /// Mood & Most Loved
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                favAlbum != null
                                    ? favAlbum.title
                                    : "", // Favorite Album Title
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontsize * 18,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5.0),
                              child: Opacity(
                                opacity: 0.54,
                                child: Text(
                                  favAlbum != null
                                      ? favAlbum.artistName
                                      : "", // Favorite Song Artist
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: fontsize * 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Recent Musics
                      // Recent Title
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                          top: 15,
                          left: 10,
                          bottom: 12,
                        ),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "Recently Played",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: fontsize * 18,
                            ),
                          ),
                        ),
                      ),
                      // Recent List
                      StoreConnector<AppState, List<RecentPlayedSong>>(
                          converter: (appstate) =>
                              appstate.state.recentPlayedSongs,
                          builder: (storeContext, recentPlayedSongs) {
                            return Container(
                              height: height * 0.25,
                              margin: EdgeInsets.only(top: 0),
                              child: GridView.builder(
                                itemCount: recentPlayedSongs.length,
                                itemBuilder: (context, index) {
                                  var songInfo = recentPlayedSongs[index];
                                  var album = artists
                                      .where((element) =>
                                          element.name == songInfo.artistName)
                                      .toList()[0]
                                      .albums
                                      .where((element) =>
                                          element.title == songInfo.albumName)
                                      .toList()[0];

                                  return GridItemTile(
                                    title: album.title,
                                    subtitle: songInfo.songName,
                                    icon: album.coverArt != null
                                        ? Image.memory(album.coverArt!)
                                        : null,
                                    fn: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ListScreen(
                                          listType: MusicListType.album,
                                          album: album,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.only(left: 10),
                                scrollDirection: Axis.horizontal,
                                physics: ClampingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 15,
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),

                Positioned(
                  right: 0,
                  top: 25,
                  child: IconButton(
                      iconSize: 28,
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SettingsScreen()));
                      }),
                ),
              ],
            );
          }),
    );
  }
}
